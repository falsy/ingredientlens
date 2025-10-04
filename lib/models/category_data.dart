class CategoryData {
  static const Map<String, List<String>> subcategories = {
    'food': [
      'food_health_food',
      'food_diet_food',
      'food_dairy',
      'food_processed',
      'food_instant',
      'food_beverages',
      'food_snacks',
      'food_bakery',
      'food_seasoning',
    ],
    'cosmetics': [
      'cosmetics_skincare',
      'cosmetics_cleansing',
      'cosmetics_suncare',
      'cosmetics_mask',
      'cosmetics_makeup',
      'cosmetics_bodycare',
      'cosmetics_haircare',
      'cosmetics_handcare',
      'cosmetics_footcare',
      'cosmetics_mens',
    ],
    'medicine': [
      'medicine_skin_treatment',
      'medicine_allergy',
      'medicine_womens',
      'medicine_general',
      'medicine_supplements',
    ],
    'baby_products': [
      'baby_skincare',
      'baby_cleansers',
      'baby_medicine',
      'baby_food',
      'baby_formula',
      'baby_sanitizers',
      'baby_detergent',
      'baby_toys',
    ],
    'pet_products': [
      'pet_supplements',
      'pet_medicine',
      'pet_shampoo',
      'pet_special_food',
      'pet_food',
      'pet_treats',
      'pet_waste',
      'pet_toys',
    ],
    'household_products': [
      'household_products_dishwashing',
      'household_products_air_freshener',
      'household_products_cleaner',
      'household_products_deodorizer',
    ],
  };

  static List<String> getSubcategories(String categoryId) {
    return subcategories[categoryId] ?? [];
  }

  static bool hasSubcategories(String categoryId) {
    return subcategories.containsKey(categoryId) && 
           subcategories[categoryId]!.isNotEmpty;
  }
}