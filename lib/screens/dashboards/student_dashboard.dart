import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/local_auth_service.dart';
import '../../user_model.dart'; // Corrected import path

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<LocalAuthService>(context);
    final User? currentUser = authService.currentUser;

    if (currentUser == null) {
      // This should ideally not happen if the logic is correct
      return const Scaffold(
        body: Center(
          child: Text('خطأ: لم يتم العثور على بيانات الطالب.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً ${currentUser.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              // Clear session and navigate to login screen
              Provider.of<LocalAuthService>(context, listen: false).logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildProfileCard(context, currentUser),
          const SizedBox(height: 20),
          _buildGradesCard(context),
          const SizedBox(height: 20),
          _buildScheduleCard(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الملف الشخصي',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blueAccent),
              title: Text('الاسم: ${user.username}'),
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.blueAccent),
              title: const Text('الفصل: الخامس ابتدائي'), // Placeholder
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered, color: Colors.blueAccent),
              title: const Text('الرقم الأكاديمي: 12345'), // Placeholder
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesCard(BuildContext context) {
    // Placeholder data - In a real app, this would come from a service
    final grades = {
      'الرياضيات': '95',
      'اللغة العربية': '88',
      'العلوم': '92',
      'التاريخ': '85',
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الدرجات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...grades.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  entry.value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    // Placeholder data
    final schedule = {
      'الأحد': 'رياضيات - لغة عربية',
      'الاثنين': 'علوم - رياضة',
      'الثلاثاء': 'تاريخ - لغة إنجليزية',
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'جدول الحصص',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...schedule.entries.map((entry) {
              return ListTile(
                title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(entry.value),
              );
            }),
          ],
        ),
      ),
    );
  }
}
