import 'dart:async';
import 'utils/app_constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'academic_year_model.dart';
import 'attendance_model.dart';
import 'book_model.dart';
import 'class_model.dart';
import 'event_model.dart';
import 'grade_model.dart';
import 'leave_model.dart';
import 'performance_evaluation_model.dart';
import 'permission_model.dart';
import 'staff_model.dart';
import 'student_model.dart';
import 'subject_model.dart';
import 'teacher_model.dart';
import 'timetable_model.dart';
import 'user_model.dart';


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
      ''');
      await db.execute('''
      CREATE TABLE academic_years(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year TEXT NOT NULL UNIQUE,
        isActive INTEGER NOT NULL DEFAULT 0
      );
      ''');
      await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT NOT NULL,
        classId INTEGER,
        dateOfBirth TEXT,
        gender TEXT,
        address TEXT,
        parentName TEXT,
        parentPhone TEXT,
        parentEmail TEXT,
        enrollmentDate TEXT,
        photoUrl TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (classId) REFERENCES classes(id) ON DELETE SET NULL
      );
      ''');
      await db.execute('''
       CREATE TABLE teachers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT,
        address TEXT,
        dateOfBirth TEXT,
        qualification TEXT,
        hireDate TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE SET NULL
      );
      ''');
      await db.execute('''
      CREATE TABLE classes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        teacherId INTEGER,
        academicYearId INTEGER NOT NULL,
        classId TEXT,
        capacity INTEGER,
        yearTerm TEXT,
        subjectIds TEXT,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE SET NULL,
        FOREIGN KEY (academicYearId) REFERENCES academic_years (id) ON DELETE CASCADE
      );
      ''');
      await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        classId INTEGER NOT NULL,
        teacherId INTEGER,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE SET NULL
      );
      ''');
      await db.execute('''
      CREATE TABLE grades(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        classId INTEGER NOT NULL,
        assessmentType TEXT NOT NULL,
        semester1Grade REAL,
        semester2Grade REAL,
        weight REAL NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE
      );
      ''');
      await db.execute('''
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
      );
      ''');
      await db.execute('''
      CREATE TABLE timetables(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        teacherId INTEGER NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        lessonNumber INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE CASCADE
      );
      ''');
      await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        startTime TEXT,
        endTime TEXT,
        location TEXT,
        type TEXT
      );
      ''');
      await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        isbn TEXT UNIQUE,
        genre TEXT,
        total_copies INTEGER NOT NULL,
        available_copies INTEGER NOT NULL,
        description TEXT,
        image_url TEXT
      );
      ''');
      await db.execute('''
       CREATE TABLE borrow_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        borrowDate TEXT NOT NULL,
        returnDate TEXT,
        dueDate TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      );
      ''');
      await db.execute('''
      CREATE TABLE staff(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT,
        email TEXT UNIQUE,
        address TEXT,
        hireDate TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE SET NULL
      );
      ''');
      await db.execute('''
      CREATE TABLE leaves(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staffId INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        reason TEXT,
        status TEXT NOT NULL,
        FOREIGN KEY (staffId) REFERENCES staff (id) ON DELETE CASCADE
      );
      ''');
      await db.execute('''
      CREATE TABLE performance_evaluations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staffId INTEGER NOT NULL,
        evaluationDate TEXT NOT NULL,
        evaluatorId INTEGER NOT NULL,
        score REAL,
        comments TEXT,
        FOREIGN KEY (staffId) REFERENCES staff (id) ON DELETE CASCADE,
        FOREIGN KEY (evaluatorId) REFERENCES users (id) ON DELETE CASCADE
      );
      ''');
      await db.execute('''
      CREATE TABLE permissions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        feature TEXT NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 0,
        UNIQUE(role, feature)
      );
      ''');
      
      // Insert default admin permissions
      for (var feature in allFeatureData.keys) {
        await db.insert('permissions', {
          'role': 'admin',
          'feature': feature,
          'isEnabled': 1,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Academic Year Methods
  Future<List<AcademicYear>> getAcademicYears() async {
    final List<Map<String, dynamic>> maps = await (await database).query('academic_years');
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

  // Attendance Methods
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
  
  // User Methods
  Future<User?> getUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  
  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }
  
  Future<int> updateUserRole(int userId, String role) async {
    final db = await database;
    return await db.update('users', {'role': role}, where: 'id = ?', whereArgs: [userId]);
  }
  
  // Student Methods
  Future<List<Student>> getStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<List<Student>> searchStudents(String query, {int? classId}) async {
    final db = await database;
    String whereClause = 'name LIKE ? OR parentEmail LIKE ?';
    List<dynamic> whereArgs = ['%$query%', '%$query%'];

    if(classId != null){
      whereClause += ' AND classId = ?';
      whereArgs.add(classId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: whereClause,
      whereArgs: whereArgs,
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<Student?> getStudentByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students', where: 'parentEmail = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<int> createStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }
  
  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update('students', student.toMap(), where: 'id = ?', whereArgs: [student.id]);
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Student>> getStudentsByParentUserId(int userId) async {
    // This requires a join or a subquery. For simplicity, let's assume parentEmail is stored in users table.
    // This logic might need adjustment based on final data model.
    final user = await getUserById(userId);
    if(user?.role == 'parent' && user?.username != null){
       return searchStudents(user!.username);
    }
    return [];
  }
  
  Future<Student?> getStudentByUserId(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('students', where: 'userId = ?', whereArgs: [userId]);
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  // Book Methods
  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  Future<int> createBook(Book book) async {
    final db = await database;
    return await db.insert('books', book.toMap());
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Book>> searchBooks(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ? OR isbn LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }
  
  Future<Book?> getBookById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books', where: 'id = ?', whereArgs: [id]);
    if(maps.isNotEmpty){
      return Book.fromMap(maps.first);
    }
    return null;
  }

  // Class Methods
  Future<List<SchoolClass>> getClasses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classes');
    return List.generate(maps.length, (i) => SchoolClass.fromMap(maps[i]));
  }
  
  Future<List<SchoolClass>> searchClasses(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classes', where: 'name LIKE ?', whereArgs: ['%$query%']);
    return List.generate(maps.length, (i) => SchoolClass.fromMap(maps[i]));
  }
  
  Future<SchoolClass?> getClassByClassIdString(String id) async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('classes', where: 'id = ?', whereArgs: [int.parse(id)]);
       if (maps.isNotEmpty) {
        return SchoolClass.fromMap(maps.first);
      }
      return null;
  }
  
  Future<int> createClass(SchoolClass classData) async {
    final db = await database;
    return await db.insert('classes', classData.toMap());
  }
  
  Future<int> updateClass(SchoolClass classData) async {
    final db = await database;
    return await db.update('classes', classData.toMap(), where: 'id = ?', whereArgs: [classData.id]);
  }

  Future<int> deleteClass(int id) async {
    final db = await database;
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  // Event Methods
  Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }
  
  Future<List<Event>> searchEvents(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events', where: 'title LIKE ?', whereArgs: ['%$query%']);
    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }

  Future<int> createEvent(Event event) async {
    final db = await database;
    return await db.insert('events', event.toMap());
  }
  
  Future<int> updateEvent(Event event) async {
    final db = await database;
    return await db.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<Event?> getEventById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    }
    return null;
  }
  
  // Grade Methods
  Future<List<Grade>> getGrades() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('grades');
    return List.generate(maps.length, (i) => Grade.fromMap(maps[i]));
  }
  
  Future<int> createGrade(Grade grade) async {
    final db = await database;
    return await db.insert('grades', grade.toMap());
  }

  Future<int> updateGrade(Grade grade) async {
    final db = await database;
    return await db.update('grades', grade.toMap(), where: 'id = ?', whereArgs: [grade.id]);
  }

  Future<int> deleteGrade(int id) async {
    final db = await database;
    return await db.delete('grades', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<List<Grade>> getGradesByStudent(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('grades', where: 'studentId = ?', whereArgs: [studentId]);
    return List.generate(maps.length, (i) => Grade.fromMap(maps[i]));
  }

  Future<List<Grade>> getGradesByClass(int classId) async {
    // This might require a join with students table.
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT g.* FROM grades g
      INNER JOIN students s ON s.id = g.studentId
      WHERE s.classId = ?
    ''', [classId]);
    return List.generate(maps.length, (i) => Grade.fromMap(maps[i]));
  }

  Future<List<Grade>> getGradesBySubject(int subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('grades', where: 'subjectId = ?', whereArgs: [subjectId]);
    return List.generate(maps.length, (i) => Grade.fromMap(maps[i]));
  }
  
  Future<List<Grade>> getGradesByClassAndSubject(int classId, int subjectId) async {
     final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT g.* FROM grades g
      INNER JOIN students s ON s.id = g.studentId
      WHERE s.classId = ? AND g.subjectId = ?
    ''', [classId, subjectId]);
    return List.generate(maps.length, (i) => Grade.fromMap(maps[i]));
  }
  
  Future<void> upsertGrades(List<Grade> grades) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var grade in grades) {
        if (grade.id != null) {
          await txn.update('grades', grade.toMap(), where: 'id = ?', whereArgs: [grade.id]);
        } else {
          await txn.insert('grades', grade.toMap());
        }
      }
    });
  }

  Future<Map<int, double>> getAverageGradesBySubject(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT subjectId, AVG((semester1Grade + semester2Grade) / 2) as averageGrade
      FROM grades
      WHERE studentId = ?
      GROUP BY subjectId
    ''', [studentId]);

    return {
      for (var map in maps)
        (map['subjectId'] as int): (map['averageGrade'] as double),
    };
  }

  Future<Map<int, double>> getAverageGradesForClass(int classId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT g.subjectId, AVG((g.semester1Grade + g.semester2Grade) / 2) as averageGrade
      FROM grades g
      INNER JOIN students s ON s.id = g.studentId
      WHERE s.classId = ?
      GROUP BY g.subjectId
    ''', [classId]);

    return {
      for (var map in maps)
        (map['subjectId'] as int): (map['averageGrade'] as double),
    };
  }

  // Future<Map<int, double>> getAverageGradesBySubject(int studentId) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'grades',
  //     columns: ['subjectId', 'AVG(grade) as avgGrade'],
  //     where: 'studentId = ?',
  //     whereArgs: [studentId],
  //     groupBy: 'subjectId',
  //   );
  //   return { for (var map in maps) map['subjectId']: map['avgGrade'] };
  // }

  // Future<Map<int, double>> getAverageGradesForClass(int classId) async {
  //   final List<Map<String, dynamic>> maps = await database.rawQuery('''
  //     SELECT g.subjectId, AVG(g.grade) as avgGrade FROM grades g
  //     INNER JOIN students s ON s.id = g.studentId
  //     WHERE s.classId = ?
  //     GROUP BY g.subjectId
  //   ''', [classId]);
  //   return { for (var map in maps) map['subjectId']: map['avgGrade'] };
  // }
  
  // Leave methods
  Future<List<Leave>> getLeaves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('leaves');
    return List.generate(maps.length, (i) => Leave.fromMap(maps[i]));
  }

  Future<List<Leave>> searchLeaves(String query) async {
    // This might require a join with staff table
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT l.* FROM leaves l
      INNER JOIN staff s ON s.id = l.staffId
      WHERE s.name LIKE ?
    ''', ['%$query%']);
    return List.generate(maps.length, (i) => Leave.fromMap(maps[i]));
  }

  Future<int> createLeave(Leave leave) async {
    final db = await database;
    return await db.insert('leaves', leave.toMap());
  }

  Future<int> updateLeave(Leave leave) async {
    final db = await database;
    return await db.update('leaves', leave.toMap(), where: 'id = ?', whereArgs: [leave.id]);
  }

  Future<int> deleteLeave(int id) async {
    final db = await database;
    return await db.delete('leaves', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Leave>> getLeavesByStaffId(int staffId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('leaves', where: 'staffId = ?', whereArgs: [staffId]);
    return List.generate(maps.length, (i) => Leave.fromMap(maps[i]));
  }
  
  Future<Leave?> getLeaveById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('leaves', where: 'id = ?', whereArgs: [id]);
    if(maps.isNotEmpty){
      return Leave.fromMap(maps.first);
    }
    return null;
  }

  // Performance Evaluation Methods
  Future<List<PerformanceEvaluation>> getPerformanceEvaluations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('performance_evaluations');
    return List.generate(maps.length, (i) => PerformanceEvaluation.fromMap(maps[i]));
  }
  
  Future<List<PerformanceEvaluation>> searchPerformanceEvaluations(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT pe.* FROM performance_evaluations pe
      INNER JOIN staff s ON s.id = pe.staffId
      WHERE s.name LIKE ?
    ''', ['%$query%']);
    return List.generate(maps.length, (i) => PerformanceEvaluation.fromMap(maps[i]));
  }
  
  Future<int> createPerformanceEvaluation(PerformanceEvaluation evaluation) async {
    final db = await database;
    return await db.insert('performance_evaluations', evaluation.toMap());
  }

  Future<int> updatePerformanceEvaluation(PerformanceEvaluation evaluation) async {
    final db = await database;
    return await db.update('performance_evaluations', evaluation.toMap(), where: 'id = ?', whereArgs: [evaluation.id]);
  }

  Future<int> deletePerformanceEvaluation(int id) async {
    final db = await database;
    return await db.delete('performance_evaluations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PerformanceEvaluation>> getPerformanceEvaluationsByStaffId(int staffId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('performance_evaluations', where: 'staffId = ?', whereArgs: [staffId]);
    return List.generate(maps.length, (i) => PerformanceEvaluation.fromMap(maps[i]));
  }
  
  Future<PerformanceEvaluation?> getPerformanceEvaluationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('performance_evaluations', where: 'id = ?', whereArgs: [id]);
    if(maps.isNotEmpty){
      return PerformanceEvaluation.fromMap(maps.first);
    }
    return null;
  }
  
  // Permission Methods
  Future<List<Permission>> getPermissionsByRole(String role) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('permissions', where: 'role = ?', whereArgs: [role]);
    return List.generate(maps.length, (i) => Permission.fromMap(maps[i]));
  }

  Future<int> updatePermission(Permission permission) async {
    final db = await database;
    return await db.update('permissions', permission.toMap(), where: 'id = ?', whereArgs: [permission.id]);
  }

  Future<List<Permission>> getPermissions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('permissions');
    return List.generate(maps.length, (i) => Permission.fromMap(maps[i]));
  }
  
  Future<int> createPermission(Permission permission) async {
    final db = await database;
    return await db.insert('permissions', permission.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  // Staff Methods
  Future<List<Staff>> getStaff() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('staff');
    return List.generate(maps.length, (i) => Staff.fromMap(maps[i]));
  }
  
  Future<List<Staff>> searchStaff(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('staff', where: 'name LIKE ? OR email LIKE ?', whereArgs: ['%$query%', '%$query%']);
    return List.generate(maps.length, (i) => Staff.fromMap(maps[i]));
  }
  
  Future<int> createStaff(Staff staff) async {
    final db = await database;
    return await db.insert('staff', staff.toMap());
  }

  Future<int> updateStaff(Staff staff) async {
    final db = await database;
    return await db.update('staff', staff.toMap(), where: 'id = ?', whereArgs: [staff.id]);
  }

  Future<int> deleteStaff(int id) async {
    final db = await database;
    return await db.delete('staff', where: 'id = ?', whereArgs: [id]);
  }

  Future<Staff?> getStaffById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('staff', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Staff.fromMap(maps.first);
    }
    return null;
  }

  // Subject Methods
  Future<List<Subject>> getSubjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects');
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }
  
  Future<List<Subject>> searchSubjects(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects', where: 'name LIKE ?', whereArgs: ['%$query%']);
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }

  Future<Subject?> getSubjectByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects', where: 'name = ?', whereArgs: [name]);
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    }
    return null;
  }
  
  Future<Subject?> getSubjectBySubjectId(String subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects', where: 'id = ?', whereArgs: [int.parse(subjectId)]);
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    }
    return null;
  }

  Future<int> createSubject(Subject subject) async {
    final db = await database;
    return await db.insert('subjects', subject.toMap());
  }
  
  Future<int> updateSubject(Subject subject) async {
    final db = await database;
    return await db.update('subjects', subject.toMap(), where: 'id = ?', whereArgs: [subject.id]);
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Subject>> getSubjectsForClass(int classId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects', where: 'classId = ?', whereArgs: [classId]);
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }
  
  Future<Subject?> getSubjectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects', where: 'id = ?', whereArgs: [id]);
    if(maps.isNotEmpty){
      return Subject.fromMap(maps.first);
    }
    return null;
  }
  
  // Teacher Methods
  Future<List<Teacher>> getTeachers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('teachers');
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }
  
  Future<int> createTeacher(Teacher teacher) async {
    final db = await database;
    return await db.insert('teachers', teacher.toMap());
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await database;
    return await db.update('teachers', teacher.toMap(), where: 'id = ?', whereArgs: [teacher.id]);
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<List<Teacher>> searchTeachers(String query, {String? subject}) async {
    final db = await database;
    if (subject != null && subject.isNotEmpty) {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT t.* FROM teachers t
        INNER JOIN subjects s ON s.teacherId = t.id
        WHERE (t.name LIKE ? OR t.email LIKE ?) AND s.name LIKE ?
      ''', ['%$query%', '%$query%', '%$subject%']);
      return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
    } else {
      final List<Map<String, dynamic>> maps = await db.query(
        'teachers',
        where: 'name LIKE ? OR email LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
    }
  }

  Future<List<Teacher>> getTeachersForClass(int classId) async {
    // This requires a join with subjects table.
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM teachers t
      INNER JOIN subjects s ON s.teacherId = t.id
      WHERE s.classId = ?
    ''', [classId]);
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  Future<Teacher?> getTeacherByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('teachers', where: 'userId = ?', whereArgs: [userId]);
    if (maps.isNotEmpty) {
      return Teacher.fromMap(maps.first);
    }
    return null;
  }
  
  // Timetable methods
  Future<List<TimetableEntry>> getTimetableEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('timetables');
    return List.generate(maps.length, (i) => TimetableEntry.fromMap(maps[i]));
  }
  
  Future<List<TimetableEntry>> getTimetableByClassId(int classId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('timetables', where: 'classId = ?', whereArgs: [classId]);
    return List.generate(maps.length, (i) => TimetableEntry.fromMap(maps[i]));
  }
  
  Future<List<TimetableEntry>> getTimetableEntriesByTeacher(int teacherId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('timetables', where: 'teacherId = ?', whereArgs: [teacherId]);
    return List.generate(maps.length, (i) => TimetableEntry.fromMap(maps[i]));
  }

  Future<int> insertTimetableEntry(TimetableEntry entry) async {
    final db = await database;
    return await db.insert('timetables', entry.toMap());
  }

  Future<int> updateTimetableEntry(TimetableEntry entry) async {
    final db = await database;
    return await db.update('timetables', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteTimetableEntry(int id) async {
    final db = await database;
    return await db.delete('timetables', where: 'id = ?', whereArgs: [id]);
  }
}