class ScanRecord {
  final String id;
  final String userId;
  final String? imageUrl;
  final String extractedText;
  final String detectedLanguage;
  final String? summary;
  final int taskCount;
  final DateTime createdAt;

  const ScanRecord({
    required this.id,
    required this.userId,
    this.imageUrl,
    required this.extractedText,
    required this.detectedLanguage,
    this.summary,
    this.taskCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'extracted_text': extractedText,
      'detected_language': detectedLanguage,
      'summary': summary,
      'task_count': taskCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      imageUrl: map['image_url']?.toString(),
      extractedText: map['extracted_text']?.toString() ?? '',
      detectedLanguage: map['detected_language']?.toString() ?? 'English',
      summary: map['summary']?.toString(),
      taskCount: (map['task_count'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
