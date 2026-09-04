import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/pet.dart';
import '../models/weight_record.dart';
import '../models/health_record.dart';
import '../models/vaccination.dart';

import '../utils/date_time_utils.dart';

class HealthSummaryScreen extends StatefulWidget {
  final Pet pet;

  const HealthSummaryScreen({super.key, required this.pet});

  @override
  State<HealthSummaryScreen> createState() => _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends State<HealthSummaryScreen> {
  WeightRecord? latestWeightRecord;
  WeightRecord? previousWeightRecord;

  HealthRecord? latestHealthRecord;

  Vaccination? nextVaccination;

  int medicationScheduledCount = 0;
  int medicationCompletedCount = 0;

  int hospitalRecordCount = 0;
  int vaccinationRecordCount = 0;
  int medicationRecordCount = 0;
  int weightRecordCount = 0;

  @override
  void initState() {
    super.initState();

    _loadLatestWeight();
    _loadLatestHealthRecord();
    _loadNextVaccination();
    _loadMedicationCompletionRate();
    _loadRecordCounts();
  }

  // 체중 조회
  Future<void> _loadLatestWeight() async {
    final records = await DatabaseHelper.instance.getWeightRecordsByPetId(
      widget.pet.id!,
    );

    if (!mounted) return;

    if (records.isEmpty) {
      setState(() {
        latestWeightRecord = null;
      });
      return;
    }

    // 가장 최근 날짜의 체중 기록 찾기
    records.sort((a, b) => b.date.compareTo(a.date));

    setState(
      () {
        latestWeightRecord = records[0];
        previousWeightRecord = records.length > 1 ? records[1] : null;
      },
    ); // records[0] → 가장 최근 체중, records[1] → 그 직전 체중, 기록이 하나면 previousWeightRecord = null
  }

  // 체중 텍스트 변환
  String _getWeightChangeText() {
    if (latestWeightRecord == null || previousWeightRecord == null) {
      return '';
    }

    final change = latestWeightRecord!.weight - previousWeightRecord!.weight;

    if (change == 0) {
      return '이전 체중과 동일';
    } else if (change > 0) {
      return '+ ${change.toStringAsFixed(1)} kg 증가'; // change.toStringAsFixed(1)은 숫자를 소수점 첫째 자리까지 표시하는 문자열로 바꾸는 것
    } else {
      return '- ${change.abs().toStringAsFixed(1)} kg 감소';
    }
  }

  // 건강 기록 조회
  Future<void> _loadLatestHealthRecord() async {
    final records = await DatabaseHelper.instance.getHealthRecordByPetId(
      widget.pet.id!,
    );

    if (!mounted) return;

    if (records.isEmpty) {
      setState(() {
        latestHealthRecord = null;
      });
      return;
    }

    // 가장 최근 날짜의 병원 기록 찾기
    records.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      latestHealthRecord = records.first;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  // 예방접종 조회
  Future<void> _loadNextVaccination() async {
    final vaccinations = await DatabaseHelper.instance.getUpcomingVaccinations(
      widget.pet.id!,
    );

    if (!mounted) return;

    if (vaccinations.isEmpty) {
      setState(() {
        nextVaccination = null;
      });
      return;
    }

    // 가장 가까운 예정 접종 찾기
    vaccinations.sort((a, b) => a.vaccinationDate.compareTo(b.vaccinationDate));

    setState(() {
      nextVaccination = vaccinations.first;
    });
  }

  // 약 복용 비율 계산
  double get medicationCompletionRate {
    if (medicationScheduledCount == 0) {
      return 0;
    }

    return medicationCompletedCount / medicationScheduledCount;
  }

  // 약 복용 조회
  Future<void> _loadMedicationCompletionRate() async {
    final medications = await DatabaseHelper.instance.getMedicationsByPetId(
      widget.pet.id!,
    );

    final today = DateTimeUtils.todayKst();

    // 최근 30일: 오늘 포함
    final startDate = today.subtract(const Duration(days: 29));

    int scheduledCount = 0;
    int completedCount = 0;

    for (final medication in medications) {
      if (medication.id == null) {
        continue;
      }

      // 이 약의 복용 완료 로그 조회
      final logs = await DatabaseHelper.instance.getMedicationLog(
        medication.id!,
      );

      DateTime currentDate = startDate;

      while (!currentDate.isAfter(today)) {
        bool isScheduled = false;

        final medicationStartDate = DateTime(
          medication.medicationDate.year,
          medication.medicationDate.month,
          medication.medicationDate.day,
        );

        // 시작일 이전에는 복용 예정이 아님
        if (!currentDate.isBefore(medicationStartDate)) {
          // 반복 없음
          if (medication.repeatType == 'none') {
            if (medication.nextDate != null) {
              final scheduledDate = DateTime(
                medication.nextDate!.year,
                medication.nextDate!.month,
                medication.nextDate!.day,
              );

              isScheduled = currentDate == scheduledDate;
            }
          }
          // 매일
          else if (medication.repeatType == 'daily') {
            isScheduled = true;
          }
          // 매주
          else if (medication.repeatType == 'weekly') {
            isScheduled = currentDate.weekday == medicationStartDate.weekday;
          }
          // N일마다
          else if (medication.repeatType == 'interval' &&
              medication.repeatInterval != null &&
              medication.repeatInterval! > 0) {
            final difference = currentDate
                .difference(medicationStartDate)
                .inDays;

            isScheduled = difference % medication.repeatInterval! == 0;
          }
        }

        if (isScheduled) {
          scheduledCount++;

          for (final log in logs) {
            final logDate = DateTime(
              log.medicationDate.year,
              log.medicationDate.month,
              log.medicationDate.day,
            );

            if (logDate == currentDate) {
              completedCount++;
              break;
            }
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    if (!mounted) return;

    setState(() {
      medicationScheduledCount = scheduledCount;
      medicationCompletedCount = completedCount;
    });
  }

  // 기록 건수 조회
  Future<void> _loadRecordCounts() async {
    final healthRecords = await DatabaseHelper.instance.getHealthRecordByPetId(
      widget.pet.id!,
    );

    final vaccinations = await DatabaseHelper.instance.getVaccinationsByPetId(
      widget.pet.id!,
    );

    final medications = await DatabaseHelper.instance.getMedicationsByPetId(
      widget.pet.id!,
    );

    final weightRecords = await DatabaseHelper.instance.getWeightRecordsByPetId(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() {
      hospitalRecordCount = healthRecords.length;
      vaccinationRecordCount = vaccinations.length;
      medicationRecordCount = medications.length;
      weightRecordCount = weightRecords.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.pet.name} 건강 요약',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 체중
            Row(
              children: [
                const Text(
                  '체중 기록',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const Spacer(),

                Text(
                  '$weightRecordCount건',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: latestWeightRecord == null
                    ? const Text(
                        '등록된 체중 기록이 없어요.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      )
                    : Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3E5F5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.monitor_weight_outlined,
                              color: Colors.purple,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '최근 기록',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${latestWeightRecord!.weight} kg',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _formatDate(latestWeightRecord!.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _getWeightChangeText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // 병원 기록
            Row(
              children: [
                const Text(
                  '병원 기록',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const Spacer(),

                Text(
                  '$hospitalRecordCount건',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: latestHealthRecord == null
                    ? const Text(
                        '등록된 병원 기록이 없어요.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F2FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_hospital_outlined,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '최근 기록',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  latestHealthRecord!.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  _formatDate(latestHealthRecord!.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),

                                if (latestHealthRecord!.hospital != null &&
                                    latestHealthRecord!
                                        .hospital!
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 4),

                                  Text(
                                    latestHealthRecord!.hospital!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // 예방접종
            Row(
              children: [
                const Text(
                  '예방접종',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const Spacer(),

                Text(
                  '$vaccinationRecordCount건',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: nextVaccination == null
                    ? const Text(
                        '예정된 예방접종이 없어요.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.vaccines_outlined,
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '다음 접종',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  nextVaccination!.vaccineName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  // nextVaccination!.nextDate != null
                                  //     ? _formatDate(nextVaccination!.nextDate!)
                                  //     : '다음 접종일 미정',
                                  _formatDate(nextVaccination!.nextDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // 약 복용
            const Text(
              '약 복용',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF3E0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medication_outlined,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '등록된 약 $medicationRecordCount개',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (medicationScheduledCount == 0)
                          const Text(
                            '복용 예정 기록이 없어요.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          )
                        else ...[
                          Row(
                            children: [
                              Text(
                                '최근 30일 복용 이행률',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),

                              const SizedBox(width: 10),

                              Text(
                                '${(medicationCompletionRate * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
