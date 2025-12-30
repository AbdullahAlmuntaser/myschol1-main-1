import 'package:flutter/material.dart';
import '../screens/tabs/students_tab.dart';
import '../screens/tabs/teachers_tab.dart';
import '../screens/tabs/classes_tab.dart';
import '../screens/tabs/subjects_tab.dart';
import '../screens/tabs/settings_tab.dart';
import '../screens/tabs/reports_tab.dart';
import '../screens/grades_screen.dart';
import '../screens/timetable_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/student_affairs_screen.dart';
import '../screens/parent_portal_screen.dart';
import '../screens/teacher_portal_screen.dart';
import '../screens/student_portal_screen.dart';
import '../screens/events_screen.dart';
import '../screens/staff_management_screen.dart';
import '../screens/permissions_management_screen.dart';
import '../screens/academic_years_screen.dart';

// Constants for feature names
class AppFeatures {
  static const String dashboard = 'dashboard';
  static const String students = 'students';
  static const String teachers = 'teachers';
  static const String classes = 'classes';
  static const String subjects = 'subjects';
  static const String timetable = 'timetable';
  static const String grades = 'grades';
  static const String attendance = 'attendance';
  static const String reports = 'reports';
  static const String studentAffairs = 'student_affairs';
  static const String events = 'events';
  static const String staffManagement = 'staff_management';
  static const String permissions = 'permissions';
  static const String settings = 'settings';
  static const String parentPortal = 'parent_portal';
  static const String teacherPortal = 'teacher_portal';
  static const String studentPortal = 'student_portal';
  static const String academicYears = 'academic_years';
  static const String chat = 'chat'; // Assuming 'chat' is also a feature
}

// Data for all features, including display name, icon, and associated widget
final Map<String, Map<String, dynamic>> allFeatureData = {
  AppFeatures.dashboard: {
    'label': 'لوحة التحكم',
    'icon': Icons.dashboard,
    'widget': const Center(child: Text('Dashboard Summary will be here')), // Placeholder, actual widget is DashboardSummary
  },
  AppFeatures.students: {
    'label': 'الطلاب',
    'icon': Icons.school,
    'widget': const StudentsTab(),
  },
  AppFeatures.teachers: {
    'label': 'المعلمين',
    'icon': Icons.person,
    'widget': const TeachersTab(),
  },
  AppFeatures.classes: {
    'label': 'الفصول',
    'icon': Icons.class_,
    'widget': const ClassesTab(),
  },
  AppFeatures.subjects: {
    'label': 'المواد',
    'icon': Icons.book,
    'widget': const SubjectsTab(),
  },
  AppFeatures.timetable: {
    'label': 'الجدول',
    'icon': Icons.calendar_today,
    'widget': const TimetableScreen(),
  },
  AppFeatures.grades: {
    'label': 'الدرجات',
    'icon': Icons.grade,
    'widget': const GradesScreen(),
  },
  AppFeatures.attendance: {
    'label': 'الحضور',
    'icon': Icons.check_circle,
    'widget': const AttendanceScreen(),
  },
  AppFeatures.reports: {
    'label': 'التقارير',
    'icon': Icons.bar_chart,
    'widget': const ReportsTab(),
  },
  AppFeatures.studentAffairs: {
    'label': 'شؤون الطلاب',
    'icon': Icons.business_center,
    'widget': const StudentAffairsScreen(),
  },
  AppFeatures.events: {
    'label': 'الفعاليات',
    'icon': Icons.event,
    'widget': const EventsScreen(),
  },
  AppFeatures.staffManagement: {
    'label': 'الموظفين',
    'icon': Icons.group,
    'widget': const StaffManagementScreen(),
  },
  AppFeatures.permissions: {
    'label': 'الصلاحيات',
    'icon': Icons.security,
    'widget': const PermissionsManagementScreen(),
  },
  AppFeatures.settings: {
    'label': 'الإعدادات',
    'icon': Icons.settings,
    'widget': const SettingsTab(),
  },
  AppFeatures.parentPortal: {
    'label': 'بوابة ولي الأمر',
    'icon': Icons.family_restroom,
    'widget': const ParentPortalScreen(),
  },
  AppFeatures.teacherPortal: {
    'label': 'بوابة المعلم',
    'icon': Icons.person_pin,
    'widget': const TeacherPortalScreen(),
  },
  AppFeatures.studentPortal: {
    'label': 'بوابة الطالب',
    'icon': Icons.school,
    'widget': const StudentPortalScreen(),
  },
  AppFeatures.academicYears: {
    'label': 'السنوات الدراسية',
    'icon': Icons.calendar_today, // Re-using icon, consider unique
    'widget': const AcademicYearsScreen(),
  },
  AppFeatures.chat: {
    'label': 'الدردشة',
    'icon': Icons.chat,
    'widget': const Center(child: Text('Chat Screen will be here')), // Assuming there's a ChatScreen
  },
};
