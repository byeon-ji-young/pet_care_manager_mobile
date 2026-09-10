import 'package:flutter/material.dart';

import '../models/health_record.dart';
import '../models/vaccination.dart';

import '../utils/date_time_utils.dart';

import '../database/database_helper.dart';

import '../screens/health_record_register_screen.dart';
import '../screens/vaccination_register_screen.dart';
import '../screens/past_health_tasks_screen.dart';

class PastHealthTasks extends StatefulWidget {
  final int petId;

  const PastHealthTasks({super.key, required this.petId});

  @override
  State<PastHealthTasks> createState() => _PastHealthTasksState();
}

class _PastHealthTasksState extends State<PastHealthTasks> {
  List<HealthRecord> healthRecords = [];
  List<Vaccination> vaccinations = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPastTasks();
  }

  Future<void> _loadPastTasks() async {
    final healthRecords = await DatabaseHelper.instance.getPastHealthRecords(
      widget.petId,
    );

    final vaccinations = await DatabaseHelper.instance.getPastVaccinations(
      widget.petId,
    );

    final tasks = <_PastTask>[];

    // 병원 기록
    for (final record in healthRecords) {
      tasks.add(
        _PastTask(
          date: record.date,
          title: record.title,
          subtitle: record.hospital,
          icon: Icons.local_hospital_outlined,
          color: Colors.blue,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HealthRecordRegisterScreen(
                  petId: widget.petId,
                  record: record,
                ),
              ),
            );

            if (result != null) {
              await _loadPastTasks();
            }
          },
        ),
      );
    }

    // 예방접종
    for (final vaccination in vaccinations) {
      tasks.add(
        _PastTask(
          date: vaccination.vaccinationDate,
          title: vaccination.vaccineName,
          subtitle: vaccination.hospital,
          icon: Icons.vaccines_outlined,
          color: Colors.green,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VaccinationRegisterScreen(
                  petId: widget.petId,
                  vaccination: vaccination,
                ),
              ),
            );

            if (result != null) {
              await _loadPastTasks();
            }
          },
        ),
      );
    }

    // 최신 날짜가 위로 오도록 정렬
    tasks.sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) {
      return;
    }

    setState(() {
      this.healthRecords = healthRecords;
      this.vaccinations = vaccinations;
      _tasks = tasks;
      isLoading = false;
    });
  }

  List<_PastTask> _tasks = [];

  @override
  Widget build(BuildContext context) {
    // 지난 일정이 없으면 표시하지 않음
    if (!isLoading && _tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final primaryColor = Theme.of(context).primaryColor;

    final visibleTasks = _tasks.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_outlined, color: primaryColor, size: 20),

                  const SizedBox(width: 8),

                  const Text(
                    '지난 건강 관리',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_tasks.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ...visibleTasks.map((task) => _buildPastTaskItem(context, task)),

              // 전체 일정이 3개보다 많을 때만 전체 보기 표시
              if (_tasks.length > 3) ...[
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PastHealthTasksScreen(petId: widget.petId),
                        ),
                      );

                      await _loadPastTasks();
                    },
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
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
        ),
      ),
    );
  }

  Widget _buildPastTaskItem(BuildContext context, _PastTask task) {
    final today = DateTimeUtils.todayKst();

    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);

    final todayDate = DateTime(today.year, today.month, today.day);

    final difference = todayDate.difference(taskDate).inDays;

    final dateText = '${task.date.month}월 ${task.date.day}일';

    final passedText = '$difference일 전';

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

            // 지난 날짜
            Text(
              passedText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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

class _PastTask {
  final DateTime date;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Future<void> Function() onTap;

  _PastTask({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
