import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  // 스크린 뷰 추적
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      if (kDebugMode) {
        print('📊 [Analytics] Screen View: $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging screen view: $e');
      }
    }
  }

  // 성분 분석 완료 이벤트 (주요 전환 액션)
  static Future<void> logAnalysisCompleted({
    required String category,
    required String preferenceType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'analysis_completed',
        parameters: {
          'category': category,
          'preference_type': preferenceType,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Analysis Completed - Category: $category, Preference: $preferenceType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging analysis completed: $e');
      }
    }
  }

  // 비교 분석 완료 이벤트 (주요 전환 액션)
  static Future<void> logComparisonCompleted({
    required String category,
    required String preferenceType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'comparison_completed',
        parameters: {
          'category': category,
          'preference_type': preferenceType,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Comparison Completed - Category: $category, Preference: $preferenceType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging comparison completed: $e');
      }
    }
  }

  // 결과 저장 이벤트
  static Future<void> logResultSaved({
    required String resultType,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'result_saved',
        parameters: {
          'result_type': resultType,
          'category': category,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Result Saved - Type: $resultType, Category: $category');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging result saved: $e');
      }
    }
  }

  // 성분 검색 이벤트
  static Future<void> logIngredientSearch({
    required String ingredientName,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'ingredient_search',
        parameters: {
          'ingredient_name': ingredientName,
          'category': category,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Ingredient Search - Name: $ingredientName, Category: $category');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging ingredient search: $e');
      }
    }
  }

  // 공유 이벤트
  static Future<void> logShare({
    required String contentType,
    required String method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: DateTime.now().millisecondsSinceEpoch.toString(),
        method: method,
      );
      if (kDebugMode) {
        print('📊 [Analytics] Share - Type: $contentType, Method: $method');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging share: $e');
      }
    }
  }

  // 사용자 프로필 설정 이벤트
  static Future<void> logProfileSet({
    required String profileType,
    required int itemCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'profile_set',
        parameters: {
          'profile_type': profileType,
          'item_count': itemCount,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Profile Set - Type: $profileType, Items: $itemCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging profile set: $e');
      }
    }
  }

  // 카테고리 선택 이벤트
  static Future<void> logCategorySelected({
    required String category,
    required String action,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'category_selected',
        parameters: {
          'category': category,
          'action': action,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Category Selected - Category: $category, Action: $action');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging category selected: $e');
      }
    }
  }

  // 영양 분석 완료 이벤트
  static Future<void> logNutritionAnalysisCompleted({
    required String category,
    required String preferenceType,
    required int warningCount,
    required int benefitCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'nutrition_analysis_completed',
        parameters: {
          'category': category,
          'preference_type': preferenceType,
          'warning_count': warningCount,
          'benefit_count': benefitCount,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Nutrition Analysis Completed - Category: $category, Warnings: $warningCount, Benefits: $benefitCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging nutrition analysis completed: $e');
      }
    }
  }

  // 열량 분석 완료 이벤트
  static Future<void> logCalorieAnalysisCompleted({
    required String mealType,
    required double totalCalories,
    required int foodCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'calorie_analysis_completed',
        parameters: {
          'meal_type': mealType,
          'total_calories': totalCalories,
          'food_count': foodCount,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Calorie Analysis Completed - Meal: $mealType, Calories: $totalCalories, Foods: $foodCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging calorie analysis completed: $e');
      }
    }
  }

  // 열량 저장 이벤트
  static Future<void> logCalorieSaved({
    required String mealType,
    required double totalCalories,
    required int foodCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'calorie_saved',
        parameters: {
          'meal_type': mealType,
          'total_calories': totalCalories,
          'food_count': foodCount,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Calorie Saved - Meal: $mealType, Calories: $totalCalories, Foods: $foodCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging calorie saved: $e');
      }
    }
  }

  // 영양 저장 이벤트
  static Future<void> logNutritionSaved({
    required String category,
    required String preferenceType,
    required int warningCount,
    required int benefitCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'nutrition_saved',
        parameters: {
          'category': category,
          'preference_type': preferenceType,
          'warning_count': warningCount,
          'benefit_count': benefitCount,
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Nutrition Saved - Category: $category, Warnings: $warningCount, Benefits: $benefitCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging nutrition saved: $e');
      }
    }
  }

  // 일일 한도 도달 이벤트
  static Future<void> logDailyLimitReached() async {
    try {
      await _analytics.logEvent(
        name: 'daily_limit_reached',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        print('📊 [Analytics] Daily Limit Reached');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error logging daily limit: $e');
      }
    }
  }

  // 사용자 속성 설정
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        print('📊 [Analytics] User Property Set - $name: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Analytics] Error setting user property: $e');
      }
    }
  }
}