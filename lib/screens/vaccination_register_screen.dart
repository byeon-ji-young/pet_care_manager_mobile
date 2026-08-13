import 'package:flutter/material.dart';
import 'package:pet_care_manager_mobile/database/database_helper.dart';

import '../models/vaccination.dart';

class VaccinationRegisterScreen extends StatefulWidget {
  final int petId;

  const VaccinationRegisterScreen({
    super.key,
    required this.petId
  });

  @override
  State<VaccinationRegisterScreen> createState() => _VaccinationRegisterScreen();
}

class _VaccinationRegisterScreen extends State<VaccinationRegisterScreen> {
  final TextEditingController vaccineNameController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  DateTime vaccinationDate = DateTime.now();
  DateTime? nextDate;

  @override
  void dispose() {
    vaccineNameController.dispose();
    hospitalController.dispose();
    memoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예방접종 등록'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '예방접종 기록',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: vaccineNameController,
              decoration: const InputDecoration(
                labelText: '접종 종류',
                hintText: 'ex. 종합백신, 광견병',
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: hospitalController,
              decoration: const InputDecoration(
                labelText: '병원명',
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text(
                  '접종 날짜',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  '${vaccinationDate.year}.${vaccinationDate.month.toString().padLeft(2, '0')}.${vaccinationDate.day.toString().padLeft(2, '0')}'
                ),

                const Spacer(),

                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context, 
                      initialDate: vaccinationDate,
                      firstDate: DateTime(2000), 
                      lastDate: DateTime(2100)
                    );

                    if(pickedDate != null) {
                      setState(() {
                        vaccinationDate = pickedDate;
                      });
                    }
                  }, 
                  child: const Text('날짜 선택')
                )
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Text(
                  '다음 접종일',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  nextDate != null
                    ? '${nextDate!.year}.${nextDate!.month.toString().padLeft(2, '0')}.${nextDate!.day.toString().padLeft(2,'0')}'
                    : '미정'
                ),

                const Spacer(), // Row 안에서 남아 있는 가로 공간을 Spacer()가 차지한다

                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: nextDate ?? vaccinationDate, // ?? (null-aware 연산자). nextDate가 있으면 nextDate를 사용하고, 없으면 vaccinationDate를 사용
                      firstDate: vaccinationDate, 
                      lastDate: DateTime(2100)
                    );

                    if(pickedDate != null) {
                      setState(() {
                        nextDate = pickedDate;
                      });
                    }
                  }, 
                  child: const Text('날짜 선택')
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder()
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final vaccination = Vaccination(
                    petId: widget.petId, 
                    vaccineName: vaccineNameController.text.trim(), 
                    vaccinationDate: vaccinationDate,
                    nextDate: nextDate,
                    hospital: hospitalController.text.trim().isEmpty
                      ? null
                      : hospitalController.text.trim(),
                    memo: memoController.text.trim().isEmpty
                      ? null
                      : memoController.text.trim()
                  );

                  await DatabaseHelper.instance.insertVaccination(vaccination);

                  if(!context.mounted) {
                    return;
                  }

                  Navigator.pop(context, true);
                }, 
                child: const Text(
                  '저장',
                  style: TextStyle(
                    fontSize: 16
                  ),
                )
              ),
            )
          ],
        ),
      )
    );
  }
}