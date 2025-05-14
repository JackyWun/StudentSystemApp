import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/login_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("👋 App is starting...");

  await Firebase.initializeApp();

  try {
    final testSnapshot = await FirebaseFirestore.instance.collection('Admin_jacky').get();
    print("✅ Firestore connection success: ${testSnapshot.docs.length} docs found.");
  } catch (e) {
    print("❌ Firestore connection failed: $e");
  }

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(), // <-- ✅ Start with LoginPage now!
      debugShowCheckedModeBanner: false,
    );
  }
}
