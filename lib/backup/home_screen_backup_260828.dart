import 'dart:io';

import 'package:flutter/material.dart'; // 플루터 제공 디자인 라이브러리
import 'package:pet_care_manager_mobile/models/medication.dart';

import '../screens/pet_register_screen.dart';
import '../screens/pet_detail_screen.dart';

import '../database/database_helper.dart';

import '../models/pet.dart';
import '../models/vaccination.dart';

import '../utils/date_time_utils.dart';

class HomeScreenBackup3 extends StatefulWidget {
  // StatelessWidget: 사용자에 동작에 의해 화면 자체의 데이터(상태)가 바로 바뀌지 않는 정적인 화면을 의미
  const HomeScreenBackup3({super.key}); // 플러터가 위젯을 효율적으로 관리할 수 있도록 돕는 생성자 선언

  @override
  State<HomeScreenBackup3> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenBackup3> {
  List<Pet> pets = [];

  Map<int, Vaccination?> nextVaccinations = {};
  Map<int, Medication?> nextMedications = {};

  @override
  void initState() {
    super.initState();

    loadPets();
  }

  // 반려동물 조회
  Future<void> loadPets() async {
    final loadedPets = await DatabaseHelper.instance.getPets();

    final Map<int, Vaccination?> loadedNextVaccinations = {};
    final Map<int, Medication?> loadedNextMedications = {};

    for (final pet in loadedPets) {
      final nextVaccination = await DatabaseHelper.instance.getNextVaccination(
        pet.id!,
      );

      loadedNextVaccinations[pet.id!] = nextVaccination;

      final nextMedication = await DatabaseHelper.instance.getNextMedication(
        pet.id!,
      );

      loadedNextMedications[pet.id!] = nextMedication;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      pets = loadedPets;
      nextVaccinations = loadedNextVaccinations;
      nextMedications = loadedNextMedications;
    });
  }

  // 예방접종, 약 복용 알림 메세지
  String _getReminderMessage({
    required String name,
    required DateTime nextDate,
    required String categoryType,
  }) {
    final today = DateTimeUtils.todayKst();

    final todayOnly = DateTime(today.year, today.month, today.day);
    final nextDateOnly = DateTime(nextDate.year, nextDate.month, nextDate.day);

    final difference = nextDateOnly.difference(todayOnly).inDays;

    if (difference < 0) {
      return categoryType == 'vaccine'
          ? '🔔 $name 예방접종 예정일이 ${difference.abs()}일 지났어요.'
          : '🔔 $name 복용 예정일이 ${difference.abs()}일 지났어요.';
    } else if (difference == 0) {
      return categoryType == 'vaccine'
          ? '🔔 오늘은 $name 예방접종 날이에요!'
          : '🔔 오늘은 $name 복용일이에요!';
    } else if (difference == 1) {
      return categoryType == 'vaccine'
          ? '🔔 $name 예방접종이 내일이에요.'
          : '🔔 $name 복용일이 내일이에요.';
    }

    return categoryType == 'vaccine'
        ? '💉 $name 예방접종까지 $difference일 남았어요.'
        : '💉 $name 복용까지 $difference일 남았어요.';
  }

  // 예방접종, 약 복용 알림 배경
  Color _getReminderColor(DateTime nextDate) {
    final today = DateTimeUtils.todayKst();

    final todayOnly = DateTime(today.year, today.month, today.day);
    final nextDateOnly = DateTime(nextDate.year, nextDate.month, nextDate.day);

    final difference = nextDateOnly.difference(todayOnly).inDays;

    if (difference <= 0) {
      return Colors.red.shade900;
    } else if (difference == 1 || difference <= 7) {
      return Colors.orange.shade900;
    }

    return Theme.of(context).primaryColor.withValues(alpha: 0.9);
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

                          // 예방접종 알림
                          if (nextVaccinations[pet.id] != null) ...[
                            const SizedBox(height: 15),

                            Builder(
                              builder: (context) {
                                final vaccination = nextVaccinations[pet.id]!;
                                final alertColor = _getReminderColor(
                                  vaccination.nextDate!,
                                );

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: alertColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _getReminderMessage(
                                      name: vaccination.vaccineName,
                                      nextDate: vaccination.nextDate!,
                                      categoryType: 'vaccine',
                                    ),
                                    style: TextStyle(
                                      color: alertColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],

                          // 약 복용 알림
                          if (nextMedications[pet.id!] != null) ...[
                            const SizedBox(height: 5),

                            Builder(
                              builder: (context) {
                                final medication = nextMedications[pet.id]!;
                                final alertColor = _getReminderColor(
                                  medication.nextDate!,
                                );

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: alertColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _getReminderMessage(
                                      name: medication.medicationName,
                                      nextDate: medication.nextDate!,
                                      categoryType: 'medication',
                                    ),
                                    style: TextStyle(
                                      color: alertColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
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
