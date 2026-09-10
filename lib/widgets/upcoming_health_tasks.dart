import 'package:flutter/material.dart';

import '../models/health_record.dart';
import '../models/vaccination.dart';
import '../models/medication.dart';

import '../utils/date_time_utils.dart';

import '../screens/upcoming_health_tasks_screen.dart';

class UpcomingHealthTasks extends StatelessWidget {
  final int petId;

  final List<HealthRecord> healthRecords;
  final List<Vaccination> vaccinations;
  final List<Medication> medications;

  final Future<void> Function(HealthRecord record) onHealthRecordTap;
  final Future<void> Function(Vaccination vaccination) onVaccinationTap;
  final Future<void> Function(Medication medication) onMedicationTap;

  const UpcomingHealthTasks({
    super.key,
    required this.petId,
    required this.healthRecords,
    required this.vaccinations,
    required this.medications,
    required this.onHealthRecordTap,
    required this.onVaccinationTap,
    required this.onMedicationTap,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = <_UpcomingTask>[]; // _UpcomingTask 객체를 담을 수 있는 빈 리스트 생성

    // 병원 기록
    for (final record in healthRecords) {
      tasks.add(
        _UpcomingTask(
          date: record.date,
          title: record.title,
          subtitle: record.hospital,
          icon: Icons.local_hospital_outlined,
          color: Colors.blue,
          onTap: () => onHealthRecordTap(record),
        ),
      );
    }

    // 예방접종
    for (final vaccination in vaccinations) {
      if (vaccination.nextDate == null) {
        continue;
      }

      tasks.add(
        _UpcomingTask(
          date: vaccination.nextDate!,
          title: vaccination.vaccineName,
          subtitle: vaccination.hospital,
          icon: Icons.vaccines_outlined,
          color: Colors.green,
          onTap: () => onVaccinationTap(vaccination),
        ),
      );
    }

    // 약
    for (final medication in medications) {
      if (medication.nextDate == null) {
        continue;
      }

      tasks.add(
        _UpcomingTask(
          date: medication.nextDate!,
          title: medication.medicationName,
          subtitle: medication.medicationTime?.format(
            context,
          ), // ?.은 null-safety 연산자 - null이면 format() 실행 안하고 null 반환 / null이 아니면 format() 실행
          icon: Icons.medication_outlined,
          color: Colors.orange,
          onTap: () => onMedicationTap(medication),
        ),
      );
    }

    // 날짜가 가까운 순서대로 정렬
    /*
    b.date.compareTo(a.date) - 내림차순
    a.date.compareTo(b.date) - 오름차순
    */
    tasks.sort((a, b) => a.date.compareTo(b.date));

    final visibleTasks = tasks.take(3).toList();

    // 예정 일정이 없으면 표시하지 않음
    if (tasks.isEmpty) {
      // return const SizedBox.shrink(); // shrink()는 가능한 한 크기를 작게 줄인다는 의미. 즉, 여기에 아무것도 그리지 말고 공간도 차지하지 않게 하라는 뜻
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          // decoration: BoxDecoration(
          //   color: Colors.grey.withValues(alpha: 0.08),
          //   borderRadius: BorderRadius.circular(10),
          // ),
          child: Text(
            '예정된 건강 관리가 없어요.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...visibleTasks.map((task) => _buildUpcomingTaskItem(context, task)),

          // 전체 일정이 3개보다 많을 때만 전체 보기 표시
          if (tasks.length > 3) ...[
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                ),
              ),
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpcomingHealthTasksScreen(petId: petId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '전체 일정 보기',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingTaskItem(BuildContext context, _UpcomingTask task) {
    final today = DateTimeUtils.todayKst();

    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);

    final todayDate = DateTime(today.year, today.month, today.day);

    final difference = taskDate.difference(todayDate).inDays;

    final dateText = '${task.date.month}월 ${task.date.day}일';

    final remainingText = difference == 1 ? '내일' : '$difference일 후';

    return InkWell(
      onTap: task.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: task.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(task.icon, color: task.color, size: 21),
            ),

            const SizedBox(width: 12),

            // 일정 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    [
                      dateText,
                      if (task.subtitle != null && task.subtitle!.isNotEmpty)
                        task.subtitle!,
                    ].join(' · '),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 남은 날짜
            Text(
              remainingText,
              style: TextStyle(
                fontSize: 12,
                color: task.color,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 4),

            // 상세 화면 이동
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTask {
  final DateTime date;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Future<void> Function() onTap;

  _UpcomingTask({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
