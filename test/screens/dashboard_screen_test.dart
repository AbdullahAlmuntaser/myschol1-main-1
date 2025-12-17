import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/attendance_provider.dart';
import 'package:myapp/providers/class_provider.dart';
import 'package:myapp/providers/grade_provider.dart';
import 'package:myapp/providers/student_provider.dart';
import 'package:myapp/providers/subject_provider.dart';
import 'package:myapp/providers/teacher_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/timetable_provider.dart';
import 'package:myapp/screens/attendance_screen.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/grades_screen.dart';
import 'package:myapp/screens/timetable_screen.dart';
import 'package:myapp/screens/tabs/classes_tab.dart';
import 'package:myapp/screens/tabs/reports_tab.dart';
import 'package:myapp/screens/tabs/settings_tab.dart';
import 'package:myapp/screens/tabs/subjects_tab.dart';
import 'package:myapp/screens/tabs/teachers_tab.dart';
import 'package:myapp/services/local_auth_service.dart';
import 'package:myapp/user_model.dart';

import 'dashboard_screen_test.mocks.dart';

@GenerateMocks([
  StudentProvider,
  TeacherProvider,
  ClassProvider,
  SubjectProvider,
  ThemeProvider,
  AttendanceProvider,
  GradeProvider,
  LocalAuthService,
  TimetableProvider,
])
void main() {
  late MockStudentProvider mockStudentProvider;
  late MockTeacherProvider mockTeacherProvider;
  late MockClassProvider mockClassProvider;
  late MockSubjectProvider mockSubjectProvider;
  late MockThemeProvider mockThemeProvider;
  late MockAttendanceProvider mockAttendanceProvider;
  late MockGradeProvider mockGradeProvider;
  late MockLocalAuthService mockLocalAuthService;
  late MockTimetableProvider mockTimetableProvider;
  late User fakeAdmin;

  setUp(() {
    mockStudentProvider = MockStudentProvider();
    mockTeacherProvider = MockTeacherProvider();
    mockClassProvider = MockClassProvider();
    mockSubjectProvider = MockSubjectProvider();
    mockThemeProvider = MockThemeProvider();
    mockAttendanceProvider = MockAttendanceProvider();
    mockGradeProvider = MockGradeProvider();
    mockLocalAuthService = MockLocalAuthService();
    mockTimetableProvider = MockTimetableProvider();
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
    when(mockTimetableProvider.timetableEntries).thenReturn([]);

    when(mockStudentProvider.fetchStudents()).thenAnswer((_) async => []);
    when(mockTeacherProvider.fetchTeachers()).thenAnswer((_) async {});
    when(mockClassProvider.fetchClasses()).thenAnswer((_) async {});
    when(mockSubjectProvider.fetchSubjects()).thenAnswer((_) async {});
    when(mockAttendanceProvider.fetchAttendances()).thenAnswer((_) async => {});
    when(mockGradeProvider.fetchGrades()).thenAnswer((_) async {});
    when(mockTimetableProvider.fetchTimetableEntries()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return SizedBox(
      height: 1200,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<StudentProvider>(
            create: (_) => mockStudentProvider,
          ),
          ChangeNotifierProvider<TeacherProvider>(
            create: (_) => mockTeacherProvider,
          ),
          ChangeNotifierProvider<ClassProvider>(create: (_) => mockClassProvider),
          ChangeNotifierProvider<SubjectProvider>(
            create: (_) => mockSubjectProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => mockThemeProvider),
          ChangeNotifierProvider<AttendanceProvider>(
            create: (_) => mockAttendanceProvider,
          ),
          ChangeNotifierProvider<GradeProvider>(create: (_) => mockGradeProvider),
          ChangeNotifierProvider<LocalAuthService>(
            create: (_) => mockLocalAuthService,
          ),
          ChangeNotifierProvider<TimetableProvider>(
            create: (_) => mockTimetableProvider,
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
  }

  group('DashboardScreen', () {
    testWidgets('renders correctly and displays initial tab', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('مرحباً، admin'), findsOneWidget);
      expect(find.byType(DashboardSummary), findsOneWidget);

      verify(mockStudentProvider.fetchStudents()).called(1);
      verify(mockTeacherProvider.fetchTeachers()).called(1);
      verify(mockClassProvider.fetchClasses()).called(1);
      verify(mockSubjectProvider.fetchSubjects()).called(1);
    });

    testWidgets('navigates to Attendance tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceScreen), findsOneWidget);
      expect(find.byType(DashboardSummary), findsNothing);
    });

    testWidgets('navigates to Teachers tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.person_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(TeachersTab), findsOneWidget);
      expect(find.byType(DashboardSummary), findsNothing);
    });

    testWidgets('navigates to Classes tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.class_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ClassesTab), findsOneWidget);
      expect(find.byType(DashboardSummary), findsNothing);
    });

    testWidgets('navigates to Subjects tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.book_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(SubjectsTab), findsOneWidget);
      expect(find.byType(DashboardSummary), findsNothing);
    });

    testWidgets('navigates to Timetable tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(TimetableScreen), findsOneWidget);
      expect(find.byType(DashboardSummary), findsNothing);
    });

    testWidgets('navigates to Grades tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.grade_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(GradesScreen), findsOneWidget);
      expect(find.byType(DashboardSummary), findsNothing);
    });

    testWidgets('navigates to Settings tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsTab), findsOneWidget);
      expect(find.byType(DashboardSummary), findsNothing);
    });

    testWidgets('navigates to Reports tab when tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ReportsTab), findsOneWidget);
      expect(find.byType(DashboardSummary), findsNothing);
    });

    testWidgets('theme toggle switches theme mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.light);
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsNothing);

      await tester.tap(find.byIcon(Icons.dark_mode));
      verify(mockThemeProvider.toggleTheme(true)).called(1);

      // Simulate theme change for the next rebuild
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.dark);
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsNothing);

      await tester.tap(find.byIcon(Icons.light_mode));
      verify(mockThemeProvider.toggleTheme(false)).called(1);
    });
  });
}
