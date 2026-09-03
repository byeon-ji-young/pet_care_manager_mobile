import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import '../models/medication_history_item.dart';

import '../utils/date_time_utils.dart';

class MedicationHistoryScreen extends StatefulWidget {
  final Medication medication;

  const MedicationHistoryScreen({super.key, required this.medication});

  @override
  State<MedicationHistoryScreen> createState() =>
      _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState extends State<MedicationHistoryScreen> {
  List<MedicationHistoryItem> history = [];
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

    // 이 약의 실제 복용 완료 로그 조회
    final logs = await DatabaseHelper.instance.getMedicationLog(medicationId);

    final medication = widget.medication;

    final today = DateTimeUtils.todayKst();

    final startDate = DateTime(
      medication.medicationDate.year,
      medication.medicationDate.month,
      medication.medicationDate.day,
    );

    final items = <MedicationHistoryItem>[];

    DateTime currentDate = startDate;

    while (!currentDate.isAfter(today)) {
      bool isScheduled = false;

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
        isScheduled = currentDate.weekday == startDate.weekday;
      }
      // N일마다
      else if (medication.repeatType == 'interval' &&
          medication.repeatInterval != null &&
          medication.repeatInterval! > 0) {
        final difference = currentDate.difference(startDate).inDays;

        isScheduled = difference % medication.repeatInterval! == 0;
      }

      if (isScheduled) {
        MedicationLog? matchingLog;

        for (final log in logs) {
          final logDate = DateTime(
            log.medicationDate.year,
            log.medicationDate.month,
            log.medicationDate.day,
          );

          if (logDate == currentDate) {
            matchingLog = log;
            break;
          }
        }

        items.add(
          MedicationHistoryItem(
            medicationDate: currentDate,
            completedAt: matchingLog?.completedAt,
          ),
        );
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    // 최신 날짜가 위로 오도록 정렬
    items.sort((a, b) => b.medicationDate.compareTo(a.medicationDate));

    if (!mounted) return;

    setState(() {
      history = items;
      isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
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
          : history.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildLogCard(history[index]);
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

  Widget _buildLogCard(MedicationHistoryItem item) {
    final completed = item.isCompleted;

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
                    _formatDate(item.medicationDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    completed && item.completedAt != null
                        ? '복용 완료 ${_formatTime(item.completedAt!)}'
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

            // Text(
            //   completed ? '복용 완료' : '미복용',
            //   style: TextStyle(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w600,
            //     color: completed ? Colors.green : Colors.grey,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
