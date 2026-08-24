# 🐾 Pet Care Manager Mobile

반려동물의 기본 정보와 건강 기록을 관리할 수 있는 모바일 앱입니다.

Flutter와 SQLite를 사용하여 반려동물 정보를 저장하고 관리하며,

병원 기록, 예방접종, 체중 변화, 약 복용 기록 등을 한눈에 확인할 수 있도록 개발하고 있습니다.

---

## 📱 주요 기능

### 🐾 반려동물 관리

* 반려동물 등록
* 반려동물 정보 조회
* 반려동물 정보 수정
* 반려동물 삭제
* 반려동물 사진 등록

### 🏥 건강 기록 관리

* 건강 기록 등록
* 건강 기록 조회
* 건강 기록 수정
* 건강 기록 삭제
* 병원, 진료 내용, 비용 및 메모 관리

### 💉 예방접종 관리

* 예방접종 기록 등록
* 예방접종 기록 조회
* 예방접종 기록 수정
* 예방접종 기록 삭제
* 다음 예방접종 예정일 설정
* 다음 예방접종 예정일 초기화
* 병원 및 메모 관리
* 홈 화면에서 가장 가까운 예방접종 일정 확인

### ⚖️ 체중 기록 관리

* 체중 기록 등록
* 체중 기록 조회
* 체중 기록 수정
* 체중 기록 삭제
* 체중 변화 그래프
* 날짜별 체중 확인
* 그래프 포인트 선택 시 날짜 및 체중 확인

### 💊 약 복용 관리

* 약 복용 기록 등록
* 약 복용 기록 조회
* 약 복용 기록 수정
* 약 복용 기록 삭제
* 복용 날짜 및 복용 시간 설정
* 다음 복용 예정일 설정
* 반복 복용 설정
  * 반복 없음
  * 매일
  * 매주
  * N일마다
* 메모 관리
* 약 복용 알림 예약
* 반복 약 복용 알림 예약
* 예약된 약 복용 알림 취소

### 🔔 알림 기능

* Android 알림 권한 요청
* 정확한 알람 권한 요청
* 특정 날짜 및 시간에 알림 예약
* 매일 반복 알림
* 매주 반복 알림
* N일마다 반복 알림
* 예약된 알림 취소
* 한국 시간대(`Asia/Seoul`)를 기준으로 알림 시간 관리

### 🏠 홈 화면

* 등록된 반려동물 목록 확인
* 반려동물 사진, 이름, 품종 및 몸무게 표시
* 다음 예방접종 예정일 표시
* 예방접종 예정일이 가까워진 경우 알림 문구 표시
* 반려동물 선택 시 상세 화면으로 이동

---

## 🛠️ 기술 스택

* **Flutter**
* **Dart**
* **SQLite**
* **sqflite**
* **fl_chart**
* **table_calendar**
* **flutter_local_notifications**
* **timezone**

---

## 📂 프로젝트 구조

```text
lib/
│
├── main.dart
│
├── database/
│   └── database_helper.dart
│
├── models/
│   ├── pet.dart
│   ├── health_record.dart
│   ├── vaccination.dart
│   ├── weight_record.dart
│   ├── medication.dart
│   └── medication_log.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── pet_detail_screen.dart
│   ├── pet_register_screen.dart
│   ├── health_record_register_screen.dart
│   ├── vaccination_register_screen.dart
│   ├── weight_record_register_screen.dart
│   ├── medication_register_screen.dart
│   └── medication_history_screen.dart
│
├── services/
│   └── notification_service.dart
│
├── utils/
│   └── date_time_utils.dart
│
└── widgets/
    ├── pet_profile_header.dart
    └── weight_chart.dart
```

---

## 🗄️ 데이터베이스

SQLite를 사용하여 반려동물과 관련된 데이터를 로컬에 저장합니다.

현재 관리하고 있는 주요 데이터:

* 반려동물 정보
* 건강 기록
* 예방접종 기록
* 체중 기록
* 약 복용 기록

데이터베이스 버전 변경에 따라 필요한 테이블을 마이그레이션하도록 구현하고 있습니다.

---

## 📈 체중 변화 그래프

`fl_chart`를 사용하여 반려동물의 체중 변화를 그래프로 확인할 수 있습니다.

* X축: 측정 날짜
* Y축: 체중(kg)
* 날짜순으로 체중 변화 표시
* 그래프 포인트 선택 시 날짜 및 체중 표시

---

## 🔔 약 복용 알림

`flutter_local_notifications`와 `timezone` 패키지를 사용하여 약 복용 알림 기능을 구현했습니다.

알림 서비스는 `NotificationService`에서 관리하며, 앱 전체에서 하나의 서비스를 사용할 수 있도록 Singleton 패턴을 적용했습니다.

### 알림 예약

특정 날짜와 시간에 약 복용 알림을 예약할 수 있습니다.

```dart
await NotificationService.instance.scheduleNotification(
  id: id,
  title: title,
  body: body,
  scheduledDate: scheduledDate,
);
```

### 반복 알림

약 복용 주기에 따라 다음과 같이 반복 알림을 설정할 수 있습니다.

```text
반복 없음
    ↓
특정 날짜와 시간에 1회 알림

매일
    ↓
매일 같은 시간에 반복 알림

매주
    ↓
매주 같은 요일과 시간에 반복 알림

N일마다
    ↓
설정한 일수 간격으로 알림 예약
```

`N일마다` 반복 알림은 다음 예정 날짜를 계산한 후 여러 개의 알림을 미리 예약하는 방식으로 구현했습니다.

### Timezone

예약 알림에서는 `timezone` 패키지를 사용하여 한국 시간대인 `Asia/Seoul`을 명시적으로 설정합니다.

```dart
tz_data.initializeTimeZones();

tz.setLocalLocation(
  tz.getLocation('Asia/Seoul'),
);
```

예약할 때는 `DateTime` 값을 `TZDateTime`으로 변환하여 사용합니다.

```dart
scheduledDate: tz.TZDateTime.from(
  scheduledDate,
  tz.local,
),
```

이를 통해 기기의 시간대와 관계없이 예약 시간을 명확하게 관리할 수 있도록 구성했습니다.

---

## 🚧 개발 진행 상황

* [x] 반려동물 등록
* [x] 반려동물 조회
* [x] 반려동물 수정
* [x] 반려동물 삭제
* [x] 반려동물 사진 등록
* [x] 건강 기록 CRUD
* [x] 예방접종 CRUD
* [x] 다음 예방접종 예정일 관리
* [x] 홈 화면 예방접종 예정 알림
* [x] 체중 기록 CRUD
* [x] 체중 변화 그래프
* [x] 건강 캘린더
* [x] 날짜별 건강 기록 조회
* [x] 약 복용 기록 CRUD
* [x] 약 복용 시간 설정
* [x] 다음 복용 예정일 관리
* [x] 약 복용 반복 주기 설정
* [x] 알림 서비스 초기화
* [x] 알림 권한 요청
* [x] 특정 시간 예약 알림
* [x] 매일 반복 알림
* [x] 매주 반복 알림
* [x] N일마다 반복 알림
* [x] 예약된 알림 취소
* [ ] 예방접종 예정 알림
* [ ] UI/UX 개선

---

## 🎯 개발 목표

반려동물의 기본 정보부터 병원 기록, 예방접종, 체중 변화, 약 복용 일정까지

한 곳에서 편리하게 관리할 수 있는 반려동물 건강 관리 앱을 만드는 것을 목표로 합니다.

건강 캘린더를 통해 날짜별 병원 기록, 예방접종, 체중 및 약 복용 기록을 한눈에 확인할 수 있도록 구현했습니다.

현재 약 복용 시간을 기준으로 특정 날짜의 알림을 예약하고, 매일·매주·N일마다 반복되는 복용 일정까지 알림으로 관리할 수 있도록 구현했습니다.

앞으로 예방접종 예정 알림과 UI/UX를 개선하여 반려동물의 건강 관리에 더욱 편리하게 사용할 수 있는 앱으로 발전시키는 것을 목표로 합니다.

개발 과정에서 Flutter, Dart, SQLite, 로컬 알림 및 Timezone 처리 등을 학습하고 실제 사용할 수 있는 모바일 애플리케이션으로 완성하는 것을 목표로 합니다.
