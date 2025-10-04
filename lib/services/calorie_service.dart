import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calorie_entry.dart';

class CalorieService {
  static const String _keyPrefix = 'calorie_entries';
  static const String _keyCounter = 'calorie_entry_counter';

  static final CalorieService _instance = CalorieService._internal();
  factory CalorieService() => _instance;
  CalorieService._internal();

  static CalorieService get instance => _instance;

  Future<List<CalorieEntry>> getAllCalorieEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(_keyPrefix) && key != _keyCounter);

    List<CalorieEntry> entries = [];
    for (String key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final Map<String, dynamic> json = jsonDecode(jsonString);
          entries.add(CalorieEntry.fromJson(json));
        } catch (e) {
          // 손상된 데이터는 무시
          continue;
        }
      }
    }

    // createdAt 기준 내림차순 정렬 (최신순)
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<List<CalorieEntry>> getTodayCalorieEntries() async {
    final allEntries = await getAllCalorieEntries();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return allEntries.where((entry) {
      return entry.date
              .isAfter(todayStart.subtract(const Duration(milliseconds: 1))) &&
          entry.date.isBefore(todayEnd);
    }).toList();
  }

  Future<List<CalorieEntry>> getThisWeekCalorieEntries() async {
    final allEntries = await getAllCalorieEntries();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    return allEntries.where((entry) {
      return entry.date
              .isAfter(weekStart.subtract(const Duration(milliseconds: 1))) &&
          entry.date.isBefore(weekEnd);
    }).toList();
  }

  Future<double> getTodayTotalCalories() async {
    final todayEntries = await getTodayCalorieEntries();
    return todayEntries.fold<double>(0.0, (double sum, CalorieEntry entry) => sum + entry.totalCalories);
  }

  Future<double> getThisWeekTotalCalories() async {
    final weekEntries = await getThisWeekCalorieEntries();
    return weekEntries.fold<double>(0.0, (double sum, CalorieEntry entry) => sum + entry.totalCalories);
  }

  Future<Map<String, double>> getThisWeekDailyCalories() async {
    final weekEntries = await getThisWeekCalorieEntries();
    Map<String, double> dailyTotals = {};

    for (CalorieEntry entry in weekEntries) {
      final dateKey =
          '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0.0) + entry.totalCalories;
    }

    return dailyTotals;
  }

  Future<Map<String, double>> getWeekDailyCalories(DateTime weekStart) async {
    final allEntries = await getAllCalorieEntries();
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weekEntries = allEntries.where((entry) {
      return entry.date
              .isAfter(weekStart.subtract(const Duration(milliseconds: 1))) &&
          entry.date.isBefore(weekEnd);
    }).toList();

    Map<String, double> dailyTotals = {};

    for (CalorieEntry entry in weekEntries) {
      final dateKey =
          '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0.0) + entry.totalCalories;
    }

    return dailyTotals;
  }

  Future<List<CalorieEntry>> getDayCalorieEntries(DateTime date) async {
    final allEntries = await getAllCalorieEntries();
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return allEntries.where((entry) {
      return entry.date
              .isAfter(dayStart.subtract(const Duration(milliseconds: 1))) &&
          entry.date.isBefore(dayEnd);
    }).toList();
  }

  Future<bool> addCalorieEntry(CalorieEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ID 생성 (새로운 엔트리인 경우)
      int id = entry.id ?? await _getNextId();
      final entryWithId = CalorieEntry(
        id: id,
        analysisId: entry.analysisId,
        foods: entry.foods,
        mealType: entry.mealType,
        date: entry.date,
        createdAt: entry.createdAt,
      );

      final key = '$_keyPrefix$id';
      final jsonString = jsonEncode(entryWithId.toJson());

      return await prefs.setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCalorieEntry(CalorieEntry entry) async {
    if (entry.id == null) return false;
    return await addCalorieEntry(entry); // 같은 ID로 덮어쓰기
  }

  Future<bool> removeCalorieEntry(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$id';
      return await prefs.remove(key);
    } catch (e) {
      return false;
    }
  }

  Future<CalorieEntry?> getCalorieEntry(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$id';
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return CalorieEntry.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int> _getNextId() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCounter = prefs.getInt(_keyCounter) ?? 0;
    final nextId = currentCounter + 1;
    await prefs.setInt(_keyCounter, nextId);
    return nextId;
  }

  // 데이터 정리 (선택적)
  Future<void> cleanupOldEntries({int daysToKeep = 90}) async {
    final allEntries = await getAllCalorieEntries();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    for (CalorieEntry entry in allEntries) {
      if (entry.createdAt.isBefore(cutoffDate) && entry.id != null) {
        await removeCalorieEntry(entry.id!);
      }
    }
  }
}
