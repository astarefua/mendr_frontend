import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import your DoctorDetailsScreen
import 'doctor_details_screen.dart'; // Update this path as necessary

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  _DoctorSearchScreenState createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('http://10.0.2.2:8080/api/doctors/search?specialty=$query');

      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        // Add Authorization header if needed
        // 'Authorization': 'Bearer YOUR_JWT_TOKEN',
      });

      if (res.statusCode == 200) {
        setState(() {
          _results = jsonDecode(res.body);
        });
      } else {
        print('Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildResultList() {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_results.isEmpty) return Center(child: Text('No doctors found'));

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (ctx, i) {
        final doctor = _results[i];
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDetailsScreen(doctorId: doctor['id']),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundImage: doctor['profilePictureUrl'] != null &&
                    doctor['profilePictureUrl'].isNotEmpty
                ? NetworkImage(doctor['profilePictureUrl'])
                : null,
            child: (doctor['profilePictureUrl'] == null ||
                    doctor['profilePictureUrl'].isEmpty)
                ? Icon(Icons.person)
                : null,
          ),
          title: Text(doctor['name'] ?? ''),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  doctor['specialty'] ?? '',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              if (doctor['reviewsRating'] != null)
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      doctor['reviewsRating'].toStringAsFixed(1),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Search by name or specialty',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: _buildResultList(),
    );
  }
}


















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class DoctorSearchScreen extends StatefulWidget {
//   @override
//   _DoctorSearchScreenState createState() => _DoctorSearchScreenState();
// }

// class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
//   final TextEditingController _controller = TextEditingController();
//   List<dynamic> _results = [];
//   bool _isLoading = false;


// //     Future<void> _searchDoctors() async {
// //     final query = _searchController.text.trim();
// //     if (query.isEmpty) return;

// //     setState(() {
// //       _isLoading = true;
// //       _searchResults = [];
// //     });


// //     try {
// //       final response = await http.get(
// //         Uri.parse('http://10.0.2.2:8080/api/doctors/search?specialty=$query'),
// //         headers: {'Content-Type': 'application/json'},
// //       );

// //       if (response.statusCode == 200) {
// //   setState(() {
// //     _searchResults = jsonDecode(response.body);
// //   });
// // } else {
// //   print('Error ${response.statusCode}: ${response.body}');
// //   ScaffoldMessenger.of(context).showSnackBar(
// //     SnackBar(content: Text('Failed to fetch doctors')),
// //   );
// // }

// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error: $e')),
// //       );
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }


//   Future<void> _search(String query) async {
//     if (query.isEmpty) return;
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final uri = Uri.parse('http://10.0.2.2:8080/api/doctors/search')
//           .replace(queryParameters: {
//         'name': query,
//         'specialty': query,
//       });

//       final res = await http.get(uri, headers: {
//         'Content-Type': 'application/json',
//         // Add token if needed
//       });

//       if (res.statusCode == 200) {
//         setState(() {
//           _results = jsonDecode(res.body);
//         });
//       } else {
//         print('Error ${res.statusCode}: ${res.body}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Widget _buildResultList() {
//     if (_isLoading) return Center(child: CircularProgressIndicator());
//     if (_results.isEmpty) return Center(child: Text('No doctors found'));

//     return ListView.builder(
//       itemCount: _results.length,
//       itemBuilder: (ctx, i) {
//         final doctor = _results[i];
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundImage: doctor['profilePictureUrl'] != null &&
//                     doctor['profilePictureUrl'].isNotEmpty
//                 ? NetworkImage(doctor['profilePictureUrl'])
//                 : null,
//             child: (doctor['profilePictureUrl'] == null ||
//                     doctor['profilePictureUrl'].isEmpty)
//                 ? Icon(Icons.person)
//                 : null,
//           ),
//           title: Text(doctor['name'] ?? ''),
//           subtitle: Text(doctor['specialty'] ?? ''),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: TextField(
//           controller: _controller,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: 'Search doctor by name or specialty',
//             border: InputBorder.none,
//           ),
//           onChanged: _search,
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.close),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           )
//         ],
//         backgroundColor: Colors.white,
//       ),
//       body: _buildResultList(),
//     );
//   }
// }
