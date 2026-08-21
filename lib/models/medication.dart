import 'package:flutter/material.dart';

class Medication {
  final int? id; // DB에서 생성되는 약 기록 ID
  final int petId; // 어떤 반려동물의 약인지
  final String medicationName; // 약 이름
  final DateTime medicationDate; // 복용일
  final TimeOfDay? medicationTime; // 복용시간
  final DateTime? nextDate; // 다음 복용 예정일
  final String repeatType; // 반복 복용 방식
  final int? repeatInterval; // 반복 간격
  final String? memo; // 메모

  Medication({
    this.id,
    required this.petId,
    required this.medicationName,
    required this.medicationDate,
    this.medicationTime,
    this.nextDate,
    required this.repeatType,
    this.repeatInterval,
    this.memo,
  });

  // DB → Medication 객체
  factory Medication.fromMap(Map<String, dynamic> map) {
    TimeOfDay? time;

    if (map['medication_time'] != null) {
      final parts = (map['medication_time'] as String).split(':');

      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Medication(
      id: map['id'] as int?,
      petId: map['pet_id'] as int,
      medicationName: map['medication_name'] as String,
      medicationDate: DateTime.parse(map['medication_date'] as String),
      medicationTime: time,
      nextDate: map['next_date'] != null
          ? DateTime.parse(map['next_date'] as String)
          : null,
      repeatType: map['repeat_type'] as String? ?? 'none',
      repeatInterval: map['repeat_interval'] as int?,
      memo: map['memo'] as String?,
    );
  }

  // Medication 객체 → DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'medication_name': medicationName,
      'medication_date': medicationDate.toIso8601String(),
      'next_date': nextDate?.toIso8601String(),
      'medication_time': medicationTime != null
          ? '${medicationTime!.hour.toString().padLeft(2, '0')}:${medicationTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'repeat_type': repeatType,
      'repeat_interval': repeatInterval,
      'memo': memo,
    };
  }
}
