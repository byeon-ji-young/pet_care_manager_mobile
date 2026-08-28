# 🐾 Pet Care Manager Mobile

반려동물의 기본 정보부터 건강 기록, 예방접종, 체중 변화, 약 복용 일정까지 한 곳에서 관리할 수 있는 모바일 애플리케이션입니다.

Flutter와 SQLite를 기반으로 개발했으며, 반려동물의 건강 데이터를 로컬 데이터베이스에 저장하고 날짜별로 확인할 수 있도록 구현했습니다.

또한 `flutter_local_notifications`와 `timezone`을 활용하여 약 복용 일정을 기준으로 로컬 알림을 예약할 수 있도록 구현했습니다.

---

## 📱 주요 기능

### 🐾 반려동물 관리

* [x] 반려동물 등록
* [x] 반려동물 정보 조회
* [x] 반려동물 정보 수정
* [x] 반려동물 삭제
* [x] 반려동물 사진 등록
* [x] 반려동물 기본 정보 표시
* [x] 반려동물 나이 자동 계산
* [x] 반려동물 몸무게 표시

### 🏥 건강 기록 관리

* [x] 건강 기록 등록
* [x] 건강 기록 조회
* [x] 건강 기록 수정
* [x] 건강 기록 삭제
* [x] 병원 정보 관리
* [x] 진료 내용 관리
* [x] 진료 비용 관리
* [x] 메모 관리

### 💉 예방접종 관리

* [x] 예방접종 기록 등록
* [x] 예방접종 기록 조회
* [x] 예방접종 기록 수정
* [x] 예방접종 기록 삭제
* [x] 예방접종 예정일 설정
* [x] 다음 예방접종 예정일 관리
* [x] 다음 예방접종 예정일 초기화
* [x] 병원 정보 관리
* [x] 메모 관리
* [x] 홈 화면에서 오늘의 예방접종 일정 확인

### ⚖️ 체중 기록 관리

* [x] 체중 기록 등록
* [x] 체중 기록 조회
* [x] 체중 기록 수정
* [x] 체중 기록 삭제
* [x] 날짜별 체중 확인
* [x] 체중 변화 그래프
* [x] 그래프 포인트 선택
* [x] 선택한 날짜 및 체중 확인

### 📅 건강 캘린더

* [x] 건강 캘린더 제공
* [x] 날짜별 건강 기록 조회
* [x] 날짜별 예방접종 기록 조회
* [x] 날짜별 체중 기록 조회
* [x] 날짜별 약 복용 기록 조회

### 💊 약 복용 관리

* [x] 약 복용 기록 등록
* [x] 약 복용 기록 조회
* [x] 약 복용 기록 수정
* [x] 약 복용 기록 삭제
* [x] 복용 날짜 설정
* [x] 복용 시간 설정
* [x] 다음 복용 예정일 설정
* [x] 반복 복용 설정

  * 반복 없음
  * 매일
  * 매주
  * N일마다
* [x] 메모 관리
* [x] 약 복용 이력 확인
* [x] 오늘의 복용 일정 확인
* [x] 오늘 복용 완료 상태 확인
* [x] 오늘 복용 완료 처리
* [x] 오늘 복용 완료 취소

### 🔔 알림 기능

* [x] Android 알림 권한 요청
* [x] 정확한 알람 권한 요청
* [x] 특정 날짜 및 시간 알림 예약
* [x] 매일 반복 알림
* [x] 매주 반복 알림
* [x] N일마다 반복 알림
* [x] 예약된 알림 취소
* [x] 한국 시간대(`Asia/Seoul`) 기준 알림 시간 관리

---

## 🏠 홈 화면

홈 화면에서 등록된 반려동물과 오늘 예정된 건강 관리 일정을 한눈에 확인할 수 있습니다.

### 반려동물 정보

* 반려동물 사진
* 이름
* 나이
* 몸무게

### 오늘의 건강 관리

* 💊 오늘 복용해야 하는 약
* 💉 오늘 예정된 예방접종
* 💊 약 복용 완료 여부
* 💊 약 복용 완료 / 취소 처리

약 복용 항목의 완료 상태는 SQLite에 저장되며, 앱을 다시 실행해도 해당 날짜의 복용 상태를 확인할 수 있도록 구현했습니다.

---

## 🛠️ 기술 스택

### Framework

* **Flutter**
* **Dart**

### Database

* **SQLite**
* **sqflite**

### UI / Visualization

* **fl_chart**
* **table_calendar**

### Notification

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

SQLite를 사용하여 반려동물과 관련된 데이터를 기기 내부에 로컬로 저장합니다.

### 주요 데이터

* 반려동물 정보
* 건강 기록
* 예방접종 기록
* 체중 기록
* 약 복용 정보
* 약 복용 이력

### 데이터베이스 관리

`DatabaseHelper`를 Singleton 패턴으로 구성하여 앱 전체에서 하나의 데이터베이스 접근 객체를 사용하도록 구현했습니다.

주요 데이터에 대해 다음과 같은 CRUD 기능을 제공합니다.

* Create
* Read
* Update
* Delete

또한 데이터베이스 버전 변경에 따라 필요한 테이블을 추가하거나 변경할 수 있도록 Migration 구조를 적용했습니다.

---

## 📊 체중 변화 그래프

`fl_chart`를 사용하여 반려동물의 체중 변화를 시각적으로 확인할 수 있도록 구현했습니다.

* X축: 측정 날짜
* Y축: 체중(kg)
* 날짜순 체중 데이터 표시
* 그래프 포인트 선택
* 선택한 날짜 및 체중 확인

체중 데이터를 단순한 목록으로 보여주는 것뿐만 아니라 그래프를 통해 시간에 따른 변화를 쉽게 확인할 수 있도록 구성했습니다.

---

## 📅 건강 캘린더

`table_calendar`를 사용하여 날짜별 건강 기록을 확인할 수 있도록 구현했습니다.

캘린더에서 특정 날짜를 선택하면 해당 날짜에 등록된 건강 관련 데이터를 확인할 수 있습니다.

관리 가능한 기록:

* 🏥 건강 기록
* 💉 예방접종 기록
* ⚖️ 체중 기록
* 💊 약 복용 기록

---

## 🔔 약 복용 알림

`flutter_local_notifications`와 `timezone` 패키지를 사용하여 약 복용 알림 기능을 구현했습니다.

알림 관련 기능은 `NotificationService`에서 관리하며, 앱 전체에서 하나의 서비스를 사용할 수 있도록 Singleton 패턴을 적용했습니다.

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

약 복용 주기에 따라 다음과 같은 반복 알림을 설정할 수 있습니다.

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

### 알림 취소

약 복용 일정이 변경되거나 삭제되는 경우 기존에 예약된 알림을 취소할 수 있도록 구현했습니다.

---

## 🕐 Timezone 처리

모바일 기기의 시간대에 따라 알림 시간이 달라지는 문제를 방지하기 위해 `timezone` 패키지를 사용했습니다.

앱에서는 한국 시간대인 `Asia/Seoul`을 명시적으로 설정합니다.

```dart
tz_data.initializeTimeZones();

tz.setLocalLocation(
  tz.getLocation('Asia/Seoul'),
);
```

알림 예약 시 `DateTime`을 `TZDateTime`으로 변환하여 사용합니다.

```dart
scheduledDate: tz.TZDateTime.from(
  scheduledDate,
  tz.local,
),
```

이를 통해 알림 예약 시간을 명확하게 관리할 수 있도록 구성했습니다.

---

## 🧩 주요 설계

### DatabaseHelper Singleton

데이터베이스 접근을 담당하는 `DatabaseHelper`를 Singleton으로 구성하여 앱 전체에서 동일한 데이터베이스 인스턴스를 사용하도록 했습니다.

```text
화면
 ↓
DatabaseHelper
 ↓
SQLite
```

### Model 분리

데이터 종류별로 Model을 분리하여 관리합니다.

```text
Pet
HealthRecord
Vaccination
WeightRecord
Medication
MedicationLog
```

각 Model은 데이터베이스에서 조회한 데이터를 Dart 객체로 변환하고, 화면에서는 Model을 통해 데이터를 사용할 수 있도록 구성했습니다.

### Widget 분리

반복되거나 독립적인 UI 요소는 별도의 Widget으로 분리했습니다.

예:

```text
PetProfileHeader
WeightChart
```

화면 내부에서 특정 UI를 생성하는 간단한 메서드와 별도의 Widget으로 분리해야 하는 경우를 구분하여 사용했습니다.

---

## 📈 개발 진행 상황

### v1.0.0 기준

#### 🐾 반려동물

* [x] 반려동물 등록
* [x] 반려동물 조회
* [x] 반려동물 수정
* [x] 반려동물 삭제
* [x] 반려동물 사진 등록

#### 🏥 건강 기록

* [x] 건강 기록 CRUD
* [x] 병원 및 진료 정보 관리
* [x] 건강 캘린더
* [x] 날짜별 건강 기록 조회

#### 💉 예방접종

* [x] 예방접종 CRUD
* [x] 다음 예방접종 예정일 관리
* [x] 홈 화면 예방접종 일정 표시

#### ⚖️ 체중

* [x] 체중 기록 CRUD
* [x] 체중 변화 그래프
* [x] 날짜별 체중 확인

#### 💊 약 복용

* [x] 약 복용 기록 CRUD
* [x] 약 복용 시간 설정
* [x] 다음 복용 예정일 관리
* [x] 약 복용 반복 주기 설정
* [x] 약 복용 이력 관리
* [x] 오늘의 약 복용 일정 표시
* [x] 약 복용 완료 처리
* [x] 약 복용 완료 취소

#### 🔔 알림

* [x] 알림 서비스 초기화
* [x] 알림 권한 요청
* [x] 정확한 알람 권한 요청
* [x] 특정 시간 예약 알림
* [x] 매일 반복 알림
* [x] 매주 반복 알림
* [x] N일마다 반복 알림
* [x] 예약된 알림 취소
* [x] 한국 시간대 기반 알림 처리

---

## 🎯 개발 목표

반려동물의 기본 정보부터 병원 기록, 예방접종, 체중 변화, 약 복용 일정까지 한 곳에서 편리하게 관리할 수 있는 반려동물 건강 관리 앱을 만드는 것을 목표로 개발했습니다.

특히 다음과 같은 기능을 중심으로 구현했습니다.

* 반려동물별 건강 데이터 관리
* 날짜별 건강 기록 조회
* 체중 변화 시각화
* 예방접종 일정 관리
* 약 복용 일정 관리
* 약 복용 완료 상태 관리
* 로컬 알림을 활용한 복용 일정 알림

---

## 📚 개발 과정에서 학습한 내용

이 프로젝트를 통해 Flutter와 Dart의 기본적인 앱 개발 구조부터 실제 애플리케이션에서 필요한 데이터베이스, 상태 관리, 날짜/시간 처리, 로컬 알림 등을 직접 구현했습니다.

주요 학습 내용:

* Flutter Widget 구조
* StatefulWidget / StatelessWidget
* `setState()`를 이용한 상태 변경
* 화면 간 데이터 전달
* Navigator를 이용한 화면 이동
* ListView 및 다양한 UI Widget 구성
* Widget 분리 및 재사용
* SQLite 및 `sqflite`
* 데이터베이스 CRUD
* Database Migration
* Singleton 패턴
* Dart Model 설계
* 날짜 및 시간 처리
* Timezone 처리
* Local Notification
* 반복 알림 구현
* 차트 및 캘린더 UI 구현

---

## 🚀 향후 개선 예정

현재 1차 기능 구현을 완료한 상태이며, 이후에는 기능 확장보다는 실제 사용성을 높이는 방향으로 개선할 예정입니다.

예정된 개선 사항:

* [ ] UI/UX 개선
* [ ] 예방접종 예정 알림
* [ ] 알림 설정 화면 개선
* [ ] 건강 기록 UI 개선
* [ ] 사용자 편의 기능 추가
* [ ] 앱 전체 디자인 개선

---

## 📌 Version

### v1.0.0

Pet Care Manager Mobile의 주요 기능 1차 구현 완료.

* 반려동물 관리
* 건강 기록 관리
* 예방접종 관리
* 체중 기록 및 그래프
* 건강 캘린더
* 약 복용 관리
* 약 복용 완료 처리
* 로컬 알림
* 반복 알림
* SQLite 기반 데이터 관리

---

## 📝 프로젝트를 만들며

처음에는 반려동물의 기본 정보를 저장하는 간단한 앱으로 시작했지만, 실제로 사용할 수 있는 수준의 애플리케이션을 만드는 것을 목표로 기능을 하나씩 확장했습니다.

SQLite를 이용한 데이터 관리부터 체중 그래프, 건강 캘린더, 약 복용 기록, 로컬 알림까지 직접 구현하면서 Flutter 모바일 애플리케이션 개발 전반을 경험할 수 있었습니다.

특히 단순한 CRUD 구현에 그치지 않고 데이터베이스 구조, 날짜와 시간 처리, 반복 알림, Widget 분리 등 실제 앱 개발에서 고려해야 할 부분들을 직접 고민하며 개발했습니다.

앞으로도 프로젝트를 지속적으로 개선하면서 Flutter 개발 경험과 애플리케이션 설계 역량을 높여나갈 예정입니다.
