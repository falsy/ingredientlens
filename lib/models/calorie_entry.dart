class CalorieEntry {
  final int? id;
  final String analysisId; // 분석 세션 ID
  final List<CalorieFoodItem> foods; // 음식 배열
  final String mealType; // main_meal, snack, late_night
  final DateTime date;
  final DateTime createdAt;

  CalorieEntry({
    this.id,
    required this.analysisId,
    required this.foods,
    required this.mealType,
    required this.date,
    required this.createdAt,
  });
  
  // 총 칼로리 계산
  double get totalCalories {
    return foods.fold(0.0, (sum, food) => sum + (food.calories * food.quantity));
  }
  
  // 메인 음식 이름 (가장 높은 칼로리)
  String get mainFoodName {
    if (foods.isEmpty) return '';
    final mainFood = foods.reduce((a, b) => 
        (a.calories * a.quantity) > (b.calories * b.quantity) ? a : b);
    return mainFood.name;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'analysis_id': analysisId,
      'foods': foods.map((food) => food.toMap()).toList(),
      'meal_type': mealType,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CalorieEntry.fromMap(Map<String, dynamic> map) {
    return CalorieEntry(
      id: map['id'],
      analysisId: map['analysis_id'],
      foods: (map['foods'] as List<dynamic>)
          .map((food) => CalorieFoodItem.fromMap(food))
          .toList(),
      mealType: map['meal_type'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // JSON 직렬화를 위한 메서드들
  Map<String, dynamic> toJson() {
    return toMap();
  }

  factory CalorieEntry.fromJson(Map<String, dynamic> json) {
    return CalorieEntry.fromMap(json);
  }

  CalorieEntry copyWith({
    int? id,
    String? analysisId,
    List<CalorieFoodItem>? foods,
    String? mealType,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return CalorieEntry(
      id: id ?? this.id,
      analysisId: analysisId ?? this.analysisId,
      foods: foods ?? this.foods,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// 개별 음식 아이템 클래스
class CalorieFoodItem {
  final String name;
  final String estimatedAmount;
  final double calories;
  final double quantity;
  final NutritionItem nutrition;

  CalorieFoodItem({
    required this.name,
    required this.estimatedAmount,
    required this.calories,
    required this.quantity,
    required this.nutrition,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'estimated_amount': estimatedAmount,
      'calories': calories,
      'quantity': quantity,
      'nutrition': nutrition.toMap(),
    };
  }

  factory CalorieFoodItem.fromMap(Map<String, dynamic> map) {
    return CalorieFoodItem(
      name: map['name'],
      estimatedAmount: map['estimated_amount'],
      calories: map['calories'].toDouble(),
      quantity: map['quantity'].toDouble(),
      nutrition: map['nutrition'] != null 
          ? NutritionItem.fromMap(map['nutrition'])
          : NutritionItem.empty(), // 기존 데이터 호환성을 위한 기본값
    );
  }

  CalorieFoodItem copyWith({
    String? name,
    String? estimatedAmount,
    double? calories,
    double? quantity,
    NutritionItem? nutrition,
  }) {
    return CalorieFoodItem(
      name: name ?? this.name,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      calories: calories ?? this.calories,
      quantity: quantity ?? this.quantity,
      nutrition: nutrition ?? this.nutrition,
    );
  }
}

// 개별 음식 아이템의 영양정보 클래스
class NutritionItem {
  final double protein;
  final double fat;
  final double carbohydrate;
  final double sodium;
  final double sugar;
  final double transFat;
  final double saturatedFat;
  final double cholesterol;

  NutritionItem({
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.sodium,
    required this.sugar,
    required this.transFat,
    required this.saturatedFat,
    required this.cholesterol,
  });

  // 빈 영양정보 (기존 데이터 호환성용)
  factory NutritionItem.empty() {
    return NutritionItem(
      protein: 0.0,
      fat: 0.0,
      carbohydrate: 0.0,
      sodium: 0.0,
      sugar: 0.0,
      transFat: 0.0,
      saturatedFat: 0.0,
      cholesterol: 0.0,
    );
  }

  Map<String, dynamic> toMap() {
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

  factory NutritionItem.fromMap(Map<String, dynamic> map) {
    return NutritionItem(
      protein: (map['protein'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      carbohydrate: (map['carbohydrate'] ?? 0.0).toDouble(),
      sodium: (map['sodium'] ?? 0.0).toDouble(),
      sugar: (map['sugar'] ?? 0.0).toDouble(),
      transFat: (map['trans_fat'] ?? 0.0).toDouble(),
      saturatedFat: (map['saturated_fat'] ?? 0.0).toDouble(),
      cholesterol: (map['cholesterol'] ?? 0.0).toDouble(),
    );
  }
}
