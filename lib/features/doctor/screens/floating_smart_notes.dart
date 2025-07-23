
// floating_smart_notes.dart
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:telemed_frontend/features/doctor/models/smart_note_model.dart';
import 'package:telemed_frontend/features/doctor/services/smart_note_service.dart';

class FloatingSmartNotes extends StatefulWidget {
  final String appointmentId;
  final VoidCallback? onClose;

  const FloatingSmartNotes({
    Key? key,
    required this.appointmentId,
    this.onClose,
  }) : super(key: key);

  @override
  State<FloatingSmartNotes> createState() => _FloatingSmartNotesState();
}

class _FloatingSmartNotesState extends State<FloatingSmartNotes> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _bodyPartController = TextEditingController();
  final TextEditingController _severityController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();
  final TextEditingController _extraNotesController = TextEditingController();

  List<SmartNoteModel> _savedNotes = [];
  bool _isLoading = false;
  bool _isMinimized = false;
  Timer? _autoSaveTimer;

  // Draggable position
  double _xPosition = 20.0;
  double _yPosition = 100.0;

  @override
  void initState() {
    super.initState();
    _loadExistingNotes();
    _setupAutoSave();
  }

  void _setupAutoSave() {
    // Auto-save every 3 seconds when fields have content
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_hasContent() && _formKey.currentState?.validate() == true) {
        _saveCurrentNote();
      }
    });
  }

  bool _hasContent() {
    return _symptomController.text.isNotEmpty ||
           _bodyPartController.text.isNotEmpty ||
           _severityController.text.isNotEmpty ||
           _actionController.text.isNotEmpty ||
           _followUpController.text.isNotEmpty ||
           _extraNotesController.text.isNotEmpty;
  }

  Future<void> _loadExistingNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await SmartNoteService.getSmartNotes(widget.appointmentId);
      setState(() {
        _savedNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Failed to load existing notes');
    }
  }

  Future<void> _saveCurrentNote() async {
    if (!_formKey.currentState!.validate()) return;

    final note = SmartNoteModel(
      symptom: _symptomController.text.trim(),
      bodyPart: _bodyPartController.text.trim(),
      severity: _severityController.text.trim(),
      action: _actionController.text.trim(),
      followUp: _followUpController.text.trim(),
      extraNotes: _extraNotesController.text.trim(),
    );

    final success = await SmartNoteService.saveSmartNote(widget.appointmentId, note);
    
    if (success) {
      setState(() {
        _savedNotes.add(note.copyWith(createdAt: DateTime.now()));
      });
      _clearForm();
      _showMessage('Note saved successfully', isError: false);
    } else {
      _showMessage('Failed to save note');
    }
  }

  void _clearForm() {
    _symptomController.clear();
    _bodyPartController.clear();
    _severityController.clear();
    _actionController.clear();
    _followUpController.clear();
    _extraNotesController.clear();
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _symptomController.dispose();
    _bodyPartController.dispose();
    _severityController.dispose();
    _actionController.dispose();
    _followUpController.dispose();
    _extraNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _xPosition,
      top: _yPosition,
      child: Draggable(
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: _buildNotesContainer(),
        ),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            _xPosition = details.offset.dx;
            _yPosition = details.offset.dy;
          });
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: _buildNotesContainer(),
        ),
      ),
    );
  }

  Widget _buildNotesContainer() {
    return Container(
      width: _isMinimized ? 60 : 320,
      height: _isMinimized ? 60 : 480,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _isMinimized ? _buildMinimizedView() : _buildFullView(),
    );
  }

  Widget _buildMinimizedView() {
    return InkWell(
      onTap: () => setState(() => _isMinimized = false),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2ECC71),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.note_add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildFullView() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.note_add, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Smart Notes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _isMinimized = true),
            child: const Icon(Icons.minimize, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: widget.onClose,
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF2ECC71),
            indicatorColor: Color(0xFF2ECC71),
            tabs: [
              Tab(text: 'New Note'),
              Tab(text: 'History'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildNewNoteTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewNoteTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(_symptomController, 'Symptom', Icons.sick),
                    const SizedBox(height: 8),
                    _buildTextField(_bodyPartController, 'Body Part', Icons.accessibility),
                    const SizedBox(height: 8),
                    _buildTextField(_severityController, 'Severity', Icons.priority_high),
                    const SizedBox(height: 8),
                    _buildTextField(_actionController, 'Action', Icons.medical_services),
                    const SizedBox(height: 8),
                    _buildTextField(_followUpController, 'Follow Up', Icons.schedule),
                    const SizedBox(height: 8),
                    _buildTextField(_extraNotesController, 'Extra Notes', Icons.notes, maxLines: 3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCurrentNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Note',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        prefixIcon: Icon(icon, size: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
      ),
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_savedNotes.isEmpty) {
      return const Center(
        child: Text(
          'No notes yet',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _savedNotes.length,
      itemBuilder: (context, index) {
        final note = _savedNotes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 4),
                _buildNoteRow('Symptom:', note.symptom),
                _buildNoteRow('Body Part:', note.bodyPart),
                _buildNoteRow('Severity:', note.severity),
                _buildNoteRow('Action:', note.action),
                _buildNoteRow('Follow Up:', note.followUp),
                if (note.extraNotes.isNotEmpty)
                  _buildNoteRow('Extra Notes:', note.extraNotes),
                if (note.createdAt != null)
                  Text(
                    'Saved: ${_formatDateTime(note.createdAt!)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10, color: Colors.black),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Extension helper for SmartNoteModel
extension SmartNoteModelExtension on SmartNoteModel {
  SmartNoteModel copyWith({
    String? symptom,
    String? bodyPart,
    String? severity,
    String? action,
    String? followUp,
    String? extraNotes,
    DateTime? createdAt,
  }) {
    return SmartNoteModel(
      symptom: symptom ?? this.symptom,
      bodyPart: bodyPart ?? this.bodyPart,
      severity: severity ?? this.severity,
      action: action ?? this.action,
      followUp: followUp ?? this.followUp,
      extraNotes: extraNotes ?? this.extraNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

