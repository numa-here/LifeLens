import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/document_analysis.dart';
import 'supabase_service.dart';

class DocumentService {
  final SupabaseService _supabaseService = SupabaseService();

  /// Analyzes a document (pasted text or image/PDF bytes)
  /// Returns a structured [DocumentAnalysisResult]
  Future<DocumentAnalysisResult> analyzeDocument({
    String? text,
    Uint8List? fileBytes,
    String? fileName,
    String? mimeType,
    String? userId,
  }) async {
    final hasText = text != null && text.trim().isNotEmpty;
    final hasFile = fileBytes != null && fileBytes.isNotEmpty;

    if (!hasText && !hasFile) {
      throw ArgumentError('Either document text or file bytes must be provided.');
    }

    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      // Simulate realistic AI network latency
      await Future.delayed(const Duration(milliseconds: 1800));
      return _generateMockAnalysis(text, fileName);
    }

    try {
      String? uploadedImageUrl;

      // 1. If file bytes provided, upload to private Supabase storage bucket 'scans'
      if (hasFile && userId != null) {
        final ext = fileName != null && fileName.contains('.')
            ? fileName.split('.').last
            : 'jpg';
        final storagePath = '$userId/${const Uuid().v4()}.$ext';

        try {
          await _supabaseService.client!.storage
              .from('scans')
              .uploadBinary(storagePath, fileBytes);
          uploadedImageUrl = _supabaseService.client!.storage
              .from('scans')
              .getPublicUrl(storagePath);
        } catch (storageError) {
          debugPrint('[DocumentService] Storage upload failed: $storageError');
        }
      }

      // 2. Invoke Omema's 'analyze-document' Edge Function
      final payload = <String, dynamic>{
        if (hasText) 'text': text,
        if (uploadedImageUrl != null) 'image_url': uploadedImageUrl,
        if (hasFile && uploadedImageUrl == null)
          'image_base64': base64Encode(fileBytes),
        'file_name': fileName,
        'mime_type': mimeType ?? 'image/jpeg',
      };

      final response = await _supabaseService.client!.functions.invoke(
        'analyze-document',
        body: payload,
      );

      if (response.status != 200) {
        throw Exception(
          'analyze-document returned status ${response.status}: ${response.data}',
        );
      }

      final Map<String, dynamic> data =
          response.data is String ? jsonDecode(response.data) : response.data;

      return DocumentAnalysisResult.fromMap(data);
    } catch (e) {
      debugPrint('[DocumentService] Edge function call failed ($e). Using mock fallback.');
      return _generateMockAnalysis(text, fileName);
    }
  }

  /// Generates realistic analysis for hackathon demo & offline testing
  DocumentAnalysisResult _generateMockAnalysis(String? text, String? fileName) {
    final now = DateTime.now();

    // Check if user pasted Hindi or Telugu sample text
    final bool isHindi = text != null && RegExp(r'[\u0900-\u097F]').hasMatch(text);
    final bool isTelugu = text != null && RegExp(r'[\u0C00-\u0C7F]').hasMatch(text);

    String detectedLang = 'English';
    if (isHindi) detectedLang = 'Hindi';
    if (isTelugu) detectedLang = 'Telugu';

    final bool isHandwritten = (fileName != null && fileName.toLowerCase().contains('note')) ||
        (text != null && text.contains('Dr.') || text != null && text.contains('meeting'));

    final rawOcr = text?.isNotEmpty == true
        ? text!
        : '''MUNICIPAL WATER & PROPERTY NOTICE
Account ID: 8842-TX-2026
Notice Date: 12th Oct 2026
Subject: Urgent Verification of Property Tax and Water Meter Readings.

Action Required:
1. Submit physical declaration form with latest electricity bill photocopy by 24th October 2026.
2. Clear pending assessment charges of \$142.50 before month end (31st Oct 2026).
3. Contact Zonal Officer if discrepancy found in previous receipt #4029.

Note [Handwritten margin]: "Meeting scheduled with inspector on Friday 10 AM? Confirm date."''';

    return DocumentAnalysisResult(
      summary:
          'Municipal property & utility compliance notice requiring submission of verification documents and clearing pending assessment charges before deadlines.',
      detectedLanguage: detectedLang,
      rawExtractedText: rawOcr,
      isHandwritten: isHandwritten,
      warnings: [
        'Uncertain date found in handwritten margin: "Friday 10 AM?". Verification recommended.',
        'Electricity bill photocopy is mandated as supporting proof.'
      ],
      uncertainFields: ['Inspector appointment exact date'],
      requiredDocuments: [
        'Latest Electricity Bill photocopy',
        'Physical Declaration Form',
        'Previous Receipt #4029'
      ],
      tasks: [
        SuggestedTask(
          title: 'Submit physical property declaration form',
          description: 'Submit completed form along with electricity bill photocopy to Municipal Ward 4 office.',
          deadline: now.add(const Duration(days: 11)),
          rawDeadline: '24th October 2026',
          isDateUncertain: false,
          priority: 'urgent',
          sourceEvidence: 'Submit physical declaration form with latest electricity bill photocopy by 24th October 2026.',
          requiredDocuments: ['Electricity bill photocopy', 'Declaration Form'],
        ),
        SuggestedTask(
          title: 'Pay pending assessment fee of \$142.50',
          description: 'Pay utility and property balance online or at municipal counter.',
          deadline: now.add(const Duration(days: 18)),
          rawDeadline: '31st October 2026',
          isDateUncertain: false,
          priority: 'high',
          sourceEvidence: 'Clear pending assessment charges of \$142.50 before month end (31st Oct 2026).',
          requiredDocuments: ['Account ID: 8842-TX-2026'],
        ),
        SuggestedTask(
          title: 'Verify Friday meeting with Zonal Inspector',
          description: 'Handwritten note mentions inspector appointment on Friday morning. Call office to confirm exact date.',
          deadline: now.add(const Duration(days: 4)),
          rawDeadline: 'Friday 10 AM (?)',
          isDateUncertain: true,
          priority: 'medium',
          sourceEvidence: 'Note [Handwritten margin]: "Meeting scheduled with inspector on Friday 10 AM? Confirm date."',
          requiredDocuments: [],
        ),
      ],
    );
  }
}
