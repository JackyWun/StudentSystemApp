import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_system_app_v2/utils/security.dart';
import 'package:student_system_app_v2/utils/session.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('StudentAccDetail')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showMessage(context, 'Account not found');
        return;
      }

      final userDoc = snapshot.docs.first;
      final storedHashedPassword = userDoc['password'];

      if (storedHashedPassword != hashPassword(password)) {
        _showMessage(context, 'Incorrect password');
        return;
      }

      Session.loggedInEmail = email; // ✅ Store session globally
      Navigator.pushNamed(context, '/mainMenu');
    } catch (e) {
      print('Login error: $e');
      _showMessage(context, 'Login failed. Try again.');
    }
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text(
                'Create Account',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
