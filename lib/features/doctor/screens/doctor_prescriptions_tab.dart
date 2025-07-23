import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

class DoctorPrescriptionsTab extends StatefulWidget {
  const DoctorPrescriptionsTab({Key? key}) : super(key: key);

  @override
  _DoctorPrescriptionsTabState createState() => _DoctorPrescriptionsTabState();
}

class _DoctorPrescriptionsTabState extends State<DoctorPrescriptionsTab> {
  List<Map<String, dynamic>> prescriptions = [];
  List<Map<String, dynamic>> completedAppointments = [];
  List<Map<String, dynamic>> filteredPrescriptions = [];
  
  bool isLoadingPrescriptions = true;
  bool isLoadingAppointments = false;
  bool isCreatingPrescription = false;
  
  String? prescriptionsError;
  String? appointmentsError;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterPrescriptions();
    });
  }

  void _filterPrescriptions() {
    if (_searchQuery.isEmpty) {
      filteredPrescriptions = prescriptions;
    } else {
      filteredPrescriptions = prescriptions.where((prescription) {
        final patientName = prescription['patientName']?.toString().toLowerCase() ?? '';
        final medicationName = prescription['medicationName']?.toString().toLowerCase() ?? '';
        return patientName.contains(_searchQuery) || medicationName.contains(_searchQuery);
      }).toList();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadPrescriptions() async {
    try {
      setState(() {
        isLoadingPrescriptions = true;
        prescriptionsError = null;
      });

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/prescriptions/me/doctor'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          prescriptions = data.cast<Map<String, dynamic>>();
          filteredPrescriptions = prescriptions;
          isLoadingPrescriptions = false;
        });
      } else {
        throw Exception('Failed to load prescriptions: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        prescriptionsError = e.toString();
        isLoadingPrescriptions = false;
      });
    }
  }

  Future<void> _loadCompletedAppointments() async {
    try {
      setState(() {
        isLoadingAppointments = true;
        appointmentsError = null;
      });

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments/doctor/completed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          completedAppointments = data.cast<Map<String, dynamic>>();
          isLoadingAppointments = false;
        });
      } else {
        throw Exception('Failed to load completed appointments: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        appointmentsError = e.toString();
        isLoadingAppointments = false;
      });
    }
  }

  Future<void> _createPrescription(int appointmentId, String medicationName, String dosage, String notes) async {
    try {
      setState(() {
        isCreatingPrescription = true;
      });

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/prescriptions/appointment/$appointmentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'medicationName': medicationName,
          'dosage': dosage,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        // Refresh prescriptions list
        await _loadPrescriptions();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prescription created successfully'),
              backgroundColor: Color(0xFF2ECC71),
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create prescription');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isCreatingPrescription = false;
      });
    }
  }

  void _showCreatePrescriptionDialog() async {
    await _loadCompletedAppointments();
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => CreatePrescriptionDialog(
        completedAppointments: completedAppointments,
        isLoading: isLoadingAppointments,
        error: appointmentsError,
        onCreatePrescription: _createPrescription,
        isCreating: isCreatingPrescription,
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final String patientName = prescription['patientName'] ?? 'Unknown Patient';
    final String medicationName = prescription['medicationName'] ?? 'N/A';
    final String dosage = prescription['dosage'] ?? 'N/A';
    final String notes = prescription['notes'] ?? 'No notes';
    final String issuedAt = prescription['issuedAt'] ?? '';
    
    DateTime? issuedDate;
    try {
      issuedDate = DateTime.parse(issuedAt);
    } catch (e) {
      issuedDate = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2ECC71).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Color(0xFF2ECC71),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (issuedDate != null)
                      Text(
                        '${issuedDate.day}/${issuedDate.month}/${issuedDate.year} at ${issuedDate.hour}:${issuedDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medication, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Medication:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  medicationName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.scale, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Dosage:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dosage,
                  style: const TextStyle(fontSize: 14),
                ),
                if (notes.isNotEmpty && notes != 'No notes') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Notes:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notes,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FFFC),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prescriptions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showCreatePrescriptionDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Prescription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by patient name or medication...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF2ECC71)),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),
          
          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Prescriptions: ${filteredPrescriptions.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (!isLoadingPrescriptions)
                        TextButton.icon(
                          onPressed: _loadPrescriptions,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh'),
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF2ECC71),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Prescriptions List
                  Expanded(
                    child: isLoadingPrescriptions
                        ? const Center(child: CircularProgressIndicator())
                        : prescriptionsError != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error loading prescriptions',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: _loadPrescriptions,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : filteredPrescriptions.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.medical_services,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _searchQuery.isEmpty 
                                              ? 'No prescriptions yet'
                                              : 'No prescriptions match your search',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        if (_searchQuery.isEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Create your first prescription from completed appointments',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredPrescriptions.length,
                                    itemBuilder: (context, index) {
                                      return _buildPrescriptionCard(filteredPrescriptions[index]);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePrescriptionDialog extends StatefulWidget {
  final List<Map<String, dynamic>> completedAppointments;
  final bool isLoading;
  final String? error;
  final Function(int, String, String, String) onCreatePrescription;
  final bool isCreating;

  const CreatePrescriptionDialog({
    Key? key,
    required this.completedAppointments,
    required this.isLoading,
    this.error,
    required this.onCreatePrescription,
    required this.isCreating,
  }) : super(key: key);

  @override
  _CreatePrescriptionDialogState createState() => _CreatePrescriptionDialogState();
}

class _CreatePrescriptionDialogState extends State<CreatePrescriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  
  Map<String, dynamic>? selectedAppointment;

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Create New Prescription',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: widget.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : widget.error != null
                  ? Column(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: ${widget.error}'),
                      ],
                    )
                  : widget.completedAppointments.isEmpty
                      ? const Column(
                          children: [
                            Icon(Icons.info, color: Colors.orange, size: 48),
                            SizedBox(height: 16),
                            Text(
                              'No completed appointments found.\nPrescriptions can only be issued for completed appointments.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Appointment:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<Map<String, dynamic>>(
                                value: selectedAppointment,
                                hint: const Text('Choose a completed appointment'),
                                validator: (value) => value == null ? 'Please select an appointment' : null,
                                items: widget.completedAppointments.map((appointment) {
                                  final patientName = appointment['patientName'] ?? 'Unknown';
                                  final date = DateTime.parse(appointment['appointmentDate']);
                                  final dateStr = '${date.day}/${date.month}/${date.year}';
                                  
                                  return DropdownMenuItem(
                                    value: appointment,
                                    child: Text('$patientName - $dateStr'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedAppointment = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _medicationController,
                                validator: (value) => value?.isEmpty ?? true ? 'Please enter medication name' : null,
                                decoration: InputDecoration(
                                  labelText: 'Medication Name *',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _dosageController,
                                validator: (value) => value?.isEmpty ?? true ? 'Please enter dosage' : null,
                                decoration: InputDecoration(
                                  labelText: 'Dosage *',
                                  hintText: 'e.g., 500mg twice daily',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Additional Notes',
                                  hintText: 'Special instructions, duration, etc.',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isCreating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!widget.isLoading && widget.error == null && widget.completedAppointments.isNotEmpty)
          ElevatedButton(
            onPressed: widget.isCreating
                ? null
                : () async {
                    if (_formKey.currentState!.validate() && selectedAppointment != null) {
                      await widget.onCreatePrescription(
                        selectedAppointment!['id'],
                        _medicationController.text.trim(),
                        _dosageController.text.trim(),
                        _notesController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2ECC71),
              foregroundColor: Colors.white,
            ),
            child: widget.isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Create Prescription'),
          ),
      ],
    );
  }
}