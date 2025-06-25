import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saved_result.dart';

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
    final path = join(databasePath, 'ingredient_lens.db');

    return await openDatabase(
      path,
      version: 2,
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // updatedAt 컬럼 추가
      await db.execute('ALTER TABLE saved_results ADD COLUMN updatedAt TEXT');
      // 기존 레코드들의 updatedAt을 createdAt과 동일하게 설정
      await db.execute('UPDATE saved_results SET updatedAt = createdAt WHERE updatedAt IS NULL');
    }
  }


  // 결과 저장
  Future<int> saveResult(SavedResult result) async {
    final db = await database;
    return await db.insert('saved_results', result.toMap());
  }

  // 모든 저장된 결과 조회 (최신순)
  Future<List<SavedResult>> getAllResults() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_results',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return SavedResult.fromMap(maps[i]);
    });
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

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}