import 'package:sqflite/sqflite.dart';
import '../models/saved_result.dart';
import '../models/recent_result.dart';
import '../models/saved_ingredient.dart';
import '../models/recent_ingredient.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/ingredient_lens.db';

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saved_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        resultType TEXT NOT NULL,
        responseData TEXT NOT NULL,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recent_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        overall_review TEXT NOT NULL,
        result_data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // updatedAt 컬럼 추가
      await db.execute('ALTER TABLE saved_results ADD COLUMN updatedAt TEXT');
      // 기존 레코드들의 updatedAt을 createdAt과 동일하게 설정
      await db.execute(
          'UPDATE saved_results SET updatedAt = createdAt WHERE updatedAt IS NULL');
    }

    if (oldVersion < 3) {
      // recent_results 테이블 추가
      await db.execute('''
        CREATE TABLE recent_results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          overall_review TEXT NOT NULL,
          result_data TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      // 성분 검색 테이블 추가
      await db.execute('''
        CREATE TABLE saved_ingredients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          ingredientName TEXT NOT NULL,
          category TEXT NOT NULL,
          responseData TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE recent_ingredients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ingredient_name TEXT NOT NULL,
          category TEXT NOT NULL,
          description TEXT NOT NULL,
          result_data TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  // 결과 저장
  Future<int> saveResult(SavedResult result) async {
    final db = await database;
    await _ensureTableExists(db, 'saved_results');
    return await db.insert('saved_results', result.toMap());
  }

  // 모든 저장된 결과 조회 (최신순)
  Future<List<SavedResult>> getAllResults() async {
    try {
      final db = await database;
      
      // 테이블 존재 여부 확인 및 생성
      await _ensureTableExists(db, 'saved_results');
      
      final List<Map<String, dynamic>> maps = await db.query(
        'saved_results',
        orderBy: 'createdAt DESC',
      );

      return maps.map((map) => SavedResult.fromMap(map)).toList();
    } catch (e) {
      print('DatabaseService.getAllResults() error: $e');
      return []; // 예외 발생 시 빈 리스트 반환
    }
  }

  // 특정 결과 조회
  Future<SavedResult?> getResult(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_results',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SavedResult.fromMap(maps.first);
    }
    return null;
  }

  // 결과 이름 수정
  Future<int> updateResultName(int id, String newName) async {
    final db = await database;
    return await db.update(
      'saved_results',
      {
        'name': newName,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 결과 삭제
  Future<int> deleteResult(int id) async {
    final db = await database;
    return await db.delete(
      'saved_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 최근 분석 기록 저장 (최대 3개까지)
  Future<int> saveRecentResult(RecentResult result) async {
    final db = await database;
    await _ensureTableExists(db, 'recent_results');

    // 새 항목을 추가
    final insertResult = await db.insert('recent_results', result.toMap());

    // 추가 후 3개를 초과하면 가장 오래된 것들 삭제
    final List<Map<String, dynamic>> afterInsert = await db.query(
      'recent_results',
      orderBy: 'created_at DESC',
    );

    if (afterInsert.length > 3) {
      final toDelete = afterInsert.skip(3).toList();
      for (final record in toDelete) {
        await db.delete(
          'recent_results',
          where: 'id = ?',
          whereArgs: [record['id']],
        );
      }
    }

    return insertResult;
  }

  // 최근 분석 기록 조회 (최대 3개)
  Future<List<RecentResult>> getRecentResults() async {
    try {
      final db = await database;
      await _ensureTableExists(db, 'recent_results');
      
      final List<Map<String, dynamic>> maps = await db.query(
        'recent_results',
        orderBy: 'created_at DESC',
        limit: 3,
      );

      return maps.map((map) => RecentResult.fromMap(map)).toList();
    } catch (e) {
      print('DatabaseService.getRecentResults() error: $e');
      return [];
    }
  }

  // 최근 분석 기록 삭제
  Future<int> deleteRecentResult(int id) async {
    final db = await database;
    return await db.delete(
      'recent_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 성분 검색 결과 저장
  Future<int> saveIngredient(SavedIngredient ingredient) async {
    final db = await database;
    await _ensureTableExists(db, 'saved_ingredients');
    return await db.insert('saved_ingredients', ingredient.toMap());
  }

  // 모든 저장된 성분 검색 결과 조회 (최신순)
  Future<List<SavedIngredient>> getAllIngredients() async {
    try {
      final db = await database;
      
      // 테이블 존재 여부 확인 및 생성
      await _ensureTableExists(db, 'saved_ingredients');
      
      final List<Map<String, dynamic>> maps = await db.query(
        'saved_ingredients',
        orderBy: 'createdAt DESC',
      );

      return maps.map((map) => SavedIngredient.fromMap(map)).toList();
    } catch (e) {
      print('DatabaseService.getAllIngredients() error: $e');
      return []; // 예외 발생 시 빈 리스트 반환
    }
  }

  // 특정 성분 검색 결과 조회
  Future<SavedIngredient?> getIngredient(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SavedIngredient.fromMap(maps.first);
    }
    return null;
  }

  // 성분 검색 결과 이름 수정
  Future<int> updateIngredientName(int id, String newName) async {
    final db = await database;
    return await db.update(
      'saved_ingredients',
      {
        'name': newName,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 성분 검색 결과 삭제
  Future<int> deleteIngredient(int id) async {
    final db = await database;
    return await db.delete(
      'saved_ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 최근 성분 검색 기록 저장 (최대 3개까지)
  Future<int> saveRecentIngredient(RecentIngredient ingredient) async {
    final db = await database;
    await _ensureTableExists(db, 'recent_ingredients');

    // 새 항목을 추가
    final insertResult = await db.insert('recent_ingredients', ingredient.toMap());

    // 추가 후 3개를 초과하면 가장 오래된 것들 삭제
    final List<Map<String, dynamic>> afterInsert = await db.query(
      'recent_ingredients',
      orderBy: 'created_at DESC',
    );

    if (afterInsert.length > 3) {
      final toDelete = afterInsert.skip(3).toList();
      for (final record in toDelete) {
        await db.delete(
          'recent_ingredients',
          where: 'id = ?',
          whereArgs: [record['id']],
        );
      }
    }

    return insertResult;
  }

  // 최근 성분 검색 기록 조회 (최대 3개)
  Future<List<RecentIngredient>> getRecentIngredients() async {
    try {
      final db = await database;
      await _ensureTableExists(db, 'recent_ingredients');
      
      final List<Map<String, dynamic>> maps = await db.query(
        'recent_ingredients',
        orderBy: 'created_at DESC',
        limit: 3,
      );

      return maps.map((map) => RecentIngredient.fromMap(map)).toList();
    } catch (e) {
      print('DatabaseService.getRecentIngredients() error: $e');
      return [];
    }
  }

  // 최근 성분 검색 기록 삭제
  Future<int> deleteRecentIngredient(int id) async {
    final db = await database;
    return await db.delete(
      'recent_ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 테이블 존재 여부 확인 헬퍼 메서드
  Future<bool> _tableExists(Database db, String tableName) async {
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking table existence for $tableName: $e');
      return false;
    }
  }

  // 테이블 존재 확인 및 필요시 생성
  Future<void> _ensureTableExists(Database db, String tableName) async {
    try {
      final exists = await _tableExists(db, tableName);
      if (!exists) {
        print('Creating missing table: $tableName');
        await _createMissingTable(db, tableName);
      }
    } catch (e) {
      print('Error ensuring table exists for $tableName: $e');
    }
  }

  // 누락된 테이블 생성
  Future<void> _createMissingTable(Database db, String tableName) async {
    switch (tableName) {
      case 'saved_results':
        await db.execute('''
          CREATE TABLE saved_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            resultType TEXT NOT NULL,
            responseData TEXT NOT NULL,
            category TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        print('Created saved_results table');
        break;
        
      case 'saved_ingredients':
        await db.execute('''
          CREATE TABLE saved_ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            ingredientName TEXT NOT NULL,
            category TEXT NOT NULL,
            responseData TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        print('Created saved_ingredients table');
        break;
        
      case 'recent_results':
        await db.execute('''
          CREATE TABLE recent_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            overall_review TEXT NOT NULL,
            result_data TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        print('Created recent_results table');
        break;
        
      case 'recent_ingredients':
        await db.execute('''
          CREATE TABLE recent_ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ingredient_name TEXT NOT NULL,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            result_data TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        print('Created recent_ingredients table');
        break;
        
      default:
        print('Unknown table name: $tableName');
    }
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
