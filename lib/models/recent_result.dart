class RecentResult {
  final int? id;
  final String type; // 'analysis' or 'compare'
  final String category;
  final String overallReview;
  final String resultData; // JSON string of the full result data
  final DateTime createdAt;

  const RecentResult({
    this.id,
    required this.type,
    required this.category,
    required this.overallReview,
    required this.resultData,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'overall_review': overallReview,
      'result_data': resultData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RecentResult.fromMap(Map<String, dynamic> map) {
    return RecentResult(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      overallReview: map['overall_review'],
      resultData: map['result_data'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}