import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../utils/date_time_utils.dart';

import '../widgets/hospital_visit_chart.dart';

class HospitalStatisticsScreen extends StatefulWidget {
  final int petId;

  const HospitalStatisticsScreen({super.key, required this.petId});

  @override
  State<HospitalStatisticsScreen> createState() =>
      _HospitalStatisticsScreenState();
}

class _HospitalStatisticsScreenState extends State<HospitalStatisticsScreen> {
  bool isLoading = true;

  int totalCount = 0;

  int completedCount = 0;
  int scheduledCount = 0;
  int cancelledCount = 0;

  int totalCost = 0;
  int costRecordCount = 0;
  int averageCost = 0;

  final List<Map<String, dynamic>> monthlyVisitCounts = [];

  final List<Map<String, dynamic>> examinationTypeCounts = [];

  @override
  void initState() {
    super.initState();

    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final records = await DatabaseHelper.instance.getHealthRecordByPetId(
      widget.petId,
    );

    if (!mounted) return;

    int completed = 0;
    int scheduled = 0;
    int cancelled = 0;

    int totalCostValue = 0;
    int costCount = 0;

    for (final record in records) {
      switch (record.status) {
        case 'completed':
          completed++;
          break;

        case 'scheduled':
          scheduled++;
          break;

        case 'cancelled':
          cancelled++;
          break;
      }

      if (record.cost != null) {
        totalCostValue += record.cost!;
        costCount++;
      }
    }

    // 6개월 방문 횟수
    final now = DateTimeUtils.todayKst();
    final monthlyCounts = <DateTime, int>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(
        now.year,
        now.month - i,
        1,
      ); // DateTime(now.year, now.month - i, 1)은 now.month - i가 0 이하가 되는 경우에도 Dart가 전년도 날짜로 자동 보정

      monthlyCounts[month] =
          0; // 병원에 한번도 안갔던 month도 그래프에 표시는 해야되기 때문에 값을 일단 0으로 초기화 시킴
    }

    for (final record in records) {
      if (record.status != 'completed') {
        continue;
      }

      final recordMonth = DateTime(record.date.year, record.date.month, 1);

      if (monthlyCounts.containsKey(recordMonth)) {
        monthlyCounts[recordMonth] = monthlyCounts[recordMonth]! + 1;
      }
    }

    // 검사 종류별 횟수
    final examinationCounts = <String, int>{};

    for (final record in records) {
      final examinationType = record.examinationType?.trim().isEmpty ?? true
          ? '검사 종류 미입력'
          : record.examinationType!.trim();

      examinationCounts[examinationType] =
          (examinationCounts[examinationType] ?? 0) + 1;
    }

    debugPrint('전체 병원 기록 수: ${records.length}');

    /*
    b.value.compareTo(a.value) - 내림차순
    a.value.compareTo(b.value) - 오름차순
    */
    final sortedExaminationCounts = examinationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      isLoading = false;

      totalCount = records.length;

      completedCount = completed;
      scheduledCount = scheduled;
      cancelledCount = cancelled;

      totalCost = totalCostValue;
      costRecordCount = costCount;
      averageCost = costCount == 0
          ? 0
          : (totalCostValue / costCount).round(); // round(): 반올림

      monthlyVisitCounts.clear();
      monthlyVisitCounts.addAll(
        monthlyCounts.entries.map(
          (entry) => {'month': entry.key, 'count': entry.value},
        ),
      );

      examinationTypeCounts.clear();
      examinationTypeCounts.addAll(
        sortedExaminationCounts.map(
          (entry) => {'type': entry.key, 'count': entry.value},
        ),
      );
    });
  }

  String _formatCost(int value) {
    /*
    r'(\d)(?=(\d{3})+(?!\d))'

    \d      → 숫자 하나
    (\d)    → ()는 그 부분을 그룹으로 묶는다는 뜻
    {3}     → 3개
    +       → 1번 이상 반복 ex.(\d{3})+는 3자리 숫자 묶음이 하나 이상 존재하는지 확인
    (?=...) → 뒤를 확인 (뒤에 내용을 실제로 가져오지는 않음)
    (?!...) → 뒤에 없어야 함
    */
    return '${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}원'; // replaceAllMapped: 정규식으로 특정 부분을 찾아서 원하는 문자열로 바꾸는 함수
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '병원 기록 통계',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 병원 기록 건수
                  _buildSummaryCard(),

                  const SizedBox(height: 16),

                  // 병원 진료 상태
                  _buildStatusCard(),

                  const SizedBox(height: 16),

                  // 진료비
                  _buildCostCard(),

                  const SizedBox(height: 16),

                  // 최근 6개월 방문 그래프
                  _buildMonthlyVisitCard(),

                  const SizedBox(height: 16),

                  // 검사 종류별 건수
                  _buildExaminationTypeCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '병원 기록',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.local_hospital_outlined,
                size: 32,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              Text(
                '$totalCount건',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '진료 상태',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  title: '진료 완료',
                  value: '$completedCount건',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.event_outlined,
                  title: '진료 예정',
                  value: '$scheduledCount건',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.cancel_outlined,
                  title: '취소',
                  value: '$cancelledCount건',
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.center, // crossAxisAlignment: 세로 방향 정렬
            children: [
              const Text(
                '진료비',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '※ 입력된 진료비 $costRecordCount건 기준',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.payments_outlined,
                  title: '총 진료비',
                  value: _formatCost(totalCost),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calculate_outlined,
                  title: '평균 진료비',
                  value: _formatCost(averageCost),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          /*
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '※ 입력된 진료비 $costRecordCount건 기준',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          */
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyVisitCard() {
    final totalVisits = monthlyVisitCounts.fold<int>(
      0,
      (sum, item) => sum + (item['count'] as int),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 6개월 방문 추이',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '최근 6개월 동안 총 $totalVisits회 방문했어요.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          HospitalVisitChart(monthlyVisitCounts: monthlyVisitCounts),
        ],
      ),
    );
  }

  Widget _buildExaminationTypeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.center, // crossAxisAlignment: 세로 방향 정렬
            children: [
              const Text(
                '검사 종류별 통계',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '※ 등록된 병원 기록 기준',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (examinationTypeCounts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsetsGeometry.only(top: 20),
                child: Text(
                  '검사 기록이 없습니다.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...examinationTypeCounts.map((item) {
              final type = item['type'] as String;
              final count = item['count'] as int;

              return Padding(
                padding: const EdgeInsetsGeometry.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.biotech_outlined,
                      size: 20,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count회',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
