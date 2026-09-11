import 'package:flutter/material.dart';

import '../models/health_record.dart';
import '../models/vaccination.dart';
import '../models/medication.dart';

import '../database/database_helper.dart';
import '../screens/health_record_register_screen.dart';
import '../screens/vaccination_register_screen.dart';
import '../screens/medication_history_screen.dart';
import '../screens/today_health_tasks_screen.dart';

import '../utils/date_time_utils.dart';

class TodayHealthTasks extends StatefulWidget {
  final int petId;

  final List<HealthRecord> healthRecords;
  final List<Vaccination> vaccinations;
  final List<Medication> medications;

  final Set<int> completedMedicationIds;

  final Future<void> Function()? onDataChanged;

  const TodayHealthTasks({
    super.key,
    required this.petId,
    required this.healthRecords,
    required this.vaccinations,
    required this.medications,
    required this.completedMedicationIds,
    this.onDataChanged,
  });

  @override
  State<TodayHealthTasks> createState() => _TodayHealthTasksState();
}

class _TodayHealthTasksState extends State<TodayHealthTasks> {
  int get totalCount =>
      widget.healthRecords.length +
      widget.vaccinations.length +
      widget.medications.length;

  @override
  Widget build(BuildContext context) {
    // 오늘 해야 할 일이 없으면 카드 숨김
    if (totalCount == 0) {
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
            '오늘 예정된 건강 관리가 없어요.',
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

    final taskWidgets = <Widget>[
      // 병원
      ...widget.healthRecords.map(
        (record) => _buildTodayHealthRecordItem(record),
      ),

      // 예방접종
      ...widget.vaccinations.map(
        (vaccination) => _buildTodayVaccinationItem(vaccination),
      ),

      // 약
      ...widget.medications.map(
        (medication) => _buildTodayMedicationItem(medication),
      ),
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...taskWidgets.take(3),

            if (totalCount > 3) ...[
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
                            TodayHealthTasksScreen(petId: widget.petId),
                      ),
                    );

                    if (widget.onDataChanged != null) {
                      await widget.onDataChanged!();
                    }
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
    );
  }

  // 오늘 병원 방문 하나
  Widget _buildTodayHealthRecordItem(HealthRecord record) {
    final isCompleted = record.status == 'completed';
    final color = isCompleted ? Colors.grey : Colors.blue;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HealthRecordRegisterScreen(petId: widget.petId, record: record),
          ),
        );

        if (result != null && mounted) {
          await widget.onDataChanged?.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            /*
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: Icon(
                Icons.local_hospital_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
            */
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_outlined,
                color: Colors.blue,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (record.hospital != null &&
                          record.hospital!.isNotEmpty)
                        record.hospital!,
                      if (record.time != null) record.time!.format(context),
                    ].join(' · '),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCompleted ? '방문 완료' : '방문 예정',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                /*
                IconButton(
                  onPressed: () async {
                    if (record.id == null) return;

                    try {
                      if (isCompleted) {
                        await DatabaseHelper.instance.cancelHealthRecord(
                          record.id!,
                        );
                      } else {
                        await DatabaseHelper.instance.completeHealthRecord(
                          record.id!,
                        );
                      }

                      await widget.onDataChanged?.call();
                    } catch (e) {
                      debugPrint('병원 방문 상태 변경 실패: $e');

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('병원 방문 상태를 변경하지 못했어요.')),
                      );
                    }
                  },
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 22,
                  ),
                  color: isCompleted ? Colors.grey : Colors.blue,
                  tooltip: isCompleted ? '방문 완료 취소' : '방문 완료 처리',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                */
                GestureDetector(
                  onTap: () async {
                    if (record.id == null) return;
                    try {
                      if (isCompleted) {
                        await DatabaseHelper.instance.cancelHealthRecord(
                          record.id!,
                        );
                      } else {
                        await DatabaseHelper.instance.completeHealthRecord(
                          record.id!,
                        );
                      }
                      await widget.onDataChanged?.call();
                    } catch (e) {
                      debugPrint('병원 방문 상태 변경 실패: $e');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('병원 방문 상태를 변경하지 못했어요.')),
                      );
                    }
                  },
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 22,
                    color: isCompleted ? Colors.grey : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 오늘 예방접종 하나
  Widget _buildTodayVaccinationItem(Vaccination vaccination) {
    final isCompleted = vaccination.status == 'completed';
    final color = isCompleted ? Colors.grey : Colors.green;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
        if (result != null && mounted) {
          await widget.onDataChanged?.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            /*
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: Icon(
                Icons.vaccines_outlined,
                color: Colors.green,
                size: 20,
              ),
            ),
            */
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.vaccines_outlined,
                color: Colors.green,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccination.vaccineName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vaccination.hospital?.isNotEmpty == true
                        ? vaccination.hospital!
                        : '접종 병원 미정',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCompleted ? '접종 완료' : '접종 예정',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                /*
                IconButton(
                  onPressed: () async {
                    if (vaccination.id == null) return;
                    try {
                      if (isCompleted) {
                        await DatabaseHelper.instance.cancelVaccination(
                          vaccination.id!,
                        );
                      } else {
                        await DatabaseHelper.instance.completeVaccination(
                          vaccination.id!,
                        );
                      }
                      await widget.onDataChanged?.call();
                    } catch (e) {
                      debugPrint('예방접종 상태 변경 실패: $e');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('예방접종 상태를 변경하지 못했어요.')),
                      );
                    }
                  },
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 22,
                  ),
                  color: isCompleted ? Colors.grey : Colors.green,
                  tooltip: isCompleted ? '접종 완료 취소' : '접종 완료 처리',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                */
                GestureDetector(
                  onTap: () async {
                    if (vaccination.id == null) return;
                    try {
                      if (isCompleted) {
                        await DatabaseHelper.instance.cancelVaccination(
                          vaccination.id!,
                        );
                      } else {
                        await DatabaseHelper.instance.completeVaccination(
                          vaccination.id!,
                        );
                      }
                      await widget.onDataChanged?.call();
                    } catch (e) {
                      debugPrint('예방접종 상태 변경 실패: $e');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('예방접종 상태를 변경하지 못했어요.')),
                      );
                    }
                  },
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 22,
                    color: isCompleted ? Colors.grey : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 오늘 복용할 약 하나
  Widget _buildTodayMedicationItem(Medication medication) {
    final isCompleted =
        medication.id != null &&
        widget.completedMedicationIds.contains(medication.id);

    String statusText;
    if (isCompleted) {
      statusText = '복용 완료';
    } else {
      switch (medication.scheduleStatus) {
        case 'passed':
          statusText = '복용 누락';
          break;
        case 'upcoming':
          statusText = '복용 예정';
          break;
        default:
          statusText = '복용 시간 미정';
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        if (medication.id == null) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MedicationHistoryScreen(medication: medication),
          ),
        );

        await widget.onDataChanged?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            /*
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: Icon(icon, color: Colors.orange, size: 20),
            ),
            */
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                color: Colors.orange,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.medicationName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? Colors.black87
                          : medication.scheduleStatus == 'passed'
                          ? Colors.redAccent
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medication.medicationTime?.format(context) ?? '복용 시간 미정',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted
                          ? Colors.grey[600]
                          : medication.scheduleStatus == 'passed'
                          ? Colors.redAccent
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.grey : Colors.orange,
                  ),
                ),
                const SizedBox(width: 6),
                /*
                IconButton(
                  onPressed: () async {
                    if (medication.id == null) return;

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

                      await widget.onDataChanged?.call();
                    } catch (e) {
                      debugPrint('복용 상태 변경 실패: $e');

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('복용 상태를 변경하지 못했어요.')),
                      );
                    }
                  },
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 22,
                  ),
                  color: isCompleted ? Colors.grey : Colors.orange,
                  tooltip: isCompleted ? '복용 완료 취소' : '복용 완료 처리',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                */
                GestureDetector(
                  onTap: () async {
                    if (medication.id == null) return;
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
                      await widget.onDataChanged?.call();
                    } catch (e) {
                      debugPrint('복용 상태 변경 실패: $e');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('복용 상태를 변경하지 못했어요.')),
                      );
                    }
                  },
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 22,
                    color: isCompleted ? Colors.grey : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
