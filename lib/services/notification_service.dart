import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._(); // private 생성자. 외부에서 객체를 직접 생성하지 못하게 함

  /*
    Singleton 패턴. 앱 전체에서 NotificationService를 하나만 사용하겠다는 뜻
    
    static → 클래스에 하나만 존재
    final → 한 번 만들어진 객체를 다른 객체로 바꿀 수 없음
    instance → 그 하나의 객체에 접근하는 변수
    NotificationService._() → 외부에서 함부로 객체를 생성하지 못하도록 만든 private 생성자

    => NotificationService 객체를 하나 만들어서 instance라는 이름으로 앱 전체에서 사용
  */
  static final NotificationService instance = NotificationService._();

  // 실제로 알림을 다루는 객체
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Android 알림 설정
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher', // 앱 아이콘
    );

    // iOS 알림 설정
    const iosSettings = DarwinInitializationSettings();

    // Android + iOS 설정 합치기
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 실제 초기화 실행
    await _notifications.initialize(settings: settings);
  }
}
