class MedicationHistoryItem {
  final DateTime medicationDate;
  final DateTime? completedAt;

  MedicationHistoryItem({required this.medicationDate, this.completedAt});

  bool get isCompleted => completedAt != null;
}
