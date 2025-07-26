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
        specialty: _selectedSpecialty ?? '',
        profileImage: _profileImage, // Now passing XFile? instead of String
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
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Doctor registration successful! Please wait for admin approval."),
            backgroundColor: Colors.green,
          )
        );
        
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration failed. Please try again."),
            backgroundColor: Colors.red,
          )
        );
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

                // Profile Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                      child: _profileImage == null 
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                              Text("Add Photo", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          )
                        : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Tap to add profile picture (Optional)", 
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val!.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: ['Doctor']
                      .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedRole = val),
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null ? 'Please select a role' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  items: _specialties
                      .map((specialty) => DropdownMenuItem(value: specialty, child: Text(specialty)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSpecialty = val),
                  decoration: const InputDecoration(
                    labelText: 'Medical Specialty *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null ? 'Please select a specialty' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _yearsExperienceController,
                  decoration: const InputDecoration(
                    labelText: 'Years of Experience *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _educationController,
                  decoration: const InputDecoration(
                    labelText: 'Medical Education',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., MD from University of Ghana',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _certificationsController,
                  decoration: const InputDecoration(
                    labelText: 'Certifications',
                    border: OutlineInputBorder(),
                    hintText: 'Board certifications, licenses, etc.',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _languagesController,
                  decoration: const InputDecoration(
                    labelText: 'Languages Spoken',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., English, Twi, French',
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _affiliationController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital/Clinic Affiliations',
                    border: OutlineInputBorder(),
                    hintText: 'Current workplace or affiliations',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Professional Bio',
                    border: OutlineInputBorder(),
                    hintText: 'Brief description of your practice and expertise',
                  ),
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
                  child: const Text("Create Doctor Account", 
                    style: TextStyle(color: Colors.white, fontSize: 16)),
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _yearsExperienceController.dispose();
    _educationController.dispose();
    _certificationsController.dispose();
    _languagesController.dispose();
    _affiliationController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

















