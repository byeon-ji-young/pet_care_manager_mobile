import 'package:flutter/material.dart';

import '../models/health_record.dart';
import '../models/vaccination.dart';
import '../models/medication.dart';

import '../utils/date_time_utils.dart';

class UpcomingHealthTasks extends StatelessWidget {
  final List<HealthRecord> healthRecords;
  final List<Vaccination> vaccinations;
  final List<Medication> medications;

  final Future<void> Function(HealthRecord record) onHealthRecordTap;
  final Future<void> Function(Vaccination vaccination) onVaccinationTap;
  final Future<void> Function(Medication medication) onMedicationTap;

  const UpcomingHealthTasks({
    super.key,
    required this.healthRecords,
    required this.vaccinations,
    required this.medications,
    required this.onHealthRecordTap,
    required this.onVaccinationTap,
    required this.onMedicationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (healthRecords.isNotEmpty) _buildHealthRecordGroupCard(context),

        if (vaccinations.isNotEmpty) _buildVaccinationGroupCard(context),

        if (medications.isNotEmpty) _buildMedicationGroupCard(context),
      ],
    );
  }

  // 공통 예정 알림 아이템 (병원기록, 예방접종, 약 복용 알림 카드)
  Widget _buildBannerItem({
    required BuildContext context,
    required String title,
    required DateTime targetDate,
    required String categoryType, // 'hospital', 'vaccine', 'medication'
    VoidCallback? onTap,
  }) {
    final today = DateTimeUtils.todayKst();
    final todayDate = DateTime(today.year, today.month, today.day);
    final tDate = DateTime(targetDate.year, targetDate.month, targetDate.day);

    final difference = tDate.difference(todayDate).inDays;

    Color textColor;
    IconData iconData;
    String message;

    final primaryColor = Theme.of(context).primaryColor;

    if (difference == 0) {
      textColor = Colors.red.shade900;
      iconData = Icons.notifications_active_outlined;

      if (categoryType == 'vaccine') {
        message = '오늘은 $title 예방접종 날이에요!';
      } else if (categoryType == 'medication') {
        message = '오늘은 $title 복용일이에요!';
      } else {
        message = '오늘은 $title 병원 방문일이에요!';
      }
    } else if (difference > 0) {
      textColor = primaryColor.withValues(alpha: 0.9);
      iconData = Icons.event_available_rounded;

      if (categoryType == 'vaccine') {
        message = '$title 예방접종까지 $difference일 남았어요.';
      } else if (categoryType == 'medication') {
        message = '$title 복용까지 $difference일 남았어요.';
      } else {
        message = '$title 병원 방문까지 $difference일 남았어요.';
      }
    } else {
      textColor = Colors.red.shade900;
      iconData = Icons.warning_amber_rounded;

      if (categoryType == 'vaccine') {
        message = '$title 예방접종 예정일이 ${difference.abs()}일 지났어요!';
      } else if (categoryType == 'medication') {
        message = '$title 복용 예정일이 ${difference.abs()}일 지났어요!';
      } else {
        message = '$title 병원 방문 예정일이 ${difference.abs()}일 지났어요!';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(iconData, color: textColor, size: 20),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),

            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // 병원 방문 알림 카드 그룹화
  Widget _buildHealthRecordGroupCard(BuildContext context) {
    final items = healthRecords.take(2).toList();

    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          // List.generate: items의 개수만큼 UI 생성
          final item = items[index];

          return Column(
            children: [
              _buildBannerItem(
                context: context,
                title: item.title,
                targetDate: item.date,
                categoryType: 'hospital',
                onTap: () {
                  onHealthRecordTap(item);
                },
              ),

              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: primaryColor.withValues(alpha: 0.2),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }

  // 예방 접종 알림 카드 그룹화
  Widget _buildVaccinationGroupCard(BuildContext context) {
    final items = vaccinations.take(2).toList();

    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Column(
            children: [
              if (item.nextDate != null)
                _buildBannerItem(
                  context: context,
                  title: item.vaccineName,
                  targetDate: item.nextDate!,
                  categoryType: 'vaccine',
                  onTap: () {
                    onVaccinationTap(item);
                  },
                ),

              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: primaryColor.withValues(alpha: 0.2),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }

  // 약 복용 알림 카드 그룹화
  Widget _buildMedicationGroupCard(BuildContext context) {
    final items = medications.take(2).toList();

    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Column(
            children: [
              if (item.nextDate != null)
                _buildBannerItem(
                  context: context,
                  title: item.medicationName,
                  targetDate: item.nextDate!,
                  categoryType: 'medication',
                  onTap: () {
                    onMedicationTap(item);
                  },
                ),

              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: primaryColor.withValues(alpha: 0.2),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}
