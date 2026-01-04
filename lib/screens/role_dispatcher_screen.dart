import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_auth_service.dart';
import './dashboards/admin_dashboard.dart';
import './dashboards/teacher_dashboard.dart';
import './dashboards/student_dashboard.dart';
import './dashboards/parent_dashboard.dart';
import './login_screen.dart';

class RoleDispatcherScreen extends StatelessWidget {
  const RoleDispatcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<LocalAuthService>(context);

    // While the session is loading, show a loading indicator.
    if (authService.isSessionLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentUser = authService.currentUser;

    // After loading, if a user is authenticated, direct them to their dashboard.
    if (currentUser != null) {
      switch (currentUser.role) {
        case 'admin':
          return const AdminDashboard();
        case 'teacher':
          return const TeacherDashboard();
        case 'student':
          return const StudentDashboard();
        case 'parent':
          return const ParentDashboard();
        default:
          // If the role is unknown, it's safest to send to login.
          return const LoginScreen();
      }
    } else {
      // If no user is logged in, show the login screen.
      return const LoginScreen();
    }
  }
}
