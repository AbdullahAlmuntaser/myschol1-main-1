import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/providers/student_provider.dart';
import 'package:myapp/services/local_auth_service.dart';
import 'package:myapp/student_model.dart';
import 'package:myapp/user_model.dart';

import 'student_provider_test.mocks.dart';

@GenerateMocks([DatabaseHelper, LocalAuthService])
void main() {
  late StudentProvider studentProvider;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockLocalAuthService mockAuthService;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockAuthService = MockLocalAuthService();
    studentProvider = StudentProvider(
      databaseHelper: mockDatabaseHelper,
      authService: mockAuthService,
    );

    // Mock a logged-in admin user for authorization checks
    final adminUser = User(id: 1, username: 'admin', role: 'admin', passwordHash: 'hashed_password');
    when(mockAuthService.currentUser).thenReturn(adminUser);
  });

  final tStudent = Student(
    id: 1,
    name: 'Test Student',
    dob: '2000-01-01',
    phone: '12345',
    grade: 'A',
  );
  final tStudentList = [tStudent];

  test('Initial state of students list should be empty', () {
    expect(studentProvider.students, []);
  });

  group('Database Operations', () {
    test('fetchStudents should get students from the database', () async {
      // Arrange
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);

      // Act
      await studentProvider.fetchStudents();

      // Assert
      expect(studentProvider.students, tStudentList);
      verify(mockDatabaseHelper.getStudents());
      verifyNoMoreInteractions(mockDatabaseHelper);
    });

    test('addStudent should call the database and refresh the list', () async {
      // Arrange
      when(mockDatabaseHelper.createStudent(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);

      // Act
      await studentProvider.addStudent(tStudent);

      // Assert
      verify(mockDatabaseHelper.createStudent(tStudent));
      verify(mockDatabaseHelper.getStudents());
      expect(studentProvider.students, tStudentList);
    });

    test('deleteStudent should call the database and refresh the list', () async {
      // Arrange
      when(mockDatabaseHelper.deleteStudent(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => []);

      // Act
      await studentProvider.deleteStudent(1);

      // Assert
      verify(mockDatabaseHelper.deleteStudent(1));
      verify(mockDatabaseHelper.getStudents());
      expect(studentProvider.students, []);
    });

    test('searchStudents should call the database with the correct query', () async {
      // Arrange
      when(mockDatabaseHelper.searchStudents(any)).thenAnswer((_) async => tStudentList);

      // Act
      await studentProvider.searchStudents('Test');

      // Assert
      expect(studentProvider.students, tStudentList);
      verify(mockDatabaseHelper.searchStudents('Test'));
    });

    test('addStudent should throw exception if user is not admin', () async {
      // Arrange
      when(mockAuthService.currentUser).thenReturn(User(id: 2, username: 'student', role: 'student', passwordHash: 'hashed_password'));

      // Act & Assert
      expect(() => studentProvider.addStudent(tStudent), throwsException);
    });
  });
}
