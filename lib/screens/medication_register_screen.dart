import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/medication.dart';

import '../services/notification_service.dart';

class MedicationRegisterScreen extends StatefulWidget {
  final int petId;

  final Medication? medication;

  const MedicationRegisterScreen({
    super.key,
    required this.petId,
    this.medication,
  });

  @override
  State<MedicationRegisterScreen> createState() => _MedicationRegisterScreen();
}

class _MedicationRegisterScreen extends State<MedicationRegisterScreen> {
  final TextEditingController medicationNameController =
      TextEditingController();

  final TextEditingController memoController = TextEditingController();

  DateTime medicationDate = DateTime.now();
  TimeOfDay? medicationTime;

  DateTime? nextDate;

  String repeatType = 'none';
  int? repeatInterval;

  @override
  void initState() {
    super.initState();

    final medication = widget.medication;

    if (medication != null) {
      medicationNameController.text = medication.medicationName;
      memoController.text = medication.memo ?? '';
      medicationDate = medication.medicationDate;
      medicationTime = medication.medicationTime;
      nextDate = medication.nextDate;
      repeatType = medication.repeatType;
      repeatInterval = medication.repeatInterval;
    }
  }

  @override
  void dispose() {
    medicationNameController.dispose();
    memoController.dispose();

    super.dispose();
  }

  // 약 복용 기록 삭제
  Future<void> _deleteMedication() async {
    final medication = widget.medication;

    // 신규 등록
    if (medication == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('${medication.medicationName} 기록을 삭제하시겠습니까?'),
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

    // 기존 알림 취소
    await NotificationService.instance.cancelNotification(medication.id!);

    // DB 기록 삭제
    await DatabaseHelper.instance.deleteMedication(medication.id!);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medication != null;

    return Scaffold(
      appBar: AppBar(title: null, centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + 삭제 버튼
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEditing ? '약 복용 기록 수정' : '새 약 복용 기록',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (isEditing)
                          IconButton(
                            onPressed: _deleteMedication,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            tooltip: '기록 삭제',
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 1. 약 이름
                    TextField(
                      controller: medicationNameController,
                      decoration: InputDecoration(
                        labelText: '* 약 이름',
                        hintText: '예. 심장사상충 약, 구충제',
                        prefixIcon: const Icon(Icons.medication_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 2. 복용 날짜
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: medicationDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (!mounted) {
                          return;
                        }

                        if (pickedDate != null) {
                          setState(() {
                            medicationDate = pickedDate;
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
                            Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 16),
                            const Text(
                              '* 복용 날짜',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${medicationDate.year}.${medicationDate.month.toString().padLeft(2, '0')}.${medicationDate.day.toString().padLeft(2, '0')}',
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

                    // 3.복용 시간
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: medicationTime ?? TimeOfDay.now(),
                        );

                        if (!mounted) {
                          return;
                        }

                        if (pickedTime != null) {
                          setState(() {
                            medicationTime = pickedTime;
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
                              '복용 시간',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (medicationTime != null) ...[
                              Text(
                                medicationTime!.format(context),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    medicationTime = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 3),
                            ] else ...[
                              const Text(
                                '시간 선택 (선택사항)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 4. 다음 복용 예정일
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: nextDate ?? medicationDate,
                          firstDate: medicationDate,
                          lastDate: DateTime(2100),
                        );

                        if (!mounted) {
                          return;
                        }

                        if (pickedDate != null) {
                          setState(() {
                            nextDate = pickedDate;
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
                            const Icon(Icons.event_repeat_outlined),
                            const SizedBox(width: 16),
                            const Text(
                              '다음 복용일',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (nextDate != null) ...[
                              Text(
                                '${nextDate!.year}.${nextDate!.month.toString().padLeft(2, '0')}.${nextDate!.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                // GestureDetector는 화면에서 사용자의 터치 동작을 감지하는 위젯
                                onTap: () {
                                  setState(() {
                                    nextDate = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 3),
                            ] else ...[
                              const Text(
                                '날짜 선택 (선택사항)',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 5. 반복복용
                    InkWell(
                      onTap: () async {
                        final selectedType = await showModalBottomSheet<String>(
                          context: context,
                          builder: (sheetContext) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      '반복 복용',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  ListTile(
                                    title: const Text('안 함'),
                                    trailing: repeatType == 'none'
                                        ? const Icon(Icons.check)
                                        : null,
                                    onTap: () {
                                      Navigator.pop(sheetContext, 'none');
                                    },
                                  ),

                                  ListTile(
                                    title: const Text('매일'),
                                    trailing: repeatType == 'daily'
                                        ? const Icon(Icons.check)
                                        : null,
                                    onTap: () {
                                      Navigator.pop(sheetContext, 'daily');
                                    },
                                  ),

                                  ListTile(
                                    title: const Text('매주'),
                                    trailing: repeatType == 'weekly'
                                        ? const Icon(Icons.check)
                                        : null,
                                    onTap: () {
                                      Navigator.pop(sheetContext, 'weekly');
                                    },
                                  ),

                                  ListTile(
                                    title: const Text('며칠마다'),
                                    trailing: repeatType == 'interval'
                                        ? const Icon(Icons.check)
                                        : null,
                                    onTap: () {
                                      Navigator.pop(sheetContext, 'interval');
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        // 바텀시트가 닫힌 후 State가 아직 살아있는지 확인
                        if (!mounted) {
                          return;
                        }

                        if (selectedType == null) {
                          return;
                        }

                        if (selectedType == 'interval') {
                          final interval = await showDialog<int>(
                            context: this.context,
                            builder: (dialogContext) {
                              final controller = TextEditingController(
                                text: repeatInterval?.toString() ?? '',
                              );

                              return AlertDialog(
                                title: const Text('반복 간격'),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    suffixText: '일마다',
                                    hintText: '예. 3',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final value = int.tryParse(
                                        controller.text,
                                      );

                                      if (value == null || value <= 0) {
                                        return;
                                      }

                                      Navigator.pop(dialogContext, value);
                                    },
                                    child: const Text('확인'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (!mounted) {
                            return;
                          }

                          if (interval == null) {
                            return;
                          }

                          setState(() {
                            repeatType = 'interval';
                            repeatInterval = interval;
                          });
                        } else {
                          setState(() {
                            repeatType = selectedType;
                            repeatInterval = null;
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
                            const Icon(Icons.repeat),
                            const SizedBox(width: 16),
                            const Text(
                              '반복 복용',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              switch (repeatType) {
                                'daily' => '매일',
                                'weekly' => '매주',
                                'interval' => '${repeatInterval ?? 0}일마다',
                                _ => '안 함', // _는 나머지는 전부
                              },
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

                    // 6. 메모
                    TextField(
                      controller: memoController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: '',
                        hintText: '',
                        alignLabelWithHint: true,
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
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (medicationNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('약 이름을 입력해주세요.')),
                      );

                      return;
                    }

                    final medication = Medication(
                      id: widget.medication?.id,
                      petId: widget.petId,
                      medicationName: medicationNameController.text.trim(),
                      medicationDate: medicationDate,
                      medicationTime: medicationTime,
                      repeatType: repeatType,
                      repeatInterval: repeatInterval,
                      nextDate: nextDate,
                      memo: memoController.text.trim().isEmpty
                          ? null
                          : memoController.text.trim(),
                    );

                    int? medicationId;

                    if (widget.medication == null) {
                      medicationId = await DatabaseHelper.instance
                          .insertMedication(medication);
                    } else {
                      // 기존 알림 취소
                      await NotificationService.instance.cancelNotification(
                        medication.id!,
                      );

                      await DatabaseHelper.instance.updateMedication(
                        medication,
                      );

                      medicationId = medication.id;
                    }

                    // 다음 복용일과 복용 시간이 모두 있는 경우 알림 예약
                    if (medication.nextDate != null &&
                        medication.medicationTime != null) {
                      final scheduledDate = DateTime(
                        medication.nextDate!.year,
                        medication.nextDate!.month,
                        medication.nextDate!.day,
                        medication.medicationTime!.hour,
                        medication.medicationTime!.minute,
                      );

                      try {
                        await NotificationService.instance.scheduleNotification(
                          id: medicationId!,
                          title: '${medication.medicationName} 복용 시간이에요 💊',
                          body: '반려동물의 약을 챙겨주세요.',
                          scheduledDate: scheduledDate,
                        );
                      } catch (e) {
                        debugPrint('약 복용 알림 예약 실패: $e');
                      }
                    }

                    if (!mounted) {
                      return;
                    }

                    // Navigator.pop(this.context, medicationDate);
                    Navigator.of(this.context).pop(medicationDate);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? '수정하기' : '저장하기',
                        style: const TextStyle(
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
