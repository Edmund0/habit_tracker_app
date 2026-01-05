
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A constant key for storing the check-in data in SharedPreferences.
const String _dbKey = 'momentum_db';

/// A service class for handling all data persistence using SharedPreferences.
///
/// This class abstracts the logic for saving, loading, and processing
/// check-in data, providing a clean API for the UI to interact with.
class DatabaseService extends ChangeNotifier {
  late SharedPreferences _prefs;

  // A set to store the dates of all check-ins. Using a Set ensures that
  // each date is unique. Dates are stored in 'YYYY-MM-DD' format.
  final Set<String> _checkedInDates = {};

  /// Loads the check-in data from SharedPreferences upon initialization.
  Future<void> loadDb() async {
    _prefs = await SharedPreferences.getInstance();
    // Retrieve the stored data, which is a list of date strings.
    final List<String> data = _prefs.getStringList(_dbKey) ?? [];
    _checkedInDates.clear();
    _checkedInDates.addAll(data);
    // Notify listeners to rebuild widgets that depend on this data.
    notifyListeners();
  }

  /// Saves the current check-in data to SharedPreferences.
  Future<void> _saveDb() async {
    // Convert the Set to a List to store it in SharedPreferences.
    await _prefs.setStringList(_dbKey, _checkedInDates.toList());
  }

  /// Returns a list of all dates that have been checked in.
  List<DateTime> getCheckedInDates() {
    return _checkedInDates.map((dateStr) => DateTime.parse(dateStr)).toList();
  }

  /// Toggles the check-in status for a given date.
  ///
  /// If the date is already checked in, it will be removed.
  /// If it's not checked in, it will be added.
  Future<void> toggleDate(DateTime date) async {
    final dateStr = _formatDate(date);
    if (_checkedInDates.contains(dateStr)) {
      _checkedInDates.remove(dateStr);
    } else {
      _checkedInDates.add(dateStr);
    }
    await _saveDb();
    notifyListeners();
  }

  /// Checks if a specific date is marked as checked-in.
  bool isCheckedIn(DateTime date) {
    return _checkedInDates.contains(_formatDate(date));
  }

  /// Calculates the current streak of consecutive check-in days.
  ///
  /// The streak is calculated backwards from today. It allows for a one-day
  /// gap (i.e., the streak continues if yesterday was missed but the day
  /// before was checked in).
  int getStreak() {
    if (_checkedInDates.isEmpty) {
      return 0;
    }

    int streak = 0;
    DateTime today = DateTime.now();
    
    // Check if today is a check-in day.
    if (isCheckedIn(today)) {
        streak++;
    }

    // Start checking from yesterday.
    DateTime currentDate = today.subtract(const Duration(days: 1));

    while (true) {
      if (isCheckedIn(currentDate)) {
        streak++;
      } else {
        // If today wasn't checked, and yesterday wasn't, the streak is 0.
        // The only exception is if today IS checked, in which case the streak is 1.
        if (streak == 0 || (streak == 1 && !isCheckedIn(today))) {
          break;
        }
        if (!isCheckedIn(currentDate.subtract(const Duration(days: 1)))) {
            break;
        }
      }
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Calculates the number of check-ins in the current month.
  int getMonthlyCheckIns() {
    final now = DateTime.now();
    return _checkedInDates.where((dateStr) {
      final date = DateTime.parse(dateStr);
      return date.year == now.year && date.month == now.month;
    }).length;
  }

  /// Calculates the consistency percentage for the current year.
  double getYearlyConsistency() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final daysInYear = now.difference(startOfYear).inDays + 1;

    final yearlyCheckIns = _checkedInDates.where((dateStr) {
      return DateTime.parse(dateStr).year == now.year;
    }).length;

    return (yearlyCheckIns / daysInYear);
  }

  /// Exports all check-in data to a JSON string.
  String exportData() {
    // Sort the dates for a clean, ordered export file.
    final sortedDates = _checkedInDates.toList()..sort();
    return jsonEncode({'checkedInDates': sortedDates});
  }

  /// Clears all stored check-in data.
  Future<void> resetData() async {
    _checkedInDates.clear();
    await _saveDb();
    notifyListeners();
  }

  /// A private helper to format a DateTime object into a 'YYYY-MM-DD' string.
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
