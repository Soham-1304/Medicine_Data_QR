import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/medicine.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicines.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        generic_name TEXT,
        dosage TEXT NOT NULL,
        manufacturer TEXT NOT NULL,
        batch_no TEXT NOT NULL,
        mfg_date TEXT NOT NULL,
        exp_date TEXT NOT NULL,
        description TEXT
      )
    ''');
  }

  Future<int> insert(Medicine medicine) async {
    final db = await database;
    // Check if duplicate exists with same name and batch_no
    final existing = await db.query(
      'medicines',
      where: 'LOWER(name) = ? AND LOWER(batch_no) = ?',
      whereArgs: [
        medicine.name.trim().toLowerCase(),
        medicine.batchNo.trim().toLowerCase()
      ],
    );

    if (existing.isNotEmpty) {
      final existingId = existing.first['id'] as int;
      await db.update(
        'medicines',
        medicine.toMap(),
        where: 'id = ?',
        whereArgs: [existingId],
      );
      return existingId;
    }

    return await db.insert('medicines', medicine.toMap());
  }

  Future<List<Medicine>> getAllMedicines() async {
    final db = await database;
    final result = await db.query('medicines', orderBy: 'id DESC');
    return result.map((row) => Medicine.fromMap(row)).toList();
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByNameAndBatch(String name, String batchNo) async {
    final db = await database;
    return await db.delete(
      'medicines',
      where: 'LOWER(name) = ? AND LOWER(batch_no) = ?',
      whereArgs: [
        name.trim().toLowerCase(),
        batchNo.trim().toLowerCase()
      ],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
