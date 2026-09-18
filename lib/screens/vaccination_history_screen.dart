import 'package:flutter/material.dart';

import '../models/vaccination.dart';

class VaccinationHistoryScreen extends StatelessWidget {
  final String vaccineName;
  final List<Vaccination> vaccinations;

  const VaccinationHistoryScreen({
    super.key,
    required this.vaccineName,
    required this.vaccinations,
  });

  String _formatDate(DateTime date) {
    return '${date.year}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 같은 예방접종 이름의 기록만 가져오기
    final history =
        vaccinations
            .where((vaccination) => vaccination.vaccineName == vaccineName)
            .toList()
          ..sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$vaccineName 접종 이력',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: history.isEmpty
          ? const Center(child: Text('아직 접종 기록이 없어요.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildHistoryCard(history[index]);
              },
            ),
    );
  }

  Widget _buildHistoryCard(Vaccination vaccination) {
    final completed = vaccination.status == 'completed';

    final Color statusColor = completed ? Colors.green : Colors.grey;

    final IconData statusIcon = completed
        ? Icons.check_circle_outline
        : Icons.schedule_outlined;

    final String statusText = completed ? '접종 완료' : '접종 예정';

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

          // 날짜 + 상태 + 병원
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(vaccination.vaccinationDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  [
                    statusText,
                    if (vaccination.hospital != null &&
                        vaccination.hospital!.isNotEmpty)
                      vaccination.hospital!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
