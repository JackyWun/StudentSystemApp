import 'package:flutter/material.dart';
import 'student_management_page.dart';
import 'lecture_management_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentManagementPage()),
                );
              },
              child: const Text('Manage Students'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LectureManagementPage()),
                );
              },
              child: const Text('Manage Lectures'),
            ),
          ],
        ),
      ),
    );
  }
}
