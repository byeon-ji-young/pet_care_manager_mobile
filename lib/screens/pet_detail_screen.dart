import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/pet.dart';
import '../models/health_record.dart';
import '../models/vaccination.dart';
import '../models/weight_record.dart';

import '../database/database_helper.dart';

import '../widgets/weight_chart.dart';
import '../widgets/pet_profile_header.dart';

import 'pet_register_screen.dart';
import 'health_record_register_screen.dart';
import 'vaccination_register_screen.dart';
import 'weight_record_register_screen.dart';

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

  List<WeightRecord> weightRecords = [];

  List<Vaccination> upcomingVaccinations = [];

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    currentPet = widget.pet;

    loadHealthRecords();

    loadVaccinations();

    loadWeightRecords();

    loadUpcomingVaccinations();
  }

  Future<void> loadHealthRecords() async {
    final records = await DatabaseHelper.instance.getHealthRecordByPetId(
      widget.pet.id!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      healthRecords = records;
    });
  }

  Future<void> loadVaccinations() async {
    final vaccines = await DatabaseHelper.instance.getVaccinationsByPetId(
      widget.pet.id!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      vaccinations = vaccines;
    });
  }

  Future<void> loadWeightRecords() async {
    final records = await DatabaseHelper.instance.getWeightRecordsByPetId(
      widget.pet.id!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      weightRecords = records;
    });
  }

  Future<void> loadUpcomingVaccinations() async {
    final upcomings = await DatabaseHelper.instance.getUpcomingVaccinations(
      widget.pet.id!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      upcomingVaccinations = upcomings;
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
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    // 취소했거나 아무것도 선택하지 않은 경우
    if (confirmed != true) {
      return;
    }

    // SQLite에서 삭제
    await DatabaseHelper.instance.deletePet(pet.id!);

    if (!mounted) {
      return;
    }

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

  // 예방 접종 알림 메세지 출력
  Widget _buildVaccinationMessage(Vaccination vaccination) {
    final nextDate = vaccination.nextDate!;

    final today = DateTime.now();
    final todatDate = DateTime(today.year, today.month, today.day);
    final targetDate = DateTime(nextDate.year, nextDate.month, nextDate.day);

    final difference = targetDate.difference(todatDate).inDays;

    if (difference == 0) {
      return const Text(
        '🔔 오늘은 예방접종 예정일이에요!',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );
    } else if (difference > 0) {
      return Text(
        '💉 ${vaccination.vaccineName} 예방접종까지 $difference일 남았어요.',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.blueGrey[600],
        ),
      );
    }

    return Text(
      '⚠️ ${vaccination.vaccineName} 예방접종 예정일이 ${difference.abs()}일 지났어요.', // abs()는 absolute value(절댓값)를 구하는 함수
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.redAccent,
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

  @override
  Widget build(BuildContext context) {
    // build()는 _PetDetailScreenState 안에 존재. State에서 부모 StatefulWidget의 값을 가져오려면 ~ 으로r 써야함. 즉 pet -> pet 작성해야 됨
    final pet = currentPet!;

    final selectedHealthRecords = _getHealthRecordsForDay(selectedDay);
    final selectedVaccinations = _getVaccinationsForDay(selectedDay);
    final selectedWeightRecords = _getWeightRecordsForDay(selectedDay);

    return Scaffold(
      // backgroundColor: Colors.green[10],
      appBar: AppBar(
        title: Text(
          '${pet.name} 프로필',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0, // 위젯에 주는 그림자(입체감)를 없애는 설정
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

                if (!context.mounted) {
                  return;
                }

                if (updatedPet != null) {
                  setState(() {
                    currentPet = updatedPet;
                  });
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 반려동물 정보
              PetProfileHeader(pet: pet),

              const SizedBox(height: 12),

              // 1-1. 건강 기록 캘린더
              Text(
                '🗓️ 건강 기록',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TableCalendar(
                focusedDay: focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
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
                availableCalendarFormats: const {CalendarFormat.month: '월'},
              ),

              const SizedBox(height: 20),

              // 1-2. 캘린더에 선택한 날짜 기록 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selectedDay.year}.'
                    '${selectedDay.month.toString().padLeft(2, '0')}.'
                    '${selectedDay.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '선택한 날짜의 건강 기록이에요.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 14),

                  if (selectedHealthRecords.isEmpty &&
                      selectedVaccinations.isEmpty &&
                      selectedWeightRecords.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
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
                            '이날은 기록이 없어요.',
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
                        title: record.title,
                        subtitle: record.hospital,
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

                          if (result == true) {
                            await loadHealthRecords();
                          }
                        },
                      );
                    }),
                    // 예방접종 기록
                    ...selectedVaccinations.map((vaccination) {
                      return _SelectedRecordCard(
                        icon: Icons.vaccines_outlined,
                        title: vaccination.vaccineName,
                        subtitle: vaccination.hospital,
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

                          if (result == true) {
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

                          if (result == true) {
                            await loadWeightRecords();
                          }
                        },
                      );
                    }),
                  ],
                ],
              ),

              // 1-3. 예방 접종 알림
              if (upcomingVaccinations.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: upcomingVaccinations.take(3).map((map) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildVaccinationMessage(map),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
              ],

              // 2. 병원 기록 섹션
              _SectionHeader(
                title: '🏥 병원 기록',
                onAddPressed: () async {
                  final result = await Navigator.push(
                    // Navigator는 Flutter에서 화면 이동을 관리하는 역할. push는 새로운 화면을 위에 추가
                    context, // context는 Flutter의 현재 위젯이 어디에 위치하고 있는지 알려주는 정보
                    MaterialPageRoute(
                      // MaterialPageRoute: 어떤 방식으로 새로운 화면을 띄울지 정의하는 것
                      builder: (context) => HealthRecordRegisterScreen(
                        // builder는 실제로 이동할 화면을 만들어주는 부분
                        petId: pet.id!,
                      ),
                    ),
                  );

                  if (result == true) {
                    await loadHealthRecords();
                  }
                },
              ),

              const SizedBox(height: 8),

              if (healthRecords
                  .isEmpty) // Flutter의 children: [] 안에서 {}를 사용하면 안됨. {}를 Dart가 Set으로 해석하기 때문에 에러남
                const _EmptyStateText(text: '등록된 병원 기록이 없습니다.')
              else
                Column(
                  children: healthRecords.map((record) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: ListTile(
                          title: Text(
                            record.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${record.date.year}.${record.date.month.toString().padLeft(2, '0')}.${record.date.day.toString().padLeft(2, '0')}'
                            '${record.hospital != null ? '\n${record.hospital}' : ''}',
                          ),
                          // trailing: record.cost != null ? Text('${record.cost}원') : null, // trailing: ListTile의 오른쪽에 표시할 내용을 지정
                          trailing: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Row나 Column이 주축(main axis) 방향으로 얼마나 공간을 차지할지 정하는 옵션. 즉, mainAxis 방향으로 필요한 만큼만 공간을 차지하겠다는 뜻
                            children: [
                              if (record.cost != null)
                                Padding(
                                  padding: const EdgeInsetsGeometry.only(
                                    right: 8,
                                  ),
                                  child: Text(
                                    '${record.cost}원',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () async {
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

                                  if (result == true) {
                                    await loadHealthRecords();
                                  }
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final confirmed =
                                      await showDeleteConfirmDialog(
                                        context: context,
                                        // title: '병원 기록 삭제',
                                        content:
                                            '${record.title} 기록을 삭제하시겠습니까?',
                                      );

                                  if (confirmed != true) {
                                    return;
                                  }

                                  await DatabaseHelper.instance
                                      .deleteHealthRecord(record.id!);
                                  await loadHealthRecords();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 30),

              // 3. 예방접종 섹션
              _SectionHeader(
                title: '💉 예방접종',
                onAddPressed: () async {
                  final result = await Navigator.push(
                    // Navigator는 Flutter에서 화면 이동을 관리하는 역할. push는 새로운 화면을 위에 추가
                    context, // context는 Flutter의 현재 위젯이 어디에 위치하고 있는지 알려주는 정보
                    MaterialPageRoute(
                      // MaterialPageRoute: 어떤 방식으로 새로운 화면을 띄울지 정의하는 것
                      builder: (context) => VaccinationRegisterScreen(
                        // builder는 실제로 이동할 화면을 만들어주는 부분
                        petId: pet.id!,
                      ),
                    ),
                  );

                  if (result == true) {
                    await loadVaccinations();
                    await loadUpcomingVaccinations();
                  }
                },
              ),

              const SizedBox(height: 8),

              if (vaccinations
                  .isEmpty) // Flutter의 children: [] 안에서 {}를 사용하면 안됨. {}를 Dart가 Set으로 해석하기 때문에 에러남
                const _EmptyStateText(text: '등록된 예방접종 기록이 없습니다.')
              else
                Column(
                  children: vaccinations.map((vaccination) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: ListTile(
                          title: Text(
                            vaccination.vaccineName,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '접종일: '
                            '${vaccination.vaccinationDate.year}.'
                            '${vaccination.vaccinationDate.month.toString().padLeft(2, '0')}.'
                            '${vaccination.vaccinationDate.day.toString().padLeft(2, '0')}'
                            '${vaccination.nextDate != null ? '\n다음 접종: ${vaccination.nextDate!.year}.${vaccination.nextDate!.month.toString().padLeft(2, '0')}.${vaccination.nextDate!.day.toString().padLeft(2, '0')}' : ''}'
                            '${vaccination.hospital != null ? '\n${vaccination.hospital}' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Row나 Column이 주축(main axis) 방향으로 필요한 만큼만 공간 차지
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () async {
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

                                  if (result == true) {
                                    await loadVaccinations();
                                    await loadUpcomingVaccinations();
                                  }
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final confirmed = await showDeleteConfirmDialog(
                                    context: context,
                                    // title: '예방 접종 삭제',
                                    content:
                                        '${vaccination.vaccineName} 기록을 삭제하시겠습니까?',
                                  );

                                  if (confirmed != true) {
                                    return;
                                  }

                                  await DatabaseHelper.instance
                                      .deleteVaccination(vaccination.id!);
                                  await loadVaccinations();
                                  await loadUpcomingVaccinations();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 30),

              // 4. 체중 기록 섹션
              _SectionHeader(
                title: '⚖️ 체중 기록',
                onAddPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WeightRecordRegisterScreen(petId: pet.id!),
                    ),
                  );

                  if (result == true) {
                    await loadWeightRecords();
                  }
                },
              ),

              const SizedBox(height: 8),

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

              if (weightRecords.isEmpty)
                const _EmptyStateText(text: '등록된 체중 기록이 없습니다.')
              else
                Column(
                  children: weightRecords.map((record) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: ListTile(
                          title: Text(
                            '${record.weight} kg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${record.date.year}.${record.date.month.toString().padLeft(2, '0')}.${record.date.day.toString().padLeft(2, '0')}',
                            // '${record.memo != null ? '\n${record.memo}' : ''}'
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () async {
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

                                  if (result == true) {
                                    loadWeightRecords();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final confirmed =
                                      await showDeleteConfirmDialog(
                                        context: context,
                                        // title: '체중 기록 삭제',
                                        content:
                                            '${record.weight} kg 기록을 삭제하시겠습니까?',
                                      );

                                  if (confirmed != true) {
                                    return;
                                  }

                                  await DatabaseHelper.instance
                                      .deleteWeightRecord(record.id!);
                                  await loadWeightRecords();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 섹션 헤더 (제목 + 추가 버튼 우측 배치)
class _SectionHeader extends StatelessWidget {
  // StatelessWidget: 화면에 그려질 수 있는 위젯의 자격을 부여하기 위해 상속받음
  final String title;
  final VoidCallback onAddPressed;

  const _SectionHeader({required this.title, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      // Row (가로 배치). 안에 들어가는 항목들을 일렬 배치함
      mainAxisAlignment: MainAxisAlignment
          .spaceBetween, // Row나 Column 안의 자식들을 양 끝으로 벌려서 배치하는 설정
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('추가'),
        ),
      ],
    );
  }
}
/*
클래스 방식: _SectionHeader는 독립적인 위젯으로 인식되어, 상태(State) 변경 시 플러터 엔진이 변경된 부분만 효율적으로 다시 그릴(Rebuild) 수 있음
일반 함수 방식: 부모 위젯(PetDetailScreen)의 화면이 조금이라도 다시 그려질 때 함수가 매번 새로 실행되어 불필요하게 UI를 계속 다시 생성
*/

// 빈 데이터 텍스트 스타일
class _EmptyStateText extends StatelessWidget {
  final String text;

  const _EmptyStateText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding: const EdgeInsetsGeometry.symmetric(horizontal: 4, vertical: 5),
      padding: const EdgeInsetsGeometry.only(top: 5),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[500], fontSize: 14),
      ),
    );
  }
}

class _SelectedRecordCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SelectedRecordCard({
    required this.icon,
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
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22),
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),

        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsetsGeometry.only(top: 3),
                child: Text(
                  subtitle!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              )
            : null,

        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
      ),
    );
  }
}
