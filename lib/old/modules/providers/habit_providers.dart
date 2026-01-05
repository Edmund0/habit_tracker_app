import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/old/modules/models/habit_models.dart';
import 'package:momentum/old/modules/services/local_storage_service.dart';
import 'package:momentum/old/modules/utils/streak_calculator.dart';

// Habits provider
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<String>>((ref) {
  return HabitsNotifier();
});

class HabitsNotifier extends StateNotifier<List<String>> {
  HabitsNotifier() : super([]) {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    state = await LocalStorageService.getHabits();
  }

  Future<void> addHabit(String habit) async {
    if (habit.trim().isEmpty || state.contains(habit.trim())) return;
    
    final newState = [...state, habit.trim()];
    state = newState;
    await LocalStorageService.saveHabits(newState);
  }

  Future<void> removeHabit(String habit) async {
    final newState = state.where((h) => h != habit).toList();
    state = newState;
    await LocalStorageService.saveHabits(newState);
  }

  Future<void> reload() async {
    await _loadHabits();
  }
}

// Checkins provider
final checkinsProvider = StateNotifierProvider<CheckinsNotifier, Map<String, List<String>>>((ref) {
  return CheckinsNotifier();
});

class CheckinsNotifier extends StateNotifier<Map<String, List<String>>> {
  CheckinsNotifier() : super({}) {
    _loadCheckins();
  }

  Future<void> _loadCheckins() async {
    state = await LocalStorageService.getCheckins();
  }

  Future<void> toggleHabit(String dateKey, String habit) async {
    final newState = Map<String, List<String>>.from(state);
    
    if (!newState.containsKey(dateKey)) {
      newState[dateKey] = [];
    }
    
    if (newState[dateKey]!.contains(habit)) {
      newState[dateKey] = newState[dateKey]!.where((h) => h != habit).toList();
    } else {
      newState[dateKey] = [...newState[dateKey]!, habit];
    }
    
    if (newState[dateKey]!.isEmpty) {
      newState.remove(dateKey);
    }
    
    state = newState;
    await LocalStorageService.saveCheckins(newState);
  }

  Future<void> reload() async {
    await _loadCheckins();
  }
}

// Streaks provider
final streaksProvider = Provider<StreakData>((ref) {
  final habits = ref.watch(habitsProvider);
  final checkins = ref.watch(checkinsProvider);
  
  return StreakCalculator.calculateStreaks(checkins, habits);
});