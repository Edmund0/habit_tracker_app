import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/check_in_model.dart';

/// Supported export/import formats
enum ExportFormat {
  json('JSON', 'json', 'application/json'),
  csv('CSV', 'csv', 'text/csv'),
  markdown('Markdown', 'md', 'text/markdown');

  final String displayName;
  final String extension;
  final String mimeType;

  const ExportFormat(this.displayName, this.extension, this.mimeType);
}

/// Service for converting check-in data between different formats
class ExportFormatService {
  /// Convert check-in data to the specified format
  static String convertToFormat(
    CheckInData data,
    ExportFormat format,
  ) {
    switch (format) {
      case ExportFormat.json:
        return _convertToJson(data);
      case ExportFormat.csv:
        return _convertToCsv(data);
      case ExportFormat.markdown:
        return _convertToMarkdown(data);
    }
  }

  /// Convert JSON string back to CheckInData
  static CheckInData? convertFromFormat(
    String content,
    ExportFormat format,
  ) {
    try {
      switch (format) {
        case ExportFormat.json:
          return _convertFromJson(content);
        case ExportFormat.csv:
          return _convertFromCsv(content);
        case ExportFormat.markdown:
          return _convertFromMarkdown(content);
      }
    } catch (e) {
      return null;
    }
  }

  // JSON Conversion
  static String _convertToJson(CheckInData data) {
    return const JsonEncoder.withIndent('  ').convert(data.toJson());
  }

  static CheckInData _convertFromJson(String content) {
    return CheckInData.fromJson(json.decode(content));
  }

  // CSV Conversion
  static String _convertToCsv(CheckInData data) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Date,Activity Type,Timestamp');

    // Sort dates chronologically
    final sortedDates = data.checkIns.keys.toList()..sort();

    // Data rows
    for (final dateKey in sortedDates) {
      final checkIn = data.checkIns[dateKey]!;
      final activityType = checkIn.activityType ?? '';
      final timestamp = checkIn.timestamp.toIso8601String();

      // Escape commas in activity type if needed
      final escapedActivity = activityType.contains(',')
          ? '"$activityType"'
          : activityType;

      buffer.writeln('$dateKey,$escapedActivity,$timestamp');
    }

    // Add activity types as metadata at the end
    buffer.writeln();
    buffer.writeln('# Activity Types');
    for (final activity in data.activityTypes) {
      buffer.writeln('# $activity');
    }

    // Add export metadata
    buffer.writeln();
    buffer.writeln('# Exported: ${data.exportedAt}');

    return buffer.toString();
  }

  static CheckInData _convertFromCsv(String content) {
    final lines = content.split('\n').map((line) => line.trim()).toList();
    final checkIns = <String, DayCheckIn>{};
    final activityTypes = <String>[];
    String exportedAt = DateTime.now().toIso8601String();

    var isDataSection = true;

    for (var i = 1; i < lines.length; i++) {
      // Skip header
      final line = lines[i];

      if (line.isEmpty) {
        isDataSection = false;
        continue;
      }

      if (line.startsWith('#')) {
        // Parse metadata
        if (line.startsWith('# Activity Types')) {
          continue;
        } else if (line.startsWith('# Exported:')) {
          exportedAt = line.substring('# Exported:'.length).trim();
        } else if (!isDataSection) {
          // Activity type
          final activity = line.substring(2).trim();
          if (activity.isNotEmpty) {
            activityTypes.add(activity);
          }
        }
        continue;
      }

      if (!isDataSection) continue;

      // Parse data row
      final parts = _parseCsvLine(line);
      if (parts.length >= 3) {
        final dateKey = parts[0];
        final activityType = parts[1].isEmpty ? null : parts[1];
        final timestamp = DateTime.parse(parts[2]);

        checkIns[dateKey] = DayCheckIn(
          date: dateKey,
          timestamp: timestamp,
          activityType: activityType,
        );
      }
    }

    return CheckInData(
      checkIns: checkIns,
      activityTypes: activityTypes.isEmpty
          ? ['Run', 'Yoga', 'Gym', 'Walk', 'Bike']
          : activityTypes,
      exportedAt: exportedAt,
    );
  }

  // Markdown Conversion
  static String _convertToMarkdown(CheckInData data) {
    final buffer = StringBuffer();

    buffer.writeln('# Momentum Activity Log');
    buffer.writeln();
    buffer.writeln('**Exported:** ${data.exportedAt}');
    buffer.writeln();

    // Group by month
    final Map<String, List<MapEntry<String, DayCheckIn>>> groupedByMonth = {};

    for (final entry in data.checkIns.entries) {
      final date = DateTime.parse(entry.key);
      final monthKey = DateFormat('MMMM yyyy').format(date);

      groupedByMonth.putIfAbsent(monthKey, () => []);
      groupedByMonth[monthKey]!.add(entry);
    }

    // Sort months
    final sortedMonths = groupedByMonth.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA); // Most recent first
      });

    // Write each month
    for (final month in sortedMonths) {
      buffer.writeln('## $month');
      buffer.writeln();

      // Sort dates within month (most recent first)
      final entries = groupedByMonth[month]!
        ..sort((a, b) => b.key.compareTo(a.key));

      for (final entry in entries) {
        final date = DateTime.parse(entry.key);
        final dayOfWeek = DateFormat('EEEE').format(date);
        final formattedDate = DateFormat('MMMM d, y').format(date);
        final activity = entry.value.activityType ?? '_No activity specified_';

        buffer.writeln('- **$dayOfWeek, $formattedDate**: $activity');
      }

      buffer.writeln();
    }

    // Add activity types section
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('## Available Activity Types');
    buffer.writeln();
    for (final activity in data.activityTypes) {
      buffer.writeln('- $activity');
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('_Total check-ins: ${data.checkIns.length}_');

    return buffer.toString();
  }

  static CheckInData _convertFromMarkdown(String content) {
    final lines = content.split('\n').map((line) => line.trim()).toList();
    final checkIns = <String, DayCheckIn>{};
    final activityTypes = <String>[];
    String exportedAt = DateTime.now().toIso8601String();

    var inActivityTypesSection = false;

    for (final line in lines) {
      // Parse exported date
      if (line.startsWith('**Exported:**')) {
        exportedAt = line.substring('**Exported:**'.length).trim();
        continue;
      }

      // Detect activity types section
      if (line == '## Available Activity Types') {
        inActivityTypesSection = true;
        continue;
      }

      // Parse activity types
      if (inActivityTypesSection && line.startsWith('- ') && !line.startsWith('- **')) {
        final activity = line.substring(2).trim();
        if (activity.isNotEmpty && activity != '---') {
          activityTypes.add(activity);
        }
        continue;
      }

      // Reset section flag
      if (line == '---') {
        inActivityTypesSection = false;
        continue;
      }

      // Parse check-in entries (format: - **DayOfWeek, Date**: Activity)
      if (line.startsWith('- **') && line.contains(':**')) {
        final match = RegExp(r'- \*\*.*?,\s*([^*]+)\*\*:\s*(.+)').firstMatch(line);
        if (match != null) {
          final dateStr = match.group(1)!.trim();
          final activity = match.group(2)!.trim();

          try {
            final date = DateFormat('MMMM d, y').parse(dateStr);
            final dateKey = DateFormat('yyyy-MM-dd').format(date);

            checkIns[dateKey] = DayCheckIn(
              date: dateKey,
              timestamp: date,
              activityType: activity == '_No activity specified_' ? null : activity,
            );
          } catch (e) {
            // Skip invalid dates
            continue;
          }
        }
      }
    }

    return CheckInData(
      checkIns: checkIns,
      activityTypes: activityTypes.isEmpty
          ? ['Run', 'Yoga', 'Gym', 'Walk', 'Bike']
          : activityTypes,
      exportedAt: exportedAt,
    );
  }

  // Helper method to parse CSV lines with quoted values
  static List<String> _parseCsvLine(String line) {
    final parts = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        parts.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }

    parts.add(current.toString());
    return parts;
  }
}
