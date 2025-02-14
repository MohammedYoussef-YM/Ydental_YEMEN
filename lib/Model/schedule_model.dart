import 'package:flutter/material.dart';

class Schedule {
  DateTime availableDate;
  TimeOfDay availableTime;

  Schedule({
    required this.availableDate,
    required this.availableTime,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      availableDate: DateTime.parse(json['available_date'] as String? ?? '2025-01-01'),
      availableTime: _parseTime(json['available_time'] as String? ?? '00:00'),
    );
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

List<Schedule> times_and_dates = [
  Schedule(
    availableDate: DateTime.parse('2024-12-29'), availableTime: const TimeOfDay(hour: 11,minute: 11),
  ),
];