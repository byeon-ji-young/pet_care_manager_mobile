import 'package:flutter/material.dart';

class HealthRecord {
  final int? id;
  final int petId;
  final DateTime date;
  final TimeOfDay? time;
  final String? hospital;
  final String title;
  final String? description;
  final int? cost;
  final String status; // scheduled: 예정, completed: 진료완료, cancelled: 취소

  HealthRecord({
    this.id,
    required this.petId,
    required this.date,
    this.time,
    this.hospital,
    required this.title,
    this.description,
    this.cost,
    this.status = 'scheduled',
  });

  // HealthRecord 객체 → SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'date': date.toIso8601String(),
      'time': time != null
          ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
          : null,
      'hospital': hospital,
      'title': title,
      'description': description,
      'cost': cost,
      'status': status,
    };
  }

  // SQLite Map → HealthRecord 객체
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    TimeOfDay? time;

    if (map['time'] != null) {
      final parts = (map['time'] as String).split(':');

      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return HealthRecord(
      id: map['id'] as int?,
      petId: map['pet_id'] as int,
      date: DateTime.parse(map['date'] as String),
      time: time,
      hospital: map['hospital'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      cost: map['cost'] as int?,
      status: map['status'] as String? ?? 'scheduled',
    );
  }
}
