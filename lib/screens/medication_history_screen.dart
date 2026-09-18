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
            medicationTime: medication.medicationTime,
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
              separatorBuilder: (_, _) => const SizedBox(height: 8),
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
            '아직 복용 이력이 없어요.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(MedicationHistoryItem item) {
    final completed = item.isCompleted;

    final Color statusColor = completed
        ? Colors.green
        : item.isMissed
        ? Colors.redAccent
        : Colors.grey;

    final IconData statusIcon = completed
        ? Icons.check_circle_outline
        : item.isMissed
        ? Icons.error_outline
        : Icons.schedule_outlined;

    final String statusText = completed && item.completedAt != null
        ? '복용 완료 · ${_formatTime(item.completedAt!)}'
        : item.isMissed
        ? '복용 누락'
        : '복용 예정';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // 상태 아이콘
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 21),
          ),

          const SizedBox(width: 12),

          // 날짜 + 상태
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(item.medicationDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
