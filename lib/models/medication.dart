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

  // 시간 상태를 반환하는 getter
  String get scheduleStatus {
    // 복용 시간이 없으면 상태를 판단할 수 없음
    if (medicationTime == null) {
      return 'noTime';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      medicationDate.year,
      medicationDate.month,
      medicationDate.day,
    );

    // 아직 복용 시작일이 되지 않은 경우
    if (today.isBefore(startDate)) {
      return 'upcoming';
    }

    // 오늘 실제 복용해야 하는 날인지 확인
    bool isTodayMedicationDay = false;

    // 1. 반복 없음
    if (repeatType == 'none') {
      if (nextDate == null) {
        return 'noTime';
      }

      final targetDate = DateTime(
        nextDate!.year,
        nextDate!.month,
        nextDate!.day,
      );

      isTodayMedicationDay = targetDate == today;
    }
    // 2. 매일
    else if (repeatType == 'daily') {
      isTodayMedicationDay = true;
    }
    // 3. 매주
    else if (repeatType == 'weekly') {
      isTodayMedicationDay = startDate.weekday == today.weekday;
    }
    // 4. N일마다
    else if (repeatType == 'interval' &&
        repeatInterval != null &&
        repeatInterval! > 0) {
      final difference = today.difference(startDate).inDays;

      isTodayMedicationDay = difference % repeatInterval! == 0;
    }

    // 오늘 복용하는 날이 아니면 다음 복용을 기다리는 상태
    if (!isTodayMedicationDay) {
      return 'upcoming';
    }

    // 오늘 복용해야 하는 시간
    final scheduleDateTime = DateTime(
      today.year,
      today.month,
      today.day,
      medicationTime!.hour,
      medicationTime!.minute,
    );

    // 오늘 복용 시간 전/후 판단
    if (scheduleDateTime.isBefore(now)) {
      return 'passed';
    }

    return 'upcoming';
  }
}
