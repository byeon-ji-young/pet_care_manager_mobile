import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../screens/health_record_register_screen.dart';
import '../screens/vaccination_register_screen.dart';
import '../screens/medication_history_screen.dart';

import '../utils/date_time_utils.dart';

class TodayHealthTasksScreen extends StatefulWidget {
  final int petId;

  const TodayHealthTasksScreen({super.key, required this.petId});

  @override
  State<TodayHealthTasksScreen> createState() => _TodayHealthTasksScreen();
}

class _TodayHealthTasksScreen extends State<TodayHealthTasksScreen> {
  List<_TodayTask> tasks = [];

  Set<int> completedMedicationIds = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  Future<void> _loadTodayTasks() async {
    final healthRecords = await DatabaseHelper.instance.getTodayHealthRecords(
      widget.petId,
    );

    final vaccinations = await DatabaseHelper.instance.getTodayVaccinations(
      widget.petId,
    );

    final medications = await DatabaseHelper.instance.getTodayMedications(
      widget.petId,
    );

    final todayTasks = <_TodayTask>[];

    // 병원 기록
    for (final record in healthRecords) {
      todayTasks.add(
        _TodayTask(
          title: record.title,
          subtitle: record.hospital,
          icon: Icons.local_hospital_outlined,
          color: Colors.blue,
          isCompleted: record.status == 'completed',
          statusText: record.status == 'completed' ? '방문 완료' : '방문 예정',
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
              await _loadTodayTasks();
            }
          },
          onToggle: () async {
            if (record.status == 'completed') {
              await DatabaseHelper.instance.cancelHealthRecord(record.id!);
            } else {
              await DatabaseHelper.instance.completeHealthRecord(record.id!);
            }

            await _loadTodayTasks();
          },
        ),
      );
    }

    // 예방접종
    for (final vaccination in vaccinations) {
      todayTasks.add(
        _TodayTask(
          title: vaccination.vaccineName,
          subtitle: vaccination.hospital,
          icon: Icons.vaccines_outlined,
          color: Colors.green,
          isCompleted: vaccination.status == 'completed',
          statusText: vaccination.status == 'completed' ? '접종 완료' : '접종 예정',
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
              await _loadTodayTasks();
            }
          },
          onToggle: () async {
            if (vaccination.status == 'completed') {
              await DatabaseHelper.instance.cancelVaccination(vaccination.id!);
            } else {
              await DatabaseHelper.instance.completeVaccination(
                vaccination.id!,
              );
            }

            await _loadTodayTasks();
          },
        ),
      );
    }

    // 약
    for (final medication in medications) {
      final isCompleted = await DatabaseHelper.instance.isMedicationTakenToday(
        medication.id!,
      );

      todayTasks.add(
        _TodayTask(
          title: medication.medicationName,
          subtitle: _formatMedicationTime(medication.medicationTime),
          icon: Icons.medication_outlined,
          color: Colors.orange,
          isCompleted: isCompleted,
          statusText: isCompleted ? '복용 완료' : '복용 예정',
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MedicationHistoryScreen(medication: medication),
              ),
            );

            await _loadTodayTasks();
          },
          onToggle: () async {
            try {
              if (isCompleted) {
                await DatabaseHelper.instance.cancelMedicationToday(
                  medication.id!,
                );
              } else {
                await DatabaseHelper.instance.completeMedication(
                  medicationId: medication.id!,
                  petId: widget.petId,
                  medicationDate: DateTimeUtils.nowKst(),
                );
              }

              await _loadTodayTasks();
            } catch (e) {
              debugPrint('복용 상태 변경 실패: $e');

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('복용 상태를 변경하지 못했어요.')),
              );
            }
          },
        ),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      tasks = todayTasks;
      isLoading = false;
    });
  }

  String? _formatMedicationTime(TimeOfDay? time) {
    if (time == null) {
      return null;
    }

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '오늘의 건강 관리',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(child: Text('오늘 예정된 건강 관리가 없어요.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _buildTodayTaskItem(context, tasks[index]);
              },
            ),
    );
  }

  Widget _buildTodayTaskItem(BuildContext context, _TodayTask task) {
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        // decoration: task.isCompleted
                        //     ? TextDecoration.lineThrough
                        //     : null,
                        color: Colors.black87,
                      ),
                    ),

                    if (task.subtitle != null && task.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        task.subtitle!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                task.statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: task.isCompleted ? Colors.grey : task.color,
                ),
              ),

              const SizedBox(width: 6),

              IconButton(
                onPressed: task.onToggle,
                icon: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: task.isCompleted ? Colors.grey : task.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayTask {
  final String title;
  final String? subtitle;
  final String statusText;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  final Future<void> Function() onTap;
  final Future<void> Function() onToggle;

  _TodayTask({
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.onTap,
    required this.onToggle,
  });
}
