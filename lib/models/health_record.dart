class HealthRecord {
  final int? id;
  final int petId;
  final DateTime date;
  final String? hospital;
  final String title;
  final String? description;
  final int? cost;

  HealthRecord({
    this.id,
    required this.petId,
    required this.date,
    this.hospital,
    required this.title,
    this.description,
    this.cost,
  });
}