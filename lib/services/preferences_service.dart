import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recent_nutrition_result.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  static PreferencesService get instance => _instance;
  
  SharedPreferences? _prefs;
  
  PreferencesService._internal();
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Language preference
  String? getLanguageCode() {
    return _prefs?.getString('language_code');
  }
  
  Future<bool> setLanguageCode(String languageCode) async {
    return await _prefs?.setString('language_code', languageCode) ?? false;
  }
  
  // Don't show analysis notice again
  bool getDontShowAnalysisNotice() {
    return _prefs?.getBool('dont_show_analysis_notice') ?? false;
  }
  
  Future<bool> setDontShowAnalysisNotice(bool value) async {
    return await _prefs?.setBool('dont_show_analysis_notice', value) ?? false;
  }
  
  // Last selected category
  String? getLastSelectedCategory() {
    return _prefs?.getString('last_selected_category');
  }
  
  Future<bool> setLastSelectedCategory(String category) async {
    return await _prefs?.setString('last_selected_category', category) ?? false;
  }
  
  // Category preference selection (카테고리별 프로필 선택 상태)
  String getCategoryPreferenceSelection(String category) {
    // 기본값 설정: 카테고리에 따라 다른 기본값
    String defaultValue;
    if (category == 'baby_products') {
      defaultValue = 'baby';
    } else if (category == 'pet_products') {
      defaultValue = 'pet';
    } else {
      defaultValue = 'user';
    }
    
    return _prefs?.getString('category_preference_$category') ?? defaultValue;
  }
  
  Future<bool> setCategoryPreferenceSelection(String category, String preference) async {
    return await _prefs?.setString('category_preference_$category', preference) ?? false;
  }
  
  // First launch check for onboarding
  bool isFirstLaunch() {
    return _prefs?.getBool('is_first_launch') ?? true;
  }
  
  Future<bool> setFirstLaunchCompleted() async {
    return await _prefs?.setBool('is_first_launch', false) ?? false;
  }
  
  // Physical Information
  double? getHeight() {
    return _prefs?.getDouble('height');
  }
  
  Future<bool> setHeight(double height) async {
    if (_prefs == null) {
      await init();
    }
    return await _prefs?.setDouble('height', height) ?? false;
  }
  
  double? getCurrentWeight() {
    return _prefs?.getDouble('current_weight');
  }
  
  Future<bool> setCurrentWeight(double weight) async {
    if (_prefs == null) {
      await init();
    }
    return await _prefs?.setDouble('current_weight', weight) ?? false;
  }
  
  double? getTargetWeight() {
    return _prefs?.getDouble('target_weight');
  }
  
  Future<bool> setTargetWeight(double targetWeight) async {
    if (_prefs == null) {
      await init();
    }
    return await _prefs?.setDouble('target_weight', targetWeight) ?? false;
  }
  
  // Baby Weight
  double? getBabyWeight() {
    return _prefs?.getDouble('baby_weight');
  }
  
  Future<bool> setBabyWeight(double weight) async {
    if (_prefs == null) {
      await init();
    }
    return await _prefs?.setDouble('baby_weight', weight) ?? false;
  }
  
  // Pet Weight
  double? getPetWeight() {
    return _prefs?.getDouble('pet_weight');
  }
  
  Future<bool> setPetWeight(double weight) async {
    return await _prefs?.setDouble('pet_weight', weight) ?? false;
  }
  
  // Recent nutrition results (영양 분석 결과)
  List<RecentNutritionResult> getRecentNutritionResults() {
    final jsonList = _prefs?.getStringList('recent_nutrition_results') ?? [];
    return jsonList.map((jsonString) {
      return RecentNutritionResult.fromJson(jsonDecode(jsonString));
    }).toList();
  }

  Future<bool> addRecentNutritionResult(RecentNutritionResult result) async {
    if (_prefs == null) {
      await init();
    }

    final existingResults = getRecentNutritionResults();
    
    // 최대 3개까지만 저장
    final updatedResults = [result, ...existingResults];
    if (updatedResults.length > 3) {
      updatedResults.removeLast();
    }

    final jsonList = updatedResults.map((result) => jsonEncode(result.toJson())).toList();
    return await _prefs?.setStringList('recent_nutrition_results', jsonList) ?? false;
  }

  Future<bool> removeRecentNutritionResult(DateTime createdAt) async {
    if (_prefs == null) {
      await init();
    }

    final existingResults = getRecentNutritionResults();
    final updatedResults = existingResults.where((result) => 
        result.createdAt != createdAt).toList();

    final jsonList = updatedResults.map((result) => jsonEncode(result.toJson())).toList();
    return await _prefs?.setStringList('recent_nutrition_results', jsonList) ?? false;
  }

  // Clear all preferences
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}