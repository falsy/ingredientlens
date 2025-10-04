class CalorieAnalysisResult {
  final List<CalorieFood> foods;

  CalorieAnalysisResult({
    required this.foods,
  });

  factory CalorieAnalysisResult.fromJson(List<dynamic> json) {
    return CalorieAnalysisResult(
      foods: json.map((item) => CalorieFood.fromJson(item)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return foods.map((food) => food.toJson()).toList();
  }

  // 전체 칼로리 합계 계산
  double get totalCalories {
    return foods.fold(0.0, (sum, food) => sum + food.calories);
  }
}

class CalorieFood {
  final String name;
  final String estimatedAmount;
  final double calories;
  final Nutrition nutrition;

  CalorieFood({
    required this.name,
    required this.estimatedAmount,
    required this.calories,
    required this.nutrition,
  });

  factory CalorieFood.fromJson(Map<String, dynamic> json) {
    return CalorieFood(
      name: json['name'] as String,
      estimatedAmount: json['estimated_amount'] as String,
      calories: (json['calories'] as num).toDouble(),
      nutrition: Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'estimated_amount': estimatedAmount,
      'calories': calories,
      'nutrition': nutrition.toJson(),
    };
  }
}

class Nutrition {
  final double protein;
  final double fat;
  final double carbohydrate;
  final double sodium;
  final double sugar;
  final double transFat;
  final double saturatedFat;
  final double cholesterol;

  Nutrition({
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.sodium,
    required this.sugar,
    required this.transFat,
    required this.saturatedFat,
    required this.cholesterol,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrate: (json['carbohydrate'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      transFat: (json['trans_fat'] as num).toDouble(),
      saturatedFat: (json['saturated_fat'] as num).toDouble(),
      cholesterol: (json['cholesterol'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'fat': fat,
      'carbohydrate': carbohydrate,
      'sodium': sodium,
      'sugar': sugar,
      'trans_fat': transFat,
      'saturated_fat': saturatedFat,
      'cholesterol': cholesterol,
    };
  }
}