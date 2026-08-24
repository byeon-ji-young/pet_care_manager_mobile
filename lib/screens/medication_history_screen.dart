import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';

class MedicationHistoryScreen extends StatefulWidget {
  final Medication medication;

  const MedicationHistoryScreen({super.key, required this.medication});

  @override
  State<MedicationHistoryScreen> createState() =>
      _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState extends State<MedicationHistoryScreen> {
  List<MedicationLog> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final medicationId = widget.medication.id;

    if (medicationId == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    final result = await DatabaseHelper.instance.getMedicationLog(medicationId);

    if (!mounted) return;

    // 아직 이 화면이 살아있을 때만 setState (mounted 조건 때문)
    setState(() {
      logs = result;
      isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.medication.medicationName} 복용 이력',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 아이콘
          : logs.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildLogCard(logs[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            '아직 복용 완료 기록이 없어요.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(MedicationLog log) {
    final completed = log.isCompleted;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: completed
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              child: Icon(
                completed ? Icons.check_circle : Icons.schedule_outlined,
                color: completed ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // Expanded는 Flutter에서 남는 공간을 꽉 채우도록 자식 위젯을 늘려주는 위젯
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(log.medicationDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    completed && log.completedAt != null
                        ? '복용 완료 ${_formatTime(log.completedAt!)}'
                        : '복용하지 않음',
                    style: TextStyle(
                      fontSize: 13,
                      color: completed
                          ? Colors.green.shade700
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Text(
              completed ? '복용 완료' : '미복용',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: completed ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
