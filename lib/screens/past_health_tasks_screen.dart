import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../screens/health_record_register_screen.dart';
import '../screens/vaccination_register_screen.dart';

class PastHealthTasksScreen extends StatefulWidget {
  final int petId;

  const PastHealthTasksScreen({super.key, required this.petId});

  @override
  State<PastHealthTasksScreen> createState() => _PastHealthTasksScreenState();
}

class _PastHealthTasksScreenState extends State<PastHealthTasksScreen> {
  List<_PastTask> tasks = [];

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

    final pastTasks = <_PastTask>[];

    // 병원 기록
    for (final record in healthRecords) {
      pastTasks.add(
        _PastTask(
          title: record.title,
          subtitle: record.hospital,
          date: record.date,
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
      pastTasks.add(
        _PastTask(
          title: vaccination.vaccineName,
          subtitle: vaccination.hospital,
          date: vaccination.vaccinationDate,
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
    pastTasks.sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) {
      return;
    }

    setState(() {
      tasks = pastTasks;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '지난 건강 관리',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(child: Text('지난 건강 관리 기록이 없어요.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _buildPastTaskItem(context, tasks[index]);
              },
            ),
    );
  }

  Widget _buildPastTaskItem(BuildContext context, _PastTask task) {
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
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _formatDate(task.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),

                    if (task.subtitle != null && task.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.subtitle!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }
}

class _PastTask {
  final String title;
  final String? subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;

  final Future<void> Function() onTap;

  _PastTask({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
