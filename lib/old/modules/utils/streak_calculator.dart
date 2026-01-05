import 'package:intl/intl.dart';
import '../models/habit_models.dart';

class StreakCalculator {
  static StreakData calculateStreaks(
    Map<String, List<String>> checkins,
    List<String> habits,
  ) {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    return StreakData(
      monthly: _calculateMonthlyStreak(checkins, todayNormalized),
      yearly: _calculateYearlyProgress(checkins, todayNormalized),
      total: _calculateTotalStreak(checkins, todayNormalized),
    );
  }

  static bool _hasCheckin(
    Map<String, List<String>> checkins,
    DateTime date,
  ) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return checkins[dateKey]?.isNotEmpty ?? false;
  }

  static int _calculateMonthlyStreak(
    Map<String, List<String>> checkins,
    DateTime today,
  ) {
    final monthStart = DateTime(today.year, today.month, 1);
    int streak = 0;
    DateTime currentDate = today;

    while (!currentDate.isBefore(monthStart)) {
      if (_hasCheckin(checkins, currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (_isSameDay(currentDate, today)) {
        // Today can be skipped if not checked in yet
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static YearlyProgress _calculateYearlyProgress(
    Map<String, List<String>> checkins,
    DateTime today,
  ) {
    final yearStart = DateTime(today.year, 1, 1);
    final daysInYear = today.difference(yearStart).inDays + 1;
    int checkedDays = 0;

    DateTime currentDate = yearStart;
    while (!currentDate.isAfter(today)) {
      if (_hasCheckin(checkins, currentDate)) {
        checkedDays++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    final percentage = ((checkedDays / daysInYear) * 100).round();

    // Calculate current streak within the year
    int streak = 0;
    currentDate = today;
    while (!currentDate.isBefore(yearStart)) {
      if (_hasCheckin(checkins, currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (_isSameDay(currentDate, today)) {
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return YearlyProgress(
      streak: streak,
      percentage: percentage,
      checkedDays: checkedDays,
      totalDays: daysInYear,
    );
  }

  static TotalStreak _calculateTotalStreak(
    Map<String, List<String>> checkins,
    DateTime today,
  ) {
    int streak = 0;
    DateTime currentDate = today;
    bool graceDayUsed = false;
    int missedDays = 0;

    while (true) {
      if (_hasCheckin(checkins, currentDate)) {
        streak++;
        missedDays = 0;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        missedDays++;

        if (missedDays == 1 && !graceDayUsed) {
          if (_isSameDay(currentDate, today)) {
            currentDate = currentDate.subtract(const Duration(days: 1));
            missedDays = 0;
          } else {
            graceDayUsed = true;
            currentDate = currentDate.subtract(const Duration(days: 1));
          }
        } else if (missedDays > 1 || (missedDays == 1 && graceDayUsed)) {
          break;
        } else {
          currentDate = currentDate.subtract(const Duration(days: 1));
        }
      }

      // Safety check - don't go back more than 5 years
      if (today.difference(currentDate).inDays > 365 * 5) {
        break;
      }
    }

    return TotalStreak(streak: streak, graceDayUsed: graceDayUsed);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}