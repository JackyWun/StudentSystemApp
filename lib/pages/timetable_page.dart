import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_system_app_v2/utils/notification_service.dart';
import 'package:student_system_app_v2/utils/session.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'Lecture';

  Map<String, List<Map<String, String>>> _events = {};
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    userEmail = Session.loggedInEmail ?? '';
    if (userEmail.isNotEmpty) {
      _loadEvents();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('timetable')
        .where('email', isEqualTo: userEmail)
        .get();

    final Map<String, List<Map<String, String>>> loadedEvents = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String date = data['date'] ?? '';
      final String title = data['title'] ?? '';
      final String category = data['category'] ?? '';
      if (date.isEmpty || title.isEmpty) continue;
      loadedEvents.putIfAbsent(date, () => []);
      loadedEvents[date]!.add({'title': title, 'category': category});
    }

    setState(() {
      _events = loadedEvents;
    });
  }

  Future<void> _saveEventToFirestore(String date, String title, String category, DateTime timestamp) async {
    await FirebaseFirestore.instance.collection('timetable').add({
      'email': userEmail,
      'date': date,
      'title': title,
      'category': category,
      'timestamp': timestamp,
    });
  }

  Future<void> _deleteEventFromFirestore(String date, String title) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('timetable')
        .where('email', isEqualTo: userEmail)
        .where('date', isEqualTo: date)
        .where('title', isEqualTo: title)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  void _addEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event title cannot be empty")),
      );
      return;
    }

    final String dateKey = _selectedDay.toIso8601String().substring(0, 10);
    final String title = _titleController.text.trim();
    final String category = _selectedCategory;

    try {
      await _saveEventToFirestore(dateKey, title, category, _selectedDay);

      setState(() {
        _events.putIfAbsent(dateKey, () => []);
        _events[dateKey]!.add({'title': title, 'category': category});
      });


      Navigator.pop(context);
      _titleController.clear();
      _selectedCategory = 'Lecture';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add event: $e")),
      );
    }
  }


  Future<void> _scheduleAssignmentReminder(String title, DateTime dueDate) async {
    final DateTime reminderTime = dueDate.subtract(const Duration(days: 1));
    await NotificationService.scheduleAssignmentNotification(
      id: dueDate.hashCode,
      title: title,
      scheduledTime: reminderTime,
    );
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    final String key = day.toIso8601String().substring(0, 10);
    return _events[key] ?? [];
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                hintText: 'e.g., Lecture',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: const [
                DropdownMenuItem(value: 'Lecture', child: Text('Lecture')),
                DropdownMenuItem(value: 'Assignment', child: Text('Assignment')),
                DropdownMenuItem(value: 'Meeting', child: Text('Meeting')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'Lecture';
                });
              },
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addEvent,
              icon: const Icon(Icons.check),
              label: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay);
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              eventLoader: _getEventsForDay,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddEventDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: selectedEvents.length,
                itemBuilder: (context, index) {
                  final event = selectedEvents[index];
                  final title = event['title'] ?? '';
                  final category = event['category'] ?? '';
                  return ListTile(
                    title: Text(title),
                    subtitle: Text(category),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final dateKey = _selectedDay.toIso8601String().substring(0, 10);
                        await _deleteEventFromFirestore(dateKey, title);
                        setState(() {
                          _events[dateKey]?.removeWhere((e) => e['title'] == title && e['category'] == category);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
