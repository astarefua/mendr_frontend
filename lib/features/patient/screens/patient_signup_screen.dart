import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';



class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  _PatientSignupScreenState createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime? _selectedDate;
  String _gender = 'Female';
  bool _obscurePassword = true;
  XFile? _profileImage;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _profileImage = picked);
  }


  // Replace your existing _submit method in PatientSignupScreen with this updated version

Future<void> _submit() async {
  if (_formKey.currentState!.validate()) {
    final success = await AuthService.registerPatient(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: "patient",
      gender: _gender,
      contactNumber: _phoneController.text,
      emergencyContactName: _emergencyNameController.text,
      emergencyContactRelationship: _emergencyRelationshipController.text,
      emergencyContactPhone: _emergencyPhoneController.text,
      dateOfBirth: _selectedDate?.toIso8601String() ?? '',
      profileImage: _profileImage, // Pass the XFile directly instead of the path
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSignedUp_patient', true);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed"))
      );
    }
  }
}

//   Future<void> _submit() async {
//     if (_formKey.currentState!.validate()) {
//       final success = await AuthService.registerPatient(
//         name: _nameController.text,
//         email: _emailController.text,
//         password: _passwordController.text,
//         role: "patient",
//         gender: _gender,
//         contactNumber: _phoneController.text,
//         emergencyContactName: _emergencyNameController.text,
//         emergencyContactRelationship: _emergencyRelationshipController.text,
//         emergencyContactPhone: _emergencyPhoneController.text,
//         dateOfBirth: _selectedDate?.toIso8601String() ?? '',
//         profilePictureUrl: _profileImage?.path ?? '',
//       );

//       if (success) {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setBool('hasSignedUp_patient', true);
//   Navigator.pushReplacementNamed(context, '/login');
// } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration failed")));
//       }
//     }
//   }

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
                const Text("Patient Registration", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Join our healthcare community", style: TextStyle(color: Colors.grey)),
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
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val!.contains('@') ? null : 'Enter valid email',
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (val) => val!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: 'Patient',
                  items: ['Patient'].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                  onChanged: (_) {},
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date of Birth'),
                          child: Text(_selectedDate == null
                              ? 'Select date'
                              : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        items: ['Female', 'Male'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (val) => setState(() => _gender = val!),
                        decoration: const InputDecoration(labelText: 'Gender'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 20),
                const Align(alignment: Alignment.centerLeft, child: Text("Emergency Contact", style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emergencyNameController,
                  decoration: InputDecoration(labelText: 'Contact Name'),
                ),
                TextFormField(
                  controller: _emergencyRelationshipController,
                  decoration: InputDecoration(labelText: 'Relationship'),
                ),
                TextFormField(
                  controller: _emergencyPhoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Create PatientAccount", style: TextStyle(color: Colors.white)),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
