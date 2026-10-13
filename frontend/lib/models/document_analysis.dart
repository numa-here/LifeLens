import 'package:uuid/uuid.dart';

class SuggestedTask {
  final String id;
  String title;
  String? description;
  DateTime? deadline;
  final String? rawDeadline;
  final bool isDateUncertain;
  String priority; // 'urgent', 'high', 'medium', 'low'
  final String? sourceEvidence;
  final List<String> requiredDocuments;

  SuggestedTask({
    String? id,
    required this.title,
    this.description,
    this.deadline,
    this.rawDeadline,
    this.isDateUncertain = false,
    this.priority = 'medium',
    this.sourceEvidence,
    this.requiredDocuments = const [],
  }) : id = id ?? const Uuid().v4();

  factory SuggestedTask.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    final deadlineVal = map['deadline'];
    if (deadlineVal != null) {
      parsedDate = DateTime.tryParse(deadlineVal.toString());
    }

    return SuggestedTask(
      id: map['id']?.toString() ?? const Uuid().v4(),
      title: map['title']?.toString() ?? 'Untitled Action Item',
      description: map['description']?.toString(),
      deadline: parsedDate,
      rawDeadline: map['raw_deadline']?.toString() ?? map['deadline']?.toString(),
      isDateUncertain: map['is_date_uncertain'] == true ||
          map['uncertain_date'] == true ||
          map['deadline'] == null,
      priority: (map['priority']?.toString().toLowerCase()) ?? 'medium',
      sourceEvidence: map['source_evidence']?.toString() ?? map['evidence']?.toString(),
      requiredDocuments: (map['required_documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'raw_deadline': rawDeadline,
      'is_date_uncertain': isDateUncertain,
      'priority': priority,
      'source_evidence': sourceEvidence,
      'required_documents': requiredDocuments,
    };
  }
}

class DocumentAnalysisResult {
  final String summary;
  final String detectedLanguage;
  final String rawExtractedText;
  final bool isHandwritten;
  final List<SuggestedTask> tasks;
  final List<String> warnings;
  final List<String> uncertainFields;
  final List<String> requiredDocuments;

  const DocumentAnalysisResult({
    required this.summary,
    required this.detectedLanguage,
    required this.rawExtractedText,
    this.isHandwritten = false,
    required this.tasks,
    this.warnings = const [],
    this.uncertainFields = const [],
    this.requiredDocuments = const [],
  });

  factory DocumentAnalysisResult.fromMap(Map<String, dynamic> map) {
    return DocumentAnalysisResult(
      summary: map['summary']?.toString() ?? 'Document analysis summary',
      detectedLanguage: map['detected_language']?.toString() ?? 'English',
      rawExtractedText: map['raw_extracted_text']?.toString() ??
          map['extracted_text']?.toString() ??
          '',
      isHandwritten: map['is_handwritten'] == true,
      tasks: (map['tasks'] as List<dynamic>?)
              ?.map((t) => SuggestedTask.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      warnings: (map['warnings'] as List<dynamic>?)
              ?.map((w) => w.toString())
              .toList() ??
          [],
      uncertainFields: (map['uncertain_fields'] as List<dynamic>?)
              ?.map((u) => u.toString())
              .toList() ??
          [],
      requiredDocuments: (map['required_documents'] as List<dynamic>?)
              ?.map((d) => d.toString())
              .toList() ??
          [],
    );
  }
}
