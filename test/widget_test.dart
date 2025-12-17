import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/providers/attendance_provider.dart';
import 'package:myapp/providers/class_provider.dart';
import 'package:myapp/providers/grade_provider.dart';
import 'package:myapp/providers/student_provider.dart';
import 'package:myapp/providers/subject_provider.dart';
import 'package:myapp/providers/teacher_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/services/local_auth_service.dart';
import 'package:myapp/student_model.dart';
import 'package:myapp/user_model.dart';
import 'package:provider/provider.dart';

import 'mock_generator_test.mocks.dart';
import 'screens/dashboard_screen_test.mocks.dart';

void main() {
  late MockStudentProvider mockStudentProvider;
  late MockTeacherProvider mockTeacherProvider;
  late MockClassProvider mockClassProvider;
  late MockSubjectProvider mockSubjectProvider;
  late MockThemeProvider mockThemeProvider;
  late MockAttendanceProvider mockAttendanceProvider;
  late MockGradeProvider mockGradeProvider;
  late MockLocalAuthService mockLocalAuthService;
  late User fakeAdmin;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockStudentProvider = MockStudentProvider();
    mockTeacherProvider = MockTeacherProvider();
    mockClassProvider = MockClassProvider();
    mockSubjectProvider = MockSubjectProvider();
    mockThemeProvider = MockThemeProvider();
    mockAttendanceProvider = MockAttendanceProvider();
    mockGradeProvider = MockGradeProvider();
    mockLocalAuthService = MockLocalAuthService();
    fakeAdmin = User(
      id: 1,
      username: 'admin',
      role: 'admin',
      passwordHash: 'password', // Add a dummy password hash
    );

    when(mockStudentProvider.students).thenReturn([]);
    when(mockTeacherProvider.teachers).thenReturn([]);
    when(mockClassProvider.classes).thenReturn([]);
    when(mockSubjectProvider.subjects).thenReturn([]);
    when(mockThemeProvider.themeMode).thenReturn(ThemeMode.light);
    when(mockAttendanceProvider.attendances).thenReturn([]);
    when(mockGradeProvider.grades).thenReturn([]);
    when(mockLocalAuthService.currentUser).thenReturn(fakeAdmin);

    when(mockStudentProvider.fetchStudents()).thenAnswer((_) async => []);
    when(mockTeacherProvider.fetchTeachers()).thenAnswer((_) async {});
    when(mockClassProvider.fetchClasses()).thenAnswer((_) async {});
    when(mockSubjectProvider.fetchSubjects()).thenAnswer((_) async {});
    when(mockAttendanceProvider.fetchAttendances()).thenAnswer((_) async => {});
    when(mockGradeProvider.fetchGrades()).thenAnswer((_) async {});
  });

  Widget createHomeScreen() {
    return SizedBox(
      height: 1200,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<StudentProvider>.value(
              value: mockStudentProvider),
          ChangeNotifierProvider<TeacherProvider>.value(
              value: mockTeacherProvider),
          ChangeNotifierProvider<ClassProvider>.value(value: mockClassProvider),
          ChangeNotifierProvider<SubjectProvider>.value(
              value: mockSubjectProvider),
          ChangeNotifierProvider<AttendanceProvider>.value(
              value: mockAttendanceProvider),
          ChangeNotifierProvider<GradeProvider>.value(value: mockGradeProvider),
          ChangeNotifierProvider<LocalAuthService>.value(
              value: mockLocalAuthService),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
  }

  testWidgets('Shows "No students found" message when list is empty', (
    WidgetTester tester,
  ) async {
    // Arrange
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => []);

    // Act
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle(); // Wait for async operations and animations

    // Assert
    expect(find.text('No students found.'), findsOneWidget);
    // The student list is inside a tab, so we need to find the specific tab content
    expect(find.byKey(const Key('students_tab_view')), findsOneWidget);
  });

  testWidgets('Shows a list of students when data is available', (
    WidgetTester tester,
  ) async {
    // Arrange
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    final studentList = [
      Student(
        id: 1,
        name: 'First Student',
        dob: '2001-01-01',
        phone: '111',
        grade: 'B',
      ),
    ];
    when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => studentList);

    // Act
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('No students found.'), findsNothing);
    expect(find.text('First Student'), findsOneWidget);
    expect(find.text('Grade: B | DOB: 2001-01-01'), findsOneWidget);
  });

  testWidgets('Tapping FAB navigates to AddEditStudentScreen', (
    WidgetTester tester,
  ) async {
    // Arrange
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    when(mockDatabaseHelper.getStudents()).thenAnswer((_) async => []);
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Add Student'), findsOneWidget);
  });
}
