import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';



class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  _DoctorSignupScreenState createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _ageController = TextEditingController();
  final _educationController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedSpecialty;
  String? _selectedRole = 'Doctor';
  XFile? _profileImage;

  final List<String> _specialties = [
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Pediatrician',
    'General Practitioner',
  ];

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _profileImage = picked);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await AuthService.registerDoctor(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: "doctor",
        age: int.tryParse(_ageController.text) ?? 0,
        specialty: _selectedSpecialty ?? '',
        profilePictureUrl: _profileImage?.path ?? '',
        yearsOfExperience: int.tryParse(_yearsExperienceController.text) ?? 0,
        education: _educationController.text,
        certifications: _certificationsController.text,
        languagesSpoken: _languagesController.text,
        bio: _bioController.text,
        affiliations: _affiliationController.text,
      );

      if (success) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasSignedUp_doctor', true);
  Navigator.pushReplacementNamed(context, '/login');
}
 else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("Doctor Registration", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Join our healthcare professional network", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                    child: _profileImage == null ? const Icon(Icons.camera_alt) : null,
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.contains('@') ? null : 'Enter valid email',
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: ['Doctor']
                      .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedRole = val),
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (val) => val == null ? 'Please select a role' : null,
                ),

                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  items: _specialties
                      .map((specialty) => DropdownMenuItem(value: specialty, child: Text(specialty)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSpecialty = val),
                  decoration: const InputDecoration(labelText: 'Medical Specialty'),
                  validator: (val) => val == null ? 'Please select a specialty' : null,
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearsExperienceController,
                        decoration: const InputDecoration(labelText: 'Years of Experience'),
                        keyboardType: TextInputType.number,
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                TextFormField(
                  controller: _educationController,
                  decoration: const InputDecoration(labelText: 'Medical Education'),
                ),
                TextFormField(
                  controller: _certificationsController,
                  decoration: const InputDecoration(labelText: 'Certifications'),
                ),
                TextFormField(
                  controller: _languagesController,
                  decoration: const InputDecoration(labelText: 'Languages Spoken'),
                ),
                TextFormField(
                  controller: _affiliationController,
                  decoration: const InputDecoration(labelText: 'Hospital/Clinic Affiliations'),
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Professional Bio'),
                  maxLines: 3,
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Create Doctor Account", style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text("Sign In"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
