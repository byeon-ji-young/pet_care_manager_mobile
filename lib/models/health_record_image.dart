class HealthRecordImage {
  final int? id;
  final int healthRecordId;
  final String imagePath;

  HealthRecordImage({
    this.id,
    required this.healthRecordId,
    required this.imagePath,
  });

  factory HealthRecordImage.fromMap(Map<String, dynamic> map) {
    return HealthRecordImage(
      id: map['id'] as int?,
      healthRecordId: map['health_record_id'] as int,
      imagePath: map['image_path'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'health_record_id': healthRecordId,
      'image_path': imagePath,
    };
  }
}
