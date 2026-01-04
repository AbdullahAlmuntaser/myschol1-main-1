import 'package:flutter/material.dart';
import '../dashboard_screen.dart'; // Corrected import path

// The admin dashboard will simply show the original DashboardScreen with all the tabs
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen(); // Corrected class name
  }
}
