import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/health_record.dart';

class HealthRecordRegisterScreen extends StatefulWidget {
  final int petId;
  final HealthRecord? record; // record == null → 신규 등록 / record != null → 수정

  const HealthRecordRegisterScreen({
    super.key,
    required this.petId,
    this.record
  });

  @override
  State<HealthRecordRegisterScreen> createState() => __HealthRecordRegisterScreenState();
}

class __HealthRecordRegisterScreenState extends State<HealthRecordRegisterScreen> {
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    if (record != null) {
      hospitalController.text = record.hospital ?? ''; // ??는 null일 경우 다른 값을 사용하라
      titleController.text = record.title;
      descriptionController.text = record.description ?? '';
      costController.text = record.cost?.toString() ?? '';

      selectedDate = record.date;
    }
  }

  @override
  void dispose() {
    hospitalController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    costController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('병원 기록 등록'),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '병원 기록',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: hospitalController,
              decoration: const InputDecoration(
                labelText: '병원명',
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '진료 제목',
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '진료 내용',
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '진료비',
                suffixText: '원',
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Text(
                  '방문 날짜',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                ),

                const Spacer(), // 남는 공간을 자동으로 차지하게 만드는 위젯. 즉, 여기 빈 공간을 최대한 만들어서 다른 위젯들을 밀어내라는 뜻

                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000), 
                      lastDate: DateTime(2100)
                    );

                    if(pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  }, 
                  child: const Text('날짜 선택')
                )
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity, // 가로 너비를 가능한 한 최대로 늘리기
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final record = HealthRecord(
                    id: widget.record?.id,
                    petId: widget.petId,
                    date: selectedDate,
                    hospital: hospitalController.text.trim().isEmpty
                      ? null
                      : hospitalController.text.trim(),
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                    cost: int.tryParse(costController.text.trim()) // tryParse: 비어있으면 null
                  );

                  if(widget.record == null) {
                    await DatabaseHelper.instance.insertHealthRecord(record);
                  }else {    
                    await DatabaseHelper.instance.updateHealthRecord(record);
                  }

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
      ),
    );
  }
}