import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_profile_page.dart';

class StudentListPage extends StatelessWidget {
  const StudentListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference students = FirebaseFirestore.instance.collection('students');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: students.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final doc = data.docs[index];
              final student = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(student['name'] ?? 'No Name'),
                  subtitle: Text(student['email'] ?? 'No Email'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentProfilePage(studentId: doc.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
