class MedicationLog {
  final int? id; // 복용 이력 ID
  final int medicationId; // 어떤 약 기록인지
  final int petId; // 어떤 반려동물의 복용 기록인지
  final DateTime medicationDate; // 복용 예정 날짜
  final DateTime? completedAt; // 실제 복용 완료 시간

  MedicationLog({
    this.id,
    required this.medicationId,
    required this.petId,
    required this.medicationDate,
    this.completedAt,
  });

  // DB → MedicationLog 객체
  factory MedicationLog.fromMap(Map<String, dynamic> map) {
    return MedicationLog(
      id: map['id'] as int?,
      medicationId: map['medication_id'] as int,
      petId: map['pet_id'] as int,
      medicationDate: DateTime.parse(map['medication_date'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  // MedicationLog 객체 → DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medication_id': medicationId,
      'pet_id': petId,
      'medication_date': medicationDate.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // 복용 완료 여부
  bool get isCompleted {
    return completedAt != null;
  }
}
