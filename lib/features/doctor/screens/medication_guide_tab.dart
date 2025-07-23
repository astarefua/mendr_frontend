import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../utils/constants.dart'; // Adjust path as needed

class SmartMedicationGuide {
  final int id;
  final String medicationName;
  final String? visualDescription;
  final String? imageUrl;
  final String usageInstruction;
  final String? animationUrl;
  final int dosesPerDay;
  final int totalDays;
  final DateTime startDate;
  final Map<String, dynamic>? patient;

  SmartMedicationGuide({
    required this.id,
    required this.medicationName,
    this.visualDescription,
    this.imageUrl,
    required this.usageInstruction,
    this.animationUrl,
    required this.dosesPerDay,
    required this.totalDays,
    required this.startDate,
    this.patient,
  });

  factory SmartMedicationGuide.fromJson(Map<String, dynamic> json) {
    return SmartMedicationGuide(
      id: json['id'],
      medicationName: json['medicationName'] ?? '',
      visualDescription: json['visualDescription'],
      imageUrl: json['imageUrl'],
      usageInstruction: json['usageInstruction'] ?? '',
      animationUrl: json['animationUrl'],
      dosesPerDay: json['dosesPerDay'] ?? 1,
      totalDays: json['totalDays'] ?? 1,
      startDate: DateTime.parse(json['startDate']),
      patient: json['patient'],
    );
  }
}

class MedicationGuideTab extends StatefulWidget {
  const MedicationGuideTab({super.key});

  @override
  State<MedicationGuideTab> createState() => _MedicationGuideTabState();
}

class _MedicationGuideTabState extends State<MedicationGuideTab> {
  List<SmartMedicationGuide> _guides = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMedicationGuides();
  }

  Future<void> _fetchMedicationGuides() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          _error = 'Authentication token not found';
          _isLoading = false;
        });
        return;
      }

      final uri = Uri.parse('$baseUrl/api/medication-guides');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _guides = jsonList.map((json) => SmartMedicationGuide.fromJson(json)).toList();
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _error = 'Authentication failed. Please login again.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load medication guides';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildMedicationCard(SmartMedicationGuide guide) {
    final daysRemaining = guide.totalDays - DateTime.now().difference(guide.startDate).inDays;
    final isActive = daysRemaining > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medication Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: guide.imageUrl != null && guide.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            guide.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.medication, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.medication, color: Colors.grey, size: 30),
                ),
                const SizedBox(width: 16),
                
                // Medication Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.medicationName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (guide.visualDescription != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          guide.visualDescription!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Active ($daysRemaining days left)' : 'Completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.green[800] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Usage Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6FFFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(guide.usageInstruction),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Dosage Info
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.schedule,
                    label: '${guide.dosesPerDay}x daily',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: '${guide.totalDays} days total',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Start Date
            _buildInfoChip(
              icon: Icons.play_arrow,
              label: 'Started: ${_formatDate(guide.startDate)}',
              color: Colors.purple,
            ),
            
            // Animation/Video Button
            if (guide.animationUrl != null && guide.animationUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open animation/video
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening medication guide...')),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('View Visual Guide'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    side: BorderSide(color: Colors.green[300]!),
                  ),
                ),
              ),
            ],
            
            // Patient Info (for doctors)
            if (guide.patient != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Patient: ${guide.patient!['name'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFFC),
      appBar: AppBar(
        title: const Text('Medication Guides'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMedicationGuides,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMedicationGuides,
        color: const Color(0xFF2ECC71),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchMedicationGuides,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                          ),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : _guides.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No medication guides found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pull down to refresh',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            '${_guides.length} medication guide${_guides.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._guides.map((guide) => _buildMedicationCard(guide)),
                        ],
                      ),
      ),
    );
  }
}