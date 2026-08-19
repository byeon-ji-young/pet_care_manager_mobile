import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/medication.dart';

import '../screens/medication_register_screen.dart';

class MedicationListScreen extends StatefulWidget {
  final int petId;

  const MedicationListScreen({super.key, required this.petId});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  List<Medication> medications = [];

  @override
  void initState() {
    super.initState();

    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final data = await DatabaseHelper.instance.getMedicationsByPetId(
      widget.petId,
    );

    if (!mounted) return;

    // 아직 이 화면이 살아있을 때만 setState
    setState(() {
      medications = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약 복용 기록'), centerTitle: true),
      body: medications.isEmpty
          ? const Center(
              child: Text(
                '등록된 양 복용 기록이 없습니다.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicationRegisterScreen(
                            petId: widget.petId,
                            medication: medication,
                          ),
                        ),
                      );

                      await _loadMedications();
                    },
                    leading: const Icon(Icons.medication_outlined),
                    title: Text(
                      medication.medicationName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '복용일: '
                          '${medication.medicationDate.year}.'
                          '${medication.medicationDate.month.toString().padLeft(2, '0')}.'
                          '${medication.medicationDate.day.toString().padLeft(2, '0')}',
                        ),

                        if (medication.nextDate != null)
                          Text(
                            '다음 복용일: '
                            '${medication.nextDate!.year}.'
                            '${medication.nextDate!.month.toString().padLeft(2, '0')}.'
                            '${medication.nextDate!.day.toString().padLeft(2, '0')}',
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
