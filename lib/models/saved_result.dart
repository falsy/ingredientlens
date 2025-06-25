class SavedResult {
  final int? id;
  final String name;
  final String resultType; // 'analysis' 또는 'comparison'
  final String responseData; // API 응답 JSON을 문자열로 저장
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedResult({
    this.id,
    required this.name,
    required this.resultType,
    required this.responseData,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  // DB에서 읽어올 때 사용
  factory SavedResult.fromMap(Map<String, dynamic> map) {
    return SavedResult(
      id: map['id'],
      name: map['name'],
      resultType: map['resultType'],
      responseData: map['responseData'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // DB에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'resultType': resultType,
      'responseData': responseData,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 이름 변경을 위한 copyWith 메서드
  SavedResult copyWith({
    int? id,
    String? name,
    String? resultType,
    String? responseData,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedResult(
      id: id ?? this.id,
      name: name ?? this.name,
      resultType: resultType ?? this.resultType,
      responseData: responseData ?? this.responseData,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}