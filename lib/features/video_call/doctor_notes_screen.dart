// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';


// //import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill/quill_editor.dart';
// import 'package:flutter_quill/quill_controller.dart';
// import 'package:flutter_quill/quill_configurations.dart';
// import 'package:flutter_quill/quill_provider.dart';
// import 'package:flutter_quill/widgets/quill_toolbar.dart';


// class DoctorNotesScreen extends StatefulWidget {
//   final String appointmentId;

//   const DoctorNotesScreen({super.key, required this.appointmentId});

//   @override
//   State<DoctorNotesScreen> createState() => _DoctorNotesScreenState();
// }

// class _DoctorNotesScreenState extends State<DoctorNotesScreen> {
//   final QuillController _controller = QuillController.basic();
//   final FocusNode _focusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();

//   void _saveNotes() {
//     final notes = _controller.document.toPlainText();
//     // TODO: Send notes and widget.appointmentId to backend
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Notes saved")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Smart Notes"),
//         actions: [
//           IconButton(onPressed: _saveNotes, icon: const Icon(Icons.save)),
//         ],
//       ),
//       body: QuillProvider(
//         configurations: QuillConfigurations(controller: _controller),
//         child: Column(
//           children: [
//             QuillSimpleToolbar(controller: _controller),
//             const SizedBox(height: 10),
//             Expanded(
//               child: QuillEditor(
//                 controller: _controller,
//                 focusNode: _focusNode,
//                 scrollController: _scrollController,
//                 config: const QuillEditorConfig(
//                   expands: true,
//                   padding: EdgeInsets.all(8),
//                   readOnly: false, // ✅ Add this
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






















// // import 'package:flutter/material.dart';
// // import 'package:flutter_quill/flutter_quill.dart';

// // class DoctorNotesScreen extends StatefulWidget {
// //   final String appointmentId;

// //   const DoctorNotesScreen({super.key, required this.appointmentId});

// //   @override
// //   State<DoctorNotesScreen> createState() => _DoctorNotesScreenState();
// // }

// // class _DoctorNotesScreenState extends State<DoctorNotesScreen> {
// //   final QuillController _controller = QuillController.basic();
// //   final FocusNode _focusNode = FocusNode();
// //   final ScrollController _scrollController = ScrollController();

// //   void _saveNotes() {
// //     final notes = _controller.document.toPlainText();
// //     // TODO: Send notes and widget.appointmentId to backend
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text("Notes saved")),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Smart Notes"),
// //         actions: [
// //           IconButton(onPressed: _saveNotes, icon: const Icon(Icons.save)),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           QuillSimpleToolbar(controller: _controller),
// //           const SizedBox(height: 10),
// //           Expanded(
// //             child: QuillEditor.basic(
// //               controller: _controller,
// //               //readOnly: false,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
