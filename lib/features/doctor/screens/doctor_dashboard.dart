// i didnt use this screen

import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF556B2F), // dark olive green
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              const Text(
                "Welcome, Doctor",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Manage your schedule and stay updated",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              _buildNavigationCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Doctor Dashboard",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        CircleAvatar(
          backgroundImage: AssetImage('assets/profile.jpg'),
        )
      ],
    );
  }

  Widget _buildNavigationCards(BuildContext context) {
    final List<Map<String, dynamic>> cards = [
      {
        'title': 'Set Availability',
        'icon': Icons.schedule,
        'route': '/doctor/set-availability',
      },
      {
        'title': 'Upcoming Appointments',
        'icon': Icons.calendar_today,
        'route': '/doctor/appointments',
      },
      {
        'title': 'My Availabilities',
        'icon': Icons.list_alt,
        'route': '/doctor/availabilities',
      },
      {
        'title': 'Update Profile',
        'icon': Icons.person,
        'route': '/doctor/profile',
      },
    ];

    return Expanded(
      child: GridView.builder(
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 4 / 3,
        ),
        itemBuilder: (context, index) {
          final item = cards[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, item['route']),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], size: 36, color: Colors.green[700]),
                  const SizedBox(height: 12),
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
