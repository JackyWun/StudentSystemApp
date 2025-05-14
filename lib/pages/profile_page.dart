import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_system_app_v2/utils/session.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final subjectController = TextEditingController();
  final uniController = TextEditingController();

  bool _isLoading = false;
  String? email;

  @override
  void initState() {
    super.initState();
    email = Session.loggedInEmail;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (email == null) {
      print("❌ No email in session");
      return;
    }

    setState(() => _isLoading = true);
    print("📥 Loading profile for $email");

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          nameController.text = data['name'] ?? '';
          ageController.text = data['age'] ?? '';
          subjectController.text = data['subject'] ?? '';
          uniController.text = data['university'] ?? '';
        });
        print("✅ Profile loaded");
      } else {
        print("ℹ️ No profile found for $email");
      }
    } catch (e) {
      print("❌ Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserProfile() async {
    if (email == null) return;

    print("💾 Saving profile for $email");

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // update existing document
        await snapshot.docs.first.reference.set({
          'email': email,
          'name': nameController.text.trim(),
          'age': ageController.text.trim(),
          'subject': subjectController.text.trim(),
          'university': uniController.text.trim(),
        });
        print("✅ Existing profile updated.");
      } else {
        // create new document
        await FirebaseFirestore.instance.collection('students').add({
          'email': email,
          'name': nameController.text.trim(),
          'age': ageController.text.trim(),
          'subject': subjectController.text.trim(),
          'university': uniController.text.trim(),
        });
        print("✅ New profile created.");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile saved')),
      );
    } catch (e) {
      print('❌ Error saving: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error saving: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🛠 Building ProfilePage");

    return Scaffold(
      appBar: AppBar(
        title: const Text("🔥 DEBUG PROFILE"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(controller: nameController, label: 'Name', hint: 'e.g., Sam'),
            const SizedBox(height: 12),
            _buildTextField(controller: ageController, label: 'Age', hint: 'e.g., 20'),
            const SizedBox(height: 12),
            _buildTextField(controller: subjectController, label: 'Subject', hint: 'e.g., Psychology'),
            const SizedBox(height: 12),
            _buildTextField(controller: uniController, label: 'University', hint: 'e.g., UWE'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                print("🖱 Save button pressed");
                _saveUserProfile();
              },
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
