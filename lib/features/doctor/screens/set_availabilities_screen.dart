import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SetAvailabilityScreen extends StatefulWidget {
  const SetAvailabilityScreen({super.key});

  @override
  _SetAvailabilityScreenState createState() => _SetAvailabilityScreenState();
}

class _SetAvailabilityScreenState extends State<SetAvailabilityScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _days = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
  ];

  String? _selectedDay;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final List<Map<String, String>> _availabilities = [];

  void _addAvailability() {
    if (_selectedDay != null &&
        _startTimeController.text.isNotEmpty &&
        _endTimeController.text.isNotEmpty) {
      setState(() {
        _availabilities.add({
          "dayOfWeek": _selectedDay!,
          "startTime": _startTimeController.text,
          "endTime": _endTimeController.text,
        });
        _startTimeController.clear();
        _endTimeController.clear();
        _selectedDay = null;
      });
    }
  }

  void _removeAvailability(int index) {
    setState(() {
      _availabilities.removeAt(index);
    });
  }

  Future<void> _submitAvailabilities() async {
    if (_availabilities.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least 2 availabilities.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8080/api/doctors/me/availability'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(_availabilities),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Availabilities saved successfully!')),
      );
      setState(() {
        _availabilities.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        //SnackBar(content: Text('Failed to save availabilities.')),
        SnackBar(content: Text('Failed: ${response.statusCode} - ${response.body}')),

      );
    }
  }


  Future<void> _selectTime(TextEditingController controller) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (picked != null) {
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    controller.text = formatted;
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Availability')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    hint: Text('Select Day of Week'),
                    items: _days
                        .where((day) => !_availabilities.any((a) => a['dayOfWeek'] == day))
                        .map((day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDay = val),
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _startTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(_startTimeController),
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _endTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(_endTimeController),
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _addAvailability,
                    icon: Icon(Icons.add),
                    label: Text('Add Availability'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _availabilities.isEmpty
                  ? Center(child: Text('No availabilities added yet.'))
                  : ListView.builder(
                      itemCount: _availabilities.length,
                      itemBuilder: (context, index) {
                        final avail = _availabilities[index];
                        return ListTile(
                          title: Text('${avail['dayOfWeek']}: ${avail['startTime']} - ${avail['endTime']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeAvailability(index),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: _submitAvailabilities,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Save All Availabilities'),
            ),
          ],
        ),
      ),
    );
  }
}
