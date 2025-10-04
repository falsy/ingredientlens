import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_preference.dart';
import '../utils/legacy_data_migration_util.dart';

class UserPreferenceService {
  static final UserPreferenceService _instance =
      UserPreferenceService._internal();
  factory UserPreferenceService() => _instance;
  UserPreferenceService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'user_preferences.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_preferences(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        value TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(category, value)
      )
    ''');
  }

  // 특정 카테고리의 모든 설정 가져오기 (레거시 데이터 마이그레이션 포함)
  Future<List<UserPreference>> getPreferencesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at ASC',
    );

    final preferences = <UserPreference>[];
    
    for (final map in maps) {
      var preference = UserPreference.fromMap(map);
      
      // 레거시 데이터 마이그레이션 체크
      if (LegacyDataMigrationUtil.isLegacyValue(preference.value)) {
        final convertedKey = LegacyDataMigrationUtil.convertLegacyToKey(category, preference.value);
        
        // 이미 변환된 키가 존재하는지 확인
        final existingPreference = preferences.firstWhere(
          (p) => p.value == convertedKey,
          orElse: () => UserPreference(
            category: '',
            value: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (existingPreference.category.isEmpty) {
          // 변환된 키가 존재하지 않으면 업데이트
          try {
            await _updatePreferenceValue(preference.id!, convertedKey);
            preference = preference.copyWith(value: convertedKey);
          } catch (e) {
            // UNIQUE 제약 위반 시 레거시 데이터 삭제
            await deletePreference(preference.id!);
            continue; // 이 preference는 추가하지 않음
          }
        } else {
          // 이미 변환된 키가 존재하면 레거시 데이터 삭제
          await deletePreference(preference.id!);
          continue; // 이 preference는 추가하지 않음
        }
      }
      
      preferences.add(preference);
    }

    return preferences;
  }

  // 모든 사용자 설정 가져오기 (레거시 데이터 마이그레이션 포함)
  Future<List<UserPreference>> getAllPreferences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      orderBy: 'category ASC, created_at ASC',
    );

    final preferences = <UserPreference>[];
    
    for (final map in maps) {
      var preference = UserPreference.fromMap(map);
      
      // 레거시 데이터 마이그레이션 체크
      if (LegacyDataMigrationUtil.isLegacyValue(preference.value)) {
        final convertedKey = LegacyDataMigrationUtil.convertLegacyToKey(preference.category, preference.value);
        
        // 이미 변환된 키가 같은 카테고리에 존재하는지 확인
        final existingPreference = preferences.firstWhere(
          (p) => p.category == preference.category && p.value == convertedKey,
          orElse: () => UserPreference(
            category: '',
            value: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (existingPreference.category.isEmpty) {
          // 변환된 키가 존재하지 않으면 업데이트
          try {
            await _updatePreferenceValue(preference.id!, convertedKey);
            preference = preference.copyWith(value: convertedKey);
          } catch (e) {
            // UNIQUE 제약 위반 시 레거시 데이터 삭제
            await deletePreference(preference.id!);
            continue; // 이 preference는 추가하지 않음
          }
        } else {
          // 이미 변환된 키가 존재하면 레거시 데이터 삭제
          await deletePreference(preference.id!);
          continue; // 이 preference는 추가하지 않음
        }
      }
      
      preferences.add(preference);
    }

    return preferences;
  }

  // 설정 추가
  Future<int> addPreference(UserPreference preference) async {
    final db = await database;
    try {
      return await db.insert(
        'user_preferences',
        preference.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      // 중복되는 경우 0 반환
      return 0;
    }
  }

  // 설정 삭제
  Future<int> deletePreference(int id) async {
    final db = await database;
    return await db.delete(
      'user_preferences',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // preference 값 업데이트 (마이그레이션용)
  Future<int> _updatePreferenceValue(int id, String newValue) async {
    final db = await database;
    return await db.update(
      'user_preferences',
      {'value': newValue, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 특정 카테고리와 값으로 설정 삭제
  Future<int> deletePreferenceByValue(String category, String value) async {
    final db = await database;
    return await db.delete(
      'user_preferences',
      where: 'category = ? AND value = ?',
      whereArgs: [category, value],
    );
  }

  // 설정 업데이트
  Future<int> updatePreference(UserPreference preference) async {
    final db = await database;
    return await db.update(
      'user_preferences',
      preference.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [preference.id],
    );
  }

  // 특정 설정이 존재하는지 확인
  Future<bool> preferenceExists(String category, String value) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'category = ? AND value = ?',
      whereArgs: [category, value],
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  // 카테고리별 설정 개수
  Future<int> getPreferenceCount(String category) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_preferences WHERE category = ?',
      [category],
    );
    return result.first['count'] as int;
  }

  // DB 초기화 (개발/테스트용)
  Future<void> clearAllPreferences() async {
    final db = await database;
    await db.delete('user_preferences');
  }
}
