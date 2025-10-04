import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CategoryTranslationUtil {
  static String getTranslatedCategory(BuildContext context, String category) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (category) {
      case 'food':
        return localizations.food;
      case 'cosmetics':
        return localizations.cosmetics;
      case 'baby_products':
        return localizations.baby_products;
      case 'pet_products':
        return localizations.pet_products;
      case 'medicine':
        return localizations.medicine;
      case 'household_products':
        return localizations.household_products;
      case 'cleaning_products':
        return localizations.cleaning_products;
      case 'vegan_products':
        return localizations.vegan_products;
      case 'other':
        return localizations.other;
      default:
        return category;
    }
  }

  static String getTranslatedCategoryOrSubcategory(BuildContext context, String categoryKey) {
    final localizations = AppLocalizations.of(context)!;
    
    // 먼저 서브카테고리인지 확인
    switch (categoryKey) {
      // Food subcategories
      case 'food_health_food':
        return localizations.food_health_food;
      case 'food_diet_food':
        return localizations.food_diet_food;
      case 'food_dairy':
        return localizations.food_dairy;
      case 'food_processed':
        return localizations.food_processed;
      case 'food_instant':
        return localizations.food_instant;
      case 'food_beverages':
        return localizations.food_beverages;
      case 'food_snacks':
        return localizations.food_snacks;
      case 'food_bakery':
        return localizations.food_bakery;
      case 'food_seasoning':
        return localizations.food_seasoning;
      
      // Cosmetics subcategories
      case 'cosmetics_skincare':
        return localizations.cosmetics_skincare;
      case 'cosmetics_cleansing':
        return localizations.cosmetics_cleansing;
      case 'cosmetics_suncare':
        return localizations.cosmetics_suncare;
      case 'cosmetics_mask':
        return localizations.cosmetics_mask;
      case 'cosmetics_makeup':
        return localizations.cosmetics_makeup;
      case 'cosmetics_bodycare':
        return localizations.cosmetics_bodycare;
      case 'cosmetics_haircare':
        return localizations.cosmetics_haircare;
      case 'cosmetics_handcare':
        return localizations.cosmetics_handcare;
      case 'cosmetics_footcare':
        return localizations.cosmetics_footcare;
      case 'cosmetics_mens':
        return localizations.cosmetics_mens;
      
      // Medicine subcategories
      case 'medicine_skin_treatment':
        return localizations.medicine_skin_treatment;
      case 'medicine_allergy':
        return localizations.medicine_allergy;
      case 'medicine_womens':
        return localizations.medicine_womens;
      case 'medicine_general':
        return localizations.medicine_general;
      case 'medicine_supplements':
        return localizations.medicine_supplements;
      
      // Baby subcategories
      case 'baby_skincare':
        return localizations.baby_skincare;
      case 'baby_cleansers':
        return localizations.baby_cleansers;
      case 'baby_medicine':
        return localizations.baby_medicine;
      case 'baby_food':
        return localizations.baby_food;
      case 'baby_formula':
        return localizations.baby_formula;
      case 'baby_sanitizers':
        return localizations.baby_sanitizers;
      case 'baby_detergent':
        return localizations.baby_detergent;
      case 'baby_toys':
        return localizations.baby_toys;
      
      // Pet subcategories
      case 'pet_supplements':
        return localizations.pet_supplements;
      case 'pet_medicine':
        return localizations.pet_medicine;
      case 'pet_shampoo':
        return localizations.pet_shampoo;
      case 'pet_special_food':
        return localizations.pet_special_food;
      case 'pet_food':
        return localizations.pet_food;
      case 'pet_treats':
        return localizations.pet_treats;
      case 'pet_waste':
        return localizations.pet_waste;
      case 'pet_toys':
        return localizations.pet_toys;
      
      // Household products subcategories
      case 'household_products_dishwashing':
        return localizations.household_products_dishwashing;
      case 'household_products_air_freshener':
        return localizations.household_products_air_freshener;
      case 'household_products_cleaner':
        return localizations.household_products_cleaner;
      case 'household_products_deodorizer':
        return localizations.household_products_deodorizer;
      
      // Nutrition categories
      case 'processed_food':
        return localizations.processed_food;
      case 'dessert':
        return localizations.dessert;
      case 'beverages':
        return localizations.beverages;
      
      // 서브카테고리가 아닌 경우 상위 카테고리 번역 시도
      default:
        return getTranslatedCategory(context, categoryKey);
    }
  }

  /// 카테고리 이름을 다국어로 반환하는 통합 메서드
  static String getCategoryName(BuildContext context, String categoryKey) {
    return getTranslatedCategoryOrSubcategory(context, categoryKey);
  }
}