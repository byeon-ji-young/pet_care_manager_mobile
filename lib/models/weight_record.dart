class WeightRecord {
  final int? id;
  final int petId;
  final DateTime date;
  final double weight;
  final String? memo;

  WeightRecord({
    this.id,
    required this.petId,
    required this.date,
    required this.weight,
    this.memo
  });

  // DB 데이터 → WeightRecord 객체
  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'] as int?,
      petId: map['pet_id'] as int,
      date: DateTime.parse(
        map['date'] as String,
      ),
      weight: (map['weight'] as num).toDouble(),
      memo: map['memo'] as String?,
    );
  }

  // WeightRecord 객체 → DB 데이터
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'date': date.toIso8601String(),
      'weight': weight,
      'memo': memo,
    };
  }
}
