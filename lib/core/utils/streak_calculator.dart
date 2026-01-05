import 'package:intl/intl.dart';
import '../models/check_in_model.dart';

/// Calculates streaks based on check-in data
/// Implements PRD R2.0: Streak Calculation with yesterday/today logic
class StreakCalculator {
  static StreakStats calculateStreaks(Map<String, DayCheckIn> checkIns) {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    return StreakStats(
      currentStreak: _calculateCurrentStreak(checkIns, todayNormalized),
      monthlyCount: _calculateMonthlyCount(checkIns, todayNormalized),
      yearlyCount: _calculateYearlyCount(checkIns, todayNormalized),
      yearlyPercentage: _calculateYearlyPercentage(checkIns, todayNormalized),
      totalDays: checkIns.length,
      graceDayUsed: _isGraceDayUsed(checkIns, todayNormalized),
    );
  }

  /// Check if date has a check-in
  static bool _hasCheckIn(Map<String, DayCheckIn> checkIns, DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return checkIns.containsKey(dateKey);
  }

  /// Calculate current streak with grace day (1-day forgiveness)
  static int _calculateCurrentStreak(
    Map<String, DayCheckIn> checkIns,
    DateTime today,
  ) {
    int streak = 0;
    DateTime currentDate = today;
    bool graceDayUsed = false;
    int missedDays = 0;

    while (true) {
      if (_hasCheckIn(checkIns, currentDate)) {
        streak++;
        missedDays = 0;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        missedDays++;

        // Allow skipping today if not checked in yet
        if (_isSameDay(currentDate, today)) {
          currentDate = currentDate.subtract(const Duration(days: 1));
          missedDays = 0;
        }
        // Use grace day if available
        else if (missedDays == 1 && !graceDayUsed) {
          graceDayUsed = true;
          currentDate = currentDate.subtract(const Duration(days: 1));
        }
        // Streak broken
        else {
          break;
        }
      }

      // Safety check - don't go back more than 5 years
      if (today.difference(currentDate).inDays > 365 * 5) {
        break;
      }
    }

    return streak;
  }

  /// Check if grace day was used in current streak
  static bool _isGraceDayUsed(
    Map<String, DayCheckIn> checkIns,
    DateTime today,
  ) {
    DateTime currentDate = today;

    // Skip today if not checked in
    if (!_hasCheckIn(checkIns, today)) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    // Check yesterday
    if (!_hasCheckIn(checkIns, currentDate)) {
      return true;
    }

    // Continue backwards looking for a gap
    while (_hasCheckIn(checkIns, currentDate)) {
      currentDate = currentDate.subtract(const Duration(days: 1));

      // Safety check
      if (today.difference(currentDate).inDays > 365) {
        break;
      }
    }

    // Check if day after the gap has check-in
    final dayAfterGap = currentDate.add(const Duration(days: 2));
    return _hasCheckIn(checkIns, dayAfterGap);
  }

  /// Calculate monthly count (PRD R2.1: Monthly Count)
  static int _calculateMonthlyCount(
    Map<String, DayCheckIn> checkIns,
    DateTime today,
  ) {
    final monthStart = DateTime(today.year, today.month, 1);
    int count = 0;

    DateTime currentDate = monthStart;
    while (!currentDate.isAfter(today)) {
      if (_hasCheckIn(checkIns, currentDate)) {
        count++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return count;
  }

  /// Calculate yearly count
  static int _calculateYearlyCount(
    Map<String, DayCheckIn> checkIns,
    DateTime today,
  ) {
    final yearStart = DateTime(today.year, 1, 1);
    int count = 0;

    DateTime currentDate = yearStart;
    while (!currentDate.isAfter(today)) {
      if (_hasCheckIn(checkIns, currentDate)) {
        count++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return count;
  }

  /// Calculate yearly percentage (PRD R2.1: Yearly Consistency %)
  static int _calculateYearlyPercentage(
    Map<String, DayCheckIn> checkIns,
    DateTime today,
  ) {
    final yearStart = DateTime(today.year, 1, 1);
    final daysInYear = today.difference(yearStart).inDays + 1;
    final count = _calculateYearlyCount(checkIns, today);

    return ((count / daysInYear) * 100).round();
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
