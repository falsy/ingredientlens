class SavedIngredient {
  final int? id;
  final String name;
  final String ingredientName;
  final String category;
  final String responseData; // API 응답 JSON을 문자열로 저장
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedIngredient({
    this.id,
    required this.name,
    required this.ingredientName,
    required this.category,
    required this.responseData,
    required this.createdAt,
    required this.updatedAt,
  });

  // DB에서 읽어올 때 사용
  factory SavedIngredient.fromMap(Map<String, dynamic> map) {
    return SavedIngredient(
      id: map['id'],
      name: map['name'],
      ingredientName: map['ingredientName'],
      category: map['category'],
      responseData: map['responseData'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // DB에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredientName': ingredientName,
      'category': category,
      'responseData': responseData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 이름 변경을 위한 copyWith 메서드
  SavedIngredient copyWith({
    int? id,
    String? name,
    String? ingredientName,
    String? category,
    String? responseData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      ingredientName: ingredientName ?? this.ingredientName,
      category: category ?? this.category,
      responseData: responseData ?? this.responseData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}