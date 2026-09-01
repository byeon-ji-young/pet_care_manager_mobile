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
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildHistoryCard(history[index]);
              },
            ),
    );
  }

  Widget _buildHistoryCard(Vaccination vaccination) {
    final completed = vaccination.status == 'completed';

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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(vaccination.vaccinationDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Text(
                        completed ? '접종 완료' : '접종 예정',
                        style: TextStyle(
                          fontSize: 13,
                          color: completed
                              ? Colors.green.shade700
                              : Colors.grey[600],
                        ),
                      ),

                      if (vaccination.hospital != null &&
                          vaccination.hospital!.isNotEmpty) ...[
                        const SizedBox(width: 6),

                        Text(
                          '·',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),

                        const SizedBox(width: 6),

                        Flexible(
                          child: Text(
                            vaccination.hospital!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
