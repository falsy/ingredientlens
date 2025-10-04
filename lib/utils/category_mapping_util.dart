import '../models/category.dart';

class CategoryMappingUtil {
  static const Map<String, String> _subcategoryToMainCategory = {
    // Food subcategories
    'food_health_food': 'food',
    'food_diet_food': 'food',
    'food_dairy': 'food',
    'food_processed': 'food',
    'food_instant': 'food',
    'food_beverages': 'food',
    'food_snacks': 'food',
    'food_bakery': 'food',
    'food_seasoning': 'food',
    
    // Cosmetics subcategories
    'cosmetics_skincare': 'cosmetics',
    'cosmetics_cleansing': 'cosmetics',
    'cosmetics_suncare': 'cosmetics',
    'cosmetics_mask': 'cosmetics',
    'cosmetics_makeup': 'cosmetics',
    'cosmetics_bodycare': 'cosmetics',
    'cosmetics_haircare': 'cosmetics',
    'cosmetics_handcare': 'cosmetics',
    'cosmetics_footcare': 'cosmetics',
    'cosmetics_mens': 'cosmetics',
    
    // Medicine subcategories
    'medicine_skin_treatment': 'medicine',
    'medicine_allergy': 'medicine',
    'medicine_womens': 'medicine',
    'medicine_general': 'medicine',
    'medicine_supplements': 'medicine',
    
    // Baby products subcategories
    'baby_skincare': 'baby_products',
    'baby_cleansers': 'baby_products',
    'baby_medicine': 'baby_products',
    'baby_food': 'baby_products',
    'baby_formula': 'baby_products',
    'baby_sanitizers': 'baby_products',
    'baby_detergent': 'baby_products',
    'baby_toys': 'baby_products',
    
    // Pet products subcategories
    'pet_supplements': 'pet_products',
    'pet_medicine': 'pet_products',
    'pet_shampoo': 'pet_products',
    'pet_special_food': 'pet_products',
    'pet_food': 'pet_products',
    'pet_treats': 'pet_products',
    'pet_waste': 'pet_products',
    'pet_toys': 'pet_products',
    
    // Household products subcategories
    'household_products_dishwashing': 'household_products',
    'household_products_air_freshener': 'household_products',
    'household_products_cleaner': 'household_products',
    'household_products_deodorizer': 'household_products',
  };

  /// 주어진 카테고리(메인 또는 서브)에 해당하는 아이콘 경로를 반환
  static String getCategoryIconPath(String categoryId) {
    // 먼저 영양 카테고리인지 확인
    final nutritionCategory = nutritionCategories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => const Category(id: '', nameKey: '', iconPath: ''),
    );

    if (nutritionCategory.id.isNotEmpty) {
      return nutritionCategory.iconPath;
    }

    // 메인 카테고리인지 확인
    final mainCategory = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => const Category(id: '', nameKey: '', iconPath: ''),
    );

    if (mainCategory.id.isNotEmpty) {
      return mainCategory.iconPath;
    }

    // 서브카테고리인 경우 메인 카테고리 매핑을 확인
    final mainCategoryId = _subcategoryToMainCategory[categoryId];
    if (mainCategoryId != null) {
      final mappedCategory = categories.firstWhere(
        (cat) => cat.id == mainCategoryId,
        orElse: () => const Category(id: '', nameKey: '', iconPath: ''),
      );
      if (mappedCategory.id.isNotEmpty) {
        return mappedCategory.iconPath;
      }
    }

    // 기본값: 식품 아이콘
    return 'assets/images/food.webp';
  }

  /// 서브카테고리에서 메인 카테고리 ID를 반환
  static String? getMainCategoryId(String subcategoryId) {
    return _subcategoryToMainCategory[subcategoryId];
  }
}