import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:telemed_frontend/features/patient/screens/appointment_booking.dart';
import 'package:telemed_frontend/features/patient/screens/appointments_list_screen.dart';


import 'appointment_booking_screen.dart';


class DoctorDetailsScreen extends StatefulWidget {
  final int doctorId;
  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  _DoctorDetailsScreenState createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  Map<String, dynamic>? _doctor;
  List<Availability> _availabilities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
  }

  Future<void> fetchDoctorData() async {
    setState(() => _isLoading = true);
    try {
      final profileUri =
          Uri.parse('http://10.0.2.2:8080/api/doctors/${widget.doctorId}');
      final availabilityUri = Uri.parse(
          'http://10.0.2.2:8080/api/doctors/${widget.doctorId}/availability');

      final profileResponse = await http.get(profileUri);
      final availabilityResponse = await http.get(availabilityUri);

      if (profileResponse.statusCode == 200 && availabilityResponse.statusCode == 200) {
        setState(() {
          _doctor = jsonDecode(profileResponse.body);
          _availabilities = (jsonDecode(availabilityResponse.body) as List)
              .map((e) => Availability.fromJson(e))
              .toList();
          _isLoading = false;
        });
      } else {
        print('Error fetching data');
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }

//   Widget buildStatCard(String title, String value, IconData icon) {
//   return Card(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     elevation: 2,
//     child: Padding(
//       padding: EdgeInsets.all(12),
//       child: Row(
//         children: [
//           FaIcon(icon, color: Colors.blue, size: 20), // FontAwesome icon
//           SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title,
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//               SizedBox(height: 4),
//               Text(value, style: TextStyle(color: Colors.grey[700])),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }


  Widget buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: ShapeDecoration(
            shape: PolygonBorder(sides: 8),
            color:  Color.fromARGB(213, 221, 231, 255),
            //color: Colors.deepPurple.shade50,
          ),
          child: Center(
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
        ),
        SizedBox(height: 4),
        Text(value,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
        SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 11))
      ],
    );
  }

  Widget buildAvailabilitySection() {
    if (_availabilities.isEmpty) {
      return Text("No working hours available");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Working Hours", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ..._availabilities.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(a.dayOfWeek),
                  Text('${a.startTime} - ${a.endTime}'),
                ],
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor:  Colors.white,
        appBar: AppBar(title: const Text("Doctor Details" , style: TextStyle(color: Colors.white)), centerTitle: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
              backgroundColor:  Colors.white,

      //backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:  Colors.white,
        //backgroundColor: Colors.white,
        title: const Text("Doctor Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _doctor!["profilePictureUrl"] != null
                      ? NetworkImage(_doctor!["profilePictureUrl"])
                      : null,
                  child: _doctor!["profilePictureUrl"] == null ? Icon(Icons.person, size: 40) : null,
                ),
                SizedBox(width: 16),
                Expanded(

                  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      _doctor!["name"] ?? '',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    
    // Specialty Row with Stethoscope Icon
    Row(
      children: [
        FaIcon(FontAwesomeIcons.stethoscope, color: Colors.blue, size: 18),
        SizedBox(width: 5),
        Text(
          _doctor!["specialty"] ?? '',
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    ),

    SizedBox(height: 4), // Optional spacing

    // Affiliations Row with Hospital Icon
    Row(
      children: [
        FaIcon(FontAwesomeIcons.hospital, color: Colors.blue, size: 18),
        SizedBox(width: 5),
        Text(
          _doctor!["affiliations"] ?? '',
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    ),
  ],
),




                  
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(_doctor!["name"] ?? '',
//                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                       Text(_doctor!["specialty"] ?? '',
//                           style: TextStyle(color: Colors.grey[700])),
//                       Row(
//                         children: [
                          
//                           SizedBox(width: 4),
// Text(_doctor!["affiliations"] ?? '',
//                           style: TextStyle(color: Colors.grey[700])),                        ],
//                       )
//                     ],
//                   ),
                ),
                // Text("\$30/hour",
                //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
  buildStatCard("Education", "${_doctor!["education"]}", FontAwesomeIcons.graduationCap),
  buildStatCard("Certifications", "${_doctor!["certifications"]}", FontAwesomeIcons.certificate),
  buildStatCard("Languages", "${_doctor!["languagesSpoken"]}", FontAwesomeIcons.language),
  buildStatCard("Rating", "${_doctor!["reviewsRating"]}", FontAwesomeIcons.star),
],

            ),
            SizedBox(height: 24),
            Text("About Doctor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(_doctor!["bio"] ?? ""),
            SizedBox(height: 16),
            buildAvailabilitySection(),
            SizedBox(height: 80)
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        //decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 5)]),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  final patientId = prefs.getInt('patientId');

  if (patientId != null) {
    List<Map<String, String>> availableSlots = _availabilities.map((a) {
      return {
        'dayOfWeek': a.dayOfWeek,
        'startTime': a.startTime,
        'endTime': a.endTime,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>BookAppointmentScreen(
          doctorId: _doctor!['id'],
          patientId: patientId,
          availableSlots: availableSlots,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Patient ID not found. Please log in again.')),
    );
  }
}


          ,child: Text("Book Appointment" , style:  TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class Availability {
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  Availability({required this.dayOfWeek, required this.startTime, required this.endTime});

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'].substring(0, 5),
      endTime: json['endTime'].substring(0, 5),
    );
  }
}

class PolygonBorder extends ShapeBorder {
  final int sides;
  final double borderWidth;

  const PolygonBorder({this.sides = 8, this.borderWidth = 1.0});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final angle = (2 * math.pi) / sides;
    final radius = rect.shortestSide / 2;
    final center = rect.center;

    for (int i = 0; i < sides; i++) {
      final x = center.dx + radius * math.cos(i * angle);
      final y = center.dy + radius * math.sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}




























// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';

// class DoctorDetailsScreen extends StatefulWidget {
//   final int doctorId;
//   const DoctorDetailsScreen({required this.doctorId});

//   @override
//   _DoctorDetailsScreenState createState() => _DoctorDetailsScreenState();
// }

// class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
//   Map<String, dynamic>? _doctor;
//   List<Availability> _availabilities = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchDoctorData();
//   }

//   Future<void> fetchDoctorData() async {
//     setState(() => _isLoading = true);
//     try {
//       final profileUri =
//           Uri.parse('http://10.0.2.2:8080/api/doctors/${widget.doctorId}');
//       final availabilityUri = Uri.parse(
//           'http://10.0.2.2:8080/api/doctors/${widget.doctorId}/availability');

//       final profileResponse = await http.get(profileUri);
//       final availabilityResponse = await http.get(availabilityUri);

//       if (profileResponse.statusCode == 200 && availabilityResponse.statusCode == 200) {
//         setState(() {
//           _doctor = jsonDecode(profileResponse.body);
//           _availabilities = (jsonDecode(availabilityResponse.body) as List)
//               .map((e) => Availability.fromJson(e))
//               .toList();
//           _isLoading = false;
//         });
//       } else {
//         print('Error fetching data');
//       }
//     } catch (e) {
//       print('Error fetching doctor data: $e');
//     }
//   }

//   Widget buildStatCard(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: ShapeDecoration(
//             shape: PolygonBorder(sides: 8),
//             color: Colors.deepPurple.shade50,
//           ),
//           child: Center(
//             child: Icon(icon, color: Colors.deepPurple, size: 20),
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(value,
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
//         SizedBox(height: 2),
//         Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 11))
//       ],
//     );
//   }

//   Widget buildAvailabilitySection() {
//     if (_availabilities.isEmpty) {
//       return Text("No working hours available");
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Working Hours", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         SizedBox(height: 8),
//         ..._availabilities.map((a) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(a.dayOfWeek),
//                   Text('${a.startTime} - ${a.endTime}'),
//                 ],
//               ),
//             ))
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Center(child: Text("Doctor Details"))),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Doctor Details"),
//         backgroundColor: Colors.white,
//         actions: [Icon(Icons.more_vert)],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundImage: _doctor!["profilePictureUrl"] != null
//                       ? NetworkImage(_doctor!["profilePictureUrl"])
//                       : null,
//                   child: _doctor!["profilePictureUrl"] == null ? Icon(Icons.person, size: 40) : null,
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(_doctor!["name"] ?? '',
//                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                       Text(_doctor!["specialty"] ?? '',
                      
//                           style: TextStyle(color: Colors.grey[700])),
//                       Row(
//                         children: [
//                           //Icon(Icons.local_hospital, size: 16),
//                           SizedBox(width: 4),
// Text(_doctor!["affiliations"] ?? '',
//                           style: TextStyle(color: Colors.grey[700])),                        ],
//                       )
//                     ],
//                   ),
//                 ),
//                 Text("\$30/hour",
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))
//               ],
//             ),
//             SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 buildStatCard("Education", "${_doctor!["education"]}", Icons.school),
//                 buildStatCard("Certifications", "${_doctor!["certifications"]}", Icons.verified),
//                 buildStatCard("Languages", "${_doctor!["languagesSpoken"]}", Icons.language),
//                 buildStatCard("Affiliation", "${_doctor!["affiliations"]}", Icons.local_hospital),
//               ],
//             ),
//             SizedBox(height: 24),
//             Text("About Doctor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text(_doctor!["bio"] ?? ""),
//             SizedBox(height: 16),
//             buildAvailabilitySection(),
//             SizedBox(height: 80)
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 5)]),
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             padding: EdgeInsets.symmetric(vertical: 16),
//           ),
//           onPressed: () {
//             // TODO: Navigate to booking screen
//           },
//           child: Text("Book Appointment"),
//         ),
//       ),
//     );
//   }
// }

// class Availability {
//   final String dayOfWeek;
//   final String startTime;
//   final String endTime;

//   Availability({required this.dayOfWeek, required this.startTime, required this.endTime});

//   factory Availability.fromJson(Map<String, dynamic> json) {
//     return Availability(
//       dayOfWeek: json['dayOfWeek'],
//       startTime: json['startTime'].substring(0, 5),
//       endTime: json['endTime'].substring(0, 5),
//     );
//   }
// }

// class PolygonBorder extends ShapeBorder {
//   final int sides;
//   final double borderWidth;

//   PolygonBorder({this.sides = 8, this.borderWidth = 1.0});

//   @override
//   EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

//   @override
//   Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
//     final path = Path();
//     final angle = (2 * math.pi) / sides;
//     final radius = rect.shortestSide / 2;
//     final center = rect.center;

//     for (int i = 0; i < sides; i++) {
//       final x = center.dx + radius * math.cos(i * angle);
//       final y = center.dy + radius * math.sin(i * angle);
//       if (i == 0)
//         path.moveTo(x, y);
//       else
//         path.lineTo(x, y);
//     }
//     path.close();
//     return path;
//   }

//   @override
//   Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
//     return getOuterPath(rect, textDirection: textDirection);
//   }

//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

//   @override
//   ShapeBorder scale(double t) => this;
// }
