import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class DrugsTrackerScreen extends StatefulWidget {
  final int guideId;
  const DrugsTrackerScreen({super.key, required this.guideId});

  @override
  State<DrugsTrackerScreen> createState() => _DrugsTrackerScreenState();
}

class _DrugsTrackerScreenState extends State<DrugsTrackerScreen> {
  Map<String, dynamic>? guideData;
  Map<String, dynamic>? progressData;
  bool isLoading = true;
  List<bool> doseTaken = [];
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchGuideAndProgress();
  }

  Future<void> fetchGuideAndProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final guideResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/medication/guides'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final guideList = jsonDecode(guideResponse.body) as List;

      if (guideList.isEmpty) {
        setState(() {
          guideData = null;
          progressData = null;
          isLoading = false;
        });
        return;
      }

      final selectedGuide = guideList.firstWhere(
        (g) => g['id'] == widget.guideId,
        orElse: () => null,
      );

      if (selectedGuide == null) {
        setState(() {
          guideData = null;
          progressData = null;
          isLoading = false;
        });
        return;
      }

      final progressResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/medication/progress/${widget.guideId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      setState(() {
        guideData = selectedGuide;
        progressData = jsonDecode(progressResponse.body);
        doseTaken = List.filled(selectedGuide['dosesPerDay'], false);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching guide or progress: $e");
      setState(() {
        guideData = null;
        progressData = null;
        isLoading = false;
      });
    }
  }

  Future<void> confirmDose(int doseIndex) async {
    if (doseTaken[doseIndex]) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/medication/confirm/${widget.guideId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        doseTaken[doseIndex] = true;
      });
      fetchGuideAndProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose confirmed')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  String getTimeLabel(int index, int dosesPerDay) {
    final minutesPerDose = 1440 ~/ dosesPerDay;
    final time = TimeOfDay(hour: (index * minutesPerDose) ~/ 60, minute: 0);
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (guideData == null || progressData == null) {
      return Scaffold(
        // appBar: AppBar(
        //   title: const Text("Medication Tracker", style: TextStyle(color: Colors.white)),
        //   backgroundColor: Colors.green,
        //   centerTitle: true,
        // ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication_outlined, size: 60, color: Colors.blue),
                SizedBox(height: 20),
                Text(
                  "No Medication Assigned Yet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Once a doctor assigns medication, it will appear here for tracking.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dosesPerDay = guideData!['dosesPerDay'] as int;
    final medName = guideData!['medicationName'];
    final desc = guideData!['visualDescription'];

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Medication Tracker', style: TextStyle(color: Colors.white)),
      //   backgroundColor: Colors.green,
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Strip
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = today.subtract(Duration(days: 3 - index));
                    final isToday = date.day == today.day;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isToday ? Colors.green : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(DateFormat('E').format(date),
                              style: TextStyle(
                                  color: isToday ? Colors.white : Colors.black)),
                          Text(date.day.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? Colors.white : Colors.black))
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Today\'s Progress', style: TextStyle(fontSize: 18)),
                  CircularPercentIndicator(
                    radius: 40,
                    lineWidth: 8,
                    percent: (progressData!['progressPercentage'] / 100).clamp(0.0, 1.0),
                    center: Text(
                        '${progressData!['takenDoses']}/${progressData!['expectedDoses']}'),
                    progressColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text("Today's Medicine", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              for (int i = 0; i < dosesPerDay; i++)
                Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: doseTaken[i],
                      onChanged: (_) => confirmDose(i),
                      shape: const CircleBorder(),
                      activeColor: Colors.green,
                    ),
                    title: Text(medName),
                    subtitle: Text('$desc\nTake at ${getTimeLabel(i, dosesPerDay)}'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}












// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:intl/intl.dart';

// class DrugsTrackerScreen extends StatefulWidget {
//   final int guideId;
//   const DrugsTrackerScreen({super.key, required this.guideId});

//   @override
//   State<DrugsTrackerScreen> createState() => _DrugsTrackerScreenState();
// }

// class _DrugsTrackerScreenState extends State<DrugsTrackerScreen> {
//   Map<String, dynamic>? guideData;
//   Map<String, dynamic>? progressData;
//   bool isLoading = true;
//   List<bool> doseTaken = [];
//   final today = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     fetchGuideAndProgress();
//   }

//   Future<void> fetchGuideAndProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     try {
//       final guideResponse = await http.get(
//         Uri.parse('http://10.0.2.2:8080/api/medication/guides'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       final guideList = jsonDecode(guideResponse.body) as List;

//       if (guideList.isEmpty) {
//         print("No medication guides found.");
//         setState(() {
//           guideData = null;
//           progressData = null;
//           isLoading = false;
//         });
//         return;
//       }

//       final selectedGuide = guideList.firstWhere(
//         (g) => g['id'] == widget.guideId,
//         orElse: () => null,
//       );

//       if (selectedGuide == null) {
//         print("No guide found matching guideId: ${widget.guideId}");
//         setState(() {
//           guideData = null;
//           progressData = null;
//           isLoading = false;
//         });
//         return;
//       }

//       final progressResponse = await http.get(
//         Uri.parse('http://10.0.2.2:8080/api/medication/progress/${widget.guideId}'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       setState(() {
//         guideData = selectedGuide;
//         progressData = jsonDecode(progressResponse.body);
//         doseTaken = List.filled(selectedGuide['dosesPerDay'], false);
//         isLoading = false;
//       });
//     } catch (e, stack) {
//       print("Error fetching guide or progress: $e");
//       print("Stack: $stack");
//       setState(() {
//         guideData = null;
//         progressData = null;
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> confirmDose(int doseIndex) async {
//     if (doseTaken[doseIndex]) return;

//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     final response = await http.post(
//       Uri.parse('http://10.0.2.2:8080/api/medication/confirm/${widget.guideId}'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         doseTaken[doseIndex] = true;
//       });
//       fetchGuideAndProgress();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Dose confirmed')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${response.body}')),
//       );
//     }
//   }

//   String getTimeLabel(int index, int dosesPerDay) {
//     final minutesPerDose = 1440 ~/ dosesPerDay;
//     final time = TimeOfDay(hour: (index * minutesPerDose) ~/ 60, minute: 0);
//     return time.format(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (guideData == null || progressData == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text("Medication Tracker", style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.green,
//           centerTitle: true,
//         ),
//         body: const Center(
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.medication_outlined, size: 60, color: Colors.green),
//                 SizedBox(height: 20),
//                 Text(
//                   "No Medication Assigned Yet",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "Once a doctor assigns medication, it will appear here for tracking.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     final dosesPerDay = guideData!['dosesPerDay'] as int;
//     final medName = guideData!['medicationName'];
//     final desc = guideData!['visualDescription'];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Medication Tracker', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.green,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Calendar Strip
//               SizedBox(
//                 height: 50,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 7,
//                   itemBuilder: (context, index) {
//                     final date = today.subtract(Duration(days: 3 - index));
//                     final isToday = date.day == today.day;
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 6),
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: isToday ? Colors.green : Colors.grey[200],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Text(DateFormat('E').format(date),
//                               style: TextStyle(
//                                   color: isToday ? Colors.white : Colors.black)),
//                           Text(date.day.toString(),
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: isToday ? Colors.white : Colors.black))
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Progress
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Today\'s Progress', style: TextStyle(fontSize: 18)),
//                   CircularPercentIndicator(
//                     radius: 40,
//                     lineWidth: 8,
//                     percent: (progressData!['progressPercentage'] / 100).clamp(0.0, 1.0),
//                     center: Text(
//                         '${progressData!['takenDoses']}/${progressData!['expectedDoses']}'),
//                     progressColor: Colors.green,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text("Today's Medicine", style: TextStyle(fontSize: 20)),
//               const SizedBox(height: 10),
//               for (int i = 0; i < dosesPerDay; i++)
//                 Card(
//                   child: ListTile(
//                     leading: Checkbox(
//                       value: doseTaken[i],
//                       onChanged: (_) => confirmDose(i),
//                       shape: const CircleBorder(),
//                       activeColor: Colors.green,
//                     ),
//                     title: Text(medName),
//                     subtitle: Text('$desc\nTake at ${getTimeLabel(i, dosesPerDay)}'),
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:intl/intl.dart';

// class DrugsTrackerScreen extends StatefulWidget {
//   final int guideId;
//   const DrugsTrackerScreen({super.key, required this.guideId});

//   @override
//   State<DrugsTrackerScreen> createState() => _DrugsTrackerScreenState();
// }

// class _DrugsTrackerScreenState extends State<DrugsTrackerScreen> {
//   Map<String, dynamic>? guideData;
//   Map<String, dynamic>? progressData;
//   bool isLoading = true;
//   List<bool> doseTaken = [];
//   final today = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     fetchGuideAndProgress();
//   }

//   Future<void> fetchGuideAndProgress() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token');

//   try {
//     final guideResponse = await http.get(
//       Uri.parse('http://10.0.2.2:8080/api/medication/guides'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     final guideList = jsonDecode(guideResponse.body) as List;

//     if (guideList.isEmpty) {
//       setState(() {
//         guideData = null;
//         progressData = null;
//         isLoading = false;
//       });
//       return;
//     }

//     final selectedGuide =
//         guideList.firstWhere((g) => g['id'] == widget.guideId, orElse: () => null);

//     if (selectedGuide == null) {
//       setState(() {
//         guideData = null;
//         progressData = null;
//         isLoading = false;
//       });
//       return;
//     }

//     final progressResponse = await http.get(
//       Uri.parse('http://10.0.2.2:8080/api/medication/progress/${widget.guideId}'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     setState(() {
//       guideData = selectedGuide;
//       progressData = jsonDecode(progressResponse.body);
//       doseTaken = List.filled(selectedGuide['dosesPerDay'], false);
//       isLoading = false;
//     });
//   } catch (e) {
//     debugPrint('Error: $e');
//     setState(() => isLoading = false);
//   }
// }


//   // Future<void> fetchGuideAndProgress() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final token = prefs.getString('token');

//   //   try {
//   //     final guideResponse = await http.get(
//   //       Uri.parse('http://10.0.2.2:8080/api/medication/guides'),
//   //       headers: {'Authorization': 'Bearer $token'},
//   //     );

//   //     final progressResponse = await http.get(
//   //       Uri.parse('http://10.0.2.2:8080/api/medication/progress/${widget.guideId}'),
//   //       headers: {'Authorization': 'Bearer $token'},
//   //     );

//   //     final guideList = jsonDecode(guideResponse.body) as List;
//   //     final selectedGuide =
//   //         guideList.firstWhere((g) => g['id'] == widget.guideId);

//   //     setState(() {
//   //       guideData = selectedGuide;
//   //       progressData = jsonDecode(progressResponse.body);
//   //       doseTaken = List.filled(selectedGuide['dosesPerDay'], false);
//   //       isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     debugPrint('Error: $e');
//   //     setState(() => isLoading = false);
//   //   }
//   // }

//   Future<void> confirmDose(int doseIndex) async {
//     if (doseTaken[doseIndex]) return; // prevent double tap

//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     final response = await http.post(
//       Uri.parse('http://10.0.2.2:8080/api/medication/confirm/${widget.guideId}'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         doseTaken[doseIndex] = true;
//       });
//       fetchGuideAndProgress();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Dose confirmed')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${response.body}')),
//       );
//     }
//   }

//   String getTimeLabel(int index, int dosesPerDay) {
//     final minutesPerDose = 1440 ~/ dosesPerDay;
//     final time = TimeOfDay(hour: (index * minutesPerDose) ~/ 60, minute: 0);
//     return time.format(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (guideData == null || progressData == null) {
//   return Scaffold(
//     appBar: AppBar(
//       backgroundColor: Colors.green,
//       title: const Text("Medication Tracker", style: TextStyle(color: Colors.white)),
//       centerTitle: true,
//     ),
//     body: const Center(
//       child: Padding(
//         padding: EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.medication_outlined, size: 60, color: Colors.green),
//             SizedBox(height: 20),
//             Text(
//               "No medication assigned yet",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Once a doctor assigns a medication plan, it will appear here.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }


//     // if (guideData == null || progressData == null) {
//     //   return const Scaffold(
//     //     body: Center(child: Text('Unable to load data.')),
//     //   );
//     // }

//     final dosesPerDay = guideData!['dosesPerDay'] as int;
//     final medName = guideData!['medicationName'];
//     final desc = guideData!['visualDescription'];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Medication Tracker', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.green,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Calendar Strip
//               SizedBox(
//                 height: 50,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 7,
//                   itemBuilder: (context, index) {
//                     final date = today.subtract(Duration(days: 3 - index));
//                     final isToday = date.day == today.day;
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 6),
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: isToday ? Colors.green : Colors.grey[200],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Text(DateFormat('E').format(date),
//                               style: TextStyle(
//                                   color: isToday ? Colors.white : Colors.black)),
//                           Text(date.day.toString(),
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: isToday ? Colors.white : Colors.black))
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Progress
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Today\'s Progress', style: TextStyle(fontSize: 18)),
//                   CircularPercentIndicator(
//                     radius: 40,
//                     lineWidth: 8,
//                     percent:
//                         (progressData!['progressPercentage'] / 100).clamp(0.0, 1.0),
//                     center: Text(
//                         '${progressData!['takenDoses']}/${progressData!['expectedDoses']}'),
//                     progressColor: Colors.green,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text("Today's Medicine", style: TextStyle(fontSize: 20)),
//               const SizedBox(height: 10),
//               for (int i = 0; i < dosesPerDay; i++)
//                 Card(
//                   child: ListTile(
//                     leading: Checkbox(
//                       value: doseTaken[i],
//                       onChanged: (_) => confirmDose(i),
//                       shape: const CircleBorder(),
//                       activeColor: Colors.green,
//                     ),
//                     title: Text(medName),
//                     subtitle: Text('$desc\nTake at ${getTimeLabel(i, dosesPerDay)}'),
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
