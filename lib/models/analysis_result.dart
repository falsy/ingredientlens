class AnalysisResult {
  final List<Ingredient> positiveIngredients;
  final List<Ingredient> negativeIngredients;
  final List<Ingredient> otherIngredients;
  final List<String>? overallReview;

  AnalysisResult({
    required this.positiveIngredients,
    required this.negativeIngredients,
    required this.otherIngredients,
    this.overallReview,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positive_ingredients': positiveIngredients.map((item) => item.toJson()).toList(),
      'negative_ingredients': negativeIngredients.map((item) => item.toJson()).toList(),
      'other_ingredients': otherIngredients.map((item) => item.toJson()).toList(),
      'overall_review': overallReview,
    };
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
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}