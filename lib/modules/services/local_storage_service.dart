import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/habit_models.dart';

class LocalStorageService {
  static const String _habitsKey = 'habits';
  static const String _checkinsKey = 'checkins';

  static Future<List<String>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString(_habitsKey);
    if (habitsJson == null) return [];
    
    final List<dynamic> decoded = json.decode(habitsJson);
    return decoded.cast<String>();
  }

  static Future<void> saveHabits(List<String> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_habitsKey, json.encode(habits));
  }

  static Future<Map<String, List<String>>> getCheckins() async {
    final prefs = await SharedPreferences.getInstance();
    final checkinsJson = prefs.getString(_checkinsKey);
    if (checkinsJson == null) return {};
    
    final Map<String, dynamic> decoded = json.decode(checkinsJson);
    return decoded.map((key, value) => 
      MapEntry(key, (value as List<dynamic>).cast<String>())
    );
  }

  static Future<void> saveCheckins(Map<String, List<String>> checkins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkinsKey, json.encode(checkins));
  }

  static Future<void> exportData() async {
    final habits = await getHabits();
    final checkins = await getCheckins();
    
    final data = HabitData(
      habits: habits,
      checkins: checkins,
      exportedAt: DateTime.now().toIso8601String(),
    );

    final jsonString = const JsonEncoder.withIndent('  ').convert(data.toJson());
    final fileName = 'habit-tracker-backup-${DateTime.now().toIso8601String().split('T')[0]}.json';
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Habit Tracker Backup',
    );
  }

  static Future<bool> importData(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = HabitData.fromJson(json.decode(jsonString));
      
      await saveHabits(data.habits);
      await saveCheckins(data.checkins);
      
      return true;
    } catch (e) {
      return false;
    }
  }
}