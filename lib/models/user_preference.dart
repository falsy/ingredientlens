class UserPreference {
  final int? id;
  final String category; // religion, skin, allergy, diet, health
  final String value;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreference({
    this.id,
    required this.category,
    required this.value,
    this.isCustom = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'value': value,
      'is_custom': isCustom ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserPreference.fromMap(Map<String, dynamic> map) {
    return UserPreference(
      id: map['id']?.toInt(),
      category: map['category'] ?? '',
      value: map['value'] ?? '',
      isCustom: (map['is_custom'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  UserPreference copyWith({
    int? id,
    String? category,
    String? value,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreference(
      id: id ?? this.id,
      category: category ?? this.category,
      value: value ?? this.value,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 프리셋 옵션들
class PreferencePresets {
  static const Map<String, List<String>> presets = {
    'religion': [
      'Christianity',
      'Islam',
      'Hinduism',
      'Buddhism',
    ],
    'skin': [
      'Normal',
      'Dry',
      'Oily',
      'Combination',
      'Sensitive',
      'Acne-prone',
      'Atopic',
    ],
    'allergy': [
      'Nuts',
      'Dairy',
      'Eggs',
      'Shellfish',
      'Fish',
      'Soy',
      'Gluten',
      'Sesame',
    ],
    'diet': [
      'Vegan',
      'Vegetarian',
      'Gluten-free',
      'Dairy-free',
      'Sugar-free',
      'Low-carb',
      'Halal',
    ],
    'health': [
      'Pregnancy',
      'Breastfeeding',
      'Diabetes',
      'Hypertension',
      'Heart disease',
      'Kidney disease',
    ],
    'pet_weight': [
      'pet_weight_under_1kg',
      'pet_weight_1_3kg',
      'pet_weight_3_5kg',
      'pet_weight_5_10kg',
      'pet_weight_10_20kg',
      'pet_weight_over_20kg',
    ],
  };

  static List<String> getPresets(String category) {
    return presets[category] ?? [];
  }
}
