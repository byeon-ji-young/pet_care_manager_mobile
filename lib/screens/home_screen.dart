import 'package:flutter/material.dart'; // 플루터 제공 디자인 라이브러리

import 'pet_register_screen.dart';
import 'pet_detail_screen.dart';

import '../database/database_helper.dart';

import '../models/pet.dart';
import '../models/vaccination.dart';

import '../widgets/pet_profile_header.dart';

class HomeScreen extends StatefulWidget {
  // StatelessWidget: 사용자에 동작에 의해 화면 자체의 데이터(상태)가 바로 바뀌지 않는 정적인 화면을 의미
  const HomeScreen({super.key}); // 플러터가 위젯을 효율적으로 관리할 수 있도록 돕는 생성자 선언

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> pets = [];

  Map<int, Vaccination?> nextVaccinations = {};

  @override
  void initState() {
    super.initState();

    loadPets();
  }

  // 반려동물 조회
  Future<void> loadPets() async {
    final loadedPets = await DatabaseHelper.instance.getPets();

    final Map<int, Vaccination?> loadedNextVaccinations = {};

    for (final pet in loadedPets) {
      final nextVaccination = await DatabaseHelper.instance.getNextVaccination(
        pet.id!,
      );

      loadedNextVaccinations[pet.id!] = nextVaccination;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      pets = loadedPets;
      nextVaccinations = loadedNextVaccinations;
    });
  }

  // 예방접종 알림 메세지
  String _getVaccinationMessage(Vaccination vaccination) {
    final nextDate = vaccination.nextDate!;
    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);
    final nextDateOnly = DateTime(nextDate.year, nextDate.month, nextDate.day);

    final difference = nextDateOnly.difference(todayOnly).inDays;

    if (difference < 0) {
      return '🔴 ${vaccination.vaccineName} 예방접종 예정일이 '
          '${difference.abs()}일 지났어요.';
    } else if (difference == 0) {
      return '🔴 오늘은 ${vaccination.vaccineName} 예방접종 예정일이에요!';
    } else if (difference == 1) {
      return '🟠 ${vaccination.vaccineName} 예방접종이 내일이에요.';
    } else if (difference <= 7) {
      return '🟡 ${vaccination.vaccineName} 예방접종이 '
          '$difference일 남았어요.';
    }

    return '💉 ${vaccination.vaccineName} 예방접종이 '
        '$difference일 남았어요.';
  }

  // 예방접종 알림 배경
  Color _getVaccinationColor(Vaccination vaccination) {
    final nextDate = vaccination.nextDate!;
    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);
    final nextDateOnly = DateTime(nextDate.year, nextDate.month, nextDate.day);

    final difference = nextDateOnly.difference(todayOnly).inDays;

    if (difference <= 0) {
      return Colors.red;
    } else if (difference == 1) {
      return Colors.orange;
    } else if (difference <= 7) {
      return Colors.amber;
    }

    return Colors.blue;
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
                              PetProfileHeader(pet: pet),

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
                            const SizedBox(height: 12),

                            Builder(
                              builder: (context) {
                                final vaccination = nextVaccinations[pet.id]!;
                                final alertColor = _getVaccinationColor(
                                  vaccination,
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
                                    _getVaccinationMessage(vaccination),
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
