import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/providers/student_provider.dart';
import 'package:myapp/student_model.dart';

import 'student_provider_test.mocks.dart';

// Generate a MockClient using the Mockito package.
@GenerateMocks([DatabaseHelper])
void main() {
  late StudentProvider studentProvider;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    studentProvider = StudentProvider(databaseHelper: mockDatabaseHelper);
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
      when(
        mockDatabaseHelper.getStudents(),
      ).thenAnswer((_) async => tStudentList);

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
      when(
        mockDatabaseHelper.getStudents(),
      ).thenAnswer((_) async => tStudentList);

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
      when(
        mockDatabaseHelper.getStudents(),
      ).thenAnswer((_) async => tStudentList);

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
      when(
        mockDatabaseHelper.getStudents(),
      ).thenAnswer((_) async => []); // After deleting, list should be empty

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
      when(
        mockDatabaseHelper.searchStudents('Test'),
      ).thenAnswer((_) async => searchResult);

      // act
      await studentProvider.searchStudents('Test');

      // assert
      verify(mockDatabaseHelper.searchStudents('Test'));
      expect(studentProvider.students, searchResult);
    });

    test('should call fetchStudents when query is empty', () async {
      // arrange
      when(
        mockDatabaseHelper.searchStudents('', classId: null),
      ).thenAnswer((_) async => tStudentList);

      // act
      await studentProvider.searchStudents('');

      // assert
      verify(mockDatabaseHelper.searchStudents('', classId: null));
      expect(studentProvider.students, tStudentList);
    });
  });
}
