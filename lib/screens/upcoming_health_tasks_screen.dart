import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../screens/health_record_register_screen.dart';
import '../screens/vaccination_register_screen.dart';
import '../screens/medication_register_screen.dart';

import '../utils/date_time_utils.dart';

class UpcomingHealthTasksScreen extends StatefulWidget {
  final int petId;

  const UpcomingHealthTasksScreen({super.key, required this.petId});

  @override
  State<UpcomingHealthTasksScreen> createState() =>
      _UpcomingHealthTasksScreenState();
}

class _UpcomingHealthTasksScreenState extends State<UpcomingHealthTasksScreen> {
  List<_UpcomingTask> tasks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingTasks();
  }

  String? _formatMedicationTime(TimeOfDay? time) {
    if (time == null) {
      return null;
    }

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _loadUpcomingTasks() async {
    final healthRecords = await DatabaseHelper.instance
        .getUpcomingHealthRecords(widget.petId);

    final vaccinations = await DatabaseHelper.instance.getUpcomingVaccinations(
      widget.petId,
    );

    final medications = await DatabaseHelper.instance.getUpcomingMedications(
      widget.petId,
    );

    final upcomingTasks = <_UpcomingTask>[];

    // 병원 기록
    for (final record in healthRecords) {
      upcomingTasks.add(
        _UpcomingTask(
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
              await _loadUpcomingTasks();
            }
          },
        ),
      );
    }

    // 예방접종
    for (final vaccination in vaccinations) {
      if (vaccination.nextDate == null) {
        continue;
      }

      upcomingTasks.add(
        _UpcomingTask(
          date: vaccination.nextDate!,
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
              await _loadUpcomingTasks();
            }
          },
        ),
      );
    }

    // 약
    for (final medication in medications) {
      if (medication.nextDate == null) {
        continue;
      }

      upcomingTasks.add(
        _UpcomingTask(
          date: medication.nextDate!,
          title: medication.medicationName,
          subtitle: _formatMedicationTime(medication.medicationTime),
          icon: Icons.medication_outlined,
          color: Colors.orange,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicationRegisterScreen(
                  petId: widget.petId,
                  medication: medication,
                ),
              ),
            );

            if (result != null) {
              await _loadUpcomingTasks();
            }
          },
        ),
      );
    }

    upcomingTasks.sort((a, b) => a.date.compareTo(b.date));

    if (!mounted) {
      return;
    }

    setState(() {
      tasks = upcomingTasks;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '다가오는 건강 관리',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(child: Text('다가오는 건강 관리 일정이 없어요.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _buildUpcomingTaskItem(context, tasks[index]);
              },
            ),
    );
  }

  Widget _buildUpcomingTaskItem(BuildContext context, _UpcomingTask task) {
    final today = DateTimeUtils.todayKst();

    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);

    final difference = taskDate.difference(today).inDays;

    final remainingText = difference == 1 ? '내일' : '$difference일 후';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: task.color.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: task.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: task.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(task.icon, color: task.color, size: 22),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      [
                        '${task.date.month}월 ${task.date.day}일',
                        if (task.subtitle != null && task.subtitle!.isNotEmpty)
                          task.subtitle!,
                      ].join(' · '),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                remainingText,
                style: TextStyle(
                  fontSize: 12,
                  color: task.color,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 4),

              Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
            ],
          ),
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
