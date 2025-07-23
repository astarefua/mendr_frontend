// Updated VideoCallScreen with Complete Appointment functionality
import 'package:flutter/material.dart';
import 'package:telemed_frontend/features/doctor/models/smart_note_model.dart';
import 'package:telemed_frontend/features/doctor/screens/floating_smart_notes.dart';
import 'package:telemed_frontend/features/doctor/screens/prescription_screen.dart';
import 'package:telemed_frontend/features/doctor/services/prescription_service.dart';
import 'package:telemed_frontend/features/doctor/services/smart_note_service.dart';
import 'package:webview_flutter/webview_flutter.dart';


class VideoCallScreen extends StatefulWidget {
  final String roomUrl;
  final String? appointmentId;

  const VideoCallScreen({
    Key? key,
    required this.roomUrl,
    this.appointmentId,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final WebViewController _controller;
  bool _showSmartNotes = false;
  bool _isCompletingAppointment = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.roomUrl));
  }

  Future<void> _completeAppointment() async {
    if (widget.appointmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment ID not found')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Appointment'),
          content: const Text(
            'Are you sure you want to complete this appointment? '
            'You will be able to issue a prescription afterwards.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
              ),
              child: const Text(
                'Complete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isCompletingAppointment = true);

    try {
      final result = await PrescriptionService.completeAppointment(widget.appointmentId!);

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment completed successfully!'),
            backgroundColor: Color(0xFF2ECC71),
          ),
        );

        // Navigate to prescription screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionScreen(
              appointmentId: widget.appointmentId!,
              patientName: result['patientName'] ?? 'Unknown Patient',
              patientId: result['patientId']?.toString(),
              doctorName: result['doctorName'],
              appointmentDate: result['appointmentDate']?.toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete appointment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCompletingAppointment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemedicine Video Call'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        actions: [
          // Smart Notes button
          if (widget.appointmentId != null)
            IconButton(
              icon: Icon(
                _showSmartNotes ? Icons.note_alt : Icons.note_add,
                color: _showSmartNotes ? Colors.white : Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _showSmartNotes = !_showSmartNotes;
                });
              },
              tooltip: 'Smart Notes',
            ),
          
          // Complete Appointment button
          if (widget.appointmentId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _isCompletingAppointment ? null : _completeAppointment,
                icon: _isCompletingAppointment
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  _isCompletingAppointment ? 'Completing...' : 'Complete',
                  style: const TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_showSmartNotes && widget.appointmentId != null)
            FloatingSmartNotes(
              appointmentId: widget.appointmentId!,
              onClose: () {
                setState(() {
                  _showSmartNotes = false;
                });
              },
            ),
        ],
      ),
    );
  }
}









// // Updated VideoCallScreen with Smart Notes integration
// import 'package:flutter/material.dart';
// import 'package:telemed_frontend/features/doctor/models/smart_note_model.dart';
// import 'package:telemed_frontend/features/doctor/screens/floating_smart_notes.dart';
// import 'package:telemed_frontend/features/doctor/services/smart_note_service.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String roomUrl;
//   final String? appointmentId; // Add appointmentId parameter

//   const VideoCallScreen({
//     Key? key,
//     required this.roomUrl,
//     this.appointmentId,
//   }) : super(key: key);

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   late final WebViewController _controller;
//   bool _showSmartNotes = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse(widget.roomUrl));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Telemedicine Video Call'),
//         actions: [
//           if (widget.appointmentId != null)
//             IconButton(
//               icon: Icon(
//                 _showSmartNotes ? Icons.note_alt : Icons.note_add,
//                 color: _showSmartNotes ? const Color(0xFF2ECC71) : null,
//               ),
//               onPressed: () {
//                 setState(() {
//                   _showSmartNotes = !_showSmartNotes;
//                 });
//               },
//               tooltip: 'Smart Notes',
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (_showSmartNotes && widget.appointmentId != null)
//             FloatingSmartNotes(
//               appointmentId: widget.appointmentId!,
//               onClose: () {
//                 setState(() {
//                   _showSmartNotes = false;
//                 });
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }














