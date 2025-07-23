import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  List<dynamic> allUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/admins/all-users'));

    if (response.statusCode == 200) {
      setState(() {
        allUsers = json.decode(response.body);
        isLoading = false;
        print(json.decode(response.body));

      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load users")),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8080/api/admins/delete-user/$id'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted")),
      );
      fetchUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete user")),
      );
    }
  }

  List<dynamic> filterUsers(String role) {
  if (role == "ALL") return allUsers;

  final roleMap = {
    "admin": "ROLE_ADMIN",
    "doctor": "ROLE_DOCTOR",
    "patient": "ROLE_PATIENT",
  };

  final expectedRole = roleMap[role.toLowerCase()] ?? "";

  return allUsers.where((user) => user['role'] == expectedRole).toList();
}


  // List<dynamic> filterUsers(String role) {
  //   if (role == "ALL") return allUsers;
  //   return allUsers.where((user) => user['role'].toString().toLowerCase().contains(role.toLowerCase())).toList();
  // }

  Widget buildUserCard(user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['name'] ?? 'No Name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(user['email']),
            ]),
            Row(children: [
              const Icon(Icons.badge, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text("ID: ${user['id']}"),
            ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  onPressed: () => deleteUser(user['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FFFC),
        appBar: AppBar(
          title: const Text("User Management"),
          backgroundColor: Colors.deepPurpleAccent,
          bottom: const TabBar(
            tabs: [
              Tab(text: "All Users"),
              Tab(text: "Admins"),
              Tab(text: "Doctors"),
              Tab(text: "Patients"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  buildUserList("ALL"),
                  buildUserList("admin"),
                  buildUserList("doctor"),
                  buildUserList("patient"),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            // Handle bottom nav tap if needed
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.pending), label: 'Pending'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Logs'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildUserList(String roleFilter) {
    final users = filterUsers(roleFilter);
    if (users.isEmpty) {
      return const Center(child: Text("No users found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return buildUserCard(users[index]);
      },
    );
  }
}
