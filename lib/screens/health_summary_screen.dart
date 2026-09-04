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
      return '체중 변화 없음';
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
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '${widget.pet.name} 건강 요약',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 병원 기록
            _buildSectionHeader('병원 기록', hospitalRecordCount),

            const SizedBox(height: 5),

            _buildCard(
              child: latestHealthRecord == null
                  ? _buildEmptyState('등록된 병원 기록이 없어요.')
                  : Row(
                      children: [
                        _buildIconBox(
                          Icons.local_hospital_outlined,
                          const Color(0xFFE3F2FD),
                          Colors.blue,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '최근 기록',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate(latestHealthRecord!.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                latestHealthRecord!.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1, // 최대 한 줄까지만 표시
                                overflow: TextOverflow
                                    .ellipsis, // 텍스트가 공간보다 길어서 잘릴 경우 ...을 붙여서 표시
                              ),
                              if (latestHealthRecord!
                                      .hospital
                                      ?.isNotEmpty ?? // latestHealthRecord!: ! null이 아니다. hospital?: ? null일 수 있다
                                  false) ...[
                                const SizedBox(height: 1),
                                Text(
                                  latestHealthRecord!.hospital!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // 2. 예방접종
            _buildSectionHeader('예방접종', vaccinationRecordCount),

            const SizedBox(height: 5),

            _buildCard(
              child: nextVaccination == null
                  ? _buildEmptyState('예정된 예방접종이 없어요.')
                  : Row(
                      children: [
                        _buildIconBox(
                          Icons.vaccines_outlined,
                          const Color(0xFFE8F5E9),
                          Colors.green,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '다음 접종 예정',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate(nextVaccination!.nextDate!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextVaccination!.vaccineName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // 3. 약 복용
            _buildSectionHeader('약 복용', medicationRecordCount),

            const SizedBox(height: 10),

            _buildCard(
              child: Row(
                children: [
                  _buildIconBox(
                    Icons.medication_outlined,
                    const Color(0xFFFFF3E0),
                    Colors.orange,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '등록된 약 $medicationRecordCount개',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (medicationScheduledCount == 0)
                          const Text(
                            '복용 예정 기록이 없어요.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          )
                        else
                          Row(
                            children: [
                              const Text(
                                '최근 30일 이행률',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(medicationCompletionRate * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. 체중 기록
            _buildSectionHeader('체중 기록', weightRecordCount),

            const SizedBox(height: 5),

            _buildCard(
              child: latestWeightRecord == null
                  ? _buildEmptyState('등록된 체중 기록이 없어요.')
                  : Row(
                      children: [
                        _buildIconBox(
                          Icons.monitor_weight_outlined,
                          const Color(0xFFF3E5F5),
                          Colors.purple,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '최근 기록',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[700],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate(latestWeightRecord!.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .baseline, // 텍스트들의 글자 기준선(baseline)을 맞추겠다는 뜻
                                textBaseline: TextBaseline
                                    .alphabetic, //baseline을 사용하려면 어떤 기준선을 사용할지 지정해야 함. alphabetic은 일반적인 알파벳/문자 글꼴의 기준선을 사용한다는 의미
                                children: [
                                  Text(
                                    '${latestWeightRecord!.weight}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Text(
                                    ' kg',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_getWeightChangeText().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getWeightChangeText(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 공통 위젯 헬퍼 함수들
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (title != '약 복용')
          Text(
            '$count건',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        /*
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2), // Offset(x, y)
          ),
        ],
        */
      ),
      child: child,
    );
  }

  Widget _buildIconBox(IconData icon, Color bgColor, Color iconColor) {
    /*
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
    */
    return CircleAvatar(
      radius: 22,
      backgroundColor: bgColor,
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
      ),
    );
  }
}
