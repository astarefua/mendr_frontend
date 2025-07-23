import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart'; // Make sure baseUrl is defined here
import '../../../data/services/auth_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception("No token found. Please log in.");

      final response = await http.get(
        Uri.parse('$baseUrl/api/admins/all-users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load users: ${response.body}");
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  List<Map<String, dynamic>> _filterByRole(String role) {
    return _users.where((user) => user['role'] == role).toList();
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(user['name'] ?? 'No Name'),
        subtitle: Text(user['email']),
        trailing: Text(user['role'].replaceAll('ROLE_', '')),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Patients'),
            Tab(text: 'Doctors'),
            Tab(text: 'Admins'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  children: _filterByRole("ROLE_PATIENT")
                      .map<Widget>((user) => _buildUserCard(user))
                      .toList(),
                ),
                ListView(
                  children: _filterByRole("ROLE_DOCTOR")
                      .map<Widget>((user) => _buildUserCard(user))
                      .toList(),
                ),
                ListView(
                  children: _filterByRole("ROLE_ADMIN")
                      .map<Widget>((user) => _buildUserCard(user))
                      .toList(),
                ),
              ],
            ),
    );
  }
}
