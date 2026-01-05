import 'package:json_annotation/json_annotation.dart';

part 'check_in_model.g.dart';

/// Represents a single day's check-in with optional activity type
@JsonSerializable()
class DayCheckIn {
  final String date; // Format: yyyy-MM-dd
  final String? activityType; // Optional: "Run", "Yoga", etc.
  final DateTime timestamp;

  DayCheckIn({
    required this.date,
    this.activityType,
    required this.timestamp,
  });

  factory DayCheckIn.fromJson(Map<String, dynamic> json) =>
      _$DayCheckInFromJson(json);

  Map<String, dynamic> toJson() => _$DayCheckInToJson(this);

  DayCheckIn copyWith({
    String? date,
    String? activityType,
    DateTime? timestamp,
  }) {
    return DayCheckIn(
      date: date ?? this.date,
      activityType: activityType ?? this.activityType,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// All check-ins with export metadata
@JsonSerializable()
class CheckInData {
  final Map<String, DayCheckIn> checkIns; // Key: date (yyyy-MM-dd)
  final List<String> activityTypes; // User's custom activity list
  final String? exportedAt;

  CheckInData({
    required this.checkIns,
    required this.activityTypes,
    this.exportedAt,
  });

  factory CheckInData.fromJson(Map<String, dynamic> json) =>
      _$CheckInDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInDataToJson(this);
}

/// Streak statistics
class StreakStats {
  final int currentStreak;
  final int monthlyCount;
  final int yearlyCount;
  final int yearlyPercentage;
  final int totalDays;
  final bool graceDayUsed;

  StreakStats({
    required this.currentStreak,
    required this.monthlyCount,
    required this.yearlyCount,
    required this.yearlyPercentage,
    required this.totalDays,
    this.graceDayUsed = false,
  });
}
