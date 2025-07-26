// main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemed_frontend/features/admin/screens/admin_dashboard.dart';
import 'package:telemed_frontend/features/admin/screens/manage_users_screen.dart';
import 'package:telemed_frontend/features/admin/screens/user_management_screen.dart';
import 'package:telemed_frontend/features/doctor/screens/doctor_home_tab.dart';
import 'package:telemed_frontend/features/patient/screens/notification_settings_screen.dart';
import 'package:telemed_frontend/features/patient/services/firebase_service.dart';
import 'features/commons/screens/splash_screen.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'features/doctor/screens/doctor_dashboard.dart';
import 'features/doctor/screens/set_availabilities_screen.dart';
import 'features/patient/screens/patient_home_screen.dart';
import 'features/patient/screens/patient_signup_screen.dart';
import 'features/doctor/screens/doctor_signup_screen.dart';
import 'features/admin/screens/admin_signup_screen.dart';
import 'features/auth/screens/login_screen.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telemedicine App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case '/role-selection':
            return MaterialPageRoute(builder: (_) => RoleSelectionScreen());
          case '/login':
            final role = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => LoginScreen(role: role),
            );
          case '/signup/patient':
            return MaterialPageRoute(builder: (_) => PatientSignupScreen());
          case '/signup/doctor':
            return MaterialPageRoute(builder: (_) => DoctorSignupScreen());
          case '/signup/admin':
            return MaterialPageRoute(builder: (_) => AdminSignupScreen());
          case '/home/patient':
            return MaterialPageRoute(builder: (_) => PatientHomeScreen());
          case '/home/doctor':
            return MaterialPageRoute(builder: (_) => DoctorDashboardScreen());
          case '/doctor/set-availability':
            return MaterialPageRoute(builder: (_) => SetAvailabilityScreen());

           case '/admin/dashboard': // ✅ Added route for Admin user management
            return MaterialPageRoute(builder: (_) => AdminDashboard());

            case '/notifications':
              return  MaterialPageRoute(builder: (_) => NotificationSettingsScreen());

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text("No route defined for \${settings.name}")),
              ),
            );
        }
      },
    );
  }
}




































