import 'dart:io';

import 'package:flutter/material.dart'; // 플루터 제공 디자인 라이브러리

import 'pet_register_screen.dart';
import 'pet_detail_screen.dart';

import '../database/database_helper.dart';

import '../models/pet.dart';

class HomeScreen extends StatefulWidget  { // StatelessWidget: 사용자에 동작에 의해 화면 자체의 데이터(상태)가 바로 바뀌지 않는 정적인 화면을 의미
  const HomeScreen({super.key}); // 플러터가 위젯을 효율적으로 관리할 수 있도록 돕는 생성자 선언

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> pets = [];

  @override
  void initState() {
    super.initState();

    loadPets();
  }

  Future<void> loadPets() async {
    final loadedPets = await DatabaseHelper.instance.getPets();

    if (!mounted) {
      return;
    }

    setState(() {
      pets = loadedPets;
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
        title: Row( // Row는 기본적으로 가로 방향으로 배치. 세로 배치는 Column
          children: const [
            Icon(
              Icons.pets,
            ),

            SizedBox(width: 8),
            
            Text(
              '펫몽',
              /*
              // 개별 텍스트에 구글폰트 적용시키는 방법 *
              style: GoogleFonts.jua( 
                fontWeight: FontWeight.bold
              ),
              */
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            
            Spacer(),
            
            Text(
              '우리 아이 건강일지',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
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
                  const Icon(
                    Icons.pets,
                    size: 80,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    '등록된 반려동물이 없어요.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '우리 아이를 등록해 주세요.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /*
                    화면 이동 버튼 (ElevatedButton.icon & Navigator)

                    ElevatedButton.icon: 입체감이 있는 버튼에 아이콘(+)과 글자(반려동물 등록)를 같이 넣어 생성
                    onPressed: () { ... }: 버튼을 눌렀을 때 실행될 동작 정의
                    Navigator.push(...): 새로운 화면을 스택처럼 위에 쌓아서 띄워주는 플러터의 화면 이동 방식
                    MaterialPageRoute: 안드로이드/iOS 스타일의 부드러운 화면 전환 애니메이션 효과를 부여하며 PetRegisterScreen 화면으로 넘어감
                  */
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push( // 등록 화면에서 돌아오면 이미 loadPets()를 호출
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
                        vertical: 12
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // 리스트 전체 여백 추가
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];

                return Card(
                  elevation: 1, // 카드 그림자 살짝 부여
                  margin: const EdgeInsets.only(bottom: 12), // 카드 사이 간격
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // 카드 모서리 둥글게
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 2,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: pet.imagePath != null
                        ? FileImage(File(pet.imagePath!))
                        : null,
                      child: pet.imagePath == null
                        ? Icon(Icons.pets, size: 28)
                        : null,
                    ),

                    title: Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${pet.breed?.isEmpty == true ? '품종 미입력' : pet.breed} · '
                        '${pet.weight != null ? '${pet.weight}kg' : '몸무게 미입력'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),

                    trailing: const Icon(
                      Icons.chevron_right, // 이동 가능함을 암시하는 화살표 아이콘
                      color: Colors.grey,
                    ),

                    /*
                      onTap은 사용자가 이 카드를 '터치(클릭)'했을 때 무슨 행동을 할지 정의하는 이벤트 함수

                      Navigator.push(...): 새로운 화면을 화면 스택(Stack) 맨 위에 쌓아서(Push) 보여달라
                      MaterialPageRoute(...): 안드로이드/iOS 스타일의 부드러운 화면 전환 애니메이션
                      builder: (context) => PetDetailScreen(pet: pet): 이동할 목적지 화면인 PetDetailScreen을 생성하면서 선택된 데이터 전달
                    */
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetailScreen(
                            pet: pet, // 왼쪽 pet은 상세 화면에서 받는 변수 이름, 오른쪽 pet은 현재 홈 화면에서 선택한 Pet 객체
                          ),
                        ),
                      );

                      if(result == true) {
                        loadPets();
                      }
                    },
                  ),
                );
              },
            ),

      floatingActionButton: pets.isNotEmpty // FloatingActionButton: 화면 위에 둥둥 떠있는 버튼
        ? FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const PetRegisterScreen()
                )
              );

              loadPets();
            },
            child: const Icon(Icons.add),
          )
        : null
    );
  }
}