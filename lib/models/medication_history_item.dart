import 'package:flutter/material.dart';

import '../utils/date_time_utils.dart';

class MedicationHistoryItem {
  final DateTime medicationDate;
  final TimeOfDay? medicationTime;
  final DateTime? completedAt;

  MedicationHistoryItem({
    required this.medicationDate,
    this.medicationTime,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  bool get isMissed {
    if (isCompleted) {
      return false;
    }

    final now = DateTimeUtils.nowKst();

    final date = DateTime(
      medicationDate.year,
      medicationDate.month,
      medicationDate.day,
    );

    final today = DateTime(now.year, now.month, now.day);

    // 과거 날짜인데 복용하지 않은 경우
    if (date.isBefore(today)) {
      return true;
    }

    // 오늘이 아니면 누락 아님
    if (date.isAfter(today)) {
      return false;
    }

    // 오늘인데 복용 시간이 없는 경우
    if (medicationTime == null) {
      return false;
    }

    // 오늘이고 복용 시간이 지난 경우
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      medicationTime!.hour,
      medicationTime!.minute,
    );

    return now.isAfter(scheduledTime);
  }
}
