import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/check_in_model.dart';
import '../services/storage_service.dart';
import '../utils/streak_calculator.dart';

/// Check-ins provider - manages all daily check-ins
final checkInsProvider = StateNotifierProvider<CheckInsNotifier, Map<String, DayCheckIn>>((ref) {
  return CheckInsNotifier();
});

class CheckInsNotifier extends StateNotifier<Map<String, DayCheckIn>> {
  CheckInsNotifier() : super({}) {
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    state = await StorageService.getCheckIns();
  }

  /// Toggle check-in for a specific date (PRD R1.1: One-Tap Check-in)
  Future<void> toggleCheckIn(DateTime date) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final newState = Map<String, DayCheckIn>.from(state);

    if (newState.containsKey(dateKey)) {
      // Remove check-in
      newState.remove(dateKey);
    } else {
      // Add check-in
      newState[dateKey] = DayCheckIn(
        date: dateKey,
        timestamp: DateTime.now(),
      );
    }

    state = newState;
    await StorageService.saveCheckIns(newState);
  }

  /// Update activity type for a date (PRD R3.0: Post-Check-in Flow)
  Future<void> updateActivityType(DateTime date, String? activityType) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final newState = Map<String, DayCheckIn>.from(state);

    if (newState.containsKey(dateKey)) {
      newState[dateKey] = newState[dateKey]!.copyWith(
        activityType: activityType,
      );
      state = newState;
      await StorageService.saveCheckIns(newState);
    }
  }

  /// Check if a date is checked in
  bool isCheckedIn(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return state.containsKey(dateKey);
  }

  /// Get activity type for a date
  String? getActivityType(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return state[dateKey]?.activityType;
  }

  /// Reload from storage
  Future<void> reload() async {
    await _loadCheckIns();
  }
}

/// Activity types provider - manages custom activity list
final activityTypesProvider = StateNotifierProvider<ActivityTypesNotifier, List<String>>((ref) {
  return ActivityTypesNotifier();
});

class ActivityTypesNotifier extends StateNotifier<List<String>> {
  ActivityTypesNotifier() : super([]) {
    _loadActivityTypes();
  }

  Future<void> _loadActivityTypes() async {
    state = await StorageService.getActivityTypes();
  }

  /// Add a new activity type (PRD R3.1: Custom Activities)
  Future<void> addActivityType(String activityType) async {
    if (activityType.trim().isEmpty || state.contains(activityType.trim())) {
      return;
    }

    final newState = [...state, activityType.trim()];
    state = newState;
    await StorageService.saveActivityTypes(newState);
  }

  /// Remove an activity type
  Future<void> removeActivityType(String activityType) async {
    final newState = state.where((a) => a != activityType).toList();
    state = newState;
    await StorageService.saveActivityTypes(newState);
  }

  /// Reload from storage
  Future<void> reload() async {
    await _loadActivityTypes();
  }
}

/// Streak stats provider - computed from check-ins
final streakStatsProvider = Provider<StreakStats>((ref) {
  final checkIns = ref.watch(checkInsProvider);
  return StreakCalculator.calculateStreaks(checkIns);
});
