import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Models
class SmartMedicationGuide {
  final int id;
  final String medicationName;
  final String visualDescription;
  final String? imageUrl;
  final String usageInstruction;
  final String? animationUrl;
  final int dosesPerDay;
  final int totalDays;
  final DateTime startDate;

  SmartMedicationGuide({
    required this.id,
    required this.medicationName,
    required this.visualDescription,
    this.imageUrl,
    required this.usageInstruction,
    this.animationUrl,
    required this.dosesPerDay,
    required this.totalDays,
    required this.startDate,
  });

  factory SmartMedicationGuide.fromJson(Map<String, dynamic> json) {
    return SmartMedicationGuide(
      id: json['id'],
      medicationName: json['medicationName'],
      visualDescription: json['visualDescription'] ?? '',
      imageUrl: json['imageUrl'],
      usageInstruction: json['usageInstruction'] ?? '',
      animationUrl: json['animationUrl'],
      dosesPerDay: json['dosesPerDay'] ?? 1,
      totalDays: json['totalDays'] ?? 1,
      startDate: DateTime.parse(json['startDate']),
    );
  }
}

class MedicationAdherence {
  final int id;
  final DateTime takenAt;
  final SmartMedicationGuide guide;

  MedicationAdherence({
    required this.id,
    required this.takenAt,
    required this.guide,
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) {
    return MedicationAdherence(
      id: json['id'],
      takenAt: DateTime.parse(json['takenAt']),
      guide: SmartMedicationGuide.fromJson(json['guide']),
    );
  }
}

// Service Class
class MedicationService {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Update with your base URL

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<SmartMedicationGuide>> getAllGuides() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/medication/guides'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SmartMedicationGuide.fromJson(json)).toList();
      }
      throw Exception('Failed to load medication guides');
    } catch (e) {
      print('Error fetching guides: $e');
      return [];
    }
  }

  static Future<List<MedicationAdherence>> getAdherenceHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/medication/adherence'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MedicationAdherence.fromJson(json)).toList();
      }
      throw Exception('Failed to load adherence history');
    } catch (e) {
      print('Error fetching adherence: $e');
      return [];
    }
  }

  static Future<bool> confirmDose(int guideId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/medication/confirm/$guideId'),
        headers: await _getAuthHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error confirming dose: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getProgress(int guideId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/medication/progress/$guideId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching progress: $e');
      return {};
    }
  }

  static Future<List<SmartMedicationGuide>> getTodaysDueMedications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/medication/due-today'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SmartMedicationGuide.fromJson(json)).toList();
      }
      throw Exception('Failed to load due medications');
    } catch (e) {
      print('Error fetching due medications: $e');
      return [];
    }
  }

  static Future<Map<String, List<String>>> getDoseCalendar() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/medication/calendar'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(key, List<String>.from(value)));
      }
      return {};
    } catch (e) {
      print('Error fetching calendar: $e');
      return {};
    }
  }
}

// Main Screen
class MedicationTrackingScreen extends StatefulWidget {
  const MedicationTrackingScreen({super.key});

  @override
  _MedicationTrackingScreenState createState() => _MedicationTrackingScreenState();
}

class _MedicationTrackingScreenState extends State<MedicationTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Data
  List<SmartMedicationGuide> _allGuides = [];
  List<MedicationAdherence> _adherenceHistory = [];
  List<SmartMedicationGuide> _todaysDue = [];
  Map<String, List<String>> _calendar = {};
  final Map<int, Map<String, dynamic>> _progressData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    try {
      final futures = await Future.wait([
        MedicationService.getAllGuides(),
        MedicationService.getAdherenceHistory(),
        MedicationService.getTodaysDueMedications(),
        MedicationService.getDoseCalendar(),
      ]);

      _allGuides = futures[0] as List<SmartMedicationGuide>;
      _adherenceHistory = futures[1] as List<MedicationAdherence>;
      _todaysDue = futures[2] as List<SmartMedicationGuide>;
      _calendar = futures[3] as Map<String, List<String>>;

      // Load progress for each guide
      for (var guide in _allGuides) {
        final progress = await MedicationService.getProgress(guide.id);
        _progressData[guide.id] = progress;
      }
    } catch (e) {
      _showErrorSnackBar('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDose(SmartMedicationGuide guide) async {
    final success = await MedicationService.confirmDose(guide.id);
    if (success) {
      _showSuccessSnackBar('Dose confirmed for ${guide.medicationName}');
      _loadAllData(); // Refresh data
    } else {
      _showErrorSnackBar('Failed to confirm dose');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Tracker'),

        




        backgroundColor: Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.today), text: 'Due Today'),
            Tab(icon: Icon(Icons.medication), text: 'All Meds'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodaysDueTab(),
                _buildAllMedicationsTab(),
                _buildHistoryTab(),
                _buildCalendarTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAllData,
        backgroundColor: Color(0xFF2ECC71),
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildTodaysDueTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _todaysDue.length,
        itemBuilder: (context, index) {
          final guide = _todaysDue[index];
          return _buildTodayDueCard(guide);
        },
      ),
    );
  }

  Widget _buildTodayDueCard(SmartMedicationGuide guide) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.medication, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.medicationName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        guide.visualDescription,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      guide.usageInstruction,
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${guide.dosesPerDay} times/day',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                ElevatedButton.icon(
                  onPressed: () => _confirmDose(guide),
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text('Take Now', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2ECC71),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllMedicationsTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _allGuides.length,
        itemBuilder: (context, index) {
          final guide = _allGuides[index];
          final progress = _progressData[guide.id] ?? {};
          return _buildMedicationCard(guide, progress);
        },
      ),
    );
  }

  Widget _buildMedicationCard(SmartMedicationGuide guide, Map<String, dynamic> progress) {
    final progressPercentage = (progress['adherencePercentage'] ?? 0.0) as double;
    final remainingDays = guide.totalDays - 
        DateTime.now().difference(guide.startDate).inDays;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF2ECC71),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.medication, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.medicationName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        guide.visualDescription,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(guide.usageInstruction),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip('${guide.dosesPerDay}x/day', Icons.schedule),
                _buildInfoChip('$remainingDays days left', Icons.calendar_today),
                _buildInfoChip('${progressPercentage.toStringAsFixed(1)}%', Icons.trending_up),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
            ),
            SizedBox(height: 8),
            Text(
              'Started: ${DateFormat('MMM dd, yyyy').format(guide.startDate)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF2ECC71).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Color(0xFF2ECC71)),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Color(0xFF2ECC71)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final groupedHistory = <String, List<MedicationAdherence>>{};
    
    for (var adherence in _adherenceHistory) {
      final dateKey = DateFormat('yyyy-MM-dd').format(adherence.takenAt);
      if (!groupedHistory.containsKey(dateKey)) {
        groupedHistory[dateKey] = [];
      }
      groupedHistory[dateKey]!.add(adherence);
    }

    final sortedDates = groupedHistory.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final adherences = groupedHistory[date]!;
          return _buildHistoryDateSection(date, adherences);
        },
      ),
    );
  }

  Widget _buildHistoryDateSection(String date, List<MedicationAdherence> adherences) {
    final parsedDate = DateTime.parse(date);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == date;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isToday ? Icons.today : Icons.calendar_today,
                  color: isToday ? Color(0xFF2ECC71) : Colors.grey,
                ),
                SizedBox(width: 8),
                Text(
                  isToday ? 'Today' : DateFormat('EEEE, MMM dd').format(parsedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Color(0xFF2ECC71) : Colors.black,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${adherences.length} doses',
                    style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...adherences.map((adherence) => _buildHistoryItem(adherence)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(MedicationAdherence adherence) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFF2ECC71),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adherence.guide.medicationName,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Taken at ${DateFormat('h:mm a').format(adherence.takenAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 20),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    final today = DateTime.now();
    final currentMonth = DateTime(today.year, today.month, 1);
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: daysInMonth,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final date = DateTime(today.year, today.month, day);
                  final dateKey = DateFormat('yyyy-MM-dd').format(date);
                  final medications = _calendar[dateKey] ?? [];
                  
                  return _buildCalendarDay(day, medications, date == today);
                },
              ),
            ),
            if (_calendar.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Legend:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildLegendItem(Color(0xFF2ECC71), 'Has medications'),
                  SizedBox(width: 16),
                  _buildLegendItem(Colors.blue, 'Today'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(int day, List<String> medications, bool isToday) {
    return Container(
      decoration: BoxDecoration(
        color: isToday 
            ? Colors.blue 
            : medications.isNotEmpty 
                ? Color(0xFF2ECC71) 
                : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              color: isToday || medications.isNotEmpty ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (medications.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}