import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telemed_frontend/features/patient/screens/med_tracker.dart';
import 'package:telemed_frontend/features/patient/screens/medication_tracking_screen_final.dart';
import 'package:telemed_frontend/utils/constants.dart';
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

  print('DEBUG: patientId = $patientId');
  print('DEBUG: token = $token');

  if (patientId == null || token == null) {
    print('DEBUG: patientId or token is null, returning early');
    return;
  }

  final url = Uri.parse('$baseUrl/api/patients/$patientId');
  print('DEBUG: Making request to: $url');
  
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  print('DEBUG: Response status: ${response.statusCode}');
  print('DEBUG: Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('DEBUG: Parsed data: $data');
    setState(() {
      patientName = data['name'];
      profilePictureUrl = data['profilePictureUrl'];
    });
    print('DEBUG: Set patientName = $patientName, profilePictureUrl = $profilePictureUrl');
  }
}





  Future<void> fetchTopDoctors() async {
    final response = await http.get(Uri.parse('$baseUrl/api/doctors/top-rated?limit=2'));
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
      Uri.parse('$baseUrl/api/medication/guides'),
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


  void _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Remove token and user data

  // Navigate to login screen
  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
                    ? NetworkImage('$baseUrl$profilePictureUrl')

                  //? NetworkImage(profilePictureUrl!)
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

        PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert, size: 30, color: Colors.black),
  onSelected: (String value) {
    if (value == 'update') {
      // Navigate to update profile screen
      Navigator.pushNamed(context, '/update-profile');
    } else if (value == 'notifications') {
      // Navigate to notifications screen
      Navigator.pushNamed(context, '/notifications');
    } else if (value == 'logout') {
      // Log out logic here
      // Clear shared preferences, navigate to login
      _logout(context);
    }
  },
  itemBuilder: (BuildContext context) => [
    const PopupMenuItem(
      value: 'update',
      child: Text('Update Profile'),
    ),
    const PopupMenuItem(
      value: 'notifications',
      child: Text('See Notifications'),
    ),
    const PopupMenuItem(
      value: 'logout',
      child: Text('Log Out'),
    ),
  ],
),








        // Stack(
        //   children: [
        //     const Icon(Icons.notifications_none, size: 30, color: Colors.black),
        //     Positioned(
        //       right: 0,
        //       top: 0,
        //       child: Container(
        //         width: 8,
        //         height: 8,
        //         decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        //       ),
        //     )
        //   ],
        // ),
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
                ?MedicationTrackingScreenFinal()
                //? MedicationTrackingScreen()

          //? DrugsTrackerScreen(guideId: guideId!)
          : const NoMedicationScreen(), // 👈 shows message if no guide
      MendrAIScreen(),
      DrugSearchScreen()
    
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
                    CircleAvatar(
  radius: 45, 
  backgroundImage: doctor['profilePictureUrl'] != null 
      ? NetworkImage('$baseUrl${doctor['profilePictureUrl']}') 
      : null,
  child: doctor['profilePictureUrl'] == null ? Icon(Icons.person, size: 50) : null,
),
                    //CircleAvatar(radius: 45, backgroundImage: NetworkImage(doctor['profilePictureUrl'])),
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























