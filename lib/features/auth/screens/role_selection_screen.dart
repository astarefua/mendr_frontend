import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  Future<void> _handleSelection(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSignedUp = prefs.getBool('hasSignedUp_$role') ?? false;

    if (hasSignedUp) {
      Navigator.pushNamed(context, '/login', arguments: role); // ✅ Pass role
    } else {
      Navigator.pushNamed(context, '/signup/$role');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
          

      backgroundColor: Color(0xFFFFFFFF),
      //backgroundColor: Color(0xFFF6FFFC),
    
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "AUTHORIZATION",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 14,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 30),
            RoleCard(
              title: 'I am a doctor',
              icon: Icons.medical_services_outlined,
              borderColor: Colors.deepOrange,
              iconColor: Colors.deepOrange,
              onTap: () => _handleSelection(context, 'doctor'),
            ),
            const SizedBox(height: 20),
            RoleCard(
              title: 'I am a patient',
              icon: Icons.assignment_ind_outlined,
              borderColor: Colors.green,
              iconColor: Colors.green,
              onTap: () => _handleSelection(context, 'patient'),
            ),
            const SizedBox(height: 20),
            RoleCard(
              title: 'I am an admin',
              icon: Icons.admin_panel_settings_outlined,
              borderColor: Colors.blue,
              iconColor: Colors.blue,
              onTap: () => _handleSelection(context, 'admin'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  const RoleCard({
    required this.title,
    required this.icon,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 2,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Icon(icon, size: 40, color: iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
























// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({Key? key}) : super(key: key);

//   Future<void> _handleSelection(BuildContext context, String role) async {
//     final prefs = await SharedPreferences.getInstance();
//     final hasSignedUp = prefs.getBool('hasSignedUp_$role') ?? false;

//     if (hasSignedUp) {
//       Navigator.pushNamed(context, '/login');
//     } else {
//       Navigator.pushNamed(context, '/signup/$role');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF6FFFC),
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "AUTHORIZATION",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.5,
//                 fontSize: 14,
//                 color: Colors.teal.shade700,
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Doctor
//             RoleCard(
//               title: 'I am a doctor',
//               icon: Icons.medical_services_outlined,
//               borderColor: Colors.deepOrange,
//               iconColor: Colors.deepOrange,
//               onTap: () => _handleSelection(context, 'doctor'),
//             ),
//             const SizedBox(height: 20),

//             // Patient
//             RoleCard(
//               title: 'I am a patient',
//               icon: Icons.assignment_ind_outlined,
//               borderColor: Colors.green,
//               iconColor: Colors.green,
//               onTap: () => _handleSelection(context, 'patient'),
//             ),
//             const SizedBox(height: 20),

//             // Admin
//             RoleCard(
//               title: 'I am an admin',
//               icon: Icons.admin_panel_settings_outlined,
//               borderColor: Colors.blue,
//               iconColor: Colors.blue,
//               onTap: () => _handleSelection(context, 'admin'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RoleCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color borderColor;
//   final Color iconColor;
//   final VoidCallback onTap;

//   const RoleCard({
//     required this.title,
//     required this.icon,
//     required this.borderColor,
//     required this.iconColor,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: 200,
//           padding: const EdgeInsets.symmetric(vertical: 24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: iconColor.withOpacity(0.25),
//                 blurRadius: 20,
//                 spreadRadius: 2,
//                 offset: Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: iconColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: borderColor, width: 2),
//                 ),
//                 child: Icon(icon, size: 40, color: iconColor),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
















// import 'package:flutter/material.dart';

// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({Key? key}) : super(key: key);

//   void _navigateTo(BuildContext context, String role) {
//     Navigator.pushNamed(context, '/login', arguments: role); // or your target route
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF6FFFC), // soft minty white
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "AUTHORIZATION",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.5,
//                 fontSize: 14,
//                 color: Colors.teal.shade700,
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Doctor
//             RoleCard(
//               title: 'I am a doctor',
//               icon: Icons.medical_services_outlined,
//               borderColor: Colors.deepOrange,
//               iconColor: Colors.deepOrange,
//               onTap: () => _navigateTo(context, 'doctor'),
//             ),
//             const SizedBox(height: 20),

//             // Patient
//             RoleCard(
//               title: 'I am a patient',
//               icon: Icons.assignment_ind_outlined,
//               borderColor: Colors.green,
//               iconColor: Colors.green,
//               onTap: () => _navigateTo(context, 'patient'),
//             ),
//             const SizedBox(height: 20),

//             // Admin
//             RoleCard(
//               title: 'I am an admin',
//               icon: Icons.admin_panel_settings_outlined,
//               borderColor: Colors.blue,
//               iconColor: Colors.blue,
//               onTap: () => _navigateTo(context, 'admin'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RoleCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color borderColor;
//   final Color iconColor;
//   final VoidCallback onTap;

//   const RoleCard({
//     required this.title,
//     required this.icon,
//     required this.borderColor,
//     required this.iconColor,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: 200,
//           padding: const EdgeInsets.symmetric(vertical: 24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: iconColor.withOpacity(0.25), // colored shadow 💥

                
//                 blurRadius: 20,
//                 offset: Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: iconColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: borderColor, width: 2),
//                 ),
//                 child: Icon(icon, size: 40, color: iconColor),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

















