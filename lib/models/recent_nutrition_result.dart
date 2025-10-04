class RecentNutritionResult {
  final String overallReview;
  final String category;
  final String responseData;
  final DateTime createdAt;

  RecentNutritionResult({
    required this.overallReview,
    required this.category,
    required this.responseData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'overallReview': overallReview,
      'category': category,
      'responseData': responseData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecentNutritionResult.fromJson(Map<String, dynamic> json) {
    return RecentNutritionResult(
      overallReview: json['overallReview'],
      category: json['category'],
      responseData: json['responseData'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}