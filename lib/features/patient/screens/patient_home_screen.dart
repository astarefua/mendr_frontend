import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telemed_frontend/features/patient/screens/med_tracker.dart';
import 'doctor_search_screen.dart';
import 'doctor_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'appointment_screen.dart';
import 'drugs_tracker_screen.dart';
import 'mendr_ai_screen.dart';
import 'wikipedia_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  List<dynamic> topDoctors = [];
  String? patientName;
  String? profilePictureUrl;
  int? guideId;

  @override
  void initState() {
    super.initState();
    fetchTopDoctors();
    fetchPatientProfile();
    fetchMedicationGuide();
  }

  Future<void> fetchPatientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getInt('patientId');
    final token = prefs.getString('token');

    if (patientId == null || token == null) return;

    final url = Uri.parse('http://10.0.2.2:8080/api/patients/$patientId');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        patientName = data['name'];
        profilePictureUrl = data['profilePictureUrl'];
      });
    }
  }

  Future<void> fetchTopDoctors() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/doctors/top-rated?limit=2'));
    if (response.statusCode == 200) {
      setState(() {
        topDoctors = json.decode(response.body);
      });
    }
  }

  Future<void> fetchMedicationGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/medication/guides'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          guideId = data[0]['id']; // Get first guide
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat('EEE, ddMMM yyyy').format(DateTime.now()).toUpperCase();

    return Scaffold(
      //backgroundColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildHeader(date),
            const SizedBox(height: 20),
            _buildSearchBar(context),
            const SizedBox(height: 30),
            _buildCategoryChips(),
            const SizedBox(height: 30),
            ...topDoctors.asMap().entries.map((entry) {
              int index = entry.key;
              var doctor = entry.value;
              return _buildDoctorCard(doctor, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorSearchScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(172, 229, 228, 228),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Text("Search", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: profilePictureUrl != null
                  ? NetworkImage(profilePictureUrl!)
                  : const AssetImage('assets/profile.jpg') as ImageProvider,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back 👋", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text(patientName ?? 'Loading...',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            )
          ],
        ),
        Stack(
          children: [
            const Icon(Icons.notifications_none, size: 30, color: Colors.black),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final categories = ["Appointments", "Drugs Tracker", "Mendr AI", "Wikipedia"];
    final icons = [
      Icons.calendar_today,
      Icons.medication_outlined,
      Icons.smart_toy_outlined,
      Icons.menu_book_outlined
    ];
    final screens = [
      PatientAppointmentsScreen(),
      guideId != null
                ? MedicationTrackingScreen()

          //? DrugsTrackerScreen(guideId: guideId!)
          : const NoMedicationScreen(), // 👈 shows message if no guide
      MendrAIScreen(),
      PillImageFetcher(),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(categories.length, (index) {
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screens[index])),
          child: Column(
            children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(icons[index], color: Colors.black)),
              const SizedBox(height: 6),
              Text(categories[index], style: const TextStyle(fontSize: 10, color: Colors.black))
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDoctorCard(dynamic doctor, int index) {
    final availableDays = (doctor['availableDays'] as List<dynamic>)
        .map((day) => day.toString().substring(0, 3).toUpperCase())
        .toList();

    final Color cardColor = index == 0 ? const Color.fromARGB(156, 0, 51, 255) : const Color.fromARGB(143, 0, 0, 255);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctorId: doctor['id'])),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 220,
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(30)),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(radius: 45, backgroundImage: NetworkImage(doctor['profilePictureUrl'])),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                const SizedBox(width: 4),
                                Text(doctor['averageRating'].toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(doctor['name'],
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(doctor['specialty'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // calendar strip

            





Container(
  height: 95,
  decoration: const BoxDecoration(
    color: Color(0xFFDDE7FF),
    borderRadius: BorderRadius.all(
      Radius.circular(25), // 👈 Curves all sides (top & bottom)
    ),
  ),
  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
  padding: const EdgeInsets.only(top: 5 , left: 8),
  child: const Text(
    'Slots',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
)
,
      // const Text(
      //   'Slots', // 👈 Your custom label here
      //   style: TextStyle(
          
      //     fontSize: 16,
      //     fontWeight: FontWeight.bold,
      //     color: Colors.white,
      //   ),
      // ),
      const SizedBox(height: 8),
      Expanded(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 7,
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index));
            final dayAbbr = DateFormat('E').format(date).substring(0, 3).toUpperCase();
            final dayNum = date.day;
            final isAvailable = availableDays.contains(dayAbbr);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal:   4, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.white : const Color(0xFFDDE7FF),
                borderRadius: BorderRadius.circular(30), // vertical oval
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayAbbr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  ),
)

            //calendar strip
//             Container(
//   height: 80,
//   decoration: const BoxDecoration(
//     color:  Color(0xFFDDE7FF), 
//     borderRadius: BorderRadius.all(
//       Radius.circular(20), // 👈 Curves all sides (top & bottom)
//     ),
//   ),
//   padding: const EdgeInsets.symmetric(vertical: 5),
//   child: ListView.builder(
//     scrollDirection: Axis.horizontal,
//     itemCount: 7,
//     itemBuilder: (context, index) {
//       final date = DateTime.now().add(Duration(days: index));
//       final dayAbbr = DateFormat('E').format(date).substring(0, 3).toUpperCase();
//       final dayNum = date.day;
//       final isAvailable = availableDays.contains(dayAbbr);

//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 5),
//         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
//         decoration: BoxDecoration(
//           color: isAvailable ? Colors.white : const Color(0xFFDDE7FF) ,
//           borderRadius: BorderRadius.circular(30), // vertical oval
//         ),
//         child: Column(
          


//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               dayAbbr,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               dayNum.toString(),
//               style: const TextStyle(
//                 //fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   ),
// )

            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            //   decoration: const BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: List.generate(7, (index) {
            //       final date = DateTime.now().add(Duration(days: index));
            //       final dayAbbr = DateFormat('E').format(date).substring(0, 3).toUpperCase();
            //       final dayNum = date.day;
            //       final isAvailable = availableDays.contains(dayAbbr);

            //       return Column(
            //         children: [
            //           Text(dayAbbr,
            //               style: TextStyle(
            //                   color: isAvailable ? Colors.blue : Colors.grey,
            //                   fontWeight: FontWeight.bold)),
            //           const SizedBox(height: 4),
            //           Container(
            //             padding: const EdgeInsets.all(6),
            //             decoration: BoxDecoration(
            //               color: isAvailable ? Colors.blue : Colors.grey.shade300,
            //               shape: BoxShape.circle,
            //             ),
            //             child: Text(dayNum.toString(),
            //                 style: const TextStyle(color: Colors.white, fontSize: 12)),
            //           ),
            //         ],
            //       );
            //     }),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}




// 🎯 Fallback screen if no medication guide exists
class NoMedicationScreen extends StatelessWidget {
  const NoMedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medication Tracker", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medication_outlined, size: 60, color: Colors.green),
              SizedBox(height: 20),
              Text("No Medication Assigned Yet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text("You don't have any medication plan assigned by your doctor.",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

























// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'doctor_search_screen.dart';
// import 'doctor_details_screen.dart'; // Make sure this exists
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'appointment_screen.dart';
// import 'drugs_tracker_screen.dart';
// import 'mendr_ai_screen.dart';
// import 'wikipedia_screen.dart';



// class PatientHomeScreen extends StatefulWidget {
//   const PatientHomeScreen({Key? key}) : super(key: key);

//   @override
//   State<PatientHomeScreen> createState() => _PatientHomeScreenState();
// }

// class _PatientHomeScreenState extends State<PatientHomeScreen> {
//   List<dynamic> topDoctors = [];
//   String? patientName;
// String? profilePictureUrl;
// int? guideId;



//   @override
//   void initState() {
//     super.initState();
//     fetchTopDoctors();
//       fetchPatientProfile(); // ⬅️ Add this
//       fetchMedicationGuide();


//   }


//   Future<void> fetchPatientProfile() async {
//   final prefs = await SharedPreferences.getInstance();
//   final patientId = prefs.getInt('patientId');
//   final token = prefs.getString('token');

//   if (patientId == null || token == null) {
//     print("Missing patientId or token");
//     return;
//   }

//   final url = Uri.parse('http://10.0.2.2:8080/api/patients/$patientId');
//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     setState(() {
//       patientName = data['name'];
//       profilePictureUrl = data['profilePictureUrl'];
//     });
//   } else {
//     print("Failed to fetch patient profile: ${response.statusCode}");
//   }
// }


//   Future<void> fetchTopDoctors() async {
//     final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/doctors/top-rated?limit=2'));

//     if (response.statusCode == 200) {
//       setState(() {
//         topDoctors = json.decode(response.body);
//       });
//     } else {
//       print("Failed to load doctors");
//     }
//   }


//   Future<void> fetchMedicationGuide() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token');

//   final response = await http.get(
//     Uri.parse('http://10.0.2.2:8080/api/medication/guides'),
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     },
//   );

//   if (response.statusCode == 200) {
//     final List data = jsonDecode(response.body);
//     if (data.isNotEmpty) {
//       setState(() {
//         guideId = data[0]['id']; // Grab first guide
//       });
//     }
//   } else {
//     print("Failed to load medication guides");
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     final String date =
//         DateFormat('EEE, ddMMM yyyy').format(DateTime.now()).toUpperCase();

//     return Scaffold(
//       backgroundColor: Color(0xFFF6FFFC),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(20.0),
//           children: [
//             _buildHeader(date),
//             const SizedBox(height: 20),
//             _buildSearchBar(context),
//             const SizedBox(height: 30),
//             _buildCategoryChips(),
//             const SizedBox(height: 30),
//             ...topDoctors.asMap().entries.map((entry) {
//   int index = entry.key;
//   var doctor = entry.value;
//   return _buildDoctorCard(doctor, index);
// }).toList(),

//             //...topDoctors.map((doctor) => _buildDoctorCard(doctor)).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => DoctorSearchScreen()),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Row(
//           children: const [
//             Icon(Icons.search, color: Colors.grey),
//             SizedBox(width: 10),
//             Text("Search", style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }



//   Widget _buildHeader(String date) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Row(
//         children: [
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: profilePictureUrl != null
//                 ? NetworkImage(profilePictureUrl!)
//                 : const AssetImage('assets/profile.jpg') as ImageProvider,
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Welcome back 👋",
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//               Text(
//                 patientName ?? 'Loading...',
//                 style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//             ],
//           )
//         ],
//       ),
//       Stack(
//         children: [
//           const Icon(Icons.notifications_none, size: 30, color: Colors.black),
//           Positioned(
//             right: 0,
//             top: 0,
//             child: Container(
//               width: 8,
//               height: 8,
//               decoration: const BoxDecoration(
//                   color: Colors.red, shape: BoxShape.circle),
//             ),
//           )
//         ],
//       ),
//     ],
//   );
// }



// Widget _buildCategoryChips() {
//     final categories = ["Appointments", "Drugs Tracker", "Mendr AI", "Wikepedia"];
//     final icons = [
//       Icons.calendar_today,
//       Icons.medication_outlined,
//       Icons.smart_toy_outlined,
//       Icons.menu_book_outlined
//     ];
//     final screens = [
//   AppointmentScreen(),
//   guideId != null 
//     ? DrugsTrackerScreen(guideId: guideId!) 
//     : Placeholder(), // fallback if null
//   MendrAIScreen(),
//   WikipediaScreen(),
// ];

    
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: List.generate(categories.length, (index) {
//         return GestureDetector(
//           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screens[index])),
//           child: Column(
//             children: [
//               CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(icons[index], color: Colors.black)),
//               const SizedBox(height: 6),
//               Text(categories[index], style: const TextStyle(fontSize: 10, color: Colors.black))
//             ],
//           ),
//         );
//       }),
//     );
//   }



  


//   Widget _buildDoctorCard(dynamic doctor, int index) {
//   final availableDays = (doctor['availableDays'] as List<dynamic>)
//       .map((day) => day.toString().substring(0, 3).toUpperCase())
//       .toList();

//   // 🎨 Alternate background color for 1st and 2nd doctor
//   final Color cardColor = index == 0
//       ? const Color(0xFFFFF4EC) // Blue
//       : const Color(0xFFF0F4FF); // Cyan/Teal variant for distinction

//   return GestureDetector(
//     onTap: () => Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => DoctorDetailsScreen(doctorId: doctor['id']),
//       ),
//     ),
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       height: 200,
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Column(
//         children: [
//           // 🔵 Top section with doctor image + info
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🖼 Doctor profile picture
//                   CircleAvatar(
//                     radius: 45,
//                     backgroundImage: NetworkImage(doctor['profilePictureUrl']),
//                   ),
//                   const SizedBox(width: 16),
//                   // 📄 Doctor Info
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // ⭐ Rating badge
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(Icons.star, color: Colors.orange, size: 16),
//                               const SizedBox(width: 4),
//                               Text(
//                                 doctor['averageRating'].toString(),
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, color: Colors.black),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           doctor['name'],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           doctor['specialty'],
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),

//           // 🔘 Bottom slots calendar area
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: List.generate(7, (index) {
//                 final date = DateTime.now().add(Duration(days: index));
//                 final dayAbbr = DateFormat('E').format(date).substring(0, 3).toUpperCase();
//                 final dayNum = date.day;
//                 final isAvailable = availableDays.contains(dayAbbr);

//                 return Column(
//                   children: [
//                     Text(
//                       dayAbbr,
//                       style: TextStyle(
//                         color: isAvailable ? Colors.blue : Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: isAvailable ? Colors.blue : Colors.grey.shade300,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Text(
//                         dayNum.toString(),
//                         style: const TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }


// }