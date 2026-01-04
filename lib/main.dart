import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/dashboards/admin_dashboard.dart';
import 'screens/dashboards/student_dashboard.dart';
import 'screens/dashboards/teacher_dashboard.dart';
import 'screens/dashboards/parent_dashboard.dart';
import 'screens/role_dispatcher_screen.dart';
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
import 'providers/leave_provider.dart';
import 'providers/performance_evaluation_provider.dart';
import 'providers/permission_provider.dart';
import 'database_helper.dart';
import 'screens/grades_screen.dart';
import 'screens/attendance_screen.dart';
import 'services/local_auth_service.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_manage_users_screen.dart';
import 'dart:developer' as developer;

final notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  await notificationService.init();

  final dbHelper = DatabaseHelper();
  final authService = LocalAuthService();

  final existingAdmin = await dbHelper.getUserByUsername('admin');
  if (existingAdmin == null) {
    developer.log('Creating initial admin user...', name: 'AdminCreation');
    await authService.adminCreateUser('admin', 'admin123', 'admin');
  }

  final existingAbdullah = await dbHelper.getUserByUsername('abdullah');
  if (existingAbdullah == null) {
    developer.log('Creating abdullah user...', name: 'AdminCreation');
    await authService.adminCreateUser('abdullah', 'abd772030', 'admin');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalAuthService()),
        ChangeNotifierProxyProvider<LocalAuthService, StudentProvider>(
          create: (context) => StudentProvider(authService: Provider.of<LocalAuthService>(context, listen: false)),
          update: (context, authService, previous) => StudentProvider(authService: authService),
        ),
        ChangeNotifierProxyProvider<LocalAuthService, TeacherProvider>(
          create: (context) => TeacherProvider(authService: Provider.of<LocalAuthService>(context, listen: false)),
          update: (context, authService, previous) => TeacherProvider(authService: authService),
        ),
        ChangeNotifierProxyProvider<LocalAuthService, ClassProvider>(
          create: (context) => ClassProvider(authService: Provider.of<LocalAuthService>(context, listen: false)),
          update: (context, authService, previous) => ClassProvider(authService: authService),
        ),
        // Updated SubjectProvider to use ChangeNotifierProxyProvider
        ChangeNotifierProxyProvider<LocalAuthService, SubjectProvider>(
          create: (context) => SubjectProvider(authService: Provider.of<LocalAuthService>(context, listen: false)),
          update: (context, authService, previous) => SubjectProvider(authService: authService),
        ),
        ChangeNotifierProxyProvider<LocalAuthService, GradeProvider>(
          create: (context) => GradeProvider(authService: Provider.of<LocalAuthService>(context, listen: false)),
          update: (context, authService, previous) => GradeProvider(authService: authService),
        ),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => PerformanceEvaluationProvider()),
        ChangeNotifierProxyProvider<LocalAuthService, PermissionProvider>(
          create: (context) => PermissionProvider(),
          update: (context, authService, previousPermissionProvider) {
            final permissionProvider = previousPermissionProvider ?? PermissionProvider();
            final role = authService.currentUser?.role;
            permissionProvider.loadPermissions(role);
            return permissionProvider;
          },
        ),
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'نظام إدارة الطلاب',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const RoleDispatcherScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/admin_manage_users': (context) => const AdminManageUsersScreen(),
              '/admin_dashboard': (context) => const AdminDashboard(),
              '/teacher_dashboard': (context) => const TeacherDashboard(),
              '/student_dashboard': (context) => const StudentDashboard(),
              '/parent_dashboard': (context) => const ParentDashboard(),
              GradesScreen.routeName: (context) => const GradesScreen(),
              AttendanceScreen.routeName: (context) => const AttendanceScreen(),
            },
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
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

class AppTheme {
  static const MaterialColor primarySeedColor = Colors.deepPurple;

  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.amiri(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.amiri(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.amiri(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.amiri(fontSize: 28, fontWeight: FontWeight.bold),
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
