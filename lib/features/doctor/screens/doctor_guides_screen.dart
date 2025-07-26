import 'package:flutter/material.dart';
import 'package:telemed_frontend/features/doctor/services/smg_final_service.dart';
//import '../../../data/services/medication_guide_service.dart';

class DoctorGuidesScreen extends StatefulWidget {
  const DoctorGuidesScreen({super.key});

  @override
  State<DoctorGuidesScreen> createState() => _DoctorGuidesScreenState();
}

class _DoctorGuidesScreenState extends State<DoctorGuidesScreen> {
  List<SmartMedicationGuide> _guides = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final guides = await MedicationGuideService.getDoctorGuides();
      
      if (mounted) {
        setState(() {
          _guides = guides;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _loadGuides: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _deleteGuide(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guide'),
        content: const Text('Are you sure you want to delete this medication guide?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await MedicationGuideService.deleteMedicationGuide(id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Guide deleted successfully')),
          );
          _loadGuides(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete guide'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFFC),
      appBar: AppBar(
        title: const Text(
          'My Medication Guides',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _guides.isEmpty
                  ? _buildEmptyState()
                  : _buildGuidesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to create guide screen
          final result = await Navigator.pushNamed(context, '/create-medication-guide');
          if (result == true) {
            _loadGuides(); // Refresh list if guide was created
          }
        },
        backgroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading guides',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadGuides,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.medication_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Medication Guides',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t created any medication guides yet.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/create-medication-guide');
              if (result == true) {
                _loadGuides();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create Your First Guide',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidesList() {
    return RefreshIndicator(
      onRefresh: _loadGuides,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _guides.length,
        itemBuilder: (context, index) {
          final guide = _guides[index];
          return _buildGuideCard(guide);
        },
      ),
    );
  }

  Widget _buildGuideCard(SmartMedicationGuide guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with medication name and actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    guide.medicationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Navigator.pushNamed(
                          context,
                          '/edit-medication-guide',
                          arguments: guide,
                        ).then((result) {
                          if (result == true) _loadGuides();
                        });
                        break;
                      case 'delete':
                        _deleteGuide(guide.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Patient info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Patient: ${guide.patient['name'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Visual description
            if (guide.visualDescription.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.visibility, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      guide.visualDescription,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Usage instruction
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(guide.usageInstruction),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Dosage and duration info
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.schedule,
                    label: '${guide.dosesPerDay}x daily',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: '${guide.totalDays} days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Start date
            _buildInfoChip(
              icon: Icons.play_arrow,
              label: 'Start: ${_formatDate(guide.startDate)}',
              fullWidth: true,
            ),
            
            // Media indicators
            if (guide.imageUrl != null || guide.animationUrl != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (guide.imageUrl != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image, size: 16, color: Colors.blue),
                          SizedBox(width: 4),
                          Text('Image', style: TextStyle(color: Colors.blue, fontSize: 12)),
                        ],
                      ),
                    ),
                  if (guide.imageUrl != null && guide.animationUrl != null)
                    const SizedBox(width: 8),
                  if (guide.animationUrl != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_outline, size: 16, color: Colors.purple),
                          SizedBox(width: 4),
                          Text('Animation', style: TextStyle(color: Colors.purple, fontSize: 12)),
                        ],
                      ),
                    ),
                ],
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
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2ECC71)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2ECC71),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}