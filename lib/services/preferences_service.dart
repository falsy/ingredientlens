// Simple in-memory preferences for now
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  static PreferencesService get instance => _instance;
  
  // In-memory storage
  final Map<String, dynamic> _storage = {};
  
  PreferencesService._internal();
  
  Future<void> init() async {
    // Initialize with default values
    // language_code는 null로 두어서 시스템 언어를 감지하도록 함
    _storage['dont_show_analysis_notice'] = false;
  }
  
  // Language preference
  String? getLanguageCode() {
    return _storage['language_code'] as String?;
  }
  
  Future<bool> setLanguageCode(String languageCode) async {
    _storage['language_code'] = languageCode;
    return true;
  }
  
  // Don't show analysis notice again
  bool getDontShowAnalysisNotice() {
    return _storage['dont_show_analysis_notice'] as bool? ?? false;
  }
  
  Future<bool> setDontShowAnalysisNotice(bool value) async {
    _storage['dont_show_analysis_notice'] = value;
    return true;
  }
  
  // Last selected category
  String? getLastSelectedCategory() {
    return _storage['last_selected_category'] as String?;
  }
  
  Future<bool> setLastSelectedCategory(String category) async {
    _storage['last_selected_category'] = category;
    return true;
  }
  
  // Clear all preferences
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }
}