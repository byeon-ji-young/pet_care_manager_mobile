import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../models/pet.dart';
import '../models/weight_record.dart';
import '../models/health_record.dart';
import '../models/vaccination.dart';

import '../utils/date_time_utils.dart';

import '../widgets/weight_chart.dart';

import 'hospital_statistics_screen.dart';

class HealthSummaryScreen extends StatefulWidget {
  final Pet pet;

  const HealthSummaryScreen({super.key, required this.pet});

  @override
  State<HealthSummaryScreen> createState() => _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends State<HealthSummaryScreen> {
  WeightRecord? latestWeightRecord;
  WeightRecord? previousWeightRecord;
  List<WeightRecord> weightRecords = [];

  HealthRecord? latestHealthRecord;

  Vaccination? nextVaccination;
  List<Vaccination> upcomingVaccinations = [];

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

    setState(() {
      // records[0] → 가장 최근 체중, records[1] → 그 직전 체중, 기록이 하나면 previousWeightRecord = null
      latestWeightRecord = records[0];
      previousWeightRecord = records.length > 1 ? records[1] : null;
      weightRecords = records;
    });
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

  // 체중 변화 그래프 보기
  void _showWeightChart() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 내부 컨텐츠 크기만큼 유연하게 조절
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 위쪽 손잡이 (Handle Bar)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. 상단 헤더 영역 (제목 & 서브텍스트)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Icon(
                        //   Icons.show_chart,
                        //   size: 18,
                        //   color: Theme.of(context).primaryColor,
                        // ),
                        const SizedBox(width: 6),
                        const Text(
                          '체중 변화 그래프', // 📈
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '총 ${weightRecords.length}개 기록',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // 3. 차트를 감싸는 깔끔한 메인 카드
                Card(
                  elevation: 0,
                  // color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 차트 위젯 배치
                      WeightChart(records: weightRecords),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 날짜별 복용 현황 데이터 조회
  Future<List<Map<String, dynamic>>> _getMedicationMissedRecords() async {
    final medications = await DatabaseHelper.instance.getMedicationsByPetId(
      widget.pet.id!,
    );

    final today = DateTimeUtils.todayKst();
    final startDate = today.subtract(
      const Duration(days: 29), // Duration(days: 29): 29일이라는 기간 생성
    ); // subtract는 날짜에서 기간을 빼는 함수

    final result = <Map<String, dynamic>>[];

    for (final medication in medications) {
      if (medication.id == null) {
        continue;
      }

      final logs = await DatabaseHelper.instance.getMedicationLog(
        medication.id!,
      );

      final missedDates = <DateTime>[];

      final medicationStartDate = DateTime(
        medication.medicationDate.year,
        medication.medicationDate.month,
        medication.medicationDate.day,
      );

      DateTime currentDate = startDate;

      // currentDate가 today보다 뒤 날짜가 아닌지 판단. 즉, currentDate가 today보다 같거나 이전이면 반복
      while (!currentDate.isAfter(today)) {
        bool isScheduled = false;

        if (!currentDate.isBefore(medicationStartDate)) {
          if (medication.repeatType == 'none') {
            final scheduledDate = DateTime(
              (medication.nextDate ?? medication.medicationDate).year,
              (medication.nextDate ?? medication.medicationDate).month,
              (medication.nextDate ?? medication.medicationDate).day,
            );

            isScheduled = currentDate == scheduledDate;
          } else if (medication.repeatType == 'daily') {
            isScheduled = true;
          } else if (medication.repeatType == 'weekly') {
            isScheduled = currentDate.weekday == medicationStartDate.weekday;
          } else if (medication.repeatType == 'interval' &&
              medication.repeatInterval != null &&
              medication.repeatInterval! > 0) {
            final difference = currentDate
                .difference(medicationStartDate)
                .inDays;

            isScheduled = difference % medication.repeatInterval! == 0;
          }
        }

        if (isScheduled) {
          bool isCompleted = false;

          for (final log in logs) {
            final logDate = DateTime(
              log.medicationDate.year,
              log.medicationDate.month,
              log.medicationDate.day,
            );

            if (logDate == currentDate && log.completedAt != null) {
              isCompleted = true;
              break;
            }
          }

          // 이미 복용 완료한 경우
          if (!isCompleted) {
            bool isMissed = true;

            // 오늘 복용하는 약이라면 시간까지 확인
            if (currentDate == today) {
              // 복용 시간이 없으면 아직 누락으로 판단하지 않음
              if (medication.medicationTime == null) {
                isMissed = false;
              } else {
                final now = DateTimeUtils.nowKst();

                final medicationDateTime = DateTime(
                  today.year,
                  today.month,
                  today.day,
                  medication.medicationTime!.hour,
                  medication.medicationTime!.minute,
                );

                // 아직 복용 시간이 지나지 않았으면 누락 아님
                if (now.isBefore(medicationDateTime)) {
                  isMissed = false;
                }
              }
            }

            if (isMissed) {
              missedDates.add(currentDate);
            }
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }

      if (missedDates.isNotEmpty) {
        result.add({
          'medicationName': medication.medicationName,
          'dates': missedDates.reversed.toList(),
        });
      }
    }

    return result;
  }

  // 예정된 예방접종 보기
  void _showUpcomingVaccinations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 핸들
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    '접종 예정 내역',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: upcomingVaccinations.length,
                      itemBuilder: (context, index) {
                        final vaccination = upcomingVaccinations[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.vaccines_outlined,
                              color: Colors.green,
                            ),
                          ),
                          title: Text(
                            vaccination.vaccineName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _formatDate(vaccination.nextDate!),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 약 복용 상세 보기
  void _showMedicationCompletionDetail() {
    final missedCount = medicationScheduledCount - medicationCompletedCount;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 제목
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '복용 현황',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '최근 30일',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 이행률
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            '복용 이행률',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          // const SizedBox(height: 4),
                          Text(
                            '${(medicationCompletionRate * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // const SizedBox(height: 8),

                // 복용 통계
                Row(
                  children: [
                    Expanded(
                      child: _buildMedicationStatItem(
                        title: '복용 완료',
                        value: '$medicationCompletedCount회',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMedicationStatItem(
                        title: '전체 복용',
                        value: '$medicationScheduledCount회',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMedicationStatItem(
                        title: '복용 누락',
                        value: '$missedCount회',
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  '복용 누락 기록',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                FutureBuilder<List<Map<String, dynamic>>>(
                  // FutureBuilder는 비동기로 데이터를 가져오는 동안 화면을 알아서 상태별로 그려주는 위젯
                  future: _getMedicationMissedRecords(), // 실제로 데이터를 가져오는 함수 실행
                  builder: (context, snapshot) {
                    // builder: (context, snapshot): 데이터 상태가 바뀔 때마다 이 부분에서 무엇을 화면에 보여줄지 결정. snapshot에는 현재 데이터 상태가 들어 있음

                    // 로딩 중인 경우
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    // 에러 또는 데이터가 없는 경우
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '복용 누락 기록을 불러오지 못했어요.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      );
                    }

                    final missedRecords = snapshot.data!;

                    if (missedRecords.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        // decoration: BoxDecoration(
                        //   color: Colors.green.withValues(alpha: 0.06),
                        //   borderRadius: BorderRadius.circular(10),
                        // ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '최근 30일 동안 복용 누락이 없어요.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: missedRecords.map((record) {
                        final medicationName =
                            record['medicationName'] as String;

                        final dates = record['dates'] as List<DateTime>;

                        final dateText = dates
                            .map((date) {
                              return '${date.month.toString().padLeft(2, '0')}.'
                                  '${date.day.toString().padLeft(2, '0')}';
                            })
                            .join(' · ');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  medicationName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                dateText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicationStatItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
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
        upcomingVaccinations = [];
      });
      return;
    }

    // 가장 가까운 예정 접종 찾기
    vaccinations.sort((a, b) => a.nextDate!.compareTo(b.nextDate!));

    setState(() {
      nextVaccination = vaccinations.first;
      upcomingVaccinations = vaccinations;
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
            // 1. 건강
            _buildSectionHeader('건강', hospitalRecordCount),

            const SizedBox(height: 5),

            _buildCard(
              child: latestHealthRecord == null
                  ? _buildEmptyState(
                      '등록된 병원 기록이 없어요.',
                      icon: Icons.local_hospital_outlined,
                      bgColor: const Color(0xFFE3F2FD),
                      iconColor: Colors.blue,
                    )
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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HospitalStatisticsScreen(petId: widget.pet.id!),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart_outlined, size: 16),
                label: const Text(
                  '병원 기록 통계',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. 예방접종
            _buildSectionHeader('예방접종', vaccinationRecordCount),

            const SizedBox(height: 5),

            _buildCard(
              child: nextVaccination == null
                  ? _buildEmptyState(
                      '예정된 예방접종이 없어요.',
                      icon: Icons.vaccines_outlined,
                      bgColor: const Color(0xFFE8F5E9),
                      iconColor: Colors.green,
                    )
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

            if (upcomingVaccinations.length >= 2) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _showUpcomingVaccinations,
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text(
                    '접종 예정 내역',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 3. 약
            _buildSectionHeader('약', medicationRecordCount),

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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showMedicationCompletionDetail,
                icon: const Icon(Icons.analytics_outlined, size: 16),
                label: const Text(
                  '복용 현황',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 4. 체중
            _buildSectionHeader('체중', weightRecordCount),

            const SizedBox(height: 5),

            _buildCard(
              child: latestWeightRecord == null
                  ? _buildEmptyState(
                      '등록된 체중 기록이 없어요.',
                      icon: Icons.monitor_weight_outlined,
                      bgColor: const Color(0xFFF3E5F5),
                      iconColor: Colors.purple,
                    )
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

            // 체중 변화 그래프 버튼
            if (weightRecords.length >= 2)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _showWeightChart,
                  icon: const Icon(Icons.show_chart_outlined, size: 16),
                  label: const Text(
                    '체중 변화 그래프',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // shrinkWrap: 실제로 터치할 수 있는 영역의 크기를 줄이는 설정
                  ),
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
        if (title != '약')
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

  Widget _buildEmptyState(
    String text, {
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        _buildIconBox(icon, bgColor, iconColor),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }
}
