import 'package:shared_preferences/shared_preferences.dart';

class UsageLimitService {
  static const int _dailyLimit = 100;
  static const String _keyPrefix = 'daily_usage_';
  static const String _keyLastReset = 'last_reset_date';

  static final UsageLimitService _instance = UsageLimitService._internal();
  factory UsageLimitService() => _instance;
  UsageLimitService._internal();

  Future<bool> canMakeRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    
    final today = _getTodayKey();
    final currentUsage = prefs.getInt(today) ?? 0;
    
    return currentUsage < _dailyLimit;
  }

  Future<int> getRemainingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    
    final today = _getTodayKey();
    final currentUsage = prefs.getInt(today) ?? 0;
    
    return (_dailyLimit - currentUsage).clamp(0, _dailyLimit);
  }

  Future<int> getCurrentUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    
    final today = _getTodayKey();
    return prefs.getInt(today) ?? 0;
  }

  Future<void> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);
    
    final today = _getTodayKey();
    final currentUsage = prefs.getInt(today) ?? 0;
    
    await prefs.setInt(today, currentUsage + 1);
  }

  Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastReset = prefs.getString(_keyLastReset);
    
    if (lastReset != today) {
      // 새로운 날이면 모든 사용량 초기화
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
      await prefs.setString(_keyLastReset, today);
    }
  }

  String _getTodayKey() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return '$_keyPrefix$today';
  }

  int get dailyLimit => _dailyLimit;
}