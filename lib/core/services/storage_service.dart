import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/check_in_model.dart';
import 'export_format_service.dart';
import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart' as file_download;

/// Local-first storage service for check-ins
/// Implements PRD R1.2: Persistence with immediate save to local storage
class StorageService {
  static const String _checkInsKey = 'check_ins_v2';
  static const String _activityTypesKey = 'activity_types';

  /// Load all check-ins from storage
  static Future<Map<String, DayCheckIn>> getCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    final checkInsJson = prefs.getString(_checkInsKey);

    if (checkInsJson == null) return {};

    final Map<String, dynamic> decoded = json.decode(checkInsJson);
    return decoded.map((key, value) =>
      MapEntry(key, DayCheckIn.fromJson(value as Map<String, dynamic>))
    );
  }

  /// Save check-ins to storage
  static Future<void> saveCheckIns(Map<String, DayCheckIn> checkIns) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = checkIns.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_checkInsKey, json.encode(encoded));
  }

  /// Load activity types
  static Future<List<String>> getActivityTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final activityTypesJson = prefs.getString(_activityTypesKey);

    if (activityTypesJson == null) {
      // Default activity types from PRD
      return ['Run', 'Yoga', 'Gym', 'Walk', 'Bike'];
    }

    final List<dynamic> decoded = json.decode(activityTypesJson);
    return decoded.cast<String>();
  }

  /// Save activity types
  static Future<void> saveActivityTypes(List<String> activityTypes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activityTypesKey, json.encode(activityTypes));
  }

  /// Export data in the specified format (PRD R6.0)
  /// Works on Web, Mobile (iOS/Android), and Desktop (Windows/macOS/Linux)
  static Future<void> exportData({ExportFormat format = ExportFormat.json}) async {
    final checkIns = await getCheckIns();
    final activityTypes = await getActivityTypes();

    final data = CheckInData(
      checkIns: checkIns,
      activityTypes: activityTypes,
      exportedAt: DateTime.now().toIso8601String(),
    );

    final content = ExportFormatService.convertToFormat(data, format);
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final fileName = 'momentum-backup-$dateStr.${format.extension}';

    if (kIsWeb) {
      // Web platform - trigger download in browser
      file_download.downloadFile(content, fileName);
    } else {
      // Mobile and Desktop platforms - save to temp directory and share
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      // Share the file (works on mobile and desktop)
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Momentum Backup',
        text: 'Backup created on ${DateTime.now().toLocal()}',
      );
    }
  }

  /// Import data from file (PRD R6.1 compatible)
  /// Automatically detects format based on file extension
  static Future<bool> importData(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      // Detect format from file extension
      final extension = filePath.split('.').last.toLowerCase();
      ExportFormat? format;

      for (final f in ExportFormat.values) {
        if (f.extension == extension) {
          format = f;
          break;
        }
      }

      // Default to JSON if format not recognized
      format ??= ExportFormat.json;

      // Convert from format
      final data = ExportFormatService.convertFromFormat(content, format);
      if (data == null) return false;

      await saveCheckIns(data.checkIns);
      await saveActivityTypes(data.activityTypes);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset all data (PRD R6.1)
  static Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkInsKey);
    await prefs.remove(_activityTypesKey);
  }
}
