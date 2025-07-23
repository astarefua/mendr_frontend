
// lib/presentation/screens/appointment_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemed_frontend/data/services/auth_service.dart';
import 'package:telemed_frontend/features/patient/screens/appointment_model.dart';
import 'package:telemed_frontend/features/patient/screens/appointment_service.dart';

class AppointmentBookingScreenFinal extends StatefulWidget {
  const AppointmentBookingScreenFinal({super.key});

  @override
  State<AppointmentBookingScreenFinal> createState() => _AppointmentBookingScreenFinalState();
}

class _AppointmentBookingScreenFinalState extends State<AppointmentBookingScreenFinal> {
  List<Doctor> doctors = [];
  List<DoctorAvailability> selectedDoctorAvailability = [];
  Doctor? selectedDoctor;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? selectedTime;
  bool isLoading = false;
  bool isDoctorsLoading = true;
  int? patientId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _getPatientId();
    await _loadDoctors();
  }

  Future<void> _getPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await AuthService.getUserFromToken();
    
    if (user != null && user['id'] != null) {
      patientId = user['id'] is int ? user['id'] : int.tryParse(user['id'].toString());
    }
    
    // Fallback to stored patientId
    patientId ??= prefs.getInt('patientId');
  }

  Future<void> _loadDoctors() async {
    try {
      final doctorsList = await AppointmentService.getAllDoctors();
      if (mounted) {
        setState(() {
          doctors = doctorsList;
          isDoctorsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isDoctorsLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading doctors: $e')),
        );
      }
    }
  }

  Future<void> _loadDoctorAvailability(int doctorId) async {
    try {
      setState(() => isLoading = true);
      final availability = await AppointmentService.getDoctorAvailability(doctorId);
      if (mounted) {
        setState(() {
          selectedDoctorAvailability = availability;
          selectedTime = null;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading availability: $e')),
        );
      }
    }
  }

  List<TimeOfDay> _getAvailableTimeSlots() {
    if (selectedDoctorAvailability.isEmpty) return [];

    final dayOfWeek = _getDayOfWeekString(selectedDate.weekday);
    final availableSlot = selectedDoctorAvailability.firstWhere(
      (slot) => slot.dayOfWeek.toUpperCase() == dayOfWeek,
      orElse: () => DoctorAvailability(
        id: 0, 
        doctorId: 0, 
        dayOfWeek: '', 
        startTime: '00:00', 
        endTime: '00:00'
      ),
    );

    if (availableSlot.dayOfWeek.isEmpty) return [];

    final startTime = TimeOfDay(
      hour: int.parse(availableSlot.startTime.split(':')[0]),
      minute: int.parse(availableSlot.startTime.split(':')[1]),
    );
    final endTime = TimeOfDay(
      hour: int.parse(availableSlot.endTime.split(':')[0]),
      minute: int.parse(availableSlot.endTime.split(':')[1]),
    );

    List<TimeOfDay> slots = [];
    int currentMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    while (currentMinutes < endMinutes) {
      slots.add(TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ));
      currentMinutes += 30; // 30-minute slots
    }

    return slots;
  }

  String _getDayOfWeekString(int weekday) {
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    return days[weekday - 1];
  }

  Future<void> _bookAppointment() async {
    if (selectedDoctor == null || selectedTime == null || patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final appointmentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (appointmentDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future date and time')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final appointment = Appointment(
        doctorId: selectedDoctor!.id,
        patientId: patientId!,
        appointmentDate: appointmentDateTime,
      );

      await AppointmentService.bookAppointment(appointment);

      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFFC),
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isDoctorsLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Doctor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<Doctor>(
                            value: selectedDoctor,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Choose a doctor',
                            ),
                            items: doctors.map((doctor) {
                              return DropdownMenuItem(
                                value: doctor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      doctor.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      doctor.specialty,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (doctor) {
                              setState(() {
                                selectedDoctor = doctor;
                                selectedTime = null;
                              });
                              if (doctor != null) {
                                _loadDoctorAvailability(doctor.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  selectedDate = date;
                                  selectedTime = null;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time Selection
                  if (selectedDoctor != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (_getAvailableTimeSlots().isEmpty)
                              const Text(
                                'No available slots for this date',
                                style: TextStyle(color: Colors.red),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _getAvailableTimeSlots().map((time) {
                                  final isSelected = selectedTime == time;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedTime = time;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF2ECC71)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF2ECC71)
                                              : Colors.grey,
                                        ),
                                      ),
                                      child: Text(
                                        time.format(context),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Book Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _bookAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Book Appointment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}