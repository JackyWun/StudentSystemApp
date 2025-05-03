import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({Key? key}) : super(key: key);

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();

  Future<void> _addStudent() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final university = _universityController.text.trim();

    if (name.isEmpty || email.isEmpty || subject.isEmpty || university.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please fill in all fields.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('students').add({
        'name': name,
        'email': email,
        'subject': subject,
        'university': university,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Student added successfully!')),
      );

      // Clear text fields
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _universityController.clear();

      // After adding student, go back to previous page
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to add student: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Student Name'),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Email'),
            const SizedBox(height: 16),
            _buildTextField(_subjectController, 'Subject'),
            const SizedBox(height: 16),
            _buildTextField(_universityController, 'University'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addStudent,
              icon: const Icon(Icons.save),
              label: const Text('Save Student'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
