import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

class DoctorMedicationGuidesTab extends StatefulWidget {
  const DoctorMedicationGuidesTab({super.key});

  @override
  State<DoctorMedicationGuidesTab> createState() => _DoctorMedicationGuidesTabState();
}

class _DoctorMedicationGuidesTabState extends State<DoctorMedicationGuidesTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _visualDescController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _usageController = TextEditingController();
  final TextEditingController _animationUrlController = TextEditingController();
  final TextEditingController _dosesPerDayController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();
  DateTime? _startDate;

  List<dynamic> medicationGuides = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGuides();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchGuides() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/medication-guides'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        medicationGuides = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print('Failed to fetch guides: ${response.body}');
    }
  }

  Future<void> submitGuide() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/medication-guides/guides'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "patientId": int.parse(_patientIdController.text),
        "medicationName": _medicationNameController.text,
        "visualDescription": _visualDescController.text,
        "imageUrl": _imageUrlController.text,
        "usageInstruction": _usageController.text,
        "animationUrl": _animationUrlController.text,
        "dosesPerDay": int.parse(_dosesPerDayController.text),
        "totalDays": int.parse(_totalDaysController.text),
        "startDate": _startDate?.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medication Guide Created")),
      );
      _formKey.currentState!.reset();
      fetchGuides();
    } else {
      print('Failed to create guide: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create guide")),
      );
    }
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Assign New Medication Guide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _patientIdController,
            decoration: const InputDecoration(labelText: "Patient ID"),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Enter patient ID' : null,
          ),
          TextFormField(
            controller: _medicationNameController,
            decoration: const InputDecoration(labelText: "Medication Name"),
            validator: (value) => value!.isEmpty ? 'Enter medication name' : null,
          ),
          TextFormField(
            controller: _visualDescController,
            decoration: const InputDecoration(labelText: "Visual Description"),
          ),
          TextFormField(
            controller: _imageUrlController,
            decoration: const InputDecoration(labelText: "Image URL"),
          ),
          TextFormField(
            controller: _usageController,
            decoration: const InputDecoration(labelText: "Usage Instruction"),
          ),
          TextFormField(
            controller: _animationUrlController,
            decoration: const InputDecoration(labelText: "Animation URL"),
          ),
          TextFormField(
            controller: _dosesPerDayController,
            decoration: const InputDecoration(labelText: "Doses Per Day"),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _totalDaysController,
            decoration: const InputDecoration(labelText: "Total Days"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(_startDate != null ? 'Start: ${DateFormat.yMMMd().format(_startDate!)}' : 'Pick Start Date'),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _pickStartDate,
                child: const Text('Choose Date'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: submitGuide,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
            ),
            child: const Text('Assign Guide'),
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget buildGuideList() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : medicationGuides.isEmpty
            ? const Text("No medication guides assigned yet.")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Previously Created Guides", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    itemCount: medicationGuides.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final guide = medicationGuides[index];
                      return Card(
                        child: ListTile(
                          title: Text(guide['medicationName']),
                          subtitle: Text("Patient ID: ${guide['patient']['id']} | Start: ${guide['startDate'] ?? 'N/A'}"),
                          trailing: const Icon(Icons.medical_services_outlined),
                        ),
                      );
                    },
                  ),
                ],
              );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          buildForm(),
          buildGuideList(),
        ],
      ),
    );
  }
}
