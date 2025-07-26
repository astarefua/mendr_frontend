import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telemed_frontend/features/patient/screens/prescription_screen.dart';
import '../services/medication_service.dart';

class MedicationTrackingScreenFinal extends StatefulWidget {
  const MedicationTrackingScreenFinal({super.key});

  @override
  State<MedicationTrackingScreenFinal> createState() => _MedicationTrackingScreenFinalState();
}

class _MedicationTrackingScreenFinalState extends State<MedicationTrackingScreenFinal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SmartMedicationGuide> allGuides = [];
  List<SmartMedicationGuide> todaysDueMedications = [];
  List<MedicationAdherence> adherenceHistory = [];
  Map<String, List<String>> doseCalendar = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Changed from 4 to 5
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final results = await Future.wait([
        MedicationService.getAllGuides(),
        MedicationService.getTodaysDueMedications(),
        MedicationService.getAdherenceHistory(),
        MedicationService.getDoseCalendar(),
      ]);

      setState(() {
        allGuides = results[0] as List<SmartMedicationGuide>;
        todaysDueMedications = results[1] as List<SmartMedicationGuide>;
        adherenceHistory = results[2] as List<MedicationAdherence>;
        doseCalendar = results[3] as Map<String, List<String>>;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _confirmDose(int guideId) async {
    final success = await MedicationService.confirmDose(guideId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dose confirmed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to confirm dose. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFFC),
      appBar: AppBar(
        title: const Text('Medication Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2ECC71),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true, // Added to handle 5 tabs better
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.medication), text: 'All Meds'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Prescriptions'), // New 5th tab
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(),
                _buildAllMedicationsTab(),
                _buildHistoryTab(),
                _buildCalendarTab(),
                const PrescriptionScreen(), // 5th tab
              ],
            ),
    );
  }

  Widget _buildTodayTab() {
    if (todaysDueMedications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Color(0xFF2ECC71)),
            SizedBox(height: 16),
            Text(
              'No medications due today!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              'Great job staying on track!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todaysDueMedications.length,
      itemBuilder: (context, index) {
        final medication = todaysDueMedications[index];
        return _buildTodayMedicationCard(medication);
      },
    );
  }

  Widget _buildTodayMedicationCard(SmartMedicationGuide medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFF2ECC71).withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: medication.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            medication.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.medication, color: Color(0xFF2ECC71), size: 30),
                          ),
                        )
                      : const Icon(Icons.medication, color: Color(0xFF2ECC71), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.medicationName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (medication.visualDescription != null)
                        Text(
                          medication.visualDescription!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      Text(
                        '${medication.dosesPerDay} times/day for ${medication.totalDays} days',
                        style: const TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (medication.usageInstruction != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        medication.usageInstruction!,
                        style: const TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmDose(medication.id),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Confirm Dose', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _showProgressDialog(medication),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Icon(Icons.analytics, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllMedicationsTab() {
    if (allGuides.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No medications found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              'Your medication guides will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allGuides.length,
      itemBuilder: (context, index) {
        final medication = allGuides[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(SmartMedicationGuide medication) {
    final startDate = DateTime.parse(medication.startDate);
    final endDate = startDate.add(Duration(days: medication.totalDays));
    final isActive = DateTime.now().isBefore(endDate) && DateTime.now().isAfter(startDate.subtract(const Duration(days: 1)));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2ECC71).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: medication.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    medication.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.medication, color: isActive ? const Color(0xFF2ECC71) : Colors.grey),
                  ),
                )
              : Icon(Icons.medication, color: isActive ? const Color(0xFF2ECC71) : Colors.grey),
        ),
        title: Text(
          medication.medicationName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (medication.visualDescription != null)
              Text(medication.visualDescription!),
            const SizedBox(height: 4),
            Text(
              '${medication.dosesPerDay} times/day • ${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}',
              style: TextStyle(
                color: isActive ? const Color(0xFF2ECC71) : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2ECC71) : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        onTap: () => _showProgressDialog(medication),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (adherenceHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No history available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              'Your medication history will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Group by date
    Map<String, List<MedicationAdherence>> groupedHistory = {};
    for (var adherence in adherenceHistory) {
      final date = DateTime.parse(adherence.takenAt);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      groupedHistory.putIfAbsent(dateKey, () => []).add(adherence);
    }

    final sortedDates = groupedHistory.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final date = DateTime.parse(dateKey);
        final dayAdherence = groupedHistory[dateKey]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              DateFormat('EEEE, MMM dd, yyyy').format(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${dayAdherence.length} doses taken'),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF2ECC71)),
            ),
            children: dayAdherence.map((adherence) {
              final takenTime = DateTime.parse(adherence.takenAt);
              return ListTile(
                title: Text(adherence.guide.medicationName),
                subtitle: Text('Taken at ${DateFormat('hh:mm a').format(takenTime)}'),
                leading: const Icon(Icons.medication, color: Color(0xFF2ECC71)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    if (doseCalendar.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No medication schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              'Your medication calendar will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final sortedDates = doseCalendar.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateStr = sortedDates[index];
        final medications = doseCalendar[dateStr]!;
        final date = DateTime.parse(dateStr);
        final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isToday ? 4 : 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isToday ? const Color(0xFF2ECC71).withOpacity(0.1) : null,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF2ECC71) : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.black,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              DateFormat('EEEE, MMM dd').format(date),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isToday ? const Color(0xFF2ECC71) : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: medications.map((med) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      med,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF2ECC71)),
                    ),
                  )).toList(),
                ),
              ],
            ),
            trailing: isToday ? const Icon(Icons.today, color: Color(0xFF2ECC71)) : null,
          ),
        );
      },
    );
  }

  Future<void> _showProgressDialog(SmartMedicationGuide medication) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final progress = await MedicationService.getProgress(medication.id);
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (progress != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(medication.medicationName, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: progress.progressPercentage / 100,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                strokeWidth: 8,
              ),
              const SizedBox(height: 16),
              Text(
                '${progress.progressPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71)),
              ),
              const SizedBox(height: 16),
              _buildProgressStat('Expected Doses', progress.expectedDoses.toString()),
              _buildProgressStat('Taken Doses', progress.takenDoses.toString()),
              _buildProgressStat('Remaining Doses', progress.remainingDoses.toString()),
              if (progress.isCompleted)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF2ECC71)),
                      SizedBox(width: 8),
                      Text('Completed!', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Color(0xFF2ECC71))),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load progress')),
      );
    }
  }

  Widget _buildProgressStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

















