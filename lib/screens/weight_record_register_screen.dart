import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/weight_record.dart';

class WeightRecordRegisterScreen extends StatefulWidget {
  final int petId;
  final WeightRecord? record;

  const WeightRecordRegisterScreen({
    super.key,
    required this.petId,
    this.record
  });

  @override
  State<WeightRecordRegisterScreen> createState() => _WeightRecordRegisterScreen();
}

class _WeightRecordRegisterScreen extends State<WeightRecordRegisterScreen> {
  final weightController = TextEditingController();
  final memoController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    if(record != null) {
      weightController.text = record.weight.toString();
      memoController.text = record.memo ?? '';

      selectedDate = record.date;
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    memoController.dispose();

    super.dispose();
  }

  Future<void> saveWeightRecord() async {
    final weightText = weightController.text.trim();

    if(weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('몸무게를 입력해주세요.')
        )
      );

      return;
    }

    final weight = double.tryParse(weightText);

    if(weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 몸무게를 입력해주세요.')
        )
      );
      return;
    }

    final record = WeightRecord(
      id: widget.record?.id,
      petId: widget.petId,
      date: selectedDate,
      weight: weight,
      memo: memoController.text.trim().isEmpty
          ? null
          : memoController.text.trim(),
    );

    if(widget.record == null) {
      await DatabaseHelper.instance.insertWeightRecord(record);
    }else {
      await DatabaseHelper.instance.updateWeightRecord(record);
    }

    if(!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? '체중 기록 수정' : '체중 기록 등록'
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '측정 날짜',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 8),

            /*
            InkWell: 터치했을 때 물결처럼 퍼지는 클릭 효과를 만들어주는 위젯

            onTap → 한 번 탭
            onDoubleTap → 두 번 탭
            onLongPress → 길게 누르기
            onTapDown → 누르는 순간
            onTapUp → 손가락을 뗀 순간
            */
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000), 
                  lastDate: DateTime.now()
                );

                if(pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today) // suffixIcon: TextField, TextFormField 안에서 오른쪽 끝에 아이콘을 넣는 속성
                ),
                
                child: Text(
                  '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}'
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '몸무게',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ex. 3.5',
                suffixText: 'kg'
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '메모',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: memoController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '메모를 입력해주세요.'
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveWeightRecord, 
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