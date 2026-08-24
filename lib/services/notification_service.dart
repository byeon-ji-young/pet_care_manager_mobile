import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../utils/date_time_utils.dart';

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

    // Android 13 이상 알림 권한 요청
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();

    // 정확한 알람 권한 요청. exactAllowWhileIdle 사용안할거면 주석처리 해야됨
    await androidPlugin?.requestExactAlarmsPermission();
  }

  // ================================================ 반복 X ================================================
  // 약 복용 알림 예약
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

        inexactAllowWhileIdle
        - inexact: 정확하지 않은
      */
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // 예약된 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }
  // ================================================ 반복 X ================================================

  // ================================================ 반복 O ================================================
  // 약 복용 알림 예약
  Future<void> scheduleMedicationNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String repeatType,
    int? repeatInterval,
  }) async {
    // 반복 없음
    if (repeatType == 'none') {
      await _schedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );

      return;
    }
    // 매일
    else if (repeatType == 'daily') {
      await _schedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      return;
    }
    // 매주
    else if (repeatType == 'weekly') {
      await _schedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      return;
    }
    // N일마다
    else if (repeatType == 'interval' &&
        repeatInterval != null &&
        repeatInterval > 0) {
      const repeatCount = 30;

      final now = DateTimeUtils.nowKst();

      DateTime nextScheduledDate = scheduledDate; // 첫 번째 예약 날짜를 복용 날짜로 설정

      // 과거에 해당하는 반복 날짜를 전부 건너뛰고 가장 가까운 미래 날짜를 찾는 코드
      while (nextScheduledDate.isBefore(now)) {
        nextScheduledDate = nextScheduledDate.add(
          Duration(
            days: repeatInterval,
          ), // Duration(days: repeatInterval) = repeatInterval만큼의 일(day)을 나타내는 시간 간격을 만든다
        );
      }

      for (int i = 0; i < repeatCount; i++) {
        await _schedule(
          id: id * 1000 + i,
          title: title,
          body: body,
          scheduledDate: nextScheduledDate,
        );

        nextScheduledDate = nextScheduledDate.add(
          Duration(days: repeatInterval),
        );
      }
    }
  }

  // 예약 공통 함수
  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          '약 복용 알림',
          channelDescription: '반려동물 약 복용 시간 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  // 약 복용 알림 취소
  Future<void> cancelMedicationNotification({
    required int id,
    required String repeatType,
  }) async {
    // 일반 / 매일 / 매주
    if (repeatType != 'interval') {
      await _notifications.cancel(id: id);
      return;
    }

    // N일마다 예약된 알림 30개 취소
    const repeatCount = 30;

    for (int i = 0; i < repeatCount; i++) {
      await _notifications.cancel(id: id * 1000 + i);
    }
  }

  // ================================================ 반복 O ================================================
}
