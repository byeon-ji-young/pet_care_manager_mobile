import 'package:flutter/material.dart'; // 플루터 제공 디자인 라이브러리

import '../screens/pet_register_screen.dart';

class HomeScreenBackup extends StatelessWidget { // StatelessWidget: 사용자에 동작에 의해 화면 자체의 데이터(상태)가 바로 바뀌지 않는 정적인 화면을 의미
  const HomeScreenBackup({super.key}); // 플러터가 위젯을 효율적으로 관리할 수 있도록 돕는 생성자 선언

  // 1. 화면의 기본 뼈대 구축 (Scaffold & AppBar)
  /* 
    build: 화면에 무엇을 그릴지 정의하는 메서드
    Scaffold: 앱 화면의 기본 레이아웃 뼈대 (상단바, 배경색, 바텀시트 등을 담는 도화지 역할)
    AppBar: 앱 상단 타이틀 바에 'PetCareManager'라는 글자 표시
  */
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetCareManager'),
      ),

      // 2. 중앙 세로 정렬 (Center & Column)
      /* 
        Center: 자식 위젯을 화면의 가로·세로 중앙에 위치
        Column: 안쪽에 들어가는 요소들(children)을 위에서 아래로 세로 배치
        mainAxisAlignment: MainAxisAlignment.center: 세로 방향 기준으로도 가운데 정렬
      */
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3. 시각적 요소와 간격 조절 (Icon, Text, SizedBox)
            /*
              Icon(Icons.pets, size: 80): 크기 80pt짜리 반려동물 발바닥 아이콘을 표시
              SizedBox(height: ...): 눈에 보이지 않는 상자로, 위젯들 사이에 세로 여백(간격) 생성
              Text: 화면에 안내 문구를 출력. style을 통해 글자 크기(fontSize)나 굵기(fontWeight) 지정 가능
            */
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

            const Text(
              '우리 아이를 등록해 주세요.',
            ),

            const SizedBox(height: 30),

            // 4. 화면 이동 버튼 (ElevatedButton.icon & Navigator)
            /*
              ElevatedButton.icon: 입체감이 있는 버튼에 아이콘(+)과 글자(반려동물 등록)를 같이 넣어 생성
              onPressed: () { ... }: 버튼을 눌렀을 때 실행될 동작 정의
              Navigator.push(...): 새로운 화면을 스택처럼 위에 쌓아서 띄워주는 플러터의 화면 이동 방식
              MaterialPageRoute: 안드로이드/iOS 스타일의 부드러운 화면 전환 애니메이션 효과를 부여하며 PetRegisterScreen 화면으로 넘어감
            */
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetRegisterScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('반려동물 등록'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class HomeScreen extends StatelessWidget {  // 1. "나도 화면 위젯이야!" 라고 선언
  const HomeScreen({super.key});            // 2. 플루터 엔진이 위젯을 식별하기 위한 생성자

  @override                                 // 3. "기존 부모의 방식을 내가 새로 정의할게"
  Widget build(BuildContext context) {      // 4. 실제로 화면에 그려질 부품(UI)을 리턴하는 함수
    return Scaffold(...);
  }
}
1. extends StatelessWidget:
  HomeScreen이라는 클래스가 플루터의 화면 부품(StatelessWidget) 역할을 이어받게 만들어줌. (이걸 안 쓰면 단순 데이터 클래스일 뿐, 화면에 띄울 수 없음)
2. const HomeScreen({super.key});:
  플루터 엔진이 수많은 위젯들 사이에서 이 위젯을 구분하고 최적화하기 위해 필요한 '고유 식별 키(Key)'를 넘겨주는 생성자 규칙
3. Widget build(BuildContext context):
  플루터가 화면을 그릴 때 가장 먼저 찾아와서 실행하는 함수
  이 함수 안에서 return으로 돌려주는 위젯들(Scaffold 등)이 실제로 사용자 눈에 보이게 됨

※ StatelessWidget과 StatefulWidget의 차이
  - StatelessWidget (상태 없음) : 한번 그려지면 절대 변하지 않는 화면. 데이터 변경 불가능 (final 변수만 사용)
  - StatefulWidget (상태 있음) : 이벤트나 데이터에 의해 실시간으로 변하는 화면. 데이터 변경 가능 (setState()를 통해 화면 재갱신)
*/