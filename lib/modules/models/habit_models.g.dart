// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitData _$HabitDataFromJson(Map<String, dynamic> json) => HabitData(
  habits: (json['habits'] as List<dynamic>).map((e) => e as String).toList(),
  checkins: (json['checkins'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  exportedAt: json['exportedAt'] as String?,
);

Map<String, dynamic> _$HabitDataToJson(HabitData instance) => <String, dynamic>{
  'habits': instance.habits,
  'checkins': instance.checkins,
  'exportedAt': instance.exportedAt,
};
