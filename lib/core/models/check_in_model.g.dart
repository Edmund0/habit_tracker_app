// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayCheckIn _$DayCheckInFromJson(Map<String, dynamic> json) => DayCheckIn(
  date: json['date'] as String,
  activityType: json['activityType'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$DayCheckInToJson(DayCheckIn instance) =>
    <String, dynamic>{
      'date': instance.date,
      'activityType': instance.activityType,
      'timestamp': instance.timestamp.toIso8601String(),
    };

CheckInData _$CheckInDataFromJson(Map<String, dynamic> json) => CheckInData(
  checkIns: (json['checkIns'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, DayCheckIn.fromJson(e as Map<String, dynamic>)),
  ),
  activityTypes: (json['activityTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  exportedAt: json['exportedAt'] as String?,
);

Map<String, dynamic> _$CheckInDataToJson(CheckInData instance) =>
    <String, dynamic>{
      'checkIns': instance.checkIns,
      'activityTypes': instance.activityTypes,
      'exportedAt': instance.exportedAt,
    };
