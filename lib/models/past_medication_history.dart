import 'medication.dart';

class PastMedicationHistory {
  final Medication medication;
  final DateTime medicationDate;
  final DateTime? completedAt;

  PastMedicationHistory({
    required this.medication,
    required this.medicationDate,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  bool get isMissed {
    return !isCompleted;
  }
}
