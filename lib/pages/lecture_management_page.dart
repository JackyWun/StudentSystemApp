import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // ✅ For formatting dates

class LectureManagementPage extends StatefulWidget {
  const LectureManagementPage({Key? key}) : super(key: key);

  @override
  State<LectureManagementPage> createState() => _LectureManagementPageState();
}

class _LectureManagementPageState extends State<LectureManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();

  Future<void> _saveLecture() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('lectures').add({
        'title': _titleController.text.trim(),
        'date': _dateController.text.trim(),
        'code': _codeController.text.trim(),
        'studentEmail': _studentEmailController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Lecture saved successfully!')),
      );

      _titleController.clear();
      _dateController.clear();
      _codeController.clear();
      _studentEmailController.clear();
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Lectures')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Lecture Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'Enter lecture title' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  labelText: 'Lecture Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value!.isEmpty ? 'Pick a date' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'QR Code (6-digit)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6, // ✅ force 6 digits
                validator: (value) => (value == null || value.length != 6) ? 'Enter exactly 6 digits' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _studentEmailController,
                decoration: InputDecoration(
                  labelText: 'Student Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'Enter student email' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saveLecture,
                icon: const Icon(Icons.save),
                label: const Text('Save Lecture'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
