import 'analysis_result.dart';

class ComparisonResult {
  final List<Ingredient> productAIngredients;
  final List<Ingredient> productBIngredients;
  final List<String>? overallComparativeReview;

  ComparisonResult({
    required this.productAIngredients,
    required this.productBIngredients,
    this.overallComparativeReview,
  });

  factory ComparisonResult.fromJson(Map<String, dynamic> json) {
    return ComparisonResult(
      productAIngredients: (json['product_a_ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item))
          .toList() ?? [],
      productBIngredients: (json['product_b_ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item))
          .toList() ?? [],
      overallComparativeReview: (json['overall_comparative_review'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_a_ingredients': productAIngredients.map((item) => item.toJson()).toList(),
      'product_b_ingredients': productBIngredients.map((item) => item.toJson()).toList(),
      'overall_comparative_review': overallComparativeReview,
    };
  }
}