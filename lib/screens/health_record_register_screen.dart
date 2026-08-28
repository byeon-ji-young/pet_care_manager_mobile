import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/health_record.dart';

import '../utils/date_time_utils.dart';

class HealthRecordRegisterScreen extends StatefulWidget {
  final int petId;
  final HealthRecord? record; // record == null → 신규 등록 / record != null → 수정

  const HealthRecordRegisterScreen({
    super.key,
    required this.petId,
    this.record,
  });

  @override
  State<HealthRecordRegisterScreen> createState() =>
      _HealthRecordRegisterScreenState();
}

class _HealthRecordRegisterScreenState
    extends State<HealthRecordRegisterScreen> {
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  DateTime selectedDate = DateTimeUtils.todayKst();
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    if (record != null) {
      hospitalController.text =
          record.hospital ?? ''; // ??는 null일 경우 다른 값을 사용하라
      titleController.text = record.title;
      descriptionController.text = record.description ?? '';
      costController.text = record.cost?.toString() ?? '';

      selectedDate = record.date;
      selectedTime = record.time;
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

  // 병원 기록 삭제
  Future<void> _deleteRecord() async {
    final record = widget.record;

    // 신규 등록 화면은 삭제할 기록이 없으므로 종료
    if (record == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: const Text('병원 기록 삭제'),
          content: Text('${record.title} 기록을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              // style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
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

    await DatabaseHelper.instance.deleteHealthRecord(record.id!);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;

    return Scaffold(
      appBar: AppBar(
        // title: Text(isEditing ? '병원 기록 수정' : '병원 기록 등록'),
        title: null,
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isEditing ? '병원 진료 내역 수정' : '새 병원 기록',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (isEditing) ...[
                          const Spacer(),

                          IconButton(
                            onPressed: _deleteRecord,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            tooltip: '기록 삭제',
                          ),
                        ],
                      ],
                    ),

                    Text(
                      '진료받은 내용을 꼼꼼하게 기록해 주세요.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 24),

                    // 1. 병원명 입력창
                    TextField(
                      controller: hospitalController,
                      decoration: InputDecoration(
                        labelText: '병원명',
                        hintText: '예: 펫몽 동물병원',
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 2. 진료 제목 입력창
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: '* 진료 제목',
                        hintText: '예: 예방접종 / 정기검진',
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 3. 진료 내용 입력창
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: '진료 내용',
                        hintText: '진료 소견이나 처방받은 약 정보를 적어주세요.',
                        alignLabelWithHint:
                            true, // TextField의 labelText와 hintText의 세로 정렬을 맞춰주는 옵션
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.notes),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 4. 방문 날짜 선택
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
                            const Icon(
                              Icons.calendar_month_outlined,
                              // color: Colors.grey
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '* 방문 날짜',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
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

                    // 5. 방문 시간 선택
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          setState(() {
                            selectedTime = pickedTime;
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
                            const Icon(Icons.access_time_outlined),
                            const SizedBox(width: 16),
                            const Text(
                              '방문 시간',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              selectedTime == null
                                  ? '시간 선택'
                                  : selectedTime!.format(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: selectedTime == null
                                    ? Colors.grey
                                    : null,
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

                    // 6. 진료비 입력창
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '진료비',
                        hintText: '0',
                        suffixText: '원',
                        prefixIcon: const Icon(Icons.payments_outlined),
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
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity, // 가로 너비를 가능한 한 최대로 늘리기
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("진료 제목을 입력해주세요.")),
                      );
                      return;
                    }

                    final record = HealthRecord(
                      id: widget.record?.id,
                      petId: widget.petId,
                      date: selectedDate,
                      time: selectedTime,
                      hospital: hospitalController.text.trim().isEmpty
                          ? null
                          : hospitalController.text.trim(),
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      cost: int.tryParse(
                        costController.text.trim(),
                      ), // tryParse: 비어있으면 null
                      status:
                          widget.record?.status ??
                          'completed', // 신규 등록: completed, 수정: 기존 status
                    );

                    try {
                      if (widget.record == null) {
                        await DatabaseHelper.instance.insertHealthRecord(
                          record,
                        );
                      } else {
                        await DatabaseHelper.instance.updateHealthRecord(
                          record,
                        );
                      }
                    } catch (e) {
                      debugPrint('병원 기록 저장 실패: $e');

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('병원 기록을 저장하지 못했어요.')),
                      );

                      return;
                    }

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context, selectedDate);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? '수정하기' : '저장하기',
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
