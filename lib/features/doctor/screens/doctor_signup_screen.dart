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
      appBar: AppBar(
        title: const Text("Register Doctor"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: _profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_profileImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload Profile Picture',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to select from gallery',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      val!.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
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
                  obscureText: _obscurePassword,
                  validator: (val) =>
                      val!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: 'Doctor',
                  items: ['Doctor']
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
                  onChanged: (_) {},
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  items: _specialties
                      .map((specialty) => DropdownMenuItem(value: specialty, child: Text(specialty)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSpecialty = val),
                  decoration: const InputDecoration(labelText: 'Medical Specialty'),
                  validator: (val) => val == null ? 'Please select a specialty' : null,
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Professional Information",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _yearsExperienceController,
                  decoration: InputDecoration(labelText: 'Years of Experience'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _educationController,
                  decoration: InputDecoration(labelText: 'Medical Education'),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _certificationsController,
                  decoration: InputDecoration(labelText: 'Certifications'),
                  minLines: 1,
                  maxLines: 3,
                ),

                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Additional Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _languagesController,
                  decoration: InputDecoration(labelText: 'Languages Spoken'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _affiliationController,
                  decoration: InputDecoration(labelText: 'Hospital/Clinic Affiliations'),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(labelText: 'Professional Bio'),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Create Doctor Account",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        " Sign In",
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
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

















