import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/class_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/grade_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/timetable_provider.dart';
import 'providers/event_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/leave_provider.dart'; // Import LeaveProvider
import 'providers/performance_evaluation_provider.dart'; // Import PerformanceEvaluationProvider
import 'providers/permission_provider.dart';
import 'database_helper.dart';
import 'screens/grades_screen.dart';
import 'screens/attendance_screen.dart';
import 'services/local_auth_service.dart';
import 'services/notification_service.dart'; // Import NotificationService
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_manage_users_screen.dart'; // New: Import AdminManageUsersScreen
import 'dart:developer' as developer;

final notificationService =
    NotificationService(); // Create an instance of NotificationService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  await notificationService.init(); // Initialize NotificationService
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('MyApp: build called.', name: 'MyApp');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalAuthService()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => GradeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()), // Add LeaveProvider
        ChangeNotifierProvider(create: (_) => PerformanceEvaluationProvider()), // Add PerformanceEvaluationProvider
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        Provider<NotificationService>.value(
          value: notificationService,
        ), // Provide NotificationService
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          developer.log(
            'MyApp: Building MaterialApp with themeMode: ${themeProvider.themeMode}',
            name: 'MyApp',
          );
          return MaterialApp(
            title: 'نظام إدارة الطلاب',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppInitializer(),
            routes: {
              GradesScreen.routeName: (context) => const GradesScreen(),
              AttendanceScreen.routeName: (context) => const AttendanceScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/admin_manage_users': (context) => const AdminManageUsersScreen(), // New: Admin Manage Users Screen
            },
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('ar', '')],
            locale: const Locale('ar', ''),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    developer.log('AppInitializer: initState called.', name: 'AppInitializer');
    _initializationFuture = _initializeProvidersAndAuth();
  }

  Future<void> _initializeProvidersAndAuth() async {
    developer.log(
      'AppInitializer: Initializing providers and authenticating...',
      name: 'AppInitializer',
    );

    // Initial delay to ensure context is ready
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    while (Provider.of<LocalAuthService>(
      context,
      listen: false,
    ).isSessionLoading) {
      developer.log(
        'AppInitializer: Waiting for authService.isSessionLoading to be false...',
        name: 'AppInitializer',
      );
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    final authService = Provider.of<LocalAuthService>(context, listen: false);
    developer.log(
      'AppInitializer: LocalAuthService isAuthenticated: ${authService.isAuthenticated}',
      name: 'AppInitializer',
    );

    if (authService.isAuthenticated && authService.currentUser != null) {
      developer.log(
        'AppInitializer: User is authenticated and currentUser is not null. Fetching data...',
        name: 'AppInitializer',
      );

      if (!mounted) return;
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      if (!mounted) return;
      final teacherProvider = Provider.of<TeacherProvider>(
        context,
        listen: false,
      );
      if (!mounted) return;
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      if (!mounted) return;
      final subjectProvider = Provider.of<SubjectProvider>(
        context,
        listen: false,
      );
      if (!mounted) return;
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
      if (!mounted) return;
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );
      if (!mounted) return;
      final timetableProvider = Provider.of<TimetableProvider>(
        context,
        listen: false,
      );
      if (!mounted) return;
      final eventProvider = Provider.of<EventProvider>(
        context,
        listen: false,
      );
      if (!mounted) return;
      final staffProvider = Provider.of<StaffProvider>(
        context,
        listen: false,
      );
      if (!mounted) return;
      final leaveProvider = Provider.of<LeaveProvider>(
        context,
        listen: false,
      );
      if (!mounted) return;
      final performanceEvaluationProvider = Provider.of<PerformanceEvaluationProvider>(
        context,
        listen: false,
      );

      try {
        await Future.wait([
          studentProvider.fetchStudents(),
          teacherProvider.fetchTeachers(),
          classProvider.fetchClasses(),
          subjectProvider.fetchSubjects(),
          gradeProvider.fetchGrades(),
          attendanceProvider.fetchAttendances(),
          timetableProvider.fetchTimetableEntries(),
          eventProvider.fetchEvents(),
          staffProvider.fetchStaff(),
          leaveProvider.fetchLeaves(),
          performanceEvaluationProvider.fetchPerformanceEvaluations(),
        ]);
        developer.log(
          'AppInitializer: Data fetching complete.',
          name: 'AppInitializer',
        );
      } catch (e, s) {
        developer.log(
          'AppInitializer: Error fetching initial data: $e',
          name: 'AppInitializer',
          level: 1000,
          error: e,
          stackTrace: s,
        );
      }
    } else {
      developer.log(
        'AppInitializer: User not authenticated or currentUser is null. Skipping data fetch.',
        name: 'AppInitializer',
      );
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      developer.log(
        'AppInitializer: Initialization complete. Setting _isInitialized to true.',
        name: 'AppInitializer',
      );
    } else {
      developer.log(
        'AppInitializer: Widget not mounted when trying to set _isInitialized.',
        name: 'AppInitializer',
        level: 900,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
      'AppInitializer: build called. _isInitialized: $_isInitialized',
      name: 'AppInitializer',
    );
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          developer.log(
            'AppInitializer: FutureBuilder connectionState is done.',
            name: 'AppInitializer',
          );
          return Consumer<LocalAuthService>(
            builder: (context, authService, child) {
              developer.log(
                'AppInitializer: Consumer rebuilding. isAuthenticated: ${authService.isAuthenticated}',
                name: 'AppInitializer',
              );
              if (authService.isAuthenticated &&
                  authService.currentUser != null) {
                developer.log(
                  'AppInitializer: User is authenticated. Navigating to role-based home screen.',
                  name: 'AppInitializer',
                );
                final String userRole = authService.currentUser!.role;
                developer.log(
                  'AppInitializer: Authenticated user role: $userRole',
                  name: 'AppInitializer',
                );
                return _getHomeScreenForRole(userRole);
              } else {
                developer.log(
                  'AppInitializer: User not authenticated or currentUser is null. Navigating to LoginScreen.',
                  name: 'MyApp', // Changed from AppInitializer
                );
                return const LoginScreen();
              }
            },
          );
        } else if (snapshot.hasError) {
          developer.log(
            'AppInitializer: FutureBuilder has error: ${snapshot.error}',
            name: 'AppInitializer',
            level: 1000,
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
          );
          return Scaffold(
            appBar: AppBar(title: const Text('خطأ')),
            body: Center(
              child: Text('حدث خطأ أثناء تهيئة التطبيق: ${snapshot.error}'),
            ),
          );
        } else {
          developer.log(
            'AppInitializer: FutureBuilder connectionState is waiting.',
            name: 'AppInitializer',
          );
          return Scaffold(
            appBar: AppBar(title: const Text('جار تهيئة التطبيق...')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('جار تحميل التطبيق...'),
                  Consumer<LocalAuthService>(
                    builder: (context, authService, child) {
                      return Text(
                        'المصادقة: ${authService.isAuthenticated}, المستخدم: ${authService.currentUser?.role ?? "غير متوفر"}, جار تحميل الجلسة: ${authService.isSessionLoading}',
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _getHomeScreenForRole(String role) {
    developer.log(
      'AppInitializer: Getting home screen for role: $role',
      name: 'AppInitializer',
    );
    switch (role) {
      case 'admin':
        return const DashboardScreen();
      case 'teacher':
        return const DashboardScreen();
      case 'student':
        return const DashboardScreen();
      case 'guest':
        developer.log(
          'AppInitializer: User role is guest. Falling back to LoginScreen.',
          name: 'AppInitializer',
          level: 800,
        );
        return const LoginScreen();
      default:
        developer.log(
          'AppInitializer: Unknown role: $role. Falling back to LoginScreen.',
          name: 'AppInitializer',
          level: 900,
        );
        return const LoginScreen();
    }
  }
}

class AppTheme {
  static const MaterialColor primarySeedColor = Colors.deepPurple;

  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.amiri(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.amiri(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.amiri(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.amiri(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.amiri(fontSize: 16),
    bodyMedium: GoogleFonts.amiri(fontSize: 14),
    bodySmall: GoogleFonts.amiri(fontSize: 12),
    labelLarge: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: GoogleFonts.amiri(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.amiri(fontSize: 11, fontWeight: FontWeight.w500),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: primarySeedColor,
      foregroundColor: Colors.white,
      titleTextStyle: _appTextTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primarySeedColor.shade700,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primarySeedColor, width: 2),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      titleTextStyle: _appTextTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primarySeedColor.shade200,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primarySeedColor.shade200,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[800],
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primarySeedColor.shade200, width: 2),
      ),
    ),
  );
}
