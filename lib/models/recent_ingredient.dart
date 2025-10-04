class RecentIngredient {
  final int? id;
  final String ingredientName;
  final String category;
  final String description;
  final String resultData; // JSON string of the full ingredient detail
  final DateTime createdAt;

  const RecentIngredient({
    this.id,
    required this.ingredientName,
    required this.category,
    required this.description,
    required this.resultData,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ingredient_name': ingredientName,
      'category': category,
      'description': description,
      'result_data': resultData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RecentIngredient.fromMap(Map<String, dynamic> map) {
    return RecentIngredient(
      id: map['id'],
      ingredientName: map['ingredient_name'],
      category: map['category'],
      description: map['description'],
      resultData: map['result_data'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}