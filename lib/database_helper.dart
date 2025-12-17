import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'student_model.dart';
import 'teacher_model.dart';
import 'class_model.dart';
import 'subject_model.dart';
import 'grade_model.dart';
import 'attendance_model.dart';
import 'timetable_model.dart';
import 'user_model.dart';
import 'academic_year_model.dart';
import 'leave_model.dart'; // Import Leave model
import 'performance_evaluation_model.dart'; // Import PerformanceEvaluation model
import 'event_model.dart'; // Import Event model
import 'staff_model.dart'; // Import Staff model
import 'book_model.dart'; // Import Book model
import 'borrow_record_model.dart'; // Import BorrowRecord model

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
        version: 22,
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
      )
    ''');
      await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        phone TEXT NOT NULL,
        grade TEXT NOT NULL,
        email TEXT UNIQUE,
        password TEXT,
        classId INTEGER,
        academicNumber TEXT,
        section TEXT,
        parentName TEXT,
        parentPhone TEXT,
        address TEXT,
        status INTEGER NOT NULL DEFAULT 1,
        parentUserId INTEGER,
        userId INTEGER UNIQUE
      )
    ''');
      await db.execute('''
      CREATE TABLE teachers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        subject TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT UNIQUE,
        password TEXT,
        qualificationType TEXT,
        responsibleClassId INTEGER,
        userId INTEGER UNIQUE
      )
    ''');
      await db.execute('''
      CREATE TABLE classes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        classId TEXT NOT NULL UNIQUE,
        teacherId INTEGER,
        capacity INTEGER,
        yearTerm TEXT,
        subjectIds TEXT
      )
    ''');
      await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        subjectId TEXT NOT NULL UNIQUE,
        description TEXT,
        teacherId INTEGER,
        curriculumDescription TEXT,
        learningObjectives TEXT,
        recommendedResources TEXT
      )
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
      )
    ''');
      await db.execute('''
      CREATE TABLE attendance(
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
      await db.execute('''
      CREATE TABLE timetable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        teacherId INTEGER NOT NULL,
        dayOfWeek TEXT NOT NULL, 
        lessonNumber INTEGER NOT NULL,
        startTime TEXT NOT NULL, 
        endTime TEXT NOT NULL, 
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE CASCADE
      )
    ''');

      await db.execute('''
      CREATE TABLE academic_years(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0
      )
    ''');

      await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        location TEXT NOT NULL,
        eventType TEXT NOT NULL,
        attendeeRoles TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE staff(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        department TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT,
        hireDate TEXT NOT NULL,
        salary REAL NOT NULL,
        userId INTEGER UNIQUE
      )
    ''');

      await db.execute('''
      CREATE TABLE leaves(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staffId INTEGER NOT NULL,
        leaveType TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pending',
        approvedByUserId INTEGER,
        rejectionReason TEXT,
        FOREIGN KEY (staffId) REFERENCES staff (id) ON DELETE CASCADE
      )
    ''');

      await db.execute('''
      CREATE TABLE performance_evaluations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staffId INTEGER NOT NULL,
        evaluationDate TEXT NOT NULL,
        evaluatorUserId INTEGER NOT NULL,
        overallRating TEXT NOT NULL,
        comments TEXT NOT NULL,
        areasForImprovement TEXT,
        developmentGoals TEXT,
        FOREIGN KEY (staffId) REFERENCES staff (id) ON DELETE CASCADE,
        FOREIGN KEY (evaluatorUserId) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        isbn TEXT UNIQUE,
        quantity INTEGER NOT NULL DEFAULT 0,
        availableQuantity INTEGER NOT NULL DEFAULT 0,
        shelfLocation TEXT,
        category TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE borrow_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        studentId INTEGER NOT NULL,
        borrowDate TEXT NOT NULL,
        returnDate TEXT,
        status TEXT NOT NULL,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

      await _insertInitialAdmin(db);
      developer.log(
        'DatabaseHelper: All tables created and initial admin inserted.',
        name: 'DatabaseHelper',
      );
    } catch (e, s) {
      developer.log(
        'DatabaseHelper: Error during _onCreate table creation',
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
      'DatabaseHelper: _onUpgrade called from version $oldVersion to $newVersion',
      name: 'DatabaseHelper',
    );
    try {
      if (oldVersion < 15) {
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
      }
      if (oldVersion < 16) {
        await db.execute('ALTER TABLE students ADD COLUMN userId INTEGER UNIQUE');
        await db.execute('ALTER TABLE teachers ADD COLUMN userId INTEGER UNIQUE');
      }
      if (oldVersion < 17) {
        await db.execute('ALTER TABLE subjects ADD COLUMN curriculumDescription TEXT');
        await db.execute('ALTER TABLE subjects ADD COLUMN learningObjectives TEXT');
        await db.execute('ALTER TABLE subjects ADD COLUMN recommendedResources TEXT');
      }
      if (oldVersion < 18) {
        await db.execute('''
          CREATE TABLE events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            date TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            location TEXT NOT NULL,
            eventType TEXT NOT NULL,
            attendeeRoles TEXT NOT NULL
          )
        ''');
      }
      if (oldVersion < 19) {
        await db.execute('''
          CREATE TABLE staff(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            position TEXT NOT NULL,
            department TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            address TEXT,
            hireDate TEXT NOT NULL,
            salary REAL NOT NULL,
            userId INTEGER UNIQUE
          )
        ''');
      }
      if (oldVersion < 20) {
        await db.execute('''
          CREATE TABLE leaves(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            staffId INTEGER NOT NULL,
            leaveType TEXT NOT NULL,
            startDate TEXT NOT NULL,
            endDate TEXT NOT NULL,
            reason TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'Pending',
            approvedByUserId INTEGER,
            rejectionReason TEXT,
            FOREIGN KEY (staffId) REFERENCES staff (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE performance_evaluations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            staffId INTEGER NOT NULL,
            evaluationDate TEXT NOT NULL,
            evaluatorUserId INTEGER NOT NULL,
            overallRating TEXT NOT NULL,
            comments TEXT NOT NULL,
            areasForImprovement TEXT,
            developmentGoals TEXT,
            FOREIGN KEY (staffId) REFERENCES staff (id) ON DELETE CASCADE,
            FOREIGN KEY (evaluatorUserId) REFERENCES users (id) ON DELETE SET NULL
          )
        ''');
      }
      if (oldVersion < 21) {
        await db.execute('''
          CREATE TABLE borrow_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bookId INTEGER NOT NULL,
            studentId INTEGER NOT NULL,
            borrowDate TEXT NOT NULL,
            returnDate TEXT,
            status TEXT NOT NULL,
            FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE,
            FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE
          )
        ''');
      }
      if (oldVersion < 22) {
        // Rename old grades table
        await db.execute('ALTER TABLE grades RENAME TO grades_old');

        // Create new grades table with semester1Grade and semester2Grade
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
          )
        ''');

        // Copy data from old table to new table
        // For existing records, set semester1Grade to old gradeValue and semester2Grade to NULL
        await db.execute('''
          INSERT INTO grades (id, studentId, subjectId, classId, assessmentType, semester1Grade, semester2Grade, weight)
          SELECT id, studentId, subjectId, classId, assessmentType, gradeValue, NULL, weight FROM grades_old
        ''');

        // Drop the old table
        await db.execute('DROP TABLE grades_old');
      }
    } catch (e, s) {
      developer.log(
        'DatabaseHelper: Error during _onUpgrade table migration',
        name: 'DatabaseHelper',
        level: 1000,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _insertInitialAdmin(Database db) async {
    developer.log(
      'DatabaseHelper: Checking for initial admin user...',
      name: 'DatabaseHelper',
    );
    final count = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM users"),
    );
    if (count == 0) {
      developer.log(
        'DatabaseHelper: No users found, inserting default admin.',
        name: 'DatabaseHelper',
      );
      final adminUser = User(
        username: 'admin',
        passwordHash: _hashPassword('admin123'),
        role: 'admin',
      );
      await db.insert('users', adminUser.toMap());
      developer.log(
        'DatabaseHelper: Default admin user inserted.',
        name: 'DatabaseHelper',
      );
    } else {
      developer.log(
        'DatabaseHelper: Admin user already exists.',
        name: 'DatabaseHelper',
      );
    }
  }

  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> createStudent(Student student) async {
    final db = await database;
    return await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<List<Student>> getStudentsByParentUserId(int parentUserId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'parentUserId = ?',
      whereArgs: [parentUserId],
    );
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Student>> searchStudents(
    String nameQuery, {
    String? classId,
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (nameQuery.isNotEmpty) {
      whereClauses.add('name LIKE ? OR academicNumber LIKE ?');
      whereArgs.add('%$nameQuery%');
      whereArgs.add('%$nameQuery%');
    }

    if (classId != null && classId.isNotEmpty) {
      whereClauses.add('classId = ?');
      whereArgs.add(classId);
    }

    String whereString = whereClauses.isEmpty ? '' : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  Future<Student?> getStudentByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Student?> getStudentByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> createTeacher(Teacher teacher) async {
    final db = await database;
    return await db.insert('teachers', teacher.toMap());
  }

  Future<List<Teacher>> getTeachers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('teachers');
    return List.generate(maps.length, (i) {
      return Teacher.fromMap(maps[i]);
    });
  }

  Future<Teacher?> getTeacherByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return Teacher.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await database;
    return await db.update(
      'teachers',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Teacher>> searchTeachers(String name, {String? subject}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (name.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      whereArgs.add('%$name%');
    }

    if (subject != null && subject.isNotEmpty) {
      whereClauses.add('subject LIKE ?');
      whereArgs.add('%$subject%');
    }

    String whereString = whereClauses.isEmpty ? '' : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    return List.generate(maps.length, (i) {
      return Teacher.fromMap(maps[i]);
    });
  }

  Future<int> createClass(SchoolClass schoolClass) async {
    final db = await database;
    return await db.insert(
      'classes',
      schoolClass.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SchoolClass>> getClasses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classes');
    return List.generate(maps.length, (i) {
      return SchoolClass.fromMap(maps[i]);
    });
  }

  Future<SchoolClass?> getClassById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SchoolClass.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<SchoolClass?> getClassByClassIdString(String classId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'classId = ?',
      whereArgs: [classId],
    );
    if (maps.isNotEmpty) {
      return SchoolClass.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateClass(SchoolClass schoolClass) async {
    final db = await database;
    return await db.update(
      'classes',
      schoolClass.toMap(),
      where: 'id = ?',
      whereArgs: [schoolClass.id],
    );
  }

  Future<int> deleteClass(int id) async {
    final db = await database;
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SchoolClass>> searchClasses(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'name LIKE ? OR classId LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return SchoolClass.fromMap(maps[i]);
    });
  }

  Future<int> createSubject(Subject subject) async {
    final db = await database;
    return await db.insert(
      'subjects',
      subject.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Subject>> getSubjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('subjects');
    return List.generate(maps.length, (i) {
      return Subject.fromMap(maps[i]);
    });
  }

  Future<Subject?> getSubjectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await database;
    return await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Subject>> searchSubjects(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'name LIKE ? OR subjectId LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Subject.fromMap(maps[i]);
    });
  }

  Future<Subject?> getSubjectByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Subject?> getSubjectBySubjectId(String subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> createGrade(Grade grade) async {
    final db = await database;
    return await db.insert(
      'grades',
      grade.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Grade>> getGrades() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('grades');
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<int> updateGrade(Grade grade) async {
    final db = await database;
    return await db.update(
      'grades',
      grade.toMap(),
      where: 'id = ?',
      whereArgs: [grade.id],
    );
  }

  Future<int> deleteGrade(int id) async {
    final db = await database;
    return await db.delete('grades', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Grade>> getGradesByStudent(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grades',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<List<Grade>> getGradesByClass(int classId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grades',
      where: 'classId = ?',
      whereArgs: [classId],
    );
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<List<Grade>> getGradesBySubject(int subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grades',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<List<Grade>> getGradesByClassAndSubject(
      int classId, int subjectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grades',
      where: 'classId = ? AND subjectId = ?',
      whereArgs: [classId, subjectId],
    );
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  Future<void> upsertGrades(List<Grade> grades) async {
    if (grades.isEmpty) return;
    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final grade in grades) {
        if (grade.id != null) {
          // If grade has an id, it means it's an existing one to be updated.
          batch.update(
            'grades',
            grade.toMap(),
            where: 'id = ?',
            whereArgs: [grade.id],
          );
        } else {
          // If grade has no id, it's a new one to be inserted.
          batch.insert(
            'grades',
            grade.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Map<String, dynamic>>> getAverageGradesBySubject() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT
        s.name AS subjectName,
        AVG((COALESCE(g.semester1Grade, 0) + COALESCE(g.semester2Grade, 0)) / 2 * g.weight) / AVG(g.weight) AS averageGrade
      FROM grades g
      JOIN subjects s ON g.subjectId = s.id
      GROUP BY s.name
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAverageGradesForClass(int classId) async {
    final db = await database;
    // This query calculates the weighted average grade for each subject in a specific class
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        s.name AS subjectName,
        SUM((COALESCE(g.semester1Grade, 0) + COALESCE(g.semester2Grade, 0)) / 2 * g.weight) / SUM(g.weight) AS averageGrade
      FROM grades g
      JOIN subjects s ON g.subjectId = s.id
      WHERE g.classId = ?
      GROUP BY s.name
      HAVING SUM(g.weight) > 0
    ''', [classId]);
    return result;
  }

  Future<int> createAttendance(Attendance attendance) async {
    final db = await database;
    return await db.insert(
      'attendance',
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Attendance>> getAttendances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('attendance');
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await database;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
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
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (date != null && date.isNotEmpty) {
      whereClauses.add('date = ?');
      whereArgs.add(date);
    }
    if (classId != null) {
      whereClauses.add('classId = ?');
      whereArgs.add(classId);
    }
    if (subjectId != null) {
      whereClauses.add('subjectId = ?');
      whereArgs.add(subjectId);
    }
    if (teacherId != null) {
      whereClauses.add('teacherId = ?');
      whereArgs.add(teacherId);
    }
    if (studentId != null) {
      whereClauses.add('studentId = ?');
      whereArgs.add(studentId);
    }
    if (lessonNumber != null) {
      whereClauses.add('lessonNumber = ?');
      whereArgs.add(lessonNumber);
    }

    String whereString = whereClauses.isEmpty ? '' : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  Future<List<Attendance>> getAttendancesByStudent(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  Future<void> bulkUpsertAttendances(
    List<Attendance> toUpdate,
    List<Attendance> toInsert,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final attendance in toUpdate) {
        batch.update(
          'attendance',
          attendance.toMap(),
          where: 'id = ?',
          whereArgs: [attendance.id],
        );
      }
      for (final attendance in toInsert) {
        batch.insert(
          'attendance',
          attendance.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> insertTimetableEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert(
      'timetable',
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TimetableEntry>> getTimetableEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('timetable');
    return List.generate(maps.length, (i) {
      return TimetableEntry.fromMap(maps[i]);
    });
  }

  Future<List<TimetableEntry>> getTimetableByClassId(
    int classId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'timetable',
      where: 'classId = ?',
      whereArgs: [classId],
      orderBy: 'dayOfWeek ASC, lessonNumber ASC',
    );
    return List.generate(maps.length, (i) {
      return TimetableEntry.fromMap(maps[i]);
    });
  }

  Future<List<TimetableEntry>> getTimetableEntriesByTeacher(
    int teacherId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'timetable',
      where: 'teacherId = ?',
      whereArgs: [teacherId],
      orderBy: 'dayOfWeek ASC, lessonNumber ASC',
    );
    return List.generate(maps.length, (i) {
      return TimetableEntry.fromMap(maps[i]);
    });
  }

  Future<List<TimetableEntry>> getTimetableEntriesByClass(
    int classId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'timetable',
      where: 'classId = ?',
      whereArgs: [classId],
      orderBy: 'dayOfWeek ASC, lessonNumber ASC',
    );
    return List.generate(maps.length, (i) {
      return TimetableEntry.fromMap(maps[i]);
    });
  }

  Future<int> updateTimetableEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.update(
      'timetable',
      entry,
      where: 'id = ?',
      whereArgs: [entry['id']],
    );
  }

  Future<int> deleteTimetableEntry(int id) async {
    final db = await database;
    return await db.delete('timetable', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TimetableEntry>> getTimetableEntriesByFilters({
    int? classId,
    String? dayOfWeek,
    int? teacherId,
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (classId != null) {
      whereClauses.add('classId = ?');
      whereArgs.add(classId);
    }
    if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
      whereClauses.add('dayOfWeek = ?');
      whereArgs.add(dayOfWeek);
    }
    if (teacherId != null) {
      whereClauses.add('teacherId = ?');
      whereArgs.add(teacherId);
    }

    String whereString = whereClauses.isEmpty ? '' : whereClauses.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'timetable',
      where: whereString.isEmpty ? null : whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'lessonNumber ASC',
    );
    return List.generate(maps.length, (i) {
      return TimetableEntry.fromMap(maps[i]);
    });
  }

  Future<List<Subject>> getSubjectsForClass(int classId) async {
    final db = await database;
    final List<Map<String, dynamic>> timetableMaps = await db.query(
      'timetable',
      distinct: true,
      columns: ['subjectId'],
      where: 'classId = ?',
      whereArgs: [classId],
    );

    if (timetableMaps.isEmpty) {
      return [];
    }

    List<int> subjectIds = timetableMaps.map((map) => map['subjectId'] as int).toList();
    
    final List<Map<String, dynamic>> subjectMaps = await db.query(
      'subjects',
      where: 'id IN (${subjectIds.map((_) => '?').join(',')})',
      whereArgs: subjectIds,
    );

    return List.generate(subjectMaps.length, (i) {
      return Subject.fromMap(subjectMaps[i]);
    });
  }

  Future<List<Teacher>> getTeachersForClass(int classId) async {
    final db = await database;
    final List<Map<String, dynamic>> timetableMaps = await db.query(
      'timetable',
      distinct: true,
      columns: ['teacherId'],
      where: 'classId = ?',
      whereArgs: [classId],
    );

    if (timetableMaps.isEmpty) {
      return [];
    }

    List<int> teacherIds = timetableMaps.map((map) => map['teacherId'] as int).toList();

    final List<Map<String, dynamic>> teacherMaps = await db.query(
      'teachers',
      where: 'id IN (${teacherIds.map((_) => '?').join(',')})',
      whereArgs: teacherIds,
    );

    return List.generate(teacherMaps.length, (i) {
      return Teacher.fromMap(teacherMaps[i]);
    });
  }

  Future<int> createAcademicYear(AcademicYear academicYear) async {
    final db = await database;
    return await db.insert('academic_years', academicYear.toMap());
  }

  Future<List<AcademicYear>> getAcademicYears() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('academic_years');
    return List.generate(maps.length, (i) {
      return AcademicYear.fromMap(maps[i]);
    });
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
    return await db.delete('academic_years', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setActiveAcademicYear(AcademicYear academicYear) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('academic_years', {'is_active': 0}, where: 'is_active = 1');
      await txn.update(
        'academic_years',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [academicYear.id],
      );
    });
  }

  // Event Methods
  Future<int> createEvent(Event event) async {
    final db = await database;
    return await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<Event?> getEventById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateEvent(Event event) async {
    final db = await database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Event>> searchEvents(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'title LIKE ? OR description LIKE ? OR location LIKE ? OR eventType LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'date ASC, startTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  // Staff Methods
  Future<int> createStaff(Staff staff) async {
    final db = await database;
    return await db.insert(
      'staff',
      staff.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Staff>> getStaff() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('staff');
    return List.generate(maps.length, (i) {
      return Staff.fromMap(maps[i]);
    });
  }

  Future<Staff?> getStaffById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Staff.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateStaff(Staff staff) async {
    final db = await database;
    return await db.update(
      'staff',
      staff.toMap(),
      where: 'id = ?',
      whereArgs: [staff.id],
    );
  }

  Future<int> deleteStaff(int id) async {
    final db = await database;
    return await db.delete('staff', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Staff>> searchStaff(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff',
      where: 'name LIKE ? OR position LIKE ? OR department LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Staff.fromMap(maps[i]);
    });
  }

  // Leave Methods
  Future<int> createLeave(Leave leave) async {
    final db = await database;
    return await db.insert(
      'leaves',
      leave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Leave>> getLeaves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('leaves');
    return List.generate(maps.length, (i) {
      return Leave.fromMap(maps[i]);
    });
  }

  Future<Leave?> getLeaveById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leaves',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Leave.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateLeave(Leave leave) async {
    final db = await database;
    return await db.update(
      'leaves',
      leave.toMap(),
      where: 'id = ?',
      whereArgs: [leave.id],
    );
  }

  Future<int> deleteLeave(int id) async {
    final db = await database;
    return await db.delete('leaves', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Leave>> getLeavesByStaffId(int staffId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leaves',
      where: 'staffId = ?',
      whereArgs: [staffId],
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) {
      return Leave.fromMap(maps[i]);
    });
  }

  Future<List<Leave>> searchLeaves(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leaves',
      where: 'leaveType LIKE ? OR reason LIKE ? OR status LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) {
      return Leave.fromMap(maps[i]);
    });
  }

  // PerformanceEvaluation Methods
  Future<int> createPerformanceEvaluation(PerformanceEvaluation evaluation) async {
    final db = await database;
    return await db.insert(
      'performance_evaluations',
      evaluation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PerformanceEvaluation>> getPerformanceEvaluations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('performance_evaluations');
    return List.generate(maps.length, (i) {
      return PerformanceEvaluation.fromMap(maps[i]);
    });
  }

  Future<PerformanceEvaluation?> getPerformanceEvaluationById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'performance_evaluations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PerformanceEvaluation.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updatePerformanceEvaluation(PerformanceEvaluation evaluation) async {
    final db = await database;
    return await db.update(
      'performance_evaluations',
      evaluation.toMap(),
      where: 'id = ?',
      whereArgs: [evaluation.id],
    );
  }

  Future<int> deletePerformanceEvaluation(int id) async {
    final db = await database;
    return await db.delete('performance_evaluations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PerformanceEvaluation>> getPerformanceEvaluationsByStaffId(int staffId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'performance_evaluations',
      where: 'staffId = ?',
      whereArgs: [staffId],
      orderBy: 'evaluationDate DESC',
    );
    return List.generate(maps.length, (i) {
      return PerformanceEvaluation.fromMap(maps[i]);
    });
  }

  Future<List<PerformanceEvaluation>> searchPerformanceEvaluations(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'performance_evaluations',
      where: 'overallRating LIKE ? OR comments LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'evaluationDate DESC',
    );
    return List.generate(maps.length, (i) {
      return PerformanceEvaluation.fromMap(maps[i]);
    });
  }

  // BorrowRecord Methods
  Future<int> createBorrowRecord(BorrowRecord record) async {
    final db = await database;
    return await db.insert(
      'borrow_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BorrowRecord>> getBorrowRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('borrow_records');
    return List.generate(maps.length, (i) {
      return BorrowRecord.fromMap(maps[i]);
    });
  }

  Future<BorrowRecord?> getBorrowRecordById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'borrow_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return BorrowRecord.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBorrowRecord(BorrowRecord record) async {
    final db = await database;
    return await db.update(
      'borrow_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteBorrowRecord(int id) async {
    final db = await database;
    return await db.delete('borrow_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BorrowRecord>> getBorrowRecordsByStudentId(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'borrow_records',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'borrowDate DESC',
    );
    return List.generate(maps.length, (i) {
      return BorrowRecord.fromMap(maps[i]);
    });
  }

  Future<List<BorrowRecord>> getBorrowRecordsByBookId(int bookId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'borrow_records',
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'borrowDate DESC',
    );
    return List.generate(maps.length, (i) {
      return BorrowRecord.fromMap(maps[i]);
    });
  }

  Future<List<BorrowRecord>> searchBorrowRecords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'borrow_records',
      where: 'status LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'borrowDate DESC',
    );
    return List.generate(maps.length, (i) {
      return BorrowRecord.fromMap(maps[i]);
    });
  }

  // Book Methods
  Future<int> createBook(Book book) async {
    final db = await database;
    return await db.insert(
      'books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<Book?> getBookById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Book>> searchBooks(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ? OR isbn LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }
}
