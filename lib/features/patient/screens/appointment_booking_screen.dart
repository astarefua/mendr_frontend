import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookAppointmentScreen extends StatefulWidget {
  final int doctorId;
  final int patientId;
  final List<Map<String, String>> availableSlots;

  BookAppointmentScreen({required this.doctorId, required this.patientId, required this.availableSlots});

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _submitAppointment() async {
  if (_selectedDate == null || _startTime == null || _endTime == null) return;

  final DateTime startDateTime = DateTime(
    _selectedDate!.year,
    _selectedDate!.month,
    _selectedDate!.day,
    _startTime!.hour,
    _startTime!.minute,
  );

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Session expired. Please log in again.")),
    );
    return;
  }

  final uri = Uri.parse('http://10.0.2.2:8080/api/appointments');
  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 🔐 Add token to header
    },
    body: '''{
      "doctorId": ${widget.doctorId},
      "patientId": ${widget.patientId},
      "appointmentDate": "${startDateTime.toIso8601String()}"
    }''',
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Appointment booked successfully!")),
    );
    Navigator.pop(context);
  } else {
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to book appointment.")),
    );
  }
}

  Widget _buildCalendar() {
    return CalendarDatePicker(
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 60)),
      onDateChanged: (date) => setState(() => _selectedDate = date),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text("From", style: TextStyle(color: Colors.white)),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) setState(() => _startTime = picked);
              },
              child: Text(_startTime?.format(context) ?? "Select"),
            )
          ],
        ),
        Column(
          children: [
            Text("To", style: TextStyle(color: Colors.white)),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) setState(() => _endTime = picked);
              },
              child: Text(_endTime?.format(context) ?? "Select"),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Book Appointment", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          _buildCalendar(),
          Spacer(),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade900,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Text("Choose your Time", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                _buildTimePickers(),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _submitAppointment,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text("Swipe to book...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
} 

// Note: You can improve this by disabling unavailable dates/times dynamically based on availability.
