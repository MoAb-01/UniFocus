class ScannedDocument {
  final String id;
  final String courseId;
  final String courseCode;
  final String title;
  final String category; // 'Lecture Notes', 'Homework', 'Exam Review', 'Handwritten', 'Book Chapter'
  final int pageCount;
  final String ocrText;
  final DateTime createdAt;
  final String previewColorHex;

  const ScannedDocument({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.title,
    required this.category,
    this.pageCount = 1,
    this.ocrText = '',
    required this.createdAt,
    this.previewColorHex = '#2563EB',
  });

  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    final lower = query.toLowerCase();
    return title.toLowerCase().contains(lower) ||
        courseCode.toLowerCase().contains(lower) ||
        category.toLowerCase().contains(lower) ||
        ocrText.toLowerCase().contains(lower);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'courseCode': courseCode,
    'title': title,
    'category': category,
    'pageCount': pageCount,
    'ocrText': ocrText,
    'createdAt': createdAt.toIso8601String(),
    'previewColorHex': previewColorHex,
  };

  factory ScannedDocument.fromJson(Map<String, dynamic> json) => ScannedDocument(
    id: json['id'] as String,
    courseId: json['courseId'] as String,
    courseCode: json['courseCode'] as String? ?? '',
    title: json['title'] as String,
    category: json['category'] as String? ?? 'Lecture Notes',
    pageCount: json['pageCount'] as int? ?? 1,
    ocrText: json['ocrText'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    previewColorHex: json['previewColorHex'] as String? ?? '#2563EB',
  );
}
