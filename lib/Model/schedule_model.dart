import 'package:flutter/material.dart';

class Schedule {
  final int id; // New field to hold the schedule ID
  final bool? isBooking; // New field to hold the schedule ID
  DateTime availableDate;
  TimeOfDay availableTime;

  Schedule({
    required this.id,
    this.isBooking = false,
    required this.availableDate,
    required this.availableTime,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int, // Extracting the schedule id
      isBooking: json['is_booking'] as bool ?? false, // Extracting the schedule id
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
    availableDate: DateTime.parse('2024-12-29'),
    availableTime: const TimeOfDay(hour: 11,minute: 11),
    id: 1,
    isBooking:false
  ),
];