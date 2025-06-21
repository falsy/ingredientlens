class AnalysisResult {
  final List<Ingredient> positiveIngredients;
  final List<Ingredient> negativeIngredients;
  final List<Ingredient> otherIngredients;
  final String overallReview;

  AnalysisResult({
    required this.positiveIngredients,
    required this.negativeIngredients,
    required this.otherIngredients,
    required this.overallReview,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      positiveIngredients: (json['positive_ingredients'] as List)
          .map((item) => Ingredient.fromJson(item))
          .toList(),
      negativeIngredients: (json['negative_ingredients'] as List)
          .map((item) => Ingredient.fromJson(item))
          .toList(),
      otherIngredients: (json['other_ingredients'] as List)
          .map((item) => Ingredient.fromJson(item))
          .toList(),
      overallReview: json['overall_review'] as String,
    );
  }
}

class Ingredient {
  final String name;
  final String description;

  Ingredient({
    required this.name,
    required this.description,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}