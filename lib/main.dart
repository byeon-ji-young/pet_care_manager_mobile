import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';

import 'services/notification_service.dart';

// 1. 앱의 시작점 (void main() & runApp)
/*
  void main(): 스마트폰에서 앱 아이콘을 터치했을 때 가장 먼저 실행되는 함수
  runApp(...): 플루터 엔진에게 "이제 준비된 이 위젯(PetCareManagerApp)을 스마트폰 전체 화면에 띄워줘!" 하고 명령을 내리는 구문
*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 앱이 시작되기 전에 Flutter 엔진과 플러그인을 제대로 초기화

  await NotificationService.instance.initialize();

  runApp(const PetCareManagerApp());
}

// 2. 앱 전체를 감싸는 최상위 위젯 (MaterialApp)
/*
  MaterialApp: 플루터 앱 전체를 감싸는 최상위 부품
  화면 전환(네비게이션), 테마 설정, 기본 언어/디자인 규격 등 앱 전반에 필요한 핵심 시스템 설정을 여기서 모두 관리

  class PetCareManagerApp extends StatelessWidget {
    const PetCareManagerApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        ...
      );
    }
  }
*/
class PetCareManagerApp extends StatelessWidget {
  const PetCareManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // 앱을 개발할 때 화면 오른쪽 상단에 작게 나오는 빨간색 'DEBUG' 띠를 숨겨줌
      title: 'PetCareManager', // 앱 타이틀

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true, // 구글의 최신 디자인 시스템 Material 3 적용
        textTheme: GoogleFonts.juaTextTheme(), // 화면에 구글-주아체 적용
        //textTheme: GoogleFonts.poorStoryTextTheme()
      ),

      home: const HomeScreen(), // 첫 화면 지정. 앱이 켜졌을 때 제일 먼저 띄워줄 화면을 지정함
    );
  }
}
