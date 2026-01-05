import 'package:json_annotation/json_annotation.dart';

part 'habit_models.g.dart';

@JsonSerializable()
class HabitData {
  final List<String> habits;
  final Map<String, List<String>> checkins;
  final String? exportedAt;

  HabitData({
    required this.habits,
    required this.checkins,
    this.exportedAt,
  });

  factory HabitData.fromJson(Map<String, dynamic> json) =>
      _$HabitDataFromJson(json);

  Map<String, dynamic> toJson() => _$HabitDataToJson(this);
}

class StreakData {
  final int monthly;
  final YearlyProgress yearly;
  final TotalStreak total;

  StreakData({
    required this.monthly,
    required this.yearly,
    required this.total,
  });
}

class YearlyProgress {
  final int streak;
  final int percentage;
  final int checkedDays;
  final int totalDays;

  YearlyProgress({
    required this.streak,
    required this.percentage,
    required this.checkedDays,
    required this.totalDays,
  });
}

class TotalStreak {
  final int streak;
  final bool graceDayUsed;

  TotalStreak({
    required this.streak,
    required this.graceDayUsed,
  });
}