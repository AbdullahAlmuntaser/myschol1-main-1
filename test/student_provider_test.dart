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

  test('initial students list should be empty', () {
    expect(studentProvider.students, []);
  });

  group('fetchStudents', () {
    test('should get students from the database', () async {
      // arrange
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);

      // act
      await studentProvider.fetchStudents();

      // assert
      expect(studentProvider.students, tStudentList);
      verify(mockDatabaseHelper.getStudents());
      verifyNoMoreInteractions(mockDatabaseHelper);
    });
  });

  group('addStudent', () {
    test('should call createStudent and then fetch students', () async {
      // arrange
      when(mockDatabaseHelper.createStudent(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);

      // act
      await studentProvider.addStudent(tStudent);

      // assert
      verify(mockDatabaseHelper.createStudent(tStudent));
      verify(mockDatabaseHelper.getStudents());
      expect(studentProvider.students, tStudentList);
    });
  });

  group('updateStudent', () {
    test('should call updateStudent and then fetch students', () async {
      // arrange
      when(mockDatabaseHelper.updateStudent(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => tStudentList);

      // act
      await studentProvider.updateStudent(tStudent);

      // assert
      verify(mockDatabaseHelper.updateStudent(tStudent));
      verify(mockDatabaseHelper.getStudents());
      expect(studentProvider.students, tStudentList);
    });
  });

  group('deleteStudent', () {
    test('should call deleteStudent and then fetch students', () async {
      // arrange
      when(mockDatabaseHelper.deleteStudent(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => []);

      // act
      await studentProvider.deleteStudent(tStudent.id!);

      // assert
      verify(mockDatabaseHelper.deleteStudent(tStudent.id!));
      verify(mockDatabaseHelper.getStudents());
      expect(studentProvider.students, []);
    });
  });

  group('searchStudents', () {
    test('should call searchStudents when query is not empty', () async {
      // arrange
      final searchResult = [tStudent];
      when(mockDatabaseHelper.searchStudents('Test')).thenAnswer((_) async => searchResult);

      // act
      await studentProvider.searchStudents('Test');

      // assert
      verify(mockDatabaseHelper.searchStudents('Test'));
      expect(studentProvider.students, searchResult);
    });

    test('should call fetchStudents when query is empty', () async {
      // arrange
      when(mockDatabaseHelper.searchStudents('', classId: null)).thenAnswer((_) async => tStudentList);

      // act
      await studentProvider.searchStudents('');

      // assert
      verify(mockDatabaseHelper.searchStudents('', classId: null));
      expect(studentProvider.students, tStudentList);
    });

    test('addStudent should throw exception if user is not admin', () async {
      // Arrange
      when(mockAuthService.currentUser).thenReturn(User(id: 2, username: 'student', role: 'student', passwordHash: 'hashed_password'));

      // Act & Assert
      expect(() => studentProvider.addStudent(tStudent), throwsException);
    });
  });
}
