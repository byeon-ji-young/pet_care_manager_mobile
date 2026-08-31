class Vaccination {
  final int? id;
  final int petId;
  final String vaccineName;
  final DateTime vaccinationDate;
  final DateTime? nextDate;
  final String? hospital;
  final String? memo;
  final String status;

  Vaccination({
    this.id,
    required this.petId,
    required this.vaccineName,
    required this.vaccinationDate,
    this.nextDate,
    this.hospital,
    this.memo,
    this.status = 'scheduled',
  });

  // DB 데이터 → Vaccination 객체
  factory Vaccination.fromMap(Map<String, dynamic> map) {
    return Vaccination(
      id: map['id'] as int?,
      petId: map['pet_id'] as int,
      vaccineName: map['vaccine_name'] as String,
      vaccinationDate: DateTime.parse(map['vaccination_date'] as String),
      nextDate: map['next_date'] != null
          ? DateTime.parse(map['next_date'] as String)
          : null,
      hospital: map['hospital'] as String?,
      memo: map['memo'] as String?,
      status: map['status'] as String? ?? 'scheduled',
    );
  }

  // Vaccination 객체 → DB 데이터
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'vaccine_name': vaccineName,
      'vaccination_date': vaccinationDate.toIso8601String(),
      'next_date': nextDate?.toIso8601String(),
      'hospital': hospital,
      'memo': memo,
      'status': status,
    };
  }
}
