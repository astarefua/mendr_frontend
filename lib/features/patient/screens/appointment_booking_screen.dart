// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class BookAppointmentScreen extends StatefulWidget {
//   final int doctorId;
//   final int patientId;
//   final List<Map<String, String>> availableSlots;

//   const BookAppointmentScreen({
//     required this.doctorId,
//     required this.patientId,
//     required this.availableSlots,
//     Key? key,
//   }) : super(key: key);

//   @override
//   _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
// }

// class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
//   String? _selectedSlot;
//   DateTime? _selectedDate;

//   bool _isBooking = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book Appointment'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               "Choose Available Slot",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             DropdownButtonFormField<String>(
//               value: _selectedSlot,
//               hint: const Text("Select a time slot"),
//               items: widget.availableSlots.map((slot) {
//                 final formatted = "${slot['dayOfWeek']} - ${slot['startTime']} to ${slot['endTime']}";
//                 return DropdownMenuItem<String>(
//                   value: jsonEncode(slot), // Encode the whole slot map
//                   child: Text(formatted),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedSlot = value;
//                 });
//               },
//             ),

//             const SizedBox(height: 20),
//             const Text("Pick Appointment Date"),
//             const SizedBox(height: 10),

//             ElevatedButton(
//               onPressed: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime.now().add(const Duration(days: 30)),
//                 );
//                 if (picked != null) {
//                   setState(() {
//                     _selectedDate = picked;
//                   });
//                 }
//               },
//               child: Text(_selectedDate == null
//                   ? 'Choose Date'
//                   : _selectedDate!.toLocal().toString().split(' ')[0]),
//             ),

//             const SizedBox(height: 30),
//             _isBooking
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: () {
//                       if (_selectedSlot == null || _selectedDate == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Please select slot and date"),
//                           ),
//                         );
//                         return;
//                       }

//                       final slot = jsonDecode(_selectedSlot!);
//                       _bookAppointment(slot);
//                     },
//                     child: const Text('Book Appointment'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _bookAppointment(Map<String, dynamic> slot) async {
//     setState(() {
//       _isBooking = true;
//     });

//     try {
//       // Combine selected date and slot start time
//       final timeParts = slot['startTime'].split(":");
//       final appointmentDate = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//         int.parse(timeParts[0]),
//         int.parse(timeParts[1]),
//       );

//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:8080/api/appointments'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "doctorId": widget.doctorId,
//           "patientId": widget.patientId,
//           "appointmentDate": appointmentDate.toIso8601String(),
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Appointment booked successfully")),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to book: ${response.body}")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error occurred: $e")),
//       );
//     } finally {
//       setState(() {
//         _isBooking = false;
//       });
//     }
//   }
// }











//-------------------------------------------------------------------------------------------------------



// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
// import 'package:slide_to_act/slide_to_act.dart';


// class BookAppointmentScreen extends StatefulWidget {
//   @override
//   _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
// }

// class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
//   DateTime _selectedDay = DateTime.now();
//   TimeOfDay? _startTime;
//   TimeOfDay? _endTime;

//   bool isFriday(DateTime day) {
//     return day.weekday == DateTime.friday;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(height: 20),
//             Text(
//               'December ${_selectedDay.year}',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             TableCalendar(
//               firstDay: DateTime.utc(2025, 12, 1),
//               lastDay: DateTime.utc(2025, 12, 31),
//               focusedDay: _selectedDay,
//               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//               calendarFormat: CalendarFormat.month,
//               onDaySelected: (selectedDay, focusedDay) {
//                 if (isFriday(selectedDay)) {
//                   setState(() {
//                     _selectedDay = selectedDay;
//                   });
//                 }
//               },
//               calendarStyle: CalendarStyle(
//                 selectedDecoration: BoxDecoration(
//                   color: Colors.green[700],
//                   shape: BoxShape.circle,
//                 ),
//                 todayDecoration: BoxDecoration(
//                   color: Colors.transparent,
//                 ),
//                 outsideDaysVisible: false,
//                 weekendTextStyle: TextStyle(color: Colors.black),
//               ),
//               daysOfWeekStyle: DaysOfWeekStyle(
//                 weekendStyle: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               enabledDayPredicate: (day) => isFriday(day),
//             ),
//             Spacer(),
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.black87,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     'Choose your Time',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                   SizedBox(height: 15),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       timePickerCard(
//                         label: 'From',
//                         time: _startTime,
//                         onTap: () => pickTime(true),
//                       ),
//                       timePickerCard(
//                         label: 'To',
//                         time: _endTime,
//                         onTap: () => pickTime(false),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 30),
//                   SlideAction(
//   text: "Swipe to book...",
//   textStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
//   outerColor: Colors.grey[800]!,
//   innerColor: Colors.green,
//   onSubmit: () {
//     if (_startTime != null && _endTime != null) {
//       print("Booking confirmed at $_selectedDay from $_startTime to $_endTime");
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please select time")),
//       );
//     }
//   },
// ),

//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget timePickerCard({
//     required String label,
//     required TimeOfDay? time,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Text(label, style: TextStyle(color: Colors.white)),
//           SizedBox(height: 8),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.grey[700],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.calendar_today, color: Colors.white, size: 16),
//                 SizedBox(width: 10),
//                 Text(
//                   time != null ? time.format(context) : "--:--",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void pickTime(bool isStartTime) async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: isStartTime
//           ? (_startTime ?? TimeOfDay(hour: 16, minute: 0))
//           : (_endTime ?? TimeOfDay(hour: 17, minute: 0)),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartTime) {
//           _startTime = picked;
//         } else {
//           _endTime = picked;
//         }
//       });
//     }
//   }
// }

























// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class BookAppointmentScreen extends StatefulWidget {
//   final int doctorId;
//   final int patientId;
//   final List<Map<String, String>> availableSlots;

//   BookAppointmentScreen({required this.doctorId, required this.patientId, required this.availableSlots});

//   @override
//   _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
// }

// class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
//   DateTime? _selectedDate;
//   TimeOfDay? _startTime;
//   TimeOfDay? _endTime;

//   Future<void> _submitAppointment() async {
//   if (_selectedDate == null || _startTime == null || _endTime == null) return;

//   final DateTime startDateTime = DateTime(
//     _selectedDate!.year,
//     _selectedDate!.month,
//     _selectedDate!.day,
//     _startTime!.hour,
//     _startTime!.minute,
//   );

//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token');

//   if (token == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Session expired. Please log in again.")),
//     );
//     return;
//   }

//   final uri = Uri.parse('http://10.0.2.2:8080/api/appointments');
//   final response = await http.post(
//     uri,
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token', // 🔐 Add token to header
//     },
//     body: '''{
//       "doctorId": ${widget.doctorId},
//       "patientId": ${widget.patientId},
//       "appointmentDate": "${startDateTime.toIso8601String()}"
//     }''',
//   );

//   if (response.statusCode == 200 || response.statusCode == 201) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Appointment booked successfully!")),
//     );
//     Navigator.pop(context);
//   } else {
//     print('Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Failed to book appointment.")),
//     );
//   }
// }

//   Widget _buildCalendar() {
//     return CalendarDatePicker(
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(Duration(days: 60)),
//       onDateChanged: (date) => setState(() => _selectedDate = date),
//     );
//   }

//   Widget _buildTimePickers() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         Column(
//           children: [
//             Text("From", style: TextStyle(color: Colors.white)),
//             ElevatedButton(
//               onPressed: () async {
//                 final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
//                 if (picked != null) setState(() => _startTime = picked);
//               },
//               child: Text(_startTime?.format(context) ?? "Select"),
//             )
//           ],
//         ),
//         Column(
//           children: [
//             Text("To", style: TextStyle(color: Colors.white)),
//             ElevatedButton(
//               onPressed: () async {
//                 final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
//                 if (picked != null) setState(() => _endTime = picked);
//               },
//               child: Text(_endTime?.format(context) ?? "Select"),
//             )
//           ],
//         )
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Book Appointment", style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 10),
//           _buildCalendar(),
//           Spacer(),
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.green.shade900,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//             ),
//             child: Column(
//               children: [
//                 Text("Choose your Time", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 12),
//                 _buildTimePickers(),
//                 SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: _submitAppointment,
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.lightGreen,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Center(
//                       child: Text("Swipe to book...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// } 

