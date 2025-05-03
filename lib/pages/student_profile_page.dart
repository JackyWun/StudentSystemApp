import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfilePage extends StatelessWidget {
  final String studentId;

  const StudentProfilePage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference students = FirebaseFirestore.instance.collection('students');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: students.doc(studentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Student not found.'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Email: ${data['email'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('University: ${data['University'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Subject: ${data['Subject'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
