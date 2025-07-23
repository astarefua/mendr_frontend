import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../utils/constants.dart'; // Make sure this contains your baseUrl

class BookAppointmentScreen extends StatefulWidget {
  final int doctorId;
  final int patientId;
  final List<Map<String, String>> availableSlots;

  const BookAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.availableSlots,
  });

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  bool _isLoading = false;

  // Available time slots based on doctor's availability
  List<TimeOfDay> _getAvailableTimeSlots() {
    if (_selectedDay == null) return [];

    String selectedDayName = _getDayName(_selectedDay!.weekday);
    
    // Find availability for selected day
    final dayAvailability = widget.availableSlots.firstWhere(
      (slot) => slot['dayOfWeek']!.toLowerCase() == selectedDayName.toLowerCase(),
      orElse: () => <String, String>{},
    );

    if (dayAvailability.isEmpty) return [];

    List<TimeOfDay> slots = [];
    final startTime = _parseTime(dayAvailability['startTime']!);
    final endTime = _parseTime(dayAvailability['endTime']!);

    // Generate 30-minute slots
    TimeOfDay currentTime = startTime;
    while (_isTimeBefore(currentTime, endTime)) {
      slots.add(currentTime);
      currentTime = _addMinutes(currentTime, 30);
    }

    return slots;
  }

  String _getDayName(int weekday) {
    const days = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 
      'FRIDAY', 'SATURDAY', 'SUNDAY'
    ];
    return days[weekday - 1];
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour < time2.hour || 
           (time1.hour == time2.hour && time1.minute < time2.minute);
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _bookAppointment() async {
    if (_selectedDay == null || _selectedStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')),
        );
        return;
      }

      // Create appointment DateTime
      final appointmentDateTime = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );

      final uri = Uri.parse('$baseUrl/api/appointments');
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "appointmentDate": appointmentDateTime.toIso8601String(),
          "doctorId": widget.doctorId,
          "patientId": widget.patientId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to book appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error booking appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTimeSlot(TimeOfDay time, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStartTime = time;
          _selectedEndTime = _addMinutes(time, 30);
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF84C225) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF84C225) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          _formatTimeOfDay(time),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableTimeSlots = _getAvailableTimeSlots();

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Appointment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar Section
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TableCalendar<Event>(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(Duration(days: 90)),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      eventLoader: (day) => [],
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: TextStyle(color: Colors.black87),
                        holidayTextStyle: TextStyle(color: Colors.black87),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF84C225),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Color(0xFF84C225).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(color: Colors.black87),
                        selectedTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        todayTextStyle: TextStyle(
                          color: Color(0xFF84C225),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey[600]),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey[600]),
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _selectedStartTime = null;
                            _selectedEndTime = null;
                          });
                        }
                      },
                    ),
                  ),

                  // Time Selection Section
                  if (_selectedDay != null) ...[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose your Time',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          if (availableTimeSlots.isEmpty) ...[
                            Text(
                              'No available time slots for this day',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'From',
                                        style: TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time, color: Colors.white70, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              _selectedStartTime != null 
                                                  ? _formatTimeOfDay(_selectedStartTime!)
                                                  : '00:00',
                                              style: TextStyle(color: Colors.white, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'To',
                                        style: TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time, color: Colors.white70, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              _selectedEndTime != null 
                                                  ? _formatTimeOfDay(_selectedEndTime!)
                                                  : '00:00',
                                              style: TextStyle(color: Colors.white, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 20),
                            
                            // Available Time Slots
                            Text(
                              'Available Time Slots',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12),
                            
                            Wrap(
                              children: availableTimeSlots.map((time) {
                                return _buildTimeSlot(
                                  time,
                                  _selectedStartTime?.hour == time.hour && 
                                  _selectedStartTime?.minute == time.minute,
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _bookAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF84C225),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// Event class for calendar
class Event {
  final String title;
  Event(this.title);
}