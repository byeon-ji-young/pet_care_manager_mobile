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

import 'pet_register_screen.dart';
import 'health_record_register_screen.dart';
import 'vaccination_register_screen.dart';
import 'weight_record_register_screen.dart';
import 'medication_register_screen.dart';

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

  List<Vaccination> vaccinations = [];
  List<Vaccination> upcomingVaccinations = [];

  List<WeightRecord> weightRecords = [];

  List<Medication> medications = [];
  List<Medication> upcomingMedications = [];

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

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
      loadVaccinations(),
      loadUpcomingVaccinations(),
      loadWeightRecords(),
      loadMedications(),
      loadUpcomingMedications(),
    ]);
  }

  Future<void> loadHealthRecords() async {
    final records = await DatabaseHelper.instance.getHealthRecordByPetId(
      widget.pet.id!,
    );

    if (!mounted) return;

    setState(() => healthRecords = records);
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

  // 예방접종, 약 복용 알림 카드 위젯
  Widget _buildBannerItem({
    required String title,
    required DateTime targetDate,
    required String categoryType, // 'vaccine' 또는 'medication'
  }) {
    final today = DateTime.now();
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
      message = categoryType == 'vaccine'
          ? '오늘은 $title 예방접종 날이에요!'
          : '오늘은 $title 복용일이에요!';
    } else if (difference > 0) {
      textColor = primaryColor.withValues(alpha: 0.9);
      iconData = Icons.event_available_rounded;
      message = categoryType == 'vaccine'
          ? '$title 예방접종까지 $difference일 남았어요.'
          : '$title 복용까지 $difference일 남았어요.';
    } else {
      textColor = Colors.red.shade900;
      iconData = Icons.warning_amber_rounded;
      message = categoryType == 'vaccine'
          ? '$title 예방접종 예정일이 ${difference.abs()}일 지났어요!'
          : '$title 복용 예정일이 ${difference.abs()}일 지났어요!';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
        ],
      ),
    );
  }

  // 예방 접종 알림 카드 그룹화
  Widget _buildVaccinationGroupCard(List<Vaccination> list) {
    final items = list.take(2).toList();

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
                title: item.vaccineName,
                targetDate: item.nextDate!,
                categoryType: 'vaccine',
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
  Widget _buildMedicationGroupCard(List<Medication> list) {
    final items = list.take(2).toList();

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
                title: item.medicationName,
                targetDate: item.nextDate!,
                categoryType: 'medication',
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
                  title: const Text('병원기록'),
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
                  title: const Text('체중기록'),
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

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(
                      Icons.medication_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text('약 복용'),
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

  @override
  Widget build(BuildContext context) {
    // build()는 _PetDetailScreenState 안에 존재. State에서 부모 StatefulWidget의 값을 가져오려면 ~ 으로r 써야함. 즉 pet -> pet 작성해야 됨
    final pet = currentPet!;

    final selectedHealthRecords = _getHealthRecordsForDay(selectedDay);
    final selectedVaccinations = _getVaccinationsForDay(selectedDay);
    final selectedWeightRecords = _getWeightRecordsForDay(selectedDay);
    final selectedMedications = _getMedicationsForDay(selectedDay);

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

                Navigator.pop(context, true);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 반려동물 정보 (프로필 헤더)
              PetProfileHeader(pet: pet),

              const SizedBox(height: 16),

              // 2-1. 예방 접종 알림
              if (upcomingVaccinations.isNotEmpty)
                _buildVaccinationGroupCard(upcomingVaccinations),

              // 2-2. 약 복용 알림
              if (upcomingMedications.isNotEmpty)
                _buildMedicationGroupCard(upcomingMedications),

              // 3. 캘린더 카드
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
                      const Padding(
                        padding: EdgeInsets.only(left: 8, top: 4, bottom: 8),
                        child: Text(
                          '🗓️ 건강 기록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      TableCalendar(
                        focusedDay: focusedDay,
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2100),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible:
                              false, // 달력 헤더에 있는 Format 버튼을 숨기기
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: const BoxDecoration(
                            // 오늘 날짜의 "배경/모양"
                            color: Colors
                                .transparent, // transparent: 투명한 색. 즉, 배경을 없애는 것
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(
                            // 오늘 날짜의 "글자"
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. 선택한 날짜 기록 상세 카드
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedDay.year}.'
                            '${selectedDay.month.toString().padLeft(2, '0')}.'
                            '${selectedDay.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddRecordBottomSheet,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('기록 추가'),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (selectedHealthRecords.isEmpty &&
                          selectedVaccinations.isEmpty &&
                          selectedWeightRecords.isEmpty &&
                          selectedMedications.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            // color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                '선택한 날짜에 등록된 기록이 없습니다.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // 병원 기록
                        ...selectedHealthRecords.map((record) {
                          return _SelectedRecordCard(
                            icon: Icons.local_hospital_outlined,
                            iconBgColor: const Color(0xFFE3F2FD),
                            iconColor: Colors.blue,
                            title: record.title,
                            subtitle: record.hospital,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HealthRecordRegisterScreen(
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
                              }
                            },
                          );
                        }),
                        // 예방접종 기록
                        ...selectedVaccinations.map((vaccination) {
                          return _SelectedRecordCard(
                            icon: Icons.vaccines_outlined,
                            iconBgColor: const Color(0xFFE8F5E9),
                            iconColor: Colors.green,
                            title: vaccination.vaccineName,
                            subtitle: vaccination.hospital,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VaccinationRegisterScreen(
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
                              }
                            },
                          );
                        }),
                        // 체중 기록
                        ...selectedWeightRecords.map((record) {
                          return _SelectedRecordCard(
                            icon: Icons.monitor_weight_outlined,
                            iconBgColor: const Color(0xFFF3E5F5),
                            iconColor: Colors.purple,
                            title: '${record.weight} kg',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WeightRecordRegisterScreen(
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
                          );
                        }),
                        // 약 복용 기록
                        ...selectedMedications.map((medication) {
                          return _SelectedRecordCard(
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
                                  builder: (context) =>
                                      MedicationRegisterScreen(
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
                              }
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5. 체중 변화 그래프 섹션
              /*
              위젯 하나 넣기
              children: [
                Text('A'),
              ]

              위젯 여러 개 넣기
              children: [
                Text('A'),
                Text('B'),
                Text('C'),
              ]

              조건이 맞을 때 위젯 여러 개 넣기
              children: [
                if (조건) ...[
                  Text('A'),
                  Text('B'),
                  Text('C'),
                ],
              ]
              */
              if (weightRecords.length >= 2) ...[
                // ...은 Spread Operator(스프레드 연산자). 즉, 이 리스트 안에 들어있는 위젯들을 하나씩 꺼내서 children에 넣어달라는 말
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsGeometry.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📈 체중 변화 그래프',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        WeightChart(records: weightRecords),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
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

  const _SelectedRecordCard({
    required this.icon,
    this.iconBgColor = const Color(0xFFF5F5F5),
    this.iconColor = Colors.black87,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        // leading: Container(
        //   width: 40,
        //   height: 40,
        //   decoration: BoxDecoration(
        //     color: iconBgColor,
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Icon(icon, color: iconColor, size: 22),
        // ),
        leading: CircleAvatar(
          backgroundColor: iconBgColor,
          child: Icon(icon, color: iconColor, size: 22),
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),

        subtitle: subtitle != null && subtitle!.isNotEmpty
            ? Text(
                subtitle!,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              )
            : null,

        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey, size: 20)
            : null,
      ),
    );
  }
}
