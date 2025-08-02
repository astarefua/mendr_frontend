import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String? role;
  const LoginScreen({super.key, this.role});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? get role => widget.role; // Now safe

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return; // ✅ protect context usage

      if (success) {
        final user = await AuthService.getUserFromToken();

        if (!mounted) return;

        if (user != null && user.containsKey('role')) {
          final rawRole = user['role'].toString();
          final normalizedRole = rawRole.replaceAll("ROLE_", "").toLowerCase();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful")));

          if (normalizedRole == 'patient') {
            final patientId = user['id'];
            if (patientId != null && patientId is int) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('patientId', patientId);
            }

            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/home/patient');
          } else if (normalizedRole == 'doctor') {
            Navigator.pushReplacementNamed(context, '/home/doctor');
          } else if (normalizedRole == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Unknown role: $rawRole")));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid token or missing role.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Transform.scale(
                scale: 2,
                child: Image.asset(
                  'assets/images/mendr logo.png',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) =>
                    value!.length >= 6 ? null : 'Password too short',
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    GestureDetector(
                      onTap: () {
                         if (role != null) {
                            Navigator.pushNamed(context, '/signup/$role');
                          } else {
                            Navigator.pushNamed(context, '/role-selection');
                          }
                      },
                      child: Text(
                        ' Sign Up',
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
