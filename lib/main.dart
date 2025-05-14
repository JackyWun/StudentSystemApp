import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_system_app_v2/utils/notification_service.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/main_menu.dart';
import 'pages/profile_page.dart';
import 'pages/timetable_page.dart';
import 'pages/attendance_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize local notifications
  await NotificationService.initialize();
  runApp(const StudentSystemApp());
}

class StudentSystemApp extends StatelessWidget {
  const StudentSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student System',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/mainMenu': (context) => MainMenuPage(),
        '/profile': (context) => ProfilePage(),
        '/timetable': (context) => const TimetablePage(),
        '/attendance': (context) => const AttendancePage(),
      },
    );
  }
}
