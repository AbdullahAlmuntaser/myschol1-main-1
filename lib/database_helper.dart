import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'academic_year_model.dart';
import 'attendance_model.dart';


import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      String path;
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
        path = 'school_management.db';
      } else {
        final dbPath = await getApplicationDocumentsDirectory();
        path = join(dbPath.path, 'school_management.db');
      }

      developer.log(
        'DatabaseHelper: Attempting to open database at $path',
        name: 'DatabaseHelper',
      );
      return await openDatabase(
        path,
        version: 24,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e, s) {
      developer.log(
        'DatabaseHelper: Error initializing database',
        name: 'DatabaseHelper',
        level: 1000,
        error: e,
        stackTrace: s,
      );

      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    developer.log(
      'DatabaseHelper: _onUpgrade called, upgrading database from version $oldVersion to $newVersion',
      name: 'DatabaseHelper',
    );
    // This is a placeholder for actual upgrade logic.
    // In a real app, you would handle schema changes between versions here.
    // For now, we will simply recreate the tables if the version changes significantly.
    if (oldVersion < newVersion) {
      // Example: Drop all tables and recreate them (not recommended for production)
      // await db.execute('DROP TABLE IF EXISTS users');
      // await db.execute('DROP TABLE IF EXISTS students');
      // ... and so on for all tables
      // await _onCreate(db, newVersion);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    developer.log(
      'DatabaseHelper: _onCreate called, creating tables...',
      name: 'DatabaseHelper',
    );
    try {
      await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT
      );

      CREATE TABLE academic_years(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year TEXT NOT NULL UNIQUE,
        isActive INTEGER NOT NULL DEFAULT 0
      );

      CREATE TABLE attendances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        classId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        teacherId INTEGER NOT NULL,
        date TEXT NOT NULL,
        lessonNumber INTEGER NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE CASCADE
      )
      ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AcademicYear>> getAcademicYears() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('academic_years');
    return List.generate(maps.length, (i) {
      return AcademicYear.fromMap(maps[i]);
    });
  }

  Future<int> createAcademicYear(AcademicYear academicYear) async {
    final db = await database;
    return await db.insert('academic_years', academicYear.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateAcademicYear(AcademicYear academicYear) async {
    final db = await database;
    return await db.update(
      'academic_years',
      academicYear.toMap(),
      where: 'id = ?',
      whereArgs: [academicYear.id],
    );
  }

  Future<int> deleteAcademicYear(int id) async {
    final db = await database;
    return await db.delete(
      'academic_years',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setActiveAcademicYear(AcademicYear academicYear) async {
    final db = await database;
    await db.update(
      'academic_years',
      {'isActive': 0}, // Set all to inactive first
      where: 'isActive = ?',
      whereArgs: [1],
    );
    await db.update(
      'academic_years',
      {'isActive': 1}, // Set the selected one to active
      where: 'id = ?',
      whereArgs: [academicYear.id],
    );
  }

  Future<List<Attendance>> getAttendancesByFilters({
    String? date,
    int? classId,
    int? subjectId,
    int? teacherId,
    int? studentId,
    int? lessonNumber,
  }) async {
    final db = await database;
    List<String> conditions = [];
    List<dynamic> args = [];

    if (date != null) {
      conditions.add('date = ?');
      args.add(date);
    }
    if (classId != null) {
      conditions.add('classId = ?');
      args.add(classId);
    }
    if (subjectId != null) {
      conditions.add('subjectId = ?');
      args.add(subjectId);
    }
    if (teacherId != null) {
      conditions.add('teacherId = ?');
      args.add(teacherId);
    }
    if (studentId != null) {
      conditions.add('studentId = ?');
      args.add(studentId);
    }
    if (lessonNumber != null) {
      conditions.add('lessonNumber = ?');
      args.add(lessonNumber);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'attendances',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
    );

    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  Future<int> createAttendance(Attendance attendance) async {
    final db = await database;
    return await db.insert('attendances', attendance.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await database;
    return await db.update(
      'attendances',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete(
      'attendances',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> bulkUpsertAttendances(
      List<Attendance> toUpdate, List<Attendance> toInsert) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var attendance in toUpdate) {
        await txn.update(
          'attendances',
          attendance.toMap(),
          where: 'id = ?',
          whereArgs: [attendance.id],
        );
      }
      for (var attendance in toInsert) {
        await txn.insert('attendances', attendance.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}