// screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:telemed_frontend/features/admin/models/analytics_model.dart';
import 'package:telemed_frontend/features/admin/models/doctor_model.dart';
import 'package:telemed_frontend/features/admin/models/system_log_model.dart';
import 'package:telemed_frontend/features/admin/models/user_model.dart';
//import 'package:telemed_frontend/features/admin/services/log_service.dart';
import 'package:telemed_frontend/features/admin/services/user_service.dart';
// 🆕 LOG CODE: Added import for date formatting
import 'package:intl/intl.dart';
// 🆕 PENDING CODE: Added import for DoctorResponseDTO model
import 'package:telemed_frontend/features/admin/models/doctor_model.dart';

import 'dart:math' as math;


// Custom Painter for Pie Chart
class PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final List<Color> colors;
  final int total;

  PieChartPainter(this.data, this.colors, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    double startAngle = -math.pi / 2;
    int colorIndex = 0;
    
    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '$title Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This feature will be implemented next',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomIndex = 0;
  List<UserSummaryDTO> _allUsers = [];


  
  


  // 🆕 LOG CODE: Added logs list and loading state
  List<SystemLog> _systemLogs = [];
  bool _isLogsLoading = false;
  bool _isLoading = true;

  // 🆕 PENDING CODE: Added pending doctors list and loading state
  List<DoctorResponseDTO> _pendingDoctors = [];
  bool _isPendingLoading = false;
  //bool _isLoading = true;


  



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
    //_loadLogs();

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  // 🆕 LOG CODE: Added method to load system logs
  Future<void> _loadLogs() async {
    try {
      setState(() => _isLogsLoading = true);
      final logs = await AdminService.getLogs();
      setState(() {
        _systemLogs = logs;
        _isLogsLoading = false;
      });
    } catch (e) {
      setState(() => _isLogsLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading logs: $e')),
      );
    }
  }


  

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      final users = await AdminService.getAllUsers();
      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  // 🆕 PENDING CODE: Added method to load pending doctors
  Future<void> _loadPendingDoctors() async {
    try {
      setState(() => _isPendingLoading = true);
      final doctors = await AdminService.getPendingDoctors();
      setState(() {
        _pendingDoctors = doctors;
        _isPendingLoading = false;
      });
    } catch (e) {
      setState(() => _isPendingLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pending doctors: $e')),
      );
    }
  }

  // 🆕 PENDING CODE: Added method to approve doctor
  Future<void> _approveDoctor(int doctorId, String doctorName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Doctor'),
        content: Text('Are you sure you want to approve Dr. $doctorName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Approve', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await AdminService.approveDoctor(doctorId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Doctor approved successfully')),
          );
          _loadPendingDoctors(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve doctor')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving doctor: $e')),
        );
      }
    }
  }


  

  Future<void> _deleteUser(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await AdminService.deleteUser(userId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User deleted successfully')),
          );
          _loadUsers(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete user')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  

  List<UserSummaryDTO> _getFilteredUsers() {
    switch (_tabController.index) {
      case 1:
        return _allUsers.where((user) => user.role.toLowerCase().contains('admin')).toList();
      case 2:
        return _allUsers.where((user) => user.role.toLowerCase().contains('doctor')).toList();
      case 3:
        return _allUsers.where((user) => user.role.toLowerCase().contains('patient')).toList();
      default:
        return _allUsers;
    }
  }

  // 🆕 PENDING CODE: Added method to build pending doctors content
  Widget _buildPendingContent() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Icon(Icons.pending_actions, color: Colors.orange[600], size: 24),
              SizedBox(width: 10),
              Text(
                'Pending Doctor Approvals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_pendingDoctors.length} pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Pending Doctors List
        Expanded(
          child: _isPendingLoading
              ? Center(child: CircularProgressIndicator())
              : _pendingDoctors.isEmpty
                  ? _buildEmptyPendingState()
                  : RefreshIndicator(
                      onRefresh: _loadPendingDoctors,
                      child: ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: _pendingDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _pendingDoctors[index];
                          return _buildPendingDoctorCard(doctor);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // 🆕 PENDING CODE: Added method to build individual pending doctor cards
  Widget _buildPendingDoctorCard(DoctorResponseDTO doctor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and basic info
          Row(
            children: [
              // Profile picture or initial
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.orange[300]!, width: 2),
                ),
                child: doctor.profilePictureUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          doctor.profilePictureUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 16),
              // Basic info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${doctor.name}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[600],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      doctor.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Pending badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                    SizedBox(width: 4),
                    Text(
                      'PENDING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Additional info
          if (doctor.yearsOfExperience != null || doctor.education != null || doctor.bio != null) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (doctor.yearsOfExperience != null) ...[
                    Row(
                      children: [
                        Icon(Icons.work, size: 16, color: Colors.blue[600]),
                        SizedBox(width: 6),
                        Text(
                          '${doctor.yearsOfExperience} years of experience',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                  ],
                  if (doctor.education != null) ...[
                    Row(
                      children: [
                        Icon(Icons.school, size: 16, color: Colors.purple[600]),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            doctor.education!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                  ],
                  if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, size: 16, color: Colors.green[600]),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            doctor.bio!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          
          // ID and Action buttons
          Row(
            children: [
              Text(
                'ID: ${doctor.id}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              // Approve button
              ElevatedButton.icon(
                onPressed: () => _approveDoctor(doctor.id, doctor.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[500],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.check, size: 16),
                label: Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🆕 PENDING CODE: Added method to build empty pending state
  Widget _buildEmptyPendingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
          SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No pending doctor approvals at this time',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPendingDoctors,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }
    // return Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Icon(Icons.construction, size: 64, color: Colors.grey[400]),
    //       SizedBox(height: 16),
    //       Text(
    //         '$title Coming Soon',
    //         style: TextStyle(
    //           fontSize: 24,
    //           fontWeight: FontWeight.bold,
    //           color: Colors.grey[600],
    //         ),
    //       ),
    //       SizedBox(height: 8),
    //       Text(
    //         'This feature will be implemented next',
    //         style: TextStyle(
    //           fontSize: 16,
    //           color: Colors.grey[500],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  


  Widget _buildUsersContent() {
    return Column(
      children: [
        // Top Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue[600],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue[600],
            onTap: (index) => setState(() {}),
            tabs: [
              Tab(text: 'All Users'),
              Tab(text: 'Admins'),
              Tab(text: 'Doctors'),
              Tab(text: 'Patients'),
            ],
          ),
        ),
        // Users List
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _getFilteredUsers().length,
                    itemBuilder: (context, index) {
                      final user = _getFilteredUsers()[index];
                      return _buildUserCard(user);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserSummaryDTO user) {
    Color roleColor;
    String displayRole;
    
    switch (user.role.toLowerCase()) {
      case 'role_doctor':
      case 'doctor':
        roleColor = Colors.green[100]!;
        displayRole = 'DOCTOR';
        break;
      case 'role_patient':
      case 'patient':
        roleColor = Colors.blue[100]!;
        displayRole = 'PATIENT';
        break;
      case 'role_admin':
      case 'admin':
        roleColor = Colors.purple[100]!;
        displayRole = 'ADMIN';
        break;
      default:
        roleColor = Colors.grey[100]!;
        displayRole = user.role.toUpperCase();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Left border indicator
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name.isNotEmpty ? user.name : 'No Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        displayRole,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.blue[400]),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.badge, size: 16, color: Colors.purple[400]),
                    SizedBox(width: 6),
                    Text(
                      'ID: ${user.id}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Delete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _deleteUser(user.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Delete'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _buildOverviewSection(),
          SizedBox(height: 24),
          
          // Charts Section
          Text(
            'Analytics Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          
          // Chart Cards
          _buildChartCard(
            'Appointment Status Distribution',
            _buildStatusChart(),
          ),
          SizedBox(height: 16),
          
          _buildChartCard(
            'Doctor Approval Status',
            _buildDoctorApprovalChart(),
          ),
          SizedBox(height: 16),
          
          _buildChartCard(
            'Top 5 Most Booked Doctors',
            _buildTopDoctorsChart(),
          ),
          SizedBox(height: 16),
          
          _buildChartCard(
            'Appointments by Hour of Day',
            _buildHourlyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return FutureBuilder<OverviewStats>(
      future: AdminService.getOverviewStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        
        if (snapshot.hasError) {
          return _buildErrorCard('Failed to load overview stats');
        }
        
        final stats = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Patients',
                    stats.totalPatients.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Doctors',
                    stats.totalDoctors.toString(),
                    Icons.medical_services,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending Approvals',
                    stats.pendingDoctorApprovals.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Appointments',
                    stats.totalAppointments.toString(),
                    Icons.calendar_today,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }

  Widget _buildStatusChart() {
    return FutureBuilder<OverviewStats>(
      future: AdminService.getOverviewStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildChartLoading();
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildChartError();
        }
        
        final statusData = snapshot.data!.appointmentsByStatus;
        if (statusData.isEmpty) {
          return _buildNoDataChart();
        }
        
        return SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildPieChart(statusData),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatusLegend(statusData),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    final colors = [Colors.green, Colors.orange, Colors.red, Colors.blue];
    final total = data.values.fold(0, (sum, count) => sum + count);
    
    return CustomPaint(
      size: Size(150, 150),
      painter: PieChartPainter(data, colors, total),
    );
  }

  Widget _buildStatusLegend(Map<String, int> data) {
    final colors = [Colors.green, Colors.orange, Colors.red, Colors.blue];
    final entries = data.entries.toList();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final statusEntry = entry.value;
        final color = colors[index % colors.length];
        
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusEntry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${statusEntry.value}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDoctorApprovalChart() {
    return FutureBuilder<Map<String, int>>(
      future: AdminService.getDoctorApprovalStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildChartLoading();
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildChartError();
        }
        
        final data = snapshot.data!;
        return SizedBox(
          height: 150,
          child: Row(
            children: data.entries.map((entry) {
              final isApproved = entry.key == 'Approved';
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isApproved ? Colors.green[400] : Colors.orange[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.value}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTopDoctorsChart() {
    return FutureBuilder<Map<String, int>>(
      future: AdminService.getMostBookedDoctors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildChartLoading();
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildChartError();
        }
        
        final data = snapshot.data!;
        final topDoctors = data.entries.take(5).toList();
        
        if (topDoctors.isEmpty) {
          return _buildNoDataChart();
        }
        
        final maxValue = topDoctors.first.value;
        
        return Column(
          children: topDoctors.map((doctor) {
            final percentage = (doctor.value / maxValue);
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      doctor.key,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${doctor.value}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHourlyChart() {
    return FutureBuilder<Map<int, int>>(
      future: AdminService.getAppointmentsByHour(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildChartLoading();
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildChartError();
        }
        
        final data = snapshot.data!;
        final maxValue = data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b);
        
        return SizedBox(
          height: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(24, (index) {
                final count = data[index] ?? 0;
                final height = maxValue == 0 ? 0.0 : (count / maxValue * 150);
                
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: 20,
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartLoading() {
    return SizedBox(
      height: 150,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildChartError() {
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[400], size: 48),
            SizedBox(height: 8),
            Text(
              'Failed to load chart',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataChart() {
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: Colors.grey[400], size: 48),
            SizedBox(height: 8),
            Text(
              'No data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String message) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.red[600]),
            ),
          ],
        ),
      ),
    );
  }

  
  
  
  // void _showDoctorDetails(DoctorResponseDTO doctor) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: Container(
  //         constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
  //         padding: EdgeInsets.all(24),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Row(
  //               children: [
  //                 Text(
  //                   'Doctor Details',
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 Spacer(),
  //                 IconButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   icon: Icon(Icons.close),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 16),
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Profile section
  //                     Row(
  //                       children: [
  //                         CircleAvatar(
  //                           radius: 40,
  //                           backgroundColor: Colors.blue[100],
  //                           backgroundImage: doctor.profilePictureUrl != null
  //                               ? NetworkImage(doctor.profilePictureUrl!)
  //                               : null,
  //                           child: doctor.profilePictureUrl == null
  //                               ? Icon(Icons.person, color: Colors.blue[600], size: 40)
  //                               : null,
  //                         ),
  //                         SizedBox(width: 16),
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 doctor.name,
  //                                 style: TextStyle(
  //                                   fontSize: 18,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),
  //                               Text(
  //                                 doctor.specialty,
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   color: Colors.blue[600],
  //                                 ),
  //                               ),
  //                               Text(
  //                                 doctor.email,
  //                                 style: TextStyle(
  //                                   fontSize: 14,
  //                                   color: Colors.grey[600],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 24),
                      
  //                     // Detailed information
  //                     _buildDetailRow('Years of Experience', '${doctor.yearsOfExperience} years'),
  //                     _buildDetailRow('Education', doctor.education),
  //                     _buildDetailRow('Affiliations', doctor.affiliations),
  //                     _buildDetailRow('Rating', '${doctor.reviewsRating.toStringAsFixed(1)} / 5.0'),
                      
  //                     if (doctor.bio.isNotEmpty) ...[
  //                       SizedBox(height: 16),
  //                       Text(
  //                         'Biography',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                       SizedBox(height: 8),
  //                       Text(
  //                         doctor.bio,
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           color: Colors.grey[600],
  //                         ),
  //                       ),
  //                     ],
                      
  //                     if (doctor.certifications.isNotEmpty) ...[
  //                       SizedBox(height: 16),
  //                       Text(
  //                         'Certifications',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                       SizedBox(height: 8),
  //                       ...doctor.certifications.map((cert) => Padding(
  //                         padding: EdgeInsets.symmetric(vertical: 2),
  //                         child: Row(
  //                           children: [
  //                             Icon(Icons.verified, size: 16, color: Colors.green),
  //                             SizedBox(width: 8),
  //                             Expanded(child: Text(cert)),
  //                           ],
  //                         ),
  //                       )),
  //                     ],
                      
  //                     if (doctor.languagesSpoken.isNotEmpty) ...[
  //                       SizedBox(height: 16),
  //                       Text(
  //                         'Languages Spoken',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                       SizedBox(height: 8),
  //                       Text(
  //                         doctor.languagesSpoken.join(', '),
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           color: Colors.grey[600],
  //                         ),
  //                       ),
  //                     ],
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       _approveDoctor(doctor.id);
  //                     },
  //                     child: Text('Approve Doctor'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.green[500],
  //                       foregroundColor: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }


  // Widget _buildDetailRow(String label, String value) {
  //   if (value.isEmpty) return SizedBox.shrink();
    
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 140,
  //           child: Text(
  //             '$label:',
  //             style: TextStyle(
  //               fontWeight: FontWeight.w500,
  //               color: Colors.grey[700],
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: TextStyle(
  //               color: Colors.grey[800],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  
  // 🆕 LOG CODE: Added method to build logs content
  Widget _buildLogsContent() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Icon(Icons.list_alt, color: Colors.blue[600], size: 24),
              SizedBox(width: 12),
              Text(
                'System Activity Logs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              Text(
                '${_systemLogs.length} entries',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // Logs List
        Expanded(
          child: _isLogsLoading
              ? Center(child: CircularProgressIndicator())
              : _systemLogs.isEmpty
                  ? _buildEmptyLogsState()
                  : RefreshIndicator(
                      onRefresh: _loadLogs,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _systemLogs.length,
                        itemBuilder: (context, index) {
                          final log = _systemLogs[index];
                          return _buildLogCard(log);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // 🆕 LOG CODE: Added method to build individual log cards
  Widget _buildLogCard(SystemLog log) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy • HH:mm');
    
    // Determine action type and color
    Color actionColor;
    IconData actionIcon;
    
    if (log.action.toLowerCase().contains('delete')) {
      actionColor = Colors.red[400]!;
      actionIcon = Icons.delete;
    } else if (log.action.toLowerCase().contains('create') || log.action.toLowerCase().contains('add')) {
      actionColor = Colors.green[400]!;
      actionIcon = Icons.add_circle;
    } else if (log.action.toLowerCase().contains('update') || log.action.toLowerCase().contains('edit')) {
      actionColor = Colors.orange[400]!;
      actionIcon = Icons.edit;
    } else if (log.action.toLowerCase().contains('login')) {
      actionColor = Colors.blue[400]!;
      actionIcon = Icons.login;
    } else {
      actionColor = Colors.grey[400]!;
      actionIcon = Icons.info;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Action icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              actionIcon,
              color: actionColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          // Log details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action
                Text(
                  log.action,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 6),
                // Performed by
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.blue[400]),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Performed by: ${log.performedBy}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Timestamp
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[400]),
                    SizedBox(width: 6),
                    Text(
                      formatter.format(log.timestamp),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Log ID
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'LOG ID: ${log.id}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 LOG CODE: Added method to build empty logs state
  Widget _buildEmptyLogsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No Logs Available',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'System activity logs will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadLogs,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Refresh Logs'),
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
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (_currentBottomIndex == 0) {
                _loadUsers();
              } else if (_currentBottomIndex == 2) {
                _loadPendingDoctors();
              } else if (_currentBottomIndex == 3) {
                _loadLogs();
              }
            },
            //onPressed: _currentBottomIndex == 0 ? _loadUsers : null,
          ),
        ],
      ),
      body:         IndexedStack(
        index: _currentBottomIndex,
        children: [
          _buildUsersContent(),
          _buildAnalyticsContent(),
          _buildPendingContent(),
          //_buildPlaceholder('Pending'),
        
           _buildLogsContent(),

          //_buildPlaceholder('Logs'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        // 🆕 LOG CODE: Updated onTap to load logs when switching to logs tab
        onTap: (index) {
          setState(() => _currentBottomIndex = index);
          if (index == 2 && _pendingDoctors.isEmpty && !_isPendingLoading) {
            _loadPendingDoctors();
          } else if (index == 3 && _systemLogs.isEmpty && !_isLogsLoading) {
            _loadLogs();
          }
        },
        //onTap: (index) => setState(() => _currentBottomIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
        ],
      ),
      floatingActionButton: _currentBottomIndex == 0
          ? FloatingActionButton(
              onPressed: _loadUsers,
              backgroundColor: Colors.blue[600],
              child: Icon(Icons.refresh, color: Colors.white),
            )
            // 🆕 PENDING CODE: Added floating action button for pending tab
          : _currentBottomIndex == 2
              ? FloatingActionButton(
                  onPressed: _loadPendingDoctors,
                  backgroundColor: Colors.orange[600],
                  child: Icon(Icons.refresh, color: Colors.white),
                )
          // 🆕 LOG CODE: Added floating action button for logs tab
          : _currentBottomIndex == 3
              ? FloatingActionButton(
                  onPressed: _loadLogs,
                  backgroundColor: Colors.blue[600],
                  child: Icon(Icons.refresh, color: Colors.white),
                )
              : null,
    );
  }
}



























