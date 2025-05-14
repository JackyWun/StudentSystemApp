import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_system_app_v2/utils/session.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<DocumentSnapshot> _lectures = [];
  String? userEmail;

  @override
  void initState() {
    super.initState();
    userEmail = Session.loggedInEmail;
    _loadLectures();
  }

  Future<void> _loadLectures() async {
    if (userEmail == null) return;

    print('Logged in as: $userEmail');

    final snapshot = await FirebaseFirestore.instance
        .collection('lectures')
        .where('studentEmail', isEqualTo: userEmail)
        .get();

    setState(() {
      _lectures = snapshot.docs;
    });
  }

  void _showCodeEntryDialog(DocumentSnapshot lectureDoc) {
    final codeController = TextEditingController();
    final correctCode = lectureDoc['code'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Enter Code for "${lectureDoc['title']}"'),
        content: TextField(
          controller: codeController,
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '6-digit Code'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final enteredCode = codeController.text.trim();
              if (enteredCode == correctCode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Attendance marked!')),
                );
                // Optionally save to Firestore under attendance collection
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Incorrect code')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: _lectures.isEmpty
          ? const Center(child: Text('No lectures found for you.'))
          : ListView.builder(
        itemCount: _lectures.length,
        itemBuilder: (context, index) {
          final lecture = _lectures[index].data() as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(lecture['title'] ?? 'Untitled'),
              subtitle: Text('Date: ${lecture['date'] ?? ''}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _showCodeEntryDialog(_lectures[index]),
            ),
          );
        },
      ),
    );
  }
}
