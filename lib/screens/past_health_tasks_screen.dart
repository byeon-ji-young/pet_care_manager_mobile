import 'package:flutter/material.dart';

import '../database/database_helper.dart';

import '../screens/health_record_register_screen.dart';
import '../screens/vaccination_register_screen.dart';
import '../screens/medication_history_screen.dart';

class PastHealthTasksScreen extends StatefulWidget {
  final int petId;

  const PastHealthTasksScreen({super.key, required this.petId});

  @override
  State<PastHealthTasksScreen> createState() => _PastHealthTasksScreenState();
}

class _PastHealthTasksScreenState extends State<PastHealthTasksScreen> {
  List<_PastTask> tasks = [];

  bool isLoading = true;

  // 0 = 전체, 1 = 건강, 2 = 예방접종, 3 = 약
  int selectedTab = 0;

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

    final medicationHistories = await DatabaseHelper.instance
        .getPastMedicationHistory(widget.petId);

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
          type: 0,
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
          type: 1,
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

    // 약 복용
    for (final history in medicationHistories) {
      pastTasks.add(
        _PastTask(
          title: history.medication.medicationName,
          subtitle: null,
          date: history.medicationDate,
          icon: Icons.medication_outlined,
          color: Colors.orange,
          type: 2,
          statusText: history.isCompleted ? '복용 완료' : '복용 누락',
          statusColor: history.isCompleted ? Colors.green : Colors.redAccent,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MedicationHistoryScreen(medication: history.medication),
              ),
            );

            await _loadPastTasks();
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
          : Column(
              children: [
                // 탭
                _buildTabBar(),

                // 탭 내용
                Expanded(child: _buildTaskList()),
              ],
            ),
    );
  }

  Widget _buildTabBar() {
    final tabTitles = ['전체', '건강', '예방접종', '약'];

    final tabCounts = [
      tasks.length,
      tasks.where((task) => task.type == 0).length,
      tasks.where((task) => task.type == 1).length,
      tasks.where((task) => task.type == 2).length,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          for (int index = 0; index < tabTitles.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selectedTab == index
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tabTitles[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selectedTab == index
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: selectedTab == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: selectedTab == index
                              ? Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tabCounts[index]}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selectedTab == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = selectedTab == 0
        ? tasks
        : tasks.where((task) => task.type == selectedTab - 1).toList();

    if (filteredTasks.isEmpty) {
      return const Center(
        child: Text('해당 기록이 없어요.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return _buildPastTaskItem(context, filteredTasks[index]);
      },
    );
  }

  Widget _buildPastTaskItem(BuildContext context, _PastTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: task.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: task.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(task.icon, color: task.color, size: 21),
              ),

              const SizedBox(width: 12),

              // 기록 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      [
                        _formatDate(task.date),
                        if (task.subtitle != null && task.subtitle!.isNotEmpty)
                          task.subtitle!,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // 약 복용 상태
              if (task.statusText != null) ...[
                const SizedBox(width: 8),
                Text(
                  task.statusText!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: task.statusColor,
                  ),
                ),
              ],

              const SizedBox(width: 8),

              // 이동 아이콘
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
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

  final int type;

  final String? statusText;
  final Color statusColor;

  final Future<void> Function() onTap;

  _PastTask({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
    required this.type,
    this.statusText,
    this.statusColor = Colors.grey,
    required this.onTap,
  });
}
