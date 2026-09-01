import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/pet.dart';
import '../models/health_record.dart';
import '../models/vaccination.dart';
import '../models/weight_record.dart';
import '../models/medication.dart';

import '../database/database_helper.dart';

import '../widgets/weight_chart.dart';
import '../widgets/pet_profile_header.dart';
import '../widgets/today_health_tasks.dart';
import '../widgets/upcoming_health_tasks.dart';

import 'pet_register_screen.dart';
import 'health_record_register_screen.dart';
import 'vaccination_register_screen.dart';
import 'weight_record_register_screen.dart';
import 'medication_register_screen.dart';

import '../utils/date_time_utils.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  /*
    StatefulWidget 자체는 화면의 상태를 직접 저장하는 역할을 하지 않기 때문에 실제 상태를 관리할 state 객체를 만들어야 함.
    @override
    State<PetDetailScreen> createState() => _PetDetailScreenState();

    이게 PetDetailScreen의 상태를 관리할 _PetDetailScreenState를 만들어서 연결해달라는 뜻
    그리고 아래에 class _PetDetailScreenState extends State<PetDetailScreen> { ... } 이게 실제로 상태를 관리하는 부분이 됨
  */
  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  Pet? currentPet;

  List<HealthRecord> healthRecords = [];
  List<HealthRecord> upcomingHealthRecords = [];
  List<HealthRecord> todayHealthRecords = [];

  List<Vaccination> vaccinations = [];
  List<Vaccination> upcomingVaccinations = [];
  List<Vaccination> todayVaccinations = [];

  List<WeightRecord> weightRecords = [];

  List<Medication> medications = [];
  List<Medication> upcomingMedications = [];
  List<Medication> todayMedications = [];

  // Set을 사용하는 이유는 복용 완료한 약의 ID만 중복 없이 가지고 있기 때문
  Set<int> completedMedicationIds = {};

  DateTime selectedDay = DateTimeUtils.todayKst();
  DateTime focusedDay = DateTimeUtils.todayKst();

  // 기록 화면에서 현재 선택한 탭
  // 0 = 전체, 1 = 건강, 2 = 예방접종, 3 = 약, 4 = 체중
  int selectedRecordTab = 0;

  @override
  void initState() {
    super.initState();

    currentPet = widget.pet;

    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      // Future.wait()은 여러 개의 Future 작업을 동시에 실행하고, 모두 끝날 때까지 기다린다
      loadHealthRecords(),
      loadUpcomingHealthRecords(),
      loadTodayHealthRecords(),

      loadVaccinations(),
      loadUpcomingVaccinations(),
      loadTodayVaccinations(),

      loadWeightRecords(),

      loadMedications(),
      loadUpcomingMedications(),
      loadTodayMedications(),
    ]);

    await loadTodayMedicationLogs();
  }

  Future<void> loadHealthRecords() async {
    final records = await DatabaseHelper.instance.getHealthRecordByPetId(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => healthRecords = records);
  }

  Future<void> loadUpcomingHealthRecords() async {
    final upcomings = await DatabaseHelper.instance.getUpcomingHealthRecords(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => upcomingHealthRecords = upcomings);
  }

  Future<void> loadTodayHealthRecords() async {
    final result = await DatabaseHelper.instance.getTodayHealthRecords(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() {
      todayHealthRecords = result;
    });
  }

  Future<void> loadVaccinations() async {
    final vaccines = await DatabaseHelper.instance.getVaccinationsByPetId(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => vaccinations = vaccines);
  }

  Future<void> loadWeightRecords() async {
    final records = await DatabaseHelper.instance.getWeightRecordsByPetId(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => weightRecords = records);
  }

  Future<void> loadUpcomingVaccinations() async {
    final upcomings = await DatabaseHelper.instance.getUpcomingVaccinations(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => upcomingVaccinations = upcomings);
  }

  Future<void> loadTodayVaccinations() async {
    final result = await DatabaseHelper.instance.getTodayVaccinations(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() {
      todayVaccinations = result;
    });
  }

  Future<void> loadMedications() async {
    final datas = await DatabaseHelper.instance.getMedicationsByPetId(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => medications = datas);
  }

  Future<void> loadUpcomingMedications() async {
    final upcomings = await DatabaseHelper.instance.getUpcomingMedications(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => upcomingMedications = upcomings);
  }

  Future<void> loadTodayMedications() async {
    final result = await DatabaseHelper.instance.getTodayMedications(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => todayMedications = result);
  }

  Future<void> loadTodayMedicationLogs() async {
    final completedIds = <int>{};

    for (final medication in todayMedications) {
      if (medication.id == null) continue;

      final isTaken = await DatabaseHelper.instance.isMedicationTakenToday(
        medication.id!,
      );

      if (isTaken) {
        completedIds.add(medication.id!);
      }
    }

    if (!mounted) return;

    setState(() {
      completedMedicationIds = completedIds;
    });
  }

  // 반려동물 삭제
  Future<void> _deletePet(Pet pet) async {
    final bool? confirmed = await showDialog<bool>(
      // bool?을 사용한 이유는 null도 반환될 수 있기 때문
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('반려동물 삭제'),
          content: Text('${pet.name}을(를) 정말 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    // 취소했거나 아무것도 선택하지 않은 경우
    if (confirmed != true) return;

    // SQLite에서 삭제
    await DatabaseHelper.instance.deletePet(pet.id!);

    if (!mounted) return;

    // 상세 화면 닫고 홈 화면으로 이동
    Navigator.pop(context, true);
  }
  /*
  Navigator.push() → 다음 화면으로 이동. 즉, 현재 화면 위에 새로운 화면을 쌓는 것
  Navigator.pop() → 이전 화면으로 돌아가기. 즉, 현재 화면을 제거하고 이전 화면으로 돌아가는 것
  */

  // 공통 삭제 확인 다이얼로그 함수
  Future<bool> showDeleteConfirmDialog({
    required BuildContext context,
    String? title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    return result ??
        false; // 다이얼로그 바깥 영역(배경)을 눌러서 닫은 경우 null이 반환되므로 false 처리. 즉, result가 있으면 result, 없으면 false
  }

  // 현재 선택한 날짜의 전체 기록 찾기
  List<dynamic> _getEventsForDay(DateTime day) {
    // List<dynamic>: 아무 타입이나 들어갈 수 있는 List
    final events = <dynamic>[];

    // 병원 기록
    events.addAll(healthRecords.where((record) => isSameDay(record.date, day)));

    // 예방접종 기록
    events.addAll(
      vaccinations.where(
        (vaccination) => isSameDay(vaccination.vaccinationDate, day),
      ),
    );

    // 체중 기록
    events.addAll(weightRecords.where((record) => isSameDay(record.date, day)));

    // 약 복용 기록
    events.addAll(
      medications.where(
        (medication) => isSameDay(medication.medicationDate, day),
      ),
    );

    return events;
  }

  // 현재 선택한 날짜의 병원 기록 찾기
  List<HealthRecord> _getHealthRecordsForDay(DateTime day) {
    return healthRecords
        .where((record) => isSameDay(record.date, day))
        .toList();
  }

  // 현재 선택한 날짜의 예방접종 기록 찾기
  List<Vaccination> _getVaccinationsForDay(DateTime day) {
    return vaccinations
        .where((vaccination) => isSameDay(vaccination.vaccinationDate, day))
        .toList();
  }

  // 현재 선택한 날짜의 체중 기록 찾기
  List<WeightRecord> _getWeightRecordsForDay(DateTime day) {
    return weightRecords
        .where((record) => isSameDay(record.date, day))
        .toList();
  }

  // 현재 선택한 날짜의 약 복용 기록 찾기
  List<Medication> _getMedicationsForDay(DateTime day) {
    return medications
        .where((medication) => isSameDay(medication.medicationDate, day))
        .toList();
  }

  // 선택한 탭에 해당하는 기록만 가져오기
  List<dynamic> _getFilteredRecordsForSelectedTab(DateTime day) {
    switch (selectedRecordTab) {
      // 전체
      case 0:
        return [
          ..._getHealthRecordsForDay(day),
          ..._getVaccinationsForDay(day),
          ..._getMedicationsForDay(day),
          ..._getWeightRecordsForDay(day),
        ];
      // 건강
      case 1:
        return _getHealthRecordsForDay(day);
      // 예방접종
      case 2:
        return _getVaccinationsForDay(day);
      // 약
      case 3:
        return _getMedicationsForDay(day);
      // 체중
      case 4:
        return _getWeightRecordsForDay(day);
      default:
        return [];
    }
  }

  // 선택한 날짜의 기록 카드 출력
  List<Widget> _buildSelectedRecordCards(DateTime day, Pet pet) {
    final widgets = <Widget>[];

    // 전체, 병원기록
    if (selectedRecordTab == 0 || selectedRecordTab == 1) {
      final records = _getHealthRecordsForDay(day);

      for (final record in records) {
        widgets.add(
          _SelectedRecordCard(
            icon: Icons.local_hospital_outlined,
            iconBgColor: const Color(0xFFE3F2FD),
            iconColor: Colors.blue,
            title: record.title,
            subtitle: [
              if (record.hospital != null && record.hospital!.isNotEmpty)
                record.hospital!,
              if (record.examinationType != null &&
                  record.examinationType!.isNotEmpty)
                // '검사: ${record.examinationType!}',
                record.examinationType!,
              if (record.time != null) record.time!.format(context),
              record.status == 'completed' ? '방문 완료' : '방문 예정',
            ].join(' · '),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthRecordRegisterScreen(
                    petId: pet.id!,
                    record: record,
                  ),
                ),
              );

              if (result != null && mounted) {
                if (result is DateTime) {
                  setState(() {
                    selectedDay = result;
                    focusedDay = result;
                  });
                }

                await loadHealthRecords();
                await loadUpcomingHealthRecords();
                await loadTodayHealthRecords();
              }
            },
            onStatusTap: () async {
              if (record.id == null) return;

              try {
                if (record.status == 'completed') {
                  await DatabaseHelper.instance.cancelHealthRecord(record.id!);
                } else {
                  await DatabaseHelper.instance.completeHealthRecord(
                    record.id!,
                  );
                }

                if (!mounted) return;

                await loadHealthRecords();
                await loadUpcomingHealthRecords();
                await loadTodayHealthRecords();
              } catch (e) {
                debugPrint('병원 방문 상태 변경 실패: $e');

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('진료 상태를 변경하지 못했어요.')),
                );
              }
            },
          ),
        );
      }
    }

    // 전체, 예방접종
    if (selectedRecordTab == 0 || selectedRecordTab == 2) {
      final vaccinations = _getVaccinationsForDay(day);

      for (final vaccination in vaccinations) {
        widgets.add(
          _SelectedRecordCard(
            icon: Icons.vaccines_outlined,
            iconBgColor: const Color(0xFFE8F5E9),
            iconColor: Colors.green,
            title: vaccination.vaccineName,
            subtitle: [
              if (vaccination.hospital != null &&
                  vaccination.hospital!.isNotEmpty)
                vaccination.hospital!,
              vaccination.status == 'completed' ? '접종 완료' : '접종 예정',
            ].join(' · '),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VaccinationRegisterScreen(
                    petId: pet.id!,
                    vaccination: vaccination,
                  ),
                ),
              );

              if (result != null && mounted) {
                if (result is DateTime) {
                  setState(() {
                    selectedDay = result;
                    focusedDay = result;
                  });
                }

                await loadVaccinations();
                await loadUpcomingVaccinations();
                await loadTodayVaccinations();
              }
            },
          ),
        );
      }
    }

    // 전체, 약 복용
    if (selectedRecordTab == 0 || selectedRecordTab == 3) {
      final medications = _getMedicationsForDay(day);

      for (final medication in medications) {
        widgets.add(
          _SelectedRecordCard(
            icon: Icons.medication_outlined,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: Colors.orange,
            title: medication.medicationName,
            subtitle:
                medication.medicationTime?.format(context) ??
                '', // ?.는 null이면 뒤의 함수를 실행하지 말라는 의미 / ??는 왼쪽 값이 null이면 오른쪽 값을 사용한다는 뜻
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicationRegisterScreen(
                    petId: pet.id!,
                    medication: medication,
                  ),
                ),
              );

              if (result != null && mounted) {
                if (result is DateTime) {
                  setState(() {
                    selectedDay = result;
                    focusedDay = result;
                  });
                }

                await loadMedications();
                await loadUpcomingMedications();
                await loadTodayMedications();
              }
            },
          ),
        );
      }
    }

    // 전체, 체중
    if (selectedRecordTab == 0 || selectedRecordTab == 4) {
      final records = _getWeightRecordsForDay(day);

      for (final record in records) {
        widgets.add(
          _SelectedRecordCard(
            icon: Icons.monitor_weight_outlined,
            iconBgColor: const Color(0xFFF3E5F5),
            iconColor: Colors.purple,
            title: '${record.weight} kg',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeightRecordRegisterScreen(
                    petId: pet.id!,
                    record: record,
                  ),
                ),
              );

              if (result != null && mounted) {
                if (result is DateTime) {
                  setState(() {
                    selectedDay = result;
                    focusedDay = result;
                  });
                }

                await loadWeightRecords();
              }
            },
          ),
        );
      }

      // 체중 변화 그래프 버튼
      if (selectedRecordTab == 4 && weightRecords.length >= 2) {
        widgets.add(
          Container(
            // margin: const EdgeInsets.only(top: 2),
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _showWeightChart,
              icon: const Icon(Icons.monitor_weight_outlined, size: 16),
              label: const Text(
                '체중 변화 그래프',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // 체중 변화 그래프 보기
  void _showWeightChart() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 내부 컨텐츠 크기만큼 유연하게 조절
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 위쪽 손잡이 (Handle Bar)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. 상단 헤더 영역 (제목 & 서브텍스트)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Icon(
                          //   Icons.show_chart,
                          //   size: 18,
                          //   color: Theme.of(context).primaryColor,
                          // ),
                          // const SizedBox(width: 6),
                          const Text(
                            '📈 체중 변화 그래프',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '총 ${weightRecords.length}개 기록',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 3. 차트를 감싸는 깔끔한 메인 카드
                  Card(
                    elevation: 0,
                    // color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 차트 위젯 배치
                        WeightChart(records: weightRecords),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 기록 추가 버튼 바텀 시트
  /*
  void _showAddRecordBottomSheet() {} 여기의 context는 상세화면의 context
  builder: (context) {} 여기의 context는 바텀시트의 context
  */
  void _showAddRecordBottomSheet() {
    final petId = currentPet!.id!;
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  '기록 추가',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(
                      Icons.local_hospital_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text('건강'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () async {
                    Navigator.pop(context); // 바텀시트 닫기
                    // 여기서 바로 Navigator.push()를 하면 바텀시트 위에 등록 화면이 쌓이는 구조가 됨.

                    final result = await Navigator.push(
                      // 상세화면에서 등록화면 열기
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) =>
                            HealthRecordRegisterScreen(petId: petId),
                      ),
                    );

                    if (result is DateTime) {
                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        selectedDay = result;
                        focusedDay = result;
                      });

                      await loadHealthRecords();
                      await loadUpcomingHealthRecords();
                      await loadTodayHealthRecords();
                    }
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.vaccines_outlined, color: Colors.green),
                  ),
                  title: const Text('예방접종'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () async {
                    Navigator.pop(context);

                    final result = await Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) =>
                            VaccinationRegisterScreen(petId: petId),
                      ),
                    );

                    if (result is DateTime) {
                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        selectedDay = result;
                        focusedDay = result;
                      });

                      await loadVaccinations();
                      await loadUpcomingVaccinations();
                      await loadTodayVaccinations();
                    }
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(
                      Icons.medication_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text('약'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () async {
                    Navigator.pop(context);

                    final result = await Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicationRegisterScreen(petId: petId),
                      ),
                    );

                    if (result is DateTime) {
                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        selectedDay = result;
                        focusedDay = result;
                      });

                      await loadMedications();
                      await loadUpcomingMedications();
                      await loadTodayMedications();
                    }
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF3E5F5),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      color: Colors.purple,
                    ),
                  ),
                  title: const Text('체중'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () async {
                    Navigator.pop(context);

                    final result = await Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) =>
                            WeightRecordRegisterScreen(petId: petId),
                      ),
                    );

                    // if (result == true) await loadWeightRecords();

                    if (result is DateTime) {
                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        selectedDay = result;
                        focusedDay = result;
                      });

                      await loadWeightRecords();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 기록 종류 선택 탭
  Widget _buildRecordTabs() {
    final primaryColor = Theme.of(context).primaryColor;

    const tabs = ['전체', '건강', '예방접종', '약', '체중'];

    return SizedBox(
      height: 38,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedRecordTab == index;

          return Expanded(
            child: GestureDetector(
              // GestureDetector: 탭을 터치할 수 있게 만드는 부분
              behavior: HitTestBehavior.opaque, // 텍스트 주변 여백을 터치해도 반응
              onTap: () {
                setState(() {
                  selectedRecordTab = index;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // 탭 안의 내용을 세로 방향으로 배치
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        tabs[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? primaryColor : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 200,
                    ), // 값이 변경될 때 200ms 동안 애니메이션 효과
                    curve: Curves.easeOut,
                    width: isSelected ? 28 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getEmptyRecordMessage() {
    switch (selectedRecordTab) {
      case 0:
        return '이 날짜에 등록된 기록이 없습니다.';
      case 1:
        return '이 날짜에 등록된 건강 기록이 없습니다.';
      case 2:
        return '이 날짜에 등록된 예방접종 기록이 없습니다.';
      case 3:
        return '이 날짜에 등록된 약 복용 기록이 없습니다.';
      case 4:
        return '이 날짜에 등록된 체중 기록이 없습니다.';
      default:
        return '이 날짜에 등록된 기록이 없습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // build()는 _PetDetailScreenState 안에 존재. State에서 부모 StatefulWidget의 값을 가져오려면 ~ 으로r 써야함. 즉 pet -> pet 작성해야 됨
    final pet = currentPet!;

    final filteredRecords = _getFilteredRecordsForSelectedTab(selectedDay);

    return Scaffold(
      // backgroundColor: Colors.green[10],
      appBar: AppBar(
        title: Text(
          '${pet.name} 프로필',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0, // 위젯에 주는 그림자(입체감)를 없애는 설정
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetRegisterScreen(pet: pet),
                ),
              );

              // Navigator.pop(context, true) 이걸로 true를 넘겼기 때문에, 정상적으로 수정이 됐으면 진행됨
              if (result == true) {
                final updatedPet = await DatabaseHelper.instance.getPetById(
                  pet.id!,
                ); // pet.id!의 !은 DB에서 생성된 반려동물 ID는 반드시 존재한다는 의미

                if (!context.mounted) return;

                if (updatedPet != null) {
                  setState(() => currentPet = updatedPet);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _deletePet(pet),
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        // physics: 스크롤의 물리 효과 설정. BouncingScrollPhysics(): 스크롤을 끝까지 밀었을 대 살짝 튕기는 효과 / ClampingScrollPhysics(): 튕기지 않고 멈추는 느낌
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 반려동물 정보 (프로필 헤더)
              PetProfileHeader(pet: pet),

              const SizedBox(height: 16),

              // 2. 오늘 해야 할 일
              TodayHealthTasks(
                petId: pet.id!,
                healthRecords: todayHealthRecords,
                vaccinations: todayVaccinations,
                medications: todayMedications,
                completedMedicationIds: completedMedicationIds,
                onDataChanged: () async {
                  await loadHealthRecords();
                  await loadUpcomingHealthRecords();
                  await loadTodayHealthRecords();

                  await loadVaccinations();
                  await loadUpcomingVaccinations();
                  await loadTodayVaccinations();

                  await loadMedications();
                  await loadUpcomingMedications();
                  await loadTodayMedications();

                  await loadTodayMedicationLogs();
                },
              ),

              const SizedBox(height: 4),

              // 3. 예정 알림
              UpcomingHealthTasks(
                healthRecords: upcomingHealthRecords,
                vaccinations: upcomingVaccinations,
                medications: upcomingMedications,

                onHealthRecordTap: (record) async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HealthRecordRegisterScreen(
                        petId: pet.id!,
                        record: record,
                      ),
                    ),
                  );

                  if (result != null && mounted) {
                    if (result is DateTime) {
                      setState(() {
                        selectedDay = result;
                        focusedDay = result;
                      });
                    }

                    await loadHealthRecords();
                    await loadUpcomingHealthRecords();
                    await loadTodayHealthRecords();
                  }
                },

                onVaccinationTap: (vaccination) async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VaccinationRegisterScreen(
                        petId: pet.id!,
                        vaccination: vaccination,
                      ),
                    ),
                  );

                  if (result != null && mounted) {
                    if (result is DateTime) {
                      setState(() {
                        selectedDay = result;
                        focusedDay = result;
                      });
                    }

                    await loadVaccinations();
                    await loadUpcomingVaccinations();
                    await loadTodayVaccinations();
                  }
                },

                onMedicationTap: (medication) async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicationRegisterScreen(
                        petId: pet.id!,
                        medication: medication,
                      ),
                    ),
                  );

                  if (result != null && mounted) {
                    if (result is DateTime) {
                      setState(() {
                        selectedDay = result;
                        focusedDay = result;
                      });
                    }

                    await loadMedications();
                    await loadUpcomingMedications();
                    await loadTodayMedications();
                  }
                },
              ),

              // 4. 건강 기록 카드 (+캘린더)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 건강 기록 제목 + 기록 추가 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 8,
                              top: 4,
                              bottom: 8,
                            ),
                            child: Text(
                              '🗓️ 건강 기록',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: _showAddRecordBottomSheet,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('기록 추가'),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 캘린더
                      TableCalendar(
                        focusedDay: focusedDay,
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2100),
                        rowHeight: 48, // // 캘린더 전체 비율 및 높이 조절
                        headerStyle: HeaderStyle(
                          formatButtonVisible:
                              false, // 달력 헤더에 있는 Format 버튼을 숨기기
                          titleCentered: true,
                          titleTextFormatter: (date, locale) =>
                              '${date.year}년 ${date.month}월',
                          titleTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          // 오늘 날짜의 "배경/모양"
                          todayDecoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          // 오늘 날짜의 "글자"
                          todayTextStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        eventLoader: _getEventsForDay, // 리스트가 반환되면 점 표시
                        selectedDayPredicate: (day) {
                          // selectedDayPredicate: 이 날짜가 현재 선택된 날짜인가 알려주는 부분
                          return isSameDay(selectedDay, day);
                        },
                        onDaySelected: (selected, focused) {
                          setState(() {
                            selectedDay = selected;
                            focusedDay = focused;
                          });
                        },
                        calendarFormat: CalendarFormat.month,
                      ),

                      // 캘린더와 기록 영역 구분
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Divider(height: 24, color: Colors.grey.shade200),
                      ),

                      // 선택한 날짜 기록
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          4,
                          0,
                          4,
                          4,
                        ), // L → T → R → B
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 기록 탭
                            _buildRecordTabs(),

                            const SizedBox(height: 12),

                            // 선택된 탭의 기록
                            if (filteredRecords.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 28,
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      '아직 기록이 없어요.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      _getEmptyRecordMessage(),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ..._buildSelectedRecordCards(selectedDay, pet),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 선택한 날짜 자료
class _SelectedRecordCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;

  const _SelectedRecordCard({
    required this.icon,
    this.iconBgColor = const Color(0xFFF5F5F5),
    this.iconColor = Colors.black87,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
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
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),

              const SizedBox(width: 12),

              // 기록 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),

                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 이동 아이콘
              if (onTap != null)
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
