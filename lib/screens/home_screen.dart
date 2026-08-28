import 'dart:io';

import 'package:flutter/material.dart'; // 플루터 제공 디자인 라이브러리
import 'package:pet_care_manager_mobile/models/medication.dart';

import 'pet_register_screen.dart';
import 'pet_detail_screen.dart';

import '../database/database_helper.dart';

import '../models/pet.dart';
import '../models/vaccination.dart';

import '../utils/date_time_utils.dart';

class HomeScreen extends StatefulWidget {
  // StatelessWidget: 사용자에 동작에 의해 화면 자체의 데이터(상태)가 바로 바뀌지 않는 정적인 화면을 의미
  const HomeScreen({super.key}); // 플러터가 위젯을 효율적으로 관리할 수 있도록 돕는 생성자 선언

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> pets = [];

  Map<int, List<Vaccination>> todayVaccinations = {};
  Map<int, List<Medication>> todayMedications = {};
  Map<int, Set<int>> completedMedicationIds = {};

  @override
  void initState() {
    super.initState();

    loadPets();
  }

  // 반려동물 조회
  Future<void> loadPets() async {
    final loadedPets = await DatabaseHelper.instance.getPets();

    final Map<int, List<Vaccination>> loadedTodayVaccinations = {};
    final Map<int, List<Medication>> loadedTodayMedications = {};
    final Map<int, Set<int>> loadedCompletedMedicationIds = {};

    for (final pet in loadedPets) {
      final todayVaccinations = await DatabaseHelper.instance
          .getTodayVaccinations(pet.id!);

      loadedTodayVaccinations[pet.id!] = todayVaccinations;

      final todayMedications = await DatabaseHelper.instance
          .getTodayMedications(pet.id!);

      loadedTodayMedications[pet.id!] = todayMedications;

      final completedIds = <int>{};

      for (final medication in todayMedications) {
        if (medication.id == null) {
          continue;
        }

        final isTaken = await DatabaseHelper.instance.isMedicationTakenToday(
          medication.id!,
        );

        if (isTaken) {
          completedIds.add(medication.id!);
        }
      }

      loadedCompletedMedicationIds[pet.id!] = completedIds;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      pets = loadedPets;
      todayVaccinations = loadedTodayVaccinations;
      todayMedications = loadedTodayMedications;
      completedMedicationIds = loadedCompletedMedicationIds;
    });
  }

  /* 
    화면의 기본 뼈대 구축 (Scaffold & AppBar)

    build: 화면에 무엇을 그릴지 정의하는 메서드
    Scaffold: 앱 화면의 기본 레이아웃 뼈대 (상단바, 배경색, 바텀시트 등을 담는 도화지 역할)
    AppBar: 앱 상단 타이틀 바에 'PetCareManager'라는 글자 표시
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('🐾 PetCareManager'),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Row(
              children: [
                Icon(Icons.pets),
                SizedBox(width: 6),
                Text(
                  '펫몽',
                  /*
                    // 개별 텍스트에 구글폰트 적용시키는 방법 *
                    style: GoogleFonts.jua( 
                      fontWeight: FontWeight.bold
                    ),
                */
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 5),

            Text(
              '우리 아이의 건강을 기록해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: false, // 타이틀 좌측 정렬 유지
      ),

      body: pets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 80),

                  const SizedBox(height: 20),

                  const Text(
                    '등록된 반려동물이 없어요.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '우리 아이를 등록해 주세요.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 30),

                  /*
                    화면 이동 버튼 (ElevatedButton.icon & Navigator)
                    - ElevatedButton은 Flutter에서 사용하는 기본 버튼 위젯

                    ElevatedButton.icon: 입체감이 있는 버튼에 아이콘(+)과 글자(반려동물 등록)를 같이 넣어 생성
                    onPressed: () { ... }: 버튼을 눌렀을 때 실행될 동작 정의
                    Navigator.push(...): 새로운 화면을 스택처럼 위에 쌓아서 띄워주는 플러터의 화면 이동 방식
                    MaterialPageRoute: 안드로이드/iOS 스타일의 부드러운 화면 전환 애니메이션 효과를 부여하며 PetRegisterScreen 화면으로 넘어감
                  */
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        // 등록 화면에서 돌아오면 이미 loadPets()를 호출
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PetRegisterScreen(),
                        ),
                      );

                      loadPets();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('반려동물 등록'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ), // 리스트 전체 여백 추가
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12, top: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetailScreen(pet: pet),
                        ),
                      );

                      loadPets();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 반려동물 프로필 + 우측 상단 이동 아이콘
                          Stack(
                            children: [
                              // 반려동물 프로필 카드
                              _PetHomeProfileHeader(pet: pet),

                              const Positioned(
                                top: 0,
                                right: 0,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '오늘의 건강 관리',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          ..._buildTodayHealthTasks(pet),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: // FloatingActionButton: 화면 위에 둥둥 떠있는 버튼
      pets.isNotEmpty
          ? FloatingActionButton(
              // elevation: 0,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetRegisterScreen(),
                  ),
                );

                loadPets();
              },
              child: Icon(Icons.add, color: Theme.of(context).primaryColor),
            )
          : null,
    );
  }

  List<Widget> _buildTodayHealthTasks(Pet pet) {
    final vaccinations = todayVaccinations[pet.id] ?? [];
    final medications = todayMedications[pet.id] ?? [];

    if (vaccinations.isEmpty && medications.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '🐾 오늘 예정된 건강 관리가 없어요.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ];
    }

    return [
      ...medications.map(
        (medication) => _buildTodayMedicationItem(pet, medication),
      ),
      ...vaccinations.map(
        (vaccination) => _buildTodayVaccinationItem(vaccination),
      ),
    ];
  }

  Widget _buildTodayMedicationItem(Pet pet, Medication medication) {
    final isCompleted =
        medication.id != null &&
        (completedMedicationIds[pet.id] ?? {}).contains(medication.id);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('💊', style: TextStyle(fontSize: 17)),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              medication.medicationTime != null
                  ? '${medication.medicationTime!.format(context)} ${medication.medicationName}'
                  : medication.medicationName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                // color: isCompleted ? Colors.grey : Colors.black87,
                // decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          const SizedBox(width: 8),

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
                    petId: pet.id!,
                    medicationDate: DateTimeUtils.nowKst(),
                  );
                }

                await loadPets();
              } catch (e) {
                debugPrint('복용 상태 변경 실패: $e');

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('복용 상태를 변경하지 못했어요.')),
                );
              }
            },
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: isCompleted ? Colors.green : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayVaccinationItem(Vaccination vaccination) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('💉', style: TextStyle(fontSize: 17)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${vaccination.vaccineName} 예방접종 예정',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// 반려동물 프로필
class _PetHomeProfileHeader extends StatelessWidget {
  // _PetHomeProfileHeader(pet: pet)을 호출하면 클래스의 생성자가 실행되면서 전달받은 pet 값이 클래스 내부의 final Pet pet; 변수에 저장(보관) 됨. 일반함수는 매개변수로 넘어온 pet을 직접 사용
  final Pet pet;

  const _PetHomeProfileHeader({required this.pet});

  // 생년월일로 나이 변환
  String _getAgeText(DateTime birthDate) {
    final now = DateTimeUtils.todayKst();

    int ageYear = now.year - birthDate.year;
    int ageMonth = now.month - birthDate.month;

    // 일(day) 수 비교하여 개월 수 보정
    if (now.day < birthDate.day) {
      ageMonth--;
    }

    // 개월 수가 음수일 경우 연도에서 차감
    if (ageMonth < 0) {
      ageYear--;
      ageMonth += 12;
    }

    // 1살 미만인 경우 'x개월' 표시
    if (ageYear == 0) {
      return '$ageMonth개월';
    }
    // 개월이 0인 경우 'x살' 표시
    else if (ageMonth == 0) {
      return '$ageYear살';
    }
    // 1살 이상 & 개월이 있는 경우 'x살 y개월' 표시
    else {
      return '$ageYear살 $ageMonth개월';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 성별/품종/몸무게 텍스트 조합
    final List<String> details = [];

    if (pet.birthDate != null) {
      details.add(_getAgeText(pet.birthDate!));
    }

    if (pet.weight != null) {
      details.add('${pet.weight}kg');
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          // backgroundColor: Colors.grey[100],
          backgroundImage: pet.imagePath != null
              ? FileImage(File(pet.imagePath!))
              : null,
          child: pet.imagePath == null
              ? const Icon(Icons.pets, size: 32)
              : null,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.name,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  // letterSpacing: -0.5,
                ),
              ),

              if (details.isNotEmpty) ...[
                const SizedBox(height: 6),

                Text(
                  details.join('  •  '), // join: 리스트의 문자열들을 하나의 문자열로 합치는 것,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
