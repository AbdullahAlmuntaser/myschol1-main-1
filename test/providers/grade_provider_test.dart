import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/providers/grade_provider.dart';
import 'package:myapp/grade_model.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/services/local_auth_service.dart';
import 'package:myapp/user_model.dart';

import 'grade_provider_test.mocks.dart';

@GenerateMocks([DatabaseHelper, LocalAuthService])
void main() {
  late GradeProvider gradeProvider;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockLocalAuthService mockAuthService;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockAuthService = MockLocalAuthService();
    gradeProvider = GradeProvider(
      databaseHelper: mockDatabaseHelper,
      authService: mockAuthService,
    );

    // Mock a logged-in admin user for authorization checks
    final adminUser = User(id: 1, username: 'admin', role: 'admin', passwordHash: 'hashed_password');
    when(mockAuthService.currentUser).thenReturn(adminUser);
  });

  final tGrade = Grade(
    id: 1,
    studentId: 1,
    subjectId: 1,
    classId: 1,
    assessmentType: 'Test',
    semester1Grade: 95.0,
    semester2Grade: 90.0,
    weight: 0.5,
  );
  final tGradeList = [tGrade];

  group('GradeProvider Tests', () {
    test('fetchGrades should get grades from the database', () async {
      // Arrange
      when(mockDatabaseHelper.getGrades()).thenAnswer((_) async => tGradeList);

      // Act
      await gradeProvider.fetchGrades();

      // Assert
      expect(gradeProvider.grades, tGradeList);
      verify(mockDatabaseHelper.getGrades());
      verifyNoMoreInteractions(mockDatabaseHelper);
    });

    test(
        'getGradesByClassAndSubject should call the corresponding method in DatabaseHelper',
        () async {
      // Arrange
      when(mockDatabaseHelper.getGradesByClassAndSubject(any, any))
          .thenAnswer((_) async => tGradeList);

      // Act
      final result = await gradeProvider.getGradesByClassAndSubject(1, 1);

      // Assert
      expect(result, tGradeList);
      verify(mockDatabaseHelper.getGradesByClassAndSubject(1, 1));
      verifyNoMoreInteractions(mockDatabaseHelper);
    });

    test('upsertGrades should call the database and then refresh the grades list',
        () async {
      // Arrange
      when(mockDatabaseHelper.upsertGrades(any)).thenAnswer((_) async => Future.value());
      when(mockDatabaseHelper.getGrades()).thenAnswer((_) async => tGradeList);

      // Act
      await gradeProvider.upsertGrades(tGradeList);

      // Assert
      verify(mockDatabaseHelper.upsertGrades(tGradeList)).called(1);
      verify(mockDatabaseHelper.getGrades()).called(1);
      expect(gradeProvider.grades, tGradeList);
    });

     test('addGrade should call the database and refresh the list', () async {
      // Arrange
      when(mockDatabaseHelper.createGrade(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getGrades()).thenAnswer((_) async => tGradeList);

      // Act
      await gradeProvider.addGrade(tGrade);

      // Assert
      verify(mockDatabaseHelper.createGrade(tGrade));
      verify(mockDatabaseHelper.getGrades());
      expect(gradeProvider.grades, tGradeList);
    });

    test('updateGrade should call the database and refresh the list', () async {
      // Arrange
      when(mockDatabaseHelper.updateGrade(any)).thenAnswer((_) async => 1);
       when(mockDatabaseHelper.getGrades()).thenAnswer((_) async => tGradeList);

      // Act
      await gradeProvider.updateGrade(tGrade);

      // Assert
      verify(mockDatabaseHelper.updateGrade(tGrade));
      verify(mockDatabaseHelper.getGrades());
      expect(gradeProvider.grades, tGradeList);
    });

    test('deleteGrade should call the database and refresh the list', () async {
      // Arrange
      when(mockDatabaseHelper.deleteGrade(any)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getGrades()).thenAnswer((_) async => []);

      // Act
      await gradeProvider.deleteGrade(1);

      // Assert
      verify(mockDatabaseHelper.deleteGrade(1));
      verify(mockDatabaseHelper.getGrades());
      expect(gradeProvider.grades, []);
    });

    test('addGrade should throw exception if user is not admin', () async {
      // Arrange
      when(mockAuthService.currentUser).thenReturn(User(id: 2, username: 'student', role: 'student', passwordHash: 'hashed_password'));

      // Act & Assert
      expect(() => gradeProvider.addGrade(tGrade), throwsException);
    });
  });
}
