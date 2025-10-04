import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PreferenceTranslationUtil {
  static String getTranslatedOption(BuildContext context, String option) {
    final localizations = AppLocalizations.of(context)!;
    
    // 리플렉션 대신 간단한 switch case 사용
    switch (option) {
      // Religion
      case 'Christianity':
        return localizations.christianity;
      case 'Islam':
        return localizations.islam;
      case 'Hinduism':
        return localizations.hinduism;
      case 'Buddhism':
        return localizations.buddhism;
      
      // Skin types
      case 'Normal':
        return localizations.normal;
      case 'Dry':
        return localizations.dry;
      case 'Oily':
        return localizations.oily;
      case 'Combination':
        return localizations.combination;
      case 'Sensitive':
        return localizations.sensitive;
      case 'Acne-prone':
        return localizations.acne_prone;
      case 'Atopic':
        return localizations.atopic;
      
      // Allergies
      case 'Nuts':
        return localizations.nuts;
      case 'Dairy':
        return localizations.dairy;
      case 'Eggs':
        return localizations.eggs;
      case 'Shellfish':
        return localizations.shellfish;
      case 'Fish':
        return localizations.fish;
      case 'Soy':
        return localizations.soy;
      case 'Gluten':
        return localizations.gluten;
      case 'Sesame':
        return localizations.sesame;
      
      // Diet
      case 'Vegan':
        return localizations.vegan;
      case 'Vegetarian':
        return localizations.vegetarian;
      case 'Gluten-free':
        return localizations.gluten_free;
      case 'Dairy-free':
        return localizations.dairy_free;
      case 'Sugar-free':
        return localizations.sugar_free;
      case 'Low-carb':
        return localizations.low_carb;
      case 'Halal':
        return localizations.halal;
      
      // Health
      case 'Pregnancy':
        return localizations.pregnancy;
      case 'Breastfeeding':
        return localizations.breastfeeding;
      case 'Diabetes':
        return localizations.diabetes;
      case 'Hypertension':
        return localizations.hypertension;
      case 'Heart disease':
        return localizations.heart_disease;
      case 'Kidney disease':
        return localizations.kidney_disease;
      
      // Pet weight
      case 'pet_weight_under_1kg':
        return localizations.pet_weight_under_1kg;
      case 'pet_weight_1_3kg':
        return localizations.pet_weight_1_3kg;
      case 'pet_weight_3_5kg':
        return localizations.pet_weight_3_5kg;
      case 'pet_weight_5_10kg':
        return localizations.pet_weight_5_10kg;
      case 'pet_weight_10_20kg':
        return localizations.pet_weight_10_20kg;
      case 'pet_weight_over_20kg':
        return localizations.pet_weight_over_20kg;
      
      // Direct input
      case 'direct_input':
        return localizations.direct_input;
      
      // 번역이 없으면 원본 반환
      default:
        return option;
    }
  }
}