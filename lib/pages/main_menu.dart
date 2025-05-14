import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_system_app_v2/utils/notification_service.dart';
import 'package:student_system_app_v2/utils/session.dart'; // Create this to hold logged-in email

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    Session.loggedInEmail = null;

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(Icons.person),
              label: const Text('Student Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/timetable');
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Timetable'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/attendance');
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Attendance'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('user_test').add({
                  'test': 'Hello from User!',
                  'timestamp': FieldValue.serverTimestamp(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Sent to Firestore!')),
                );
              },
              child: const Text('Test Firestore'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                await NotificationService.showInstantNotification(
                  title: 'Test Notification',
                  body: 'This is a test notification 🚀',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Notification Sent!')),
                );
              },
              child: const Text('Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
