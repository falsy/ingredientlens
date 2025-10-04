/// 레거시 영어 텍스트를 카테고리별 다국어 키로 변환하는 유틸리티
class LegacyDataMigrationUtil {
  // 카테고리별 매핑
  static const Map<String, Map<String, String>> _categoryMapping = {
    'religion': {
      'Christianity': 'christianity',
      'Islam': 'islam',
      'Hinduism': 'hinduism',
      'Buddhism': 'buddhism',
    },
    'skin': {
      'Sensitive': 'sensitive',
      'Dry': 'dry',
      'Oily': 'oily',
      'Combination': 'combination',
      'Normal': 'normal',
      'Acne-prone': 'acne_prone',
      'Atopic': 'atopic',
    },
    'allergy': {
      'Nuts': 'nuts',
      'Dairy': 'dairy',
      'Eggs': 'eggs',
      'Soy': 'soy',
      'Gluten': 'gluten',
      'Shellfish': 'shellfish',
      'Fish': 'fish',
      'Sesame': 'sesame',
    },
    'diet': {
      'Vegetarian': 'vegetarian',
      'Vegan': 'vegan',
      'Low-carb': 'low_carb',
      'Gluten-free': 'gluten_free',
      'Dairy-free': 'dairy_free',
      'Sugar-free': 'sugar_free',
      'Halal': 'halal',
    },
    'health': {
      'Diabetes': 'diabetes',
      'Hypertension': 'hypertension',
      'Heart disease': 'heart_disease',
      'Kidney disease': 'kidney_disease',
      'Pregnancy': 'pregnancy',
      'Breastfeeding': 'breastfeeding',
    },
    'pet_type': {
      'Dog': 'dog',
      'Cat': 'cat',
      'Bird': 'bird',
      'Rabbit': 'rabbit',
      'Hamster': 'hamster',
    },
    'pet_age': {
      '0-1 years': 'pet_age_0_1_year',
      '1-3 years': 'pet_age_1_3_years',
      '3-5 years': 'pet_age_3_5_years',
      '5-7 years': 'pet_age_5_7_years',
      '7-10 years': 'pet_age_7_10_years',
      '10+ years': 'pet_age_10_plus_years',
    },
    'pet_weight': {
      'Under 1kg': 'pet_weight_under_1kg',
      '1-3kg': 'pet_weight_1_3kg',
      '3-5kg': 'pet_weight_3_5kg',
      '5-10kg': 'pet_weight_5_10kg',
      '10-20kg': 'pet_weight_10_20kg',
      'Over 20kg': 'pet_weight_over_20kg',
    },
    'pet_allergy': {
      'Nuts': 'nuts',
      'Dairy': 'dairy',
      'Eggs': 'eggs',
      'Soy': 'soy',
      'Gluten': 'gluten',
      'Shellfish': 'shellfish',
      'Fish': 'fish',
      'Sesame': 'sesame',
      'Grains': 'pet_allergy_grains',
      'Chicken': 'pet_allergy_chicken',
      'Beef': 'pet_allergy_beef',
    },
    'pet_health': {
      'Healthy': 'pet_health_healthy',
      'Arthritis': 'pet_health_arthritis',
      'Heart disease': 'pet_health_heart_disease',
      'Kidney disease': 'pet_health_kidney_disease',
      'Liver disease': 'pet_health_liver_disease',
      'Diabetes': 'pet_health_diabetes',
      'Skin disease': 'pet_health_skin_disease',
      'Digestive disease': 'pet_health_digestive_disease',
    },
    'pet_neutered': {
      'Yes': 'neutered_yes',
      'No': 'neutered_no',
    },
    'baby_age': {
      '0-6 months': 'baby_age_0_6_months',
      '6-12 months': 'baby_age_6_12_months',
      '1-2 years': 'baby_age_1_2_years',
      '2-3 years': 'baby_age_2_3_years',
      '3-5 years': 'baby_age_3_5_years',
      '5+ years': 'baby_age_5_plus_years',
    },
    'baby_skin': {
      'Sensitive': 'sensitive',
      'Dry': 'dry',
      'Oily': 'oily',
      'Combination': 'combination',
      'Normal': 'normal',
      'Acne-prone': 'acne_prone',
      'Atopic': 'atopic',
    },
    'baby_allergy': {
      'Nuts': 'nuts',
      'Dairy': 'dairy',
      'Eggs': 'eggs',
      'Soy': 'soy',
      'Gluten': 'gluten',
      'Shellfish': 'shellfish',
      'Fish': 'fish',
      'Sesame': 'sesame',
    },
    'baby_health': {
      'Healthy': 'baby_health_healthy',
      'Asthma': 'baby_health_asthma',
      'Digestive sensitivity': 'baby_health_digestive_sensitivity',
      'Constipation': 'baby_health_constipation',
      'Diarrhea': 'baby_health_diarrhea',
    },
  };

  /// 값이 레거시 영어 텍스트인지 확인
  static bool isLegacyValue(String value) {
    // 이미 다국어 키 형태인지 확인 (소문자로 시작하고 언더스코어나 소문자, 숫자만 포함)
    if (RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
      return false; // 이미 키 형태
    }
    
    // 영어 텍스트 형태인지 확인 (대문자 포함, 공백 포함 등)
    return RegExp(r'[A-Z\s\-+]').hasMatch(value);
  }

  /// 카테고리별로 레거시 값을 다국어 키로 변환
  static String convertLegacyToKey(String category, String legacyValue) {
    // 이미 키 형태라면 그대로 반환
    if (!isLegacyValue(legacyValue)) {
      return legacyValue;
    }

    // 카테고리별 매핑에서 찾기
    final categoryMap = _categoryMapping[category];
    if (categoryMap != null && categoryMap.containsKey(legacyValue)) {
      return categoryMap[legacyValue]!;
    }

    // 매핑되지 않은 경우 기본 변환 (소문자, 공백을 언더스코어로)
    return legacyValue.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_').replaceAll('+', '_plus');
  }

  /// 여러 값들을 한번에 변환
  static List<String> convertLegacyValues(String category, List<String> legacyValues) {
    return legacyValues.map((value) => convertLegacyToKey(category, value)).toList();
  }
}