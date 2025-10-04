class AnalysisResult {
  final List<Ingredient> positiveIngredients;
  final List<Ingredient> negativeIngredients;
  final List<Ingredient> otherIngredients;
  final List<String>? overallReview;
  final Map<String, double>? categoryScores;
  final double? productScore;
  final double? personalizedScore;

  AnalysisResult({
    required this.positiveIngredients,
    required this.negativeIngredients,
    required this.otherIngredients,
    this.overallReview,
    this.categoryScores,
    this.productScore,
    this.personalizedScore,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      positiveIngredients: (json['positive_ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item))
          .toList() ?? [],
      negativeIngredients: (json['negative_ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item))
          .toList() ?? [],
      otherIngredients: (json['other_ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item))
          .toList() ?? [],
      overallReview: (json['overall_review'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
      categoryScores: (json['category_scores'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, (value as num).toDouble())),
      productScore: (json['product_score'] as num?)?.toDouble(),
      personalizedScore: (json['personalized_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positive_ingredients': positiveIngredients.map((item) => item.toJson()).toList(),
      'negative_ingredients': negativeIngredients.map((item) => item.toJson()).toList(),
      'other_ingredients': otherIngredients.map((item) => item.toJson()).toList(),
      'overall_review': overallReview,
      'category_scores': categoryScores,
      'product_score': productScore,
      'personalized_score': personalizedScore,
    };
  }
}

class Ingredient {
  final String name;
  final String description;
  final double? score;
  final double? personalizedScore;

  Ingredient({
    required this.name,
    required this.description,
    this.score,
    this.personalizedScore,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble(),
      personalizedScore: (json['personalized_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'score': score,
      'personalized_score': personalizedScore,
    };
  }
}