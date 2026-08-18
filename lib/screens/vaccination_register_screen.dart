import 'package:flutter/material.dart';
import 'package:pet_care_manager_mobile/database/database_helper.dart';

import '../models/vaccination.dart';

class VaccinationRegisterScreen extends StatefulWidget {
  final int petId;

  final Vaccination? vaccination;

  const VaccinationRegisterScreen({
    super.key,
    required this.petId,
    this.vaccination,
  });

  @override
  State<VaccinationRegisterScreen> createState() =>
      _VaccinationRegisterScreen();
}

class _VaccinationRegisterScreen extends State<VaccinationRegisterScreen> {
  final TextEditingController vaccineNameController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  DateTime vaccinationDate = DateTime.now();
  DateTime? nextDate;

  @override
  void initState() {
    super.initState();

    final vaccination = widget.vaccination;

    if (vaccination != null) {
      vaccineNameController.text = vaccination.vaccineName;
      hospitalController.text = vaccination.hospital ?? '';
      memoController.text = vaccination.memo ?? '';

      vaccinationDate = vaccination.vaccinationDate;
      nextDate = vaccination.nextDate;
    }
  }

  @override
  void dispose() {
    vaccineNameController.dispose();
    hospitalController.dispose();
    memoController.dispose();

    super.dispose();
  }

  // 예방접종 기록 삭제
  Future<void> _deleteVaccination() async {
    final vaccination = widget.vaccination;

    // 신규 등록 화면에서는 삭제할 기록이 없으므로 종료
    if (vaccination == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: const Text('예방접종 기록 삭제'),
          content: Text('${vaccination.vaccineName} 기록을 삭제하시겠습니까?'),
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

    await DatabaseHelper.instance.deleteVaccination(vaccination.id!);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vaccination != null;

    return Scaffold(
      appBar: AppBar(
        // title: Text(isEditing ? '예방접종 수정' : '예방접종 등록'),
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
                            isEditing ? '예방접종 기록 수정' : '새 예방접종 기록',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (isEditing)
                          IconButton(
                            onPressed: _deleteVaccination,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            tooltip: '기록 삭제',
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 1. 접종 종류
                    TextField(
                      controller: vaccineNameController,
                      decoration: InputDecoration(
                        labelText: '접종 종류',
                        hintText: 'ex. 종합백신, 광견병',
                        prefixIcon: const Icon(Icons.vaccines_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 2. 병원명
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

                    // 3. 접종 날짜 선택
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
                          initialDate: vaccinationDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            vaccinationDate = pickedDate;
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
                              // color: Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '접종 날짜',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(), // Row 안에서 남아 있는 가로 공간을 Spacer()가 차지
                            Text(
                              '${vaccinationDate.year}.${vaccinationDate.month.toString().padLeft(2, '0')}.${vaccinationDate.day.toString().padLeft(2, '0')}',
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

                    // 4. 다음 접종일 선택
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate:
                              nextDate ??
                              vaccinationDate, // ?? (null-aware 연산자). nextDate가 있으면 nextDate를 사용하고, 없으면 vaccinationDate를 사용
                          firstDate: vaccinationDate,
                          lastDate: DateTime(2100),
                        );

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
                            const Icon(
                              Icons.event_repeat_outlined,
                              // color: Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '다음 접종일',
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

                    // 5. 메모
                    TextField(
                      controller: memoController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: '메모',
                        hintText: '특이사항이나 참고할 사항을 적어주세요.',
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
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (vaccineNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("접종 종류를 입력해주세요.")),
                      );
                      return;
                    }

                    final vaccination = Vaccination(
                      id: widget.vaccination?.id,
                      petId: widget.petId,
                      vaccineName: vaccineNameController.text.trim(),
                      vaccinationDate: vaccinationDate,
                      nextDate: nextDate,
                      hospital: hospitalController.text.trim().isEmpty
                          ? null
                          : hospitalController.text.trim(),
                      memo: memoController.text.trim().isEmpty
                          ? null
                          : memoController.text.trim(),
                    );

                    if (widget.vaccination == null) {
                      await DatabaseHelper.instance.insertVaccination(
                        vaccination,
                      );
                    } else {
                      await DatabaseHelper.instance.updateVaccination(
                        vaccination,
                      );
                    }

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context, vaccinationDate);
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
