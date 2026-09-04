import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/weight_record.dart';

import '../utils/date_time_utils.dart';

class WeightRecordRegisterScreen extends StatefulWidget {
  final int petId;
  final WeightRecord? record;

  const WeightRecordRegisterScreen({
    super.key,
    required this.petId,
    this.record,
  });

  @override
  State<WeightRecordRegisterScreen> createState() =>
      _WeightRecordRegisterScreen();
}

class _WeightRecordRegisterScreen extends State<WeightRecordRegisterScreen> {
  final weightController = TextEditingController();
  final memoController = TextEditingController();

  DateTime selectedDate = DateTimeUtils.todayKst();

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    if (record != null) {
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

  // 저장
  Future<void> saveWeightRecord() async {
    final weightText = weightController.text.trim();

    if (weightText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('몸무게를 입력해주세요.')));
      return;
    }

    final weight = double.tryParse(weightText);

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('올바른 몸무게를 입력해주세요.')));
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

    if (widget.record == null) {
      await DatabaseHelper.instance.insertWeightRecord(record);
    } else {
      await DatabaseHelper.instance.updateWeightRecord(record);
    }

    await DatabaseHelper.instance.syncPetCurrentWeight(widget.petId);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, selectedDate);
  }

  // 체중 기록 삭제
  Future<void> _deleteWeightRecord() async {
    final record = widget.record;

    // 신규 등록 화면은 삭제할 기록이 없으므로 종료
    if (record == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: const Text('체중 기록 삭제'),
          content: Text('${record.weight} kg 기록을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await DatabaseHelper.instance.deleteWeightRecord(record.id!);

    await DatabaseHelper.instance.syncPetCurrentWeight(widget.petId);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;

    return Scaffold(
      appBar: AppBar(
        // title: Text(isEdit ? '체중 기록 수정' : '체중 기록 등록'),
        title: null,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit ? '체중 기록 수정' : '새 체중 기록',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (isEdit)
                          IconButton(
                            onPressed: _deleteWeightRecord,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            tooltip: '기록 삭제',
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 1. 측정 날짜 선택
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
                          lastDate: DateTimeUtils.todayKst(),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 16),
                            const Text(
                              '* 측정 날짜',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(), // Row 안에서 남아 있는 가로 공간을 Spacer()가 차지
                            Text(
                              '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 2. 몸무게 입력창
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: '* 몸무게',
                        hintText: '예: 3.5',
                        suffixText: 'kg',
                        prefixIcon: const Icon(Icons.monitor_weight_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 3. 메모 입력창
                    TextField(
                      controller: memoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: '메모',
                        hintText: '예: 특이사항이나 참고할 사항을 적어주세요.',
                        alignLabelWithHint:
                            true, // TextField의 labelText와 hintText의 세로 정렬을 맞춰주는 옵션
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 30),
                          child: Icon(Icons.notes),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 저장 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saveWeightRecord,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? '수정하기' : '저장하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
