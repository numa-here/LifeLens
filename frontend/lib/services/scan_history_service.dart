import 'package:flutter/foundation.dart';
import '../models/scan_record.dart';
import 'supabase_service.dart';

class ScanHistoryService {
  final SupabaseService _supabaseService = SupabaseService();

  // In-memory mock scans for frontend demo & local testing
  final List<ScanRecord> _mockScans = [
    ScanRecord(
      id: 'scan-1',
      userId: 'demo-user-123',
      imageUrl: null,
      detectedLanguage: 'English',
      summary: 'Municipal notice regarding property verification and water charges.',
      extractedText: 'MUNICIPAL WATER & PROPERTY NOTICE\nAccount ID: 8842-TX-2026\nNotice Date: 12th Oct 2026\nSubmit physical declaration form with latest electricity bill photocopy by 24th October 2026.\nClear pending assessment charges before month end.',
      taskCount: 3,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    ScanRecord(
      id: 'scan-2',
      userId: 'demo-user-123',
      imageUrl: null,
      detectedLanguage: 'Hindi',
      summary: 'विश्वविद्यालय परीक्षा सूचना और असाइनमेंट जमा करने की अंतिम तिथि।',
      extractedText: 'विश्वविद्यालय परीक्षा विभाग\nसभी छात्रों को सूचित किया जाता है कि सत्र 2026 के अंतिम असाइनमेंट 20 अक्टूबर तक जमा करें।\nविलंब शुल्क ₹500 प्रति दिन लागू होगा।',
      taskCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ScanRecord(
      id: 'scan-3',
      userId: 'demo-user-123',
      imageUrl: null,
      detectedLanguage: 'Telugu',
      summary: 'విద్యుత్ బిల్లు సవరణ మరియు మీటర్ రీడింగ్ ధృవీకరణ నోటీసు.',
      extractedText: 'తెలంగాణ విద్యుత్ పంపిణీ సంస్థ\nసర్వీస్ నంబర్: 10482910\nదయచేసి మీటర్ రీడింగ్ స్లిప్‌ను సబ్-స్టేషన్‌లో సమర్పించండి.',
      taskCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  /// Fetch previous scans from Supabase or mock store
  Future<List<ScanRecord>> fetchScans({required String userId}) async {
    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return List.from(_mockScans);
    }

    // ==========================================
    // OMEMA INTEGRATION POINT: Supabase 'scan_history' table
    // ==========================================
    try {
      final response = await _supabaseService.client!
          .from('scan_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => ScanRecord.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ScanHistoryService] Supabase fetch failed: $e. Using mock fallback.');
      return List.from(_mockScans);
    }
  }

  /// Save a scan record
  Future<ScanRecord> saveScan(ScanRecord record) async {
    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      _mockScans.insert(0, record);
      return record;
    }

    // ==========================================
    // OMEMA INTEGRATION POINT: Supabase insert into 'scan_history'
    // ==========================================
    try {
      await _supabaseService.client!.from('scan_history').insert(record.toMap());
      return record;
    } catch (e) {
      debugPrint('[ScanHistoryService] Save failed: $e');
      _mockScans.insert(0, record);
      return record;
    }
  }

  /// Delete a scan record
  Future<bool> deleteScan(String scanId) async {
    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      _mockScans.removeWhere((s) => s.id == scanId);
      return true;
    }

    // ==========================================
    // OMEMA INTEGRATION POINT: Supabase delete from 'scan_history'
    // ==========================================
    try {
      await _supabaseService.client!.from('scan_history').delete().eq('id', scanId);
      return true;
    } catch (e) {
      debugPrint('[ScanHistoryService] Delete failed: $e');
      _mockScans.removeWhere((s) => s.id == scanId);
      return true;
    }
  }
}
