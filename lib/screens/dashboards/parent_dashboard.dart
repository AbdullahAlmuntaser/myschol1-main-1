import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم ولي الأمر'),
      ),
      body: const Center(
        child: Text('مرحباً بك في واجهة ولي الأمر!'),
      ),
    );
  }
}
