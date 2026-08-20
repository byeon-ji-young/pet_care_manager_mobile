import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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
    // Timezone 데이터 초기화. (Timezone 데이터 준비만 하는거지 한국시간을 사용하도록 지정한건 아님)
    tz_data.initializeTimeZones();

    // 한국 시간대 설정
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

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

  // 특정 날짜와 시간에 알림 예약
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel', // Notification Channel ID (고유명)
          '약 복용 알림', // Android의 알림 설정 화면에서 볼 수 있는 채널 이름
          channelDescription: '반려동물 약 복용 시간 알림', // 알림 채널 설명
          importance: Importance.high,
          priority: Priority.high, // 우선순위
        ),
        iOS: DarwinNotificationDetails(),
      ),
      /*
        androidScheduleMode: 예약 알림을 언제 울릴 것인지와 관련된 설정
        
        exactAllowWhileIdle
        - exact: 예약한 시간을 정확하게 맞춰서 알림을 실행하도록 요청
        - AllowWhileIdle: 절전 상태(Doze/idle)에 들어가더라도 예약된 알림을 실행할 수 있도록 허용하는 방식
      */
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
