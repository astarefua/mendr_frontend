// screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  int _reminderMinutesBefore = 5;
  bool _missedDoseReminders = true;
  int _missedDoseReminderMinutes = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await NotificationService.getNotificationSettings();
    if (settings != null) {
      setState(() {
        _notificationsEnabled = settings.notificationsEnabled;
        _reminderMinutesBefore = settings.reminderMinutesBefore;
        _missedDoseReminders = settings.missedDoseReminders;
        _missedDoseReminderMinutes = settings.missedDoseReminderMinutes;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final settings = NotificationSettings(
      notificationsEnabled: _notificationsEnabled,
      reminderMinutesBefore: _reminderMinutesBefore,
      missedDoseReminders: _missedDoseReminders,
      missedDoseReminderMinutes: _missedDoseReminderMinutes,
    );

    final success = await NotificationService.updateNotificationSettings(settings);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings saved successfully'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        backgroundColor: Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(1),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'General Settings',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12),
                          SwitchListTile(
                            title: Text('Enable Notifications'),
                            subtitle: Text('Receive medication reminders'),
                            value: _notificationsEnabled,
                            onChanged: (value) => setState(() => _notificationsEnabled = value),
                            activeColor: Color(0xFF2ECC71),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_notificationsEnabled) ...[
                    SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reminder Settings',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            ListTile(
                              title: Text('Reminder Time'),
                              subtitle: Text('$_reminderMinutesBefore minutes before dose time'),
                              trailing: DropdownButton<int>(
                                value: _reminderMinutesBefore,
                                items: [1, 5, 10, 15, 30].map((minutes) {
                                  return DropdownMenuItem(
                                    value: minutes,
                                    child: Text('$minutes min'),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _reminderMinutesBefore = value!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Missed Dose Settings',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            SwitchListTile(
                              title: Text('Missed Dose Reminders'),
                              subtitle: Text('Get notified if you miss a dose'),
                              value: _missedDoseReminders,
                              onChanged: (value) => setState(() => _missedDoseReminders = value),
                              activeColor: Color(0xFF2ECC71),
                            ),
                            
                            if (_missedDoseReminders)
                              ListTile(
                                title: Text('Missed Dose Alert'),
                                subtitle: Text('$_missedDoseReminderMinutes minutes after missed dose'),
                                trailing: DropdownButton<int>(
                                  value: _missedDoseReminderMinutes,
                                  items: [5, 10, 15, 30, 60].map((minutes) {
                                    return DropdownMenuItem(
                                      value: minutes,
                                      child: Text('$minutes min'),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _missedDoseReminderMinutes = value!),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  Spacer(),
                  
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2ECC71),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save Settings',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}