# 🐾 Pet Care Manager Mobile

반려동물의 기본 정보부터 건강 기록, 예방접종, 체중 변화, 약 복용 일정까지 한 곳에서 관리할 수 있는 모바일 애플리케이션입니다.

Flutter와 SQLite를 기반으로 개발했으며, 반려동물별 건강 데이터를 로컬 데이터베이스에 저장하고 날짜별로 조회할 수 있도록 구현했습니다.

또한 `flutter_local_notifications`와 `timezone`을 활용하여 약 복용 일정에 따른 로컬 알림을 예약하고 관리할 수 있도록 구현했으며, 건강 기록 사진 첨부, 데이터 백업 및 복원, 기록 검색 기능 등을 추가하여 실제 사용성을 높였습니다.

---

## 📱 주요 기능

### 🐾 반려동물 관리

* [x] 반려동물 등록 / 조회 / 수정 / 삭제
* [x] 반려동물 사진 등록
* [x] 반려동물 기본 정보 표시
* [x] 반려동물 나이 자동 계산
* [x] 현재 몸무게 표시

### 🏥 건강 기록 관리

* [x] 건강 기록 등록 / 조회 / 수정 / 삭제
* [x] 병원 정보 관리
* [x] 진료 내용 관리
* [x] 진료 비용 관리
* [x] 검사 종류 관리
* [x] 검사 결과 관리
* [x] 건강 기록 사진 여러 장 첨부
* [x] 첨부 사진 삭제
* [x] 첨부 사진 확대 보기
* [x] 첨부 사진 좌우 스와이프
* [x] 사진 현재 위치 표시

### 💉 예방접종 관리

* [x] 예방접종 기록 등록 / 조회 / 수정 / 삭제
* [x] 예방접종 예정일 설정
* [x] 다음 예방접종 예정일 관리
* [x] 다음 예방접종 예정일 초기화
* [x] 병원 정보 및 메모 관리
* [x] 예방접종 완료 / 취소 처리
* [x] 홈 화면 예방접종 일정 표시

### ⚖️ 체중 기록 관리

* [x] 체중 기록 등록 / 조회 / 수정 / 삭제
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

* [x] 약 복용 기록 등록 / 조회 / 수정 / 삭제
* [x] 복용 날짜 및 시간 설정
* [x] 다음 복용 예정일 설정
* [x] 반복 복용 설정

  * 반복 없음
  * 매일
  * 매주
  * N일마다
* [x] 오늘의 복용 일정 확인
* [x] 오늘 복용 완료 상태 확인
* [x] 오늘 복용 완료 / 취소 처리
* [x] 약 복용 이력 확인
* [x] 실제 복용 완료 로그 저장
* [x] 복용 예정일 기준 이력 표시
* [x] 복용 완료 / 미복용 상태 구분

### 🔔 로컬 알림

* [x] Android 알림 권한 요청
* [x] 정확한 알람 권한 요청
* [x] 특정 날짜 및 시간 알림 예약
* [x] 매일 반복 알림
* [x] 매주 반복 알림
* [x] N일마다 반복 알림
* [x] 예약된 알림 취소
* [x] `Asia/Seoul` 기준 알림 시간 관리

### 💾 데이터 관리

* [x] 데이터 백업
* [x] 데이터 복원
* [x] SQLite 전체 데이터 백업
* [x] 건강 기록 사진 포함 백업
* [x] ZIP 기반 백업 파일 생성
* [x] 백업 파일 선택을 통한 데이터 복원
* [x] 복원 시 기존 데이터 전체 교체
* [x] 복원 시 건강 기록 사진 파일 복원

### 🔎 기록 검색

* [x] 기록 검색 UI
* [x] 전체 기간 기록 검색
* [x] 건강 기록 검색
* [x] 예방접종 기록 검색
* [x] 약 복용 기록 검색
* [x] 체중 기록 검색
* [x] 제목 / 병원명 / 내용 / 검사 정보 / 메모 등 검색
* [x] 검색 결과 날짜순 정렬

---

## 🏠 홈 화면

홈 화면에서 등록된 반려동물 정보와 오늘의 건강 관리 일정을 한눈에 확인할 수 있습니다.

### 반려동물 정보

* 반려동물 사진
* 이름
* 나이
* 몸무게

### 오늘의 건강 관리

* 🏥 오늘 예정된 병원 일정
* 💉 오늘 예정된 예방접종
* 💊 오늘 복용해야 하는 약
* 💊 약 복용 완료 여부
* 💊 약 복용 완료 / 취소 처리

약 복용 완료 상태는 SQLite에 저장되기 때문에 앱을 다시 실행해도 해당 날짜의 복용 상태가 유지됩니다.

---

## 🔎 기록 검색

기록 화면에서는 캘린더와 별도로 검색 기능을 제공하여 과거의 건강 관련 기록을 빠르게 찾을 수 있습니다.

검색어에 따라 다음과 같은 데이터를 검색할 수 있습니다.

* 건강 기록: 진료 제목, 병원명, 진료 내용, 검사 종류, 검사 결과
* 예방접종: 백신 이름, 병원명, 메모
* 약: 약 이름, 메모
* 체중: 체중, 메모

검색 중에는 캘린더의 선택 날짜와 관계없이 전체 기간의 기록을 검색하며, 검색 결과는 최신 기록부터 표시됩니다.

---

## 💾 데이터 백업 / 복원

기기 내부의 SQLite 데이터를 하나의 ZIP 파일로 백업하고 복원할 수 있습니다.

백업 파일은 다음과 같은 구조로 구성됩니다.

```text
petcare_backup_YYYYMMDD.zip
├── data.json
└── images/
    ├── health_record_1.jpg
    ├── health_record_2.jpg
    └── ...
```

`data.json`에는 다음 데이터를 포함합니다.

```text
pets
health_records
health_record_images
vaccinations
weight_records
medications
medication_logs
```

건강 기록 사진은 ZIP 내부의 `images` 폴더에 함께 저장되며, 복원 시 앱 전용 저장공간으로 다시 복원됩니다.

복원 과정에서는 기존 데이터를 삭제한 후 백업 파일의 데이터를 복원하며, 데이터 간 ID 관계를 유지하여 건강 기록과 첨부 사진 등의 연결 관계가 보존되도록 구성했습니다.

---

## 🛠️ 기술 스택

| 구분              | 기술                          |
| --------------- | --------------------------- |
| Framework       | Flutter                     |
| Language        | Dart                        |
| Database        | SQLite / sqflite            |
| Chart           | fl_chart                    |
| Calendar        | table_calendar              |
| Notification    | flutter_local_notifications |
| Timezone        | timezone                    |
| Image           | image_picker                |
| File Management | path_provider               |
| File Picker     | file_picker                 |
| Archive         | archive                     |

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
│   ├── health_record_image.dart
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
│   ├── medication_history_screen.dart
│   └── settings_screen.dart
│
├── services/
│   ├── notification_service.dart
│   └── backup_service.dart
│
├── utils/
│   └── date_time_utils.dart
│
└── widgets/
    ├── pet_profile_header.dart
    ├── today_health_tasks.dart
    ├── upcoming_health_tasks.dart
    └── weight_chart.dart
```

---

## 🗄️ 데이터베이스

SQLite를 사용하여 반려동물 관련 데이터를 기기 내부에 로컬로 저장합니다.

### 주요 데이터

```text
Pet

HealthRecord
HealthRecordImage

Vaccination

WeightRecord

Medication
MedicationLog
```

### 테이블 구조

```text
pets
 ├─ health_records
 │    └─ health_record_images
 │
 ├─ vaccinations
 ├─ weight_records
 └─ medications
       └─ medication_logs
```

### DatabaseHelper

`DatabaseHelper`를 Singleton으로 구성하여 앱 전체에서 동일한 데이터베이스 접근 객체를 사용하도록 구현했습니다.

주요 데이터에 대해 다음과 같은 CRUD 기능을 제공합니다.

* Create
* Read
* Update
* Delete

또한 데이터베이스 버전 변경에 대응할 수 있도록 Migration 구조를 적용했습니다.

현재 데이터베이스 버전은 `9`이며, 건강 기록 사진을 별도 테이블로 관리하기 위한 `health_record_images` 테이블이 포함되어 있습니다.

---

## 📊 체중 변화 그래프

`fl_chart`를 사용하여 반려동물의 체중 변화를 시각적으로 확인할 수 있도록 구현했습니다.

* X축: 측정 날짜
* Y축: 체중(kg)
* 날짜순 데이터 표시
* 그래프 포인트 선택
* 선택한 날짜 및 체중 확인

체중 데이터를 단순한 목록뿐만 아니라 그래프로 제공하여 시간에 따른 변화를 직관적으로 확인할 수 있도록 구성했습니다.

---

## 📅 건강 캘린더

`table_calendar`를 사용하여 날짜별 건강 데이터를 확인할 수 있도록 구현했습니다.

캘린더에서 날짜를 선택하면 해당 날짜에 등록된 건강 관련 데이터를 조회할 수 있습니다.

관리 가능한 기록:

* 🏥 건강 기록
* 💉 예방접종 기록
* ⚖️ 체중 기록
* 💊 약 복용 기록

또한 기록 검색 기능을 통해 캘린더에서 날짜를 직접 찾지 않아도 과거 기록을 빠르게 조회할 수 있습니다.

---

## 🔔 약 복용 알림

`flutter_local_notifications`와 `timezone`을 사용하여 약 복용 일정에 따른 로컬 알림 기능을 구현했습니다.

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

약 복용 주기에 따라 반복 알림을 설정할 수 있습니다.

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

`N일마다` 반복 알림은 다음 복용 예정일을 계산한 후 여러 개의 알림을 미리 예약하는 방식으로 구현했습니다.

### 알림 취소

약 복용 일정이 변경되거나 삭제되는 경우 기존에 예약된 알림을 취소할 수 있도록 구현했습니다.

---

## 🕐 Timezone 처리

모바일 기기의 시간대에 따라 알림 시간이 달라지는 문제를 방지하기 위해 `timezone` 패키지를 사용했습니다.

앱에서는 한국 시간대인 `Asia/Seoul`을 명시적으로 설정하고, 알림 예약 시 `DateTime`을 `TZDateTime`으로 변환하여 사용합니다.

```dart
tz_data.initializeTimeZones();

tz.setLocalLocation(
  tz.getLocation('Asia/Seoul'),
);
```

```dart
scheduledDate: tz.TZDateTime.from(
  scheduledDate,
  tz.local,
),
```

이를 통해 알림 예약 시간을 명확하게 관리할 수 있도록 구성했습니다.

---

## 📷 건강 기록 사진 관리

건강 기록에는 여러 장의 사진을 첨부할 수 있습니다.

사진은 이미지 파일 자체를 SQLite에 저장하지 않고, 앱 전용 저장공간에 파일로 저장한 뒤 데이터베이스에는 파일 경로를 저장하는 방식으로 구성했습니다.

```text
HealthRecord
     │
     │ 1 : N
     ↓
HealthRecordImage
     │
     └── imagePath
```

사진 등록 시:

```text
갤러리 선택
    ↓
앱 전용 저장공간에 복사
    ↓
health_record_images에 파일 경로 저장
```

사진을 수정하거나 삭제할 때는 DB의 사진 정보와 실제 이미지 파일을 함께 관리하도록 구성했습니다.

또한 확대 화면에서는 `PageView`를 사용하여 여러 장의 사진을 좌우로 넘길 수 있으며, `InteractiveViewer`를 적용하여 확대 및 축소할 수 있도록 구현했습니다.

---

## 🧩 주요 설계

### DatabaseHelper Singleton

데이터베이스 접근을 담당하는 `DatabaseHelper`를 Singleton으로 구성하여 앱 전체에서 동일한 데이터베이스 접근 객체를 사용하도록 했습니다.

```text
Screen
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
HealthRecordImage
Vaccination
WeightRecord
Medication
MedicationLog
```

데이터베이스에서 조회한 데이터를 Dart 객체로 변환하고, 화면에서는 Model을 통해 데이터를 사용할 수 있도록 구성했습니다.

### Service 분리

앱의 주요 기능 중 화면과 직접적인 관련이 없는 로직은 별도의 Service로 분리했습니다.

```text
NotificationService
BackupService
```

`NotificationService`는 로컬 알림 예약 및 취소를 담당하고, `BackupService`는 데이터 백업 및 복원 파일 처리를 담당합니다.

### Widget 분리

반복되거나 독립적인 UI 요소는 별도의 Widget으로 분리했습니다.

```text
PetProfileHeader
TodayHealthTasks
UpcomingHealthTasks
WeightChart
```

화면 내부에서만 사용되는 간단한 UI는 `_buildXXX()` 형태의 메서드로 구성하고, 독립적인 역할을 가지거나 재사용할 수 있는 UI는 별도의 Widget으로 분리했습니다.

---

## 📈 개발 진행 상황

### v1.0.0

* [x] 반려동물 관리
* [x] 건강 기록 CRUD
* [x] 예방접종 관리
* [x] 체중 기록 및 그래프
* [x] 건강 캘린더
* [x] 약 복용 관리
* [x] 약 복용 이력 관리
* [x] 오늘의 약 복용 일정
* [x] 약 복용 완료 / 취소
* [x] 로컬 알림
* [x] 반복 알림
* [x] Timezone 처리
* [x] SQLite 기반 데이터 관리

### v1.1.0

* [x] 건강 기록 사진 여러 장 첨부
* [x] 건강 기록 사진 삭제
* [x] 건강 기록 사진 확대 보기
* [x] 사진 좌우 스와이프 갤러리
* [x] 데이터 백업
* [x] 데이터 복원
* [x] 백업 파일에 건강 기록 사진 포함
* [x] 설정 화면 추가
* [x] 기록 검색 기능
* [x] 검색 UI 개선
* [x] 약 복용 이력 표시 개선

---

## 🎯 개발 목표

반려동물의 기본 정보부터 병원 기록, 예방접종, 체중 변화, 약 복용 일정까지 한 곳에서 관리할 수 있는 반려동물 건강 관리 앱을 만드는 것을 목표로 개발했습니다.

특히 다음 기능을 중심으로 구현했습니다.

* 반려동물별 건강 데이터 관리
* 날짜별 건강 기록 조회
* 건강 기록 사진 관리
* 체중 변화 시각화
* 예방접종 일정 관리
* 약 복용 일정 관리
* 약 복용 완료 상태 관리
* 로컬 알림을 활용한 복용 일정 알림
* 데이터 백업 및 복원
* 기록 검색

---

## 🚀 향후 개선 예정

현재 기본 기능과 데이터 관리 기능을 구현했으며, 이후에는 기능을 무작정 추가하기보다는 실제 사용성과 완성도를 높이는 방향으로 개선할 예정입니다.

* [ ] UI/UX 추가 개선
* [ ] 알림 설정 화면 개선
* [ ] 건강 기록 UI 개선
* [ ] 건강 데이터 요약 / 통계
* [ ] 사용자 편의 기능 추가
* [ ] 앱 전체 디자인 개선
* [ ] 실제 기기 환경 추가 테스트

---

## 📝 프로젝트를 만들며

처음에는 반려동물의 기본 정보를 저장하는 간단한 앱으로 시작했지만, 실제로 사용할 수 있는 수준의 애플리케이션을 만드는 것을 목표로 기능을 하나씩 확장했습니다.

SQLite를 이용한 데이터 관리부터 체중 그래프, 건강 캘린더, 약 복용 기록, 로컬 알림, 건강 기록 사진 관리, 데이터 백업 및 복원, 기록 검색까지 직접 구현하면서 Flutter 모바일 애플리케이션 개발 전반을 경험했습니다.

특히 단순한 CRUD 구현에 그치지 않고 데이터베이스 구조, 데이터베이스 Migration, 날짜와 시간 처리, 반복 일정, 로컬 알림, 파일 저장, 이미지 관리, 백업 및 복원, 검색 기능, Widget 및 Service 분리 등 실제 앱 개발에서 고려해야 할 요소들을 직접 구현했습니다.

또한 기능을 추가할 때 기존 구조를 유지하면서 데이터와 UI의 역할을 분리하고, 필요한 경우 별도의 Model, Widget, Service로 분리하는 과정을 통해 앱의 코드 구조를 점진적으로 개선했습니다.

이 프로젝트를 통해 Flutter 기반 모바일 애플리케이션의 전체적인 개발 흐름을 경험하고, 기능 구현뿐만 아니라 데이터 구조, 파일 관리, 사용자 경험 및 코드 구조를 함께 설계하는 경험을 쌓았습니다.

---

## 📌 Version

### v1.1.0

Pet Care Manager Mobile 1.1.0 업데이트.

**주요 기능**

* 🐾 반려동물 관리
* 🏥 건강 기록 관리
* 📷 건강 기록 사진 첨부 및 갤러리
* 💉 예방접종 관리
* ⚖️ 체중 기록 및 그래프
* 📅 건강 캘린더
* 💊 약 복용 관리 및 복용 이력
* 🔔 로컬 알림
* 🔎 기록 검색
* 💾 데이터 백업 및 복원
* 🗄️ SQLite 기반 데이터 관리
