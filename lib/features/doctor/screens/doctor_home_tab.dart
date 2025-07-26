import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:telemed_frontend/features/doctor/screens/doctor_guides_screen.dart';
import 'package:telemed_frontend/features/doctor/screens/doctor_medication_guides_tab.dart';
import 'package:telemed_frontend/features/doctor/screens/doctor_prescription_final_tab.dart';
import 'package:telemed_frontend/features/doctor/screens/doctor_prescriptions_tab.dart';
import 'package:telemed_frontend/features/doctor/screens/doctor_reviews_tab.dart';
import 'package:telemed_frontend/features/doctor/screens/medication_guide_tab.dart';
import 'package:telemed_frontend/utils/constants.dart' as Constants;
import '../../../utils/constants.dart';
import '../../video_call/video_launcher_screen.dart';
import 'doctor_availability_tab.dart'; // Add this import
//import '../video/video_launcher_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Doctor data
  Map<String, dynamic>? doctorData;
  List<Map<String, dynamic>> upcomingAppointments = [];
  
  bool isLoadingDoctor = true;
  bool isLoadingAppointments = true;
  //String? errorMessage;
  String? doctorErrorMessage;
String? appointmentsErrorMessage;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDoctorData();
    _loadUpcomingAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadDoctorData() async {
    try {
      setState(() {
        isLoadingDoctor = true;
        doctorErrorMessage = null;
      });

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Decode token to get doctor ID
      final decodedToken = JwtDecoder.decode(token);
      final doctorId = decodedToken['id'];
      
      if (doctorId == null) {
        throw Exception('Doctor ID not found in token');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/doctors/$doctorId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          doctorData = data;
          isLoadingDoctor = false;
        });
      } else {
        throw Exception('Failed to load doctor data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        doctorErrorMessage = e.toString();
        isLoadingDoctor = false;
      });
    }
  }

  Future<void> _loadUpcomingAppointments() async {
    try {
      setState(() {
        isLoadingAppointments = true;
          //appointmentsErrorMessage = null;

      });

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments/doctor/upcoming'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          upcomingAppointments = data.cast<Map<String, dynamic>>();
          isLoadingAppointments = false;
        });
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        appointmentsErrorMessage = e.toString();
        isLoadingAppointments = false;
      });
    }
  }

  void _navigateToVideoCall(String appointmentId) async {
    final token = await _getToken();
    if (token != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoLauncherScreen(
            appointmentId: appointmentId,
            token: token,
          ),
        ),
      );
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Profile Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isLoadingDoctor
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : doctorErrorMessage != null
                    ? Column(
                        children: [
                          const Icon(Icons.error, color: Colors.white, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading profile',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadDoctorData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF2ECC71),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Profile Picture
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: // Improved version of your profile image display
ClipRRect(
  borderRadius: BorderRadius.circular(40),
  child: doctorData?['profilePictureUrl'] != null &&
          doctorData!['profilePictureUrl'].toString().isNotEmpty
      ? Image.network(
          // Construct the full URL for the image
          '${Constants.baseUrl}${doctorData!['profilePictureUrl']}', // Make sure to prepend your base URL
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                  strokeWidth: 2,
                  color: Color(0xFF2ECC71),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error');
            print('Image URL: ${Constants.baseUrl}${doctorData!['profilePictureUrl']}');
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[100],
              child: Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF2ECC71),
              ),
            );
          },
        )
      : Container(
          width: 80,
          height: 80,
          color: Colors.grey[100],
          child: Icon(
            Icons.person,
            size: 40,
            color: Color(0xFF2ECC71),
          ),
        ),
),
                            
                          ),
                          const SizedBox(width: 16),
                          // Doctor Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctorData?['name'] ?? 'Doctor',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (doctorData?['specialty'] != null)
                                  Text(
                                    doctorData!['specialty'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
          
          const SizedBox(height: 24),
          
          // Upcoming Appointments Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              if (!isLoadingAppointments)
                TextButton(
                  onPressed: _loadUpcomingAppointments,
                  child: const Text('Refresh'),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Appointments List
          if (isLoadingAppointments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (upcomingAppointments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming appointments',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingAppointments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = upcomingAppointments[index];
                return _buildAppointmentCard(appointment);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final DateTime appointmentDate = DateTime.parse(appointment['appointmentDate']);
    final String patientName = appointment['patientName'] ?? 'Unknown Patient';
    final String status = appointment['status'] ?? 'PENDING';
    final String appointmentId = appointment['id']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2ECC71).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: Color(0xFF2ECC71),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year} at ${appointmentDate.hour}:${appointmentDate.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToVideoCall(appointmentId),
                  icon: const Icon(Icons.video_call, size: 18),
                  label: const Text('Start Video Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to appointment details
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '$tabName Content',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This tab is under construction',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FFFC),
      appBar: AppBar(
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add notifications functionality
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login/doctor');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          const DoctorAvailabilityTab(),
          //_buildPlaceholderTab('Tab 2'),
              const DoctorReviewsTab(), // ✅ Replace this line

          //_buildPlaceholderTab('Tab 3'),

          const DoctorPrescriptionFinalTab(),

          //const DoctorPrescriptionsTab(),

          //_buildPlaceholderTab('Tab 4'),

          const DoctorGuidesScreen(),

          //const     DoctorMedicationGuidesTab(), // NEW TAB 5

          //_buildPlaceholderTab('Tab 5'),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFF2ECC71),
          labelColor: Color(0xFF2ECC71),
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
              text: 'Home',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Availability',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Reviews',
            ),
            Tab(
              icon: Icon(Icons.medical_services),
              text: 'Prescriptions',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Guides',
            ),
          ],
        ),
      ),
    );
  }
}