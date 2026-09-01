# 📚 Pet Care Manager Mobile Study

Flutter로 `Pet Care Manager Mobile`을 개발하면서 공부한 내용을 정리한 문서입니다.

개발하면서 새롭게 배운 Flutter, Dart, SQLite, 날짜/시간 처리, 로컬 알림, Android 설정, Git 등의 개념과 실제 프로젝트에 적용한 내용을 기록합니다.

---

## 1. Flutter 기본 명령어

### `flutter doctor`

Flutter 개발 환경에 문제가 없는지 확인합니다.

```bash
flutter doctor
```

Flutter SDK, Android SDK, 연결된 기기 등의 상태를 확인할 수 있습니다.

---

### `flutter devices`

현재 Flutter에서 사용할 수 있는 기기를 확인합니다.

```bash
flutter devices
```

예:

* Android Emulator
* iOS Simulator
* Windows
* Chrome
* Edge

---

### `flutter run`

Flutter 앱을 실행합니다.

```bash
flutter run
```

특정 기기에서 실행하려면:

```bash
flutter run -d <device_id>
```

---

### `flutter emulators`

설치된 에뮬레이터를 확인합니다.

```bash
flutter emulators
```

에뮬레이터 실행:

```bash
flutter emulators --launch <emulator_id>
```

---

## 2. Flutter 패키지 관리

Flutter에서는 외부 라이브러리(패키지)를 `pubspec.yaml`에서 관리합니다.

예를 들어 캘린더 기능을 추가하기 위해 `table_calendar` 패키지를 사용할 수 있습니다.

```yaml
dependencies:
  table_calendar: ^3.2.0
```

---

### `flutter pub get`

`pubspec.yaml`에 추가하거나 변경한 패키지를 프로젝트에 적용합니다.

```bash
flutter pub get
```

패키지 적용 과정:

```text
pubspec.yaml 수정
        ↓
패키지 추가
        ↓
flutter pub get
        ↓
패키지 다운로드 및 적용
```

---

### `flutter pub add`

패키지를 추가하면서 `pubspec.yaml`에 의존성을 자동으로 등록하고 설치합니다.

```bash
flutter pub add table_calendar
```

개발용 패키지는 `--dev` 옵션을 사용할 수 있습니다.

```bash
flutter pub add --dev flutter_launcher_icons
```

---

### `flutter pub outdated`

현재 사용 중인 패키지와 업데이트 가능한 패키지를 확인합니다.

```bash
flutter pub outdated
```

---

### `flutter pub upgrade`

패키지를 가능한 최신 버전으로 업데이트합니다.

```bash
flutter pub upgrade
```

---

## 3. Flutter 화면 개발

### `Scaffold`

Flutter 화면의 기본 구조를 제공합니다.

```dart
Scaffold(
  appBar: AppBar(),
  body: ...,
  floatingActionButton: ...,
)
```

주로 다음과 같은 화면 구성에 사용합니다.

* AppBar
* Body
* FloatingActionButton
* BottomNavigationBar

---

### `AppBar`

화면 상단의 앱 바를 구성합니다.

```dart
AppBar(
  title: const Text('펫몽'),
)
```

---

### `SafeArea`

노치, 상태 표시줄, 홈 인디케이터 등의 시스템 UI와 겹치지 않도록 화면의 안전 영역을 확보합니다.

```dart
SafeArea(
  child: Column(
    children: [
      ...
    ],
  ),
)
```

---

### `SingleChildScrollView`

화면의 내용이 화면보다 길어질 경우 스크롤할 수 있도록 합니다.

등록 화면처럼 입력 항목이 여러 개 있는 화면에서 사용할 수 있습니다.

```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    children: [
      ...
    ],
  ),
)
```

---

### `Expanded`

`Row`나 `Column` 안에서 남은 공간을 차지하도록 합니다.

```dart
Column(
  children: [
    Expanded(
      child: SingleChildScrollView(
        child: ...,
      ),
    ),
  ],
)
```

예를 들어 등록 화면에서 입력 영역은 남은 공간을 차지하고 저장 버튼은 화면 하단에 배치하는 방식으로 사용할 수 있습니다.

---

### `ListView`

스크롤 가능한 목록을 만들 때 사용합니다.

```dart
ListView.builder(
  itemCount: pets.length,
  itemBuilder: (context, index) {
    final pet = pets[index];

    return Text(pet.name);
  },
)
```

---

### `Card`

정보를 하나의 카드 형태로 묶을 때 사용합니다.

```dart
Card(
  child: ListTile(
    title: Text(pet.name),
  ),
)
```

---

### `ListTile`

목록에서 제목, 설명, 아이콘 등을 일정한 형태로 배치할 때 편리합니다.

```dart
ListTile(
  leading: const Icon(Icons.pets),
  title: Text(pet.name),
  subtitle: Text(pet.breed ?? '품종 미입력'),
)
```

---

## 4. StatelessWidget

화면의 상태가 변경되지 않는 위젯을 만들 때 사용합니다.

예를 들어 `PetProfileHeader`처럼 전달받은 `Pet` 정보를 화면에 표시하는 위젯은 `StatelessWidget`으로 만들 수 있습니다.

```dart
class PetProfileHeader extends StatelessWidget {
  final Pet pet;

  const PetProfileHeader({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Text(pet.name);
  }
}
```

`StatelessWidget`은 자체적으로 변경되는 상태를 관리하지 않습니다.

---

## 5. StatefulWidget

화면의 데이터가 변경될 수 있을 때 사용합니다.

예:

* 반려동물 목록
* 선택한 날짜
* 입력한 데이터
* DB에서 불러온 데이터
* 완료 여부
* 선택된 탭

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

`StatefulWidget` 자체와 실제 변경되는 상태를 관리하는 `State` 객체가 분리되어 있습니다.

---

## 6. `initState()`

`StatefulWidget`이 처음 생성될 때 한 번 실행됩니다.

```dart
@override
void initState() {
  super.initState();

  loadPets();
}
```

화면이 처음 열릴 때 DB 데이터를 불러오거나 기존 데이터를 입력창에 표시하는 등의 작업에 사용할 수 있습니다.

예를 들어 체중 기록 수정 화면에서는:

```dart
if (record != null) {
  weightController.text = record.weight.toString();
  memoController.text = record.memo ?? '';
  selectedDate = record.date;
}
```

처럼 기존 데이터를 입력창에 넣을 수 있습니다.

---

## 7. `setState()`

화면에 표시되는 상태가 변경되었음을 Flutter에 알려줍니다.

```dart
setState(() {
  selectedDate = pickedDate;
});
```

`setState()`가 실행되면 해당 위젯이 다시 그려집니다.

프로젝트에서는 다음과 같은 상황에서 사용했습니다.

* 날짜 선택
* 다음 예방접종일 변경
* 다음 예방접종일 삭제
* 약 복용 완료 상태 변경
* 목록 새로고침
* 선택된 기록 탭 변경

---

## 8. `mounted`

비동기 작업이 끝난 후 해당 위젯이 아직 화면에 존재하는지 확인할 때 사용합니다.

```dart
if (!mounted) {
  return;
}
```

예를 들어 DB 저장이 완료되기 전에 사용자가 화면을 닫았을 경우, 이미 사라진 화면에서 `Navigator`나 `setState()`를 실행하는 것을 방지할 수 있습니다.

비동기 작업 이후 UI를 변경할 때 유용한 안전 장치입니다.

---

## 9. 화면 이동

### `Navigator.push()`

현재 화면 위에 새로운 화면을 추가합니다.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PetRegisterScreen(),
  ),
);
```

예:

```text
HomeScreen
    ↓
PetRegisterScreen
```

---

### `Navigator.pop()`

현재 화면을 닫고 이전 화면으로 돌아갑니다.

```dart
Navigator.pop(context);
```

---

### `Navigator.pop()`으로 결과 전달

현재 화면에서 이전 화면으로 값을 전달할 수도 있습니다.

```dart
Navigator.pop(context, true);
```

이 경우 이전 화면에서는:

```dart
final result = await Navigator.push(...);

if (result == true) {
  loadPets();
}
```

처럼 결과를 받을 수 있습니다.

날짜나 삭제 결과를 전달할 수도 있습니다.

```dart
Navigator.pop(context, selectedDate);
```

또는:

```dart
Navigator.pop(context, true);
```

---

## 10. 사용자 입력

### `TextEditingController`

`TextField`에 입력된 값을 가져오거나 수정할 때 사용합니다.

```dart
final TextEditingController nameController =
    TextEditingController();
```

값 가져오기:

```dart
final name = nameController.text;
```

값을 입력창에 설정하기:

```dart
nameController.text = '프리다';
```

사용이 끝나면 `dispose()`합니다.

```dart
@override
void dispose() {
  nameController.dispose();

  super.dispose();
}
```

---

### `TextField`

사용자가 문자열이나 숫자 등의 값을 입력할 수 있는 입력창입니다.

```dart
TextField(
  controller: weightController,
  decoration: const InputDecoration(
    labelText: '* 몸무게',
    hintText: '예: 3.5',
  ),
)
```

---

### `TextInputType.numberWithOptions`

숫자 입력에 적합한 키보드를 표시할 때 사용할 수 있습니다.

체중처럼 소수점이 필요한 값은 `decimal: true`를 사용할 수 있습니다.

```dart
keyboardType: const TextInputType.numberWithOptions(
  decimal: true,
)
```

---

### `double.tryParse()`

문자열을 `double` 타입 숫자로 변환합니다.

변환할 수 없는 값이면 오류를 발생시키는 대신 `null`을 반환합니다.

```dart
final weight = double.tryParse(weightText);
```

따라서 입력값 검증에 사용할 수 있습니다.

```dart
if (weight == null || weight <= 0) {
  // 잘못된 입력
}
```

---

## 11. 터치 이벤트

### `GestureDetector`

화면의 특정 영역에서 사용자의 터치 동작을 감지합니다.

```dart
GestureDetector(
  onTap: () {
    // 터치했을 때 실행
  },
  child: ...,
)
```

대표적인 이벤트:

```text
onTap          한 번 탭
onDoubleTap    두 번 탭
onLongPress    길게 누르기
onTapDown      누르는 순간
onTapUp        손가락을 뗀 순간
```

---

### `InkWell`

`GestureDetector`처럼 터치 이벤트를 처리하면서 Material 디자인의 Ripple 효과를 제공합니다.

```dart
InkWell(
  onTap: () {
    // 터치했을 때 실행
  },
  child: ...,
)
```

날짜 선택 영역처럼 사용자가 터치할 수 있는 UI에 사용할 수 있습니다.

---

## 12. 조건부 UI

Flutter에서는 조건에 따라 특정 위젯을 표시할 수 있습니다.

### 일반적인 `if`

```dart
if (isEditing)
  IconButton(
    onPressed: _deleteVaccination,
    icon: const Icon(Icons.delete_outline),
  ),
```

`isEditing`이 `true`일 때만 삭제 버튼이 표시됩니다.

---

### Collection-if

여러 위젯을 조건에 따라 추가할 수도 있습니다.

```dart
if (nextDate != null) ...[
  Text(...),
  IconButton(...),
] else ...[
  Text('날짜 선택 (선택사항)'),
]
```

---

### Spread operator `...`

여러 위젯을 한 번에 리스트에 추가할 때 사용합니다.

```dart
...[
  Text(...),
  Icon(...),
]
```

Flutter에서 조건부로 여러 위젯을 표시할 때 `if`와 함께 자주 사용합니다.

---

## 13. 리스트와 문자열 처리

### `List<String>`

문자열 데이터를 여러 개 묶어서 관리할 수 있습니다.

```dart
final List<String> details = [];
```

예를 들어 반려동물의 품종, 성별, 몸무게를 하나의 리스트에 담을 수 있습니다.

```dart
if (pet.breed != null && pet.breed!.isNotEmpty) {
  details.add(pet.breed!);
}

if (pet.gender != null && pet.gender!.isNotEmpty) {
  details.add(pet.gender!);
}
```

---

### `join()`

리스트의 문자열을 하나의 문자열로 합칩니다.

```dart
details.join(' • ')
```

예:

```text
['푸들', '남아', '3.5kg']
```

결과:

```text
푸들 • 남아 • 3.5kg
```

---

## 14. 문자열 보간

Dart에서는 `$`를 사용하여 문자열 안에 변수를 넣을 수 있습니다.

```dart
final name = '프리다';

print('우리 아이는 $name입니다.');
```

객체의 속성이나 계산식에는 `${}`를 사용할 수 있습니다.

```dart
print('${pet.name}의 몸무게는 ${pet.weight}kg입니다.');
```

---

## 15. null 처리

Dart에서는 `?`를 사용하여 null이 될 수 있는 값을 표현합니다.

```dart
DateTime? nextDate;
```

`nextDate`가 null일 수도 있다는 의미입니다.

---

### `??`

왼쪽 값이 null이면 오른쪽 값을 사용합니다.

```dart
nextDate ?? vaccinationDate
```

---

### `?.`

값이 null이 아닐 때만 뒤의 함수나 속성을 실행합니다.

```dart
medication.medicationTime?.format(context)
```

---

### `!`

해당 값이 null이 아니라고 Dart에게 알려줍니다.

```dart
nextDate!
```

실제 값이 null이면 오류가 발생할 수 있으므로 주의해야 합니다.

---

## 16. 날짜 처리

Dart에서는 `DateTime`을 사용하여 날짜와 시간을 관리합니다.

```dart
final today = DateTime.now();
```

---

### `DateTime.now()`

현재 날짜와 시간을 가져옵니다.

```dart
final now = DateTime.now();
```

---

### `DateTime` 날짜 직접 생성

```dart
final date = DateTime(
  2026,
  8,
  21,
);
```

---

### 날짜 차이 계산

```dart
final difference =
    nextDate.difference(today).inDays;
```

예:

```text
difference == 0
→ 오늘

difference == 1
→ 내일

difference > 1
→ 며칠 남음
```

---

### 날짜만 비교하기

`DateTime.now()`에는 시간 정보까지 포함되어 있기 때문에 날짜만 비교하고 싶다면 시간 정보를 제거할 수 있습니다.

```dart
final todayOnly = DateTime(
  today.year,
  today.month,
  today.day,
);
```

---

### `showDatePicker()`

Flutter에서 날짜를 선택할 수 있는 달력 UI를 표시합니다.

```dart
final pickedDate = await showDatePicker(
  context: context,
  initialDate: selectedDate,
  firstDate: DateTime(2000),
  lastDate: DateTime.now(),
);
```

사용자가 날짜를 선택하면 `DateTime?` 형태로 결과가 반환됩니다.

```dart
if (pickedDate != null) {
  setState(() {
    selectedDate = pickedDate;
  });
}
```

---

### 날짜 선택 범위 제한

`firstDate`와 `lastDate`를 이용하면 선택할 수 있는 날짜 범위를 제한할 수 있습니다.

예:

```dart
firstDate: DateTime(2000),
lastDate: DateTime.now(),
```

다음 접종일은 현재 접종일보다 이전 날짜를 선택하지 못하도록 할 수도 있습니다.

```dart
firstDate: vaccinationDate,
lastDate: DateTime(2100),
```

---

### 날짜 표시 형식 만들기

날짜를 `yyyy.MM.dd` 형태로 표시할 수 있습니다.

```dart
'${selectedDate.year}.'
'${selectedDate.month.toString().padLeft(2, '0')}.'
'${selectedDate.day.toString().padLeft(2, '0')}'
```

`padLeft(2, '0')`을 사용하면:

```text
1  → 01
8  → 08
12 → 12
```

처럼 두 자리로 맞출 수 있습니다.

---

## 17. 한국 시간 기준 날짜/시간 처리

프로젝트에서는 한국에서 사용하는 앱이기 때문에 날짜와 시간을 명확하게 한국 시간 기준으로 처리할 필요가 있습니다.

이를 위해 `DateTimeUtils`를 사용하여 날짜와 현재 시간을 관리합니다.

```dart
final today = DateTimeUtils.todayKst();
```

현재 한국 시간:

```dart
final now = DateTimeUtils.nowKst();
```

이렇게 공통 함수를 사용하면 화면마다 `DateTime.now()`를 직접 사용하는 것보다 날짜 기준을 일관되게 관리할 수 있습니다.

특히 약 복용 일정처럼:

```text
오늘
↓
오늘 복용
↓
내일 복용
↓
다음 예정일
```

을 판단해야 하는 기능에서는 날짜 기준을 통일하는 것이 중요합니다.

---

## 18. `TimeOfDay`

Flutter에서는 시간을 선택하거나 표시할 때 `TimeOfDay`를 사용할 수 있습니다.

```dart
TimeOfDay(
  hour: 9,
  minute: 30,
)
```

현재 프로젝트에서는 약 복용 시간 관리에 사용합니다.

```dart
medication.medicationTime?.format(context)
```

예:

```dart
subtitle:
    medication.medicationTime?.format(context) ?? '',
```

복용 시간이 있으면 화면에 표시하고 없으면 빈 문자열을 사용할 수 있습니다.

---

## 19. 이미지 파일 처리

반려동물 프로필 이미지처럼 로컬 파일을 화면에 표시할 수 있습니다.

```dart
import 'dart:io';
```

파일 경로를 이용하여 `File` 객체를 만들 수 있습니다.

```dart
File(pet.imagePath!)
```

그리고 `FileImage`를 사용하여 이미지로 표시합니다.

```dart
backgroundImage: pet.imagePath != null
    ? FileImage(File(pet.imagePath!))
    : null,
```

이미지가 없으면 기본 아이콘을 표시할 수도 있습니다.

```dart
child: pet.imagePath == null
    ? const Icon(Icons.pets, size: 48)
    : null,
```

---

## 20. 비동기 처리

Flutter에서는 DB 작업이나 알림 예약처럼 시간이 걸릴 수 있는 작업에 비동기 처리를 사용합니다.

### `Future`

나중에 결과가 반환될 수 있는 작업을 나타냅니다.

```dart
Future<void> saveWeightRecord() async {
  ...
}
```

---

### `async`

함수 안에서 비동기 작업을 처리할 수 있도록 합니다.

```dart
Future<void> saveWeightRecord() async {
  await DatabaseHelper.instance.insertWeightRecord(record);
}
```

---

### `await`

비동기 작업이 완료될 때까지 기다립니다.

```dart
await DatabaseHelper.instance.insertWeightRecord(record);
```

---

### `try-catch`

비동기 작업이나 DB 작업 중 발생할 수 있는 예외를 처리할 수 있습니다.

```dart
try {
  await DatabaseHelper.instance.insertWeightRecord(record);
} catch (e) {
  print(e);
}
```

---

### 실제 사용 흐름

체중 기록 저장:

```text
사용자가 저장 버튼 클릭
        ↓
입력값 검증
        ↓
WeightRecord 생성
        ↓
SQLite 저장
        ↓
저장 완료 대기
        ↓
이전 화면으로 이동
```

---

## 21. SQLite

Pet Care Manager Mobile에서는 SQLite를 사용하여 데이터를 로컬에 저장합니다.

주요 테이블:

```text
pets
health_records
vaccinations
weight_records
medications
medication_logs
```

---

### DatabaseHelper

데이터베이스 접근 코드를 한 곳에서 관리하기 위해 `DatabaseHelper`를 사용합니다.

```text
Screen
   ↓
DatabaseHelper
   ↓
SQLite
```

화면에서 직접 SQL을 처리하는 대신 `DatabaseHelper`를 통해 DB에 접근하도록 구성했습니다.

---

### Singleton 패턴

`DatabaseHelper`를 Singleton으로 구성하면 앱 전체에서 하나의 DB 접근 객체를 사용할 수 있습니다.

```text
화면 A ─┐
화면 B ─┼→ DatabaseHelper → SQLite
화면 C ─┘
```

---

### 데이터 조회

```dart
final maps = await db.query(
  'pets',
);
```

---

### 데이터 추가

```dart
await db.insert(
  'pets',
  pet.toMap(),
);
```

---

### 데이터 수정

```dart
await db.update(
  'pets',
  pet.toMap(),
  where: 'id = ?',
  whereArgs: [pet.id],
);
```

---

### 데이터 삭제

```dart
await db.delete(
  'pets',
  where: 'id = ?',
  whereArgs: [pet.id],
);
```

---

### CRUD

SQLite에서 기본적으로 사용하는 데이터 처리 구조입니다.

```text
Create
  ↓
데이터 추가

Read
  ↓
데이터 조회

Update
  ↓
데이터 수정

Delete
  ↓
데이터 삭제
```

프로젝트에서는 다음 데이터에 CRUD를 적용했습니다.

* 반려동물
* 건강 기록
* 예방접종
* 체중 기록
* 약 복용 기록

---

### 등록과 수정 구분

등록 화면 하나에서 신규 등록과 기존 데이터 수정을 함께 처리할 수 있습니다.

```dart
if (widget.record == null) {
  await DatabaseHelper.instance.insertWeightRecord(record);
} else {
  await DatabaseHelper.instance.updateWeightRecord(record);
}
```

`widget.record`가 `null`이면 신규 등록이고, 값이 있으면 수정입니다.

---

### SQLite Migration

데이터베이스 구조가 변경되면 데이터베이스 버전을 올리고 Migration을 처리할 수 있습니다.

```text
DB Version 1
    ↓
기본 테이블 생성
    ↓
DB Version 2
    ↓
새로운 테이블 추가
```

프로젝트에서는 기능이 추가되면서 필요한 테이블을 추가하거나 DB 구조를 변경할 수 있도록 Migration 구조를 적용했습니다.

---

## 22. Model 설계

데이터베이스의 데이터를 화면에서 사용하기 쉽게 Dart Model로 분리했습니다.

주요 Model:

```text
Pet
HealthRecord
Vaccination
WeightRecord
Medication
MedicationLog
```

예:

```dart
class Pet {
  final int? id;
  final String name;

  Pet({
    this.id,
    required this.name,
  });
}
```

DB에 저장할 때는 `toMap()`을 사용하고, DB에서 읽어온 데이터는 Model 객체로 변환하는 구조를 사용합니다.

```text
SQLite Map
    ↓
Model
    ↓
Flutter UI
```

---

## 23. Widget 분리

화면의 코드가 너무 길어지거나 특정 UI가 독립적인 역할을 가지게 되면 Widget을 별도 파일로 분리할 수 있습니다.

현재 프로젝트에서는 다음과 같은 Widget을 분리했습니다.

```text
widgets/

├── pet_profile_header.dart
└── weight_chart.dart
```

---

### 별도 Widget으로 분리하기 좋은 경우

다음과 같은 경우 별도 Widget으로 분리하는 것이 좋습니다.

* 여러 화면에서 재사용되는 UI
* 하나의 독립적인 역할을 가지는 UI
* 코드가 길어지는 UI
* 상태나 동작을 자체적으로 관리하는 UI
* 화면의 핵심 로직과 분리하고 싶은 UI

---

### 화면 내부 메서드와 Widget의 차이

간단한 UI를 화면 안에서만 사용한다면 `_buildSomething()` 형태의 메서드로 만들 수 있습니다.

```dart
Widget _buildTodayHealthTasks() {
  return ...;
}
```

반면 독립적인 UI이거나 재사용 가능성이 있거나 코드 규모가 커진다면 별도의 Widget으로 분리할 수 있습니다.

```text
화면 내부에서만 사용하는 간단한 UI
        ↓
_buildSomething()

독립적 / 재사용 / 규모가 큰 UI
        ↓
별도 Widget
```

프로젝트를 개발하면서 UI 규모가 커질수록 적절하게 Widget을 분리하는 것이 유지보수에 중요하다는 것을 학습했습니다.

---

## 24. 체중 변화 그래프

`fl_chart`를 사용하여 반려동물의 체중 변화를 그래프로 표시했습니다.

```text
X축
→ 날짜

Y축
→ 체중(kg)
```

주요 기능:

* 날짜순 체중 데이터 표시
* 체중 변화 시각화
* 그래프 포인트 선택
* 선택한 날짜 확인
* 선택한 체중 확인

단순한 목록보다 시간에 따른 변화를 쉽게 확인할 수 있도록 구현했습니다.

---

## 25. 건강 캘린더

`table_calendar`를 사용하여 날짜별 건강 기록을 확인할 수 있도록 구현했습니다.

캘린더에서 특정 날짜를 선택하면 해당 날짜에 등록된 건강 관련 데이터를 확인할 수 있습니다.

관리 가능한 기록:

* 🏥 건강 기록
* 💉 예방접종 기록
* ⚖️ 체중 기록
* 💊 약 복용 기록

---

## 26. 로컬 알림

Flutter에서 앱 내부 알림 기능을 구현하기 위해 `flutter_local_notifications` 패키지를 사용했습니다.

설치:

```bash
flutter pub add flutter_local_notifications
```

현재 프로젝트에서는 다음 버전을 사용합니다.

```yaml
flutter_local_notifications: ^22.3.0
```

---

### NotificationService

알림과 관련된 기능을 하나의 클래스로 관리하기 위해 별도의 서비스를 만들었습니다.

```dart
class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
}
```

---

### Singleton 패턴

```dart
NotificationService._();
```

외부에서 `NotificationService()`로 객체를 계속 생성하지 못하도록 private 생성자를 사용합니다.

```dart
static final NotificationService instance =
    NotificationService._();
```

앱 전체에서 하나의 `NotificationService` 객체를 공유할 수 있습니다.

사용할 때:

```dart
NotificationService.instance
```

처럼 접근합니다.

---

### `FlutterLocalNotificationsPlugin`

실제로 알림 기능을 담당하는 객체입니다.

```dart
final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();
```

다음 기능을 구현할 수 있습니다.

* 알림 초기화
* 예약 알림
* 반복 알림
* 알림 취소
* 알림 권한 요청

---

## 27. Android 알림 초기화

Android에서 사용할 알림 아이콘을 설정할 수 있습니다.

```dart
const androidSettings = AndroidInitializationSettings(
  '@mipmap/ic_launcher',
);
```

---

## 28. iOS 알림 초기화

iOS 알림 기능을 초기화하기 위한 설정입니다.

```dart
const iosSettings = DarwinInitializationSettings();
```

---

### `InitializationSettings`

Android와 iOS의 설정을 하나로 묶습니다.

```dart
const settings = InitializationSettings(
  android: androidSettings,
  iOS: iosSettings,
);
```

---

### 알림 초기화

```dart
await _notifications.initialize(
  settings: settings,
);
```

앱이 시작될 때 알림 기능을 사용할 수 있도록 초기화합니다.

---

## 29. Android 알림 권한

Android 13 이상에서는 알림 권한을 요청해야 합니다.

```dart
await androidPlugin?.requestNotificationsPermission();
```

정확한 시간에 알림을 예약하기 위해 정확한 알람 권한도 요청할 수 있습니다.

```dart
await androidPlugin?.requestExactAlarmsPermission();
```

---

## 30. Timezone

특정 시간에 알림을 예약하려면 날짜와 시간을 정확하게 처리해야 합니다.

Flutter에서는 `timezone` 패키지를 사용하여 시간대를 관리할 수 있습니다.

설치:

```bash
flutter pub add timezone
```

현재 프로젝트에서는 다음 버전을 사용합니다.

```yaml
timezone: ^0.11.1
```

---

### 한국 시간대 설정

Timezone 데이터를 초기화한 후 한국 시간대를 명시적으로 설정합니다.

```dart
tz_data.initializeTimeZones();

tz.setLocalLocation(
  tz.getLocation('Asia/Seoul'),
);
```

---

### `tz.TZDateTime`

예약 알림에서는 Timezone을 적용한 날짜와 시간을 사용합니다.

```dart
scheduledDate: tz.TZDateTime.from(
  scheduledDate,
  tz.local,
),
```

이를 통해 예약 시간을 명확한 시간대 기준으로 처리할 수 있습니다.

---

## 31. 예약 알림

### `zonedSchedule()`

특정 날짜와 시간에 알림을 예약합니다.

```dart
await _notifications.zonedSchedule(
  id: id,
  title: title,
  body: body,
  scheduledDate: tz.TZDateTime.from(
    scheduledDate,
    tz.local,
  ),
  notificationDetails: ...,
  androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
);
```

---

### `exactAllowWhileIdle`

Android가 절전 상태에 있더라도 예약한 시간에 최대한 정확하게 알림을 실행하도록 요청합니다.

```dart
androidScheduleMode:
    AndroidScheduleMode.exactAllowWhileIdle,
```

정확한 알림 예약을 사용하기 때문에 Android에서는 정확한 알람 권한이 필요할 수 있습니다.

---

## 32. 반복 알림

약 복용 알림은 반복 유형에 따라 예약 방식을 다르게 처리합니다.

현재 프로젝트에서는:

```text
none
daily
weekly
interval
```

형태로 반복 유형을 구분합니다.

---

### 반복 없음

```dart
if (repeatType == 'none') {
  await _schedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: scheduledDate,
  );
}
```

한 번만 알림을 예약합니다.

---

### 매일 반복

```dart
matchDateTimeComponents:
    DateTimeComponents.time,
```

시간만 일치하도록 설정하면 매일 같은 시간에 알림을 반복할 수 있습니다.

예:

```text
매일 오전 9:00
```

---

### 매주 반복

```dart
matchDateTimeComponents:
    DateTimeComponents.dayOfWeekAndTime,
```

요일과 시간을 기준으로 반복할 수 있습니다.

예:

```text
매주 월요일 오전 9:00
```

---

### N일마다 반복

`flutter_local_notifications`의 기본 반복 방식만으로 처리하기 어려운 N일 간격 알림은 여러 개의 개별 예약을 생성하는 방식으로 구현했습니다.

예를 들어 3일마다 복용하는 경우:

```text
1일차
  ↓
4일차
  ↓
7일차
  ↓
10일차
  ↓
...
```

다음 예정 날짜를 계산합니다.

```dart
nextScheduledDate = nextScheduledDate.add(
  Duration(days: repeatInterval),
);
```

---

### 과거 날짜 건너뛰기

예약 시작 날짜가 이미 과거라면 가장 가까운 미래 날짜까지 반복해서 날짜를 이동합니다.

```dart
while (nextScheduledDate.isBefore(now)) {
  nextScheduledDate = nextScheduledDate.add(
    Duration(days: repeatInterval),
  );
}
```

이를 통해 과거에 해당하는 예약을 만들지 않고 앞으로 실행될 알림부터 예약할 수 있습니다.

---

### 반복 알림 ID

N일마다 반복되는 알림은 각각 다른 ID가 필요합니다.

현재 프로젝트에서는:

```dart
id * 1000 + i
```

방식으로 ID를 생성합니다.

예를 들어 기본 ID가 `5`라면:

```text
5000
5001
5002
5003
...
```

처럼 각각 다른 예약 ID를 만들 수 있습니다.

---

### 반복 알림 취소

예약할 때 생성한 ID를 이용하여 각각의 알림을 취소합니다.

```dart
for (int i = 0; i < repeatCount; i++) {
  await _notifications.cancel(
    id: id * 1000 + i,
  );
}
```

따라서 N일마다 반복되는 알림을 취소할 때도 동일한 ID 계산 규칙이 필요합니다.

---

## 33. 약 복용 일정 데이터 설계

약 복용 기능에서는 `Medication`이 약 자체의 일정 정보를 관리합니다.

주요 데이터:

```text
Medication

id
petId
medicationName
medicationDate
medicationTime
nextDate
memo
repeatType
repeatInterval
```

약 복용 일정은 단순히 한 날짜만 저장하는 것이 아니라 반복 여부에 따라 다음 복용일을 계산해야 합니다.

```text
Medication
     ↓
복용 시작일
     ↓
반복 유형
     ↓
다음 복용일 계산
     ↓
오늘 일정 / 예정 일정
```

---

## 34. 약 복용 완료 상태

약 복용 일정과 실제 복용 완료 여부를 구분하기 위해 `Medication`과 `MedicationLog`를 분리했습니다.

```text
Medication

→ 약 자체의 복용 일정

MedicationLog

→ 특정 날짜에 실제로 복용을 완료했는지 기록
```

예:

```text
Medication
    ↓
매일 오전 9시 복용

MedicationLog
    ↓
2026-08-28
복용 완료

MedicationLog
    ↓
2026-08-29
미복용
```

이 구조를 사용하면 반복되는 약 복용 일정과 날짜별 완료 상태를 별도로 관리할 수 있습니다.

---

### 오늘 복용 완료 처리

오늘의 약 복용 항목을 완료하면 `MedicationLog`에 해당 날짜의 완료 상태를 저장합니다.

```text
오늘의 약
    ↓
복용 완료 버튼
    ↓
MedicationLog 저장
    ↓
화면 상태 변경
```

앱을 종료했다가 다시 실행해도 SQLite에 저장된 완료 상태를 확인할 수 있습니다.

---

### 완료 취소

완료된 약을 다시 미완료 상태로 변경할 수도 있습니다.

```text
복용 완료
    ↓
완료 취소
    ↓
MedicationLog 상태 변경 또는 삭제
    ↓
미완료 상태 표시
```

---

## 35. 오늘 일정과 예정 일정 분리

약 복용 기능을 구현하면서 모든 약을 하나의 목록으로 보여주는 것보다 날짜 기준으로 분리하는 것이 사용자에게 더 이해하기 쉽다는 것을 학습했습니다.

현재 프로젝트에서는 크게 다음과 같이 구분합니다.

```text
오늘 복용할 약
      ↓
todayMedications

앞으로 복용할 약
      ↓
upcomingMedications
```

오늘 일정에서는 실제 복용 완료 여부까지 함께 표시합니다.

```text
오늘의 약
   ↓
복용 예정
   ↓
복용 완료
```

미래 일정에서는 다음 복용 예정일을 중심으로 표시합니다.

---

## 36. 약 복용 일정 상태

오늘의 약 목록에서는 복용 시간이 현재 시간보다 지났는지, 아직 남았는지를 판단하여 상태를 표시할 수 있습니다.

프로젝트에서는 `scheduleStatus`를 이용하여 상태를 구분합니다.

```text
passed
→ 복용 시간이 지남

upcoming
→ 아직 복용 시간이 되지 않음
```

예:

```text
09:00 약 복용
      ↓
현재 10:00
      ↓
passed
```

반대로:

```text
14:00 약 복용
      ↓
현재 10:00
      ↓
upcoming
```

이를 통해 오늘 일정에서도 단순히 약 이름만 보여주는 것이 아니라 현재 상황을 함께 표시할 수 있습니다.

---

## 37. 반복 약의 다음 복용일 계산

반복 약은 오늘 일정과 미래 일정을 구분하기 위해 다음 복용일을 계산해야 합니다.

프로젝트에서는 반복 유형에 따라 다음 복용일을 계산합니다.

```text
none
daily
weekly
interval
```

---

### 반복하지 않는 약

반복하지 않는 약은 오늘 이후의 날짜만 예정 일정으로 처리합니다.

```text
오늘 이후
→ 예정 일정

오늘
→ 오늘 일정

과거
→ 과거 기록
```

---

### 매일 복용

오늘이거나 이미 지난 날짜라면 하루씩 이동하여 오늘 이후의 가장 가까운 날짜를 찾습니다.

```dart
while (!baseDate.isAfter(today)) {
  baseDate = baseDate.add(
    const Duration(days: 1),
  );
}
```

---

### 매주 복용

오늘이거나 이미 지난 날짜라면 7일씩 이동합니다.

```dart
while (!baseDate.isAfter(today)) {
  baseDate = baseDate.add(
    const Duration(days: 7),
  );
}
```

---

### N일마다 복용

`repeatInterval`에 저장된 일수만큼 이동합니다.

```dart
while (!baseDate.isAfter(today)) {
  baseDate = baseDate.add(
    Duration(days: interval),
  );
}
```

예:

```text
3일마다

8월 28일
   ↓
8월 31일
   ↓
9월 3일
   ↓
9월 6일
```

---

### 다음 복용일 계산의 핵심

중요한 것은 **오늘 복용해야 하는 약을 다음 복용일 계산에서 다시 오늘 일정으로 만들지 않는 것**입니다.

따라서 다음 예정일 계산에서는:

```text
baseDate > today
```

가 되도록 날짜를 이동합니다.

즉:

```text
오늘 일정
→ 오늘 복용해야 하는 약

예정 일정
→ 오늘 이후 가장 가까운 복용일
```

로 역할을 분리합니다.

---

## 38. 오늘의 건강 일정 UI

약 복용 기능을 확장하면서 특정 기능만 보여주는 것보다 사용자가 오늘 해야 할 건강 관련 일정을 한 곳에서 확인할 수 있도록 구성하는 방향을 학습했습니다.

예:

```text
오늘의 건강 일정

💊 약 복용
💉 예방접종
🏥 건강 기록
⚖️ 체중 기록
```

약 복용에서는:

```text
오늘 복용할 약
      ↓
약 이름
복용 시간
복용 상태
완료 버튼
```

과 같은 형태로 구성할 수 있습니다.

---

### 오늘 약 카드

프로젝트에서는 `_buildTodayMedicationCard()`와 같은 화면 내부 메서드를 사용하여 오늘의 약 목록을 하나의 UI 영역으로 구성할 수 있습니다.

```text
Today Medication Card
        ↓
약 개수
        ↓
오늘의 약 목록
        ↓
각 약의 시간 / 상태 / 완료 여부
```

---

### 오늘 약 항목

각 약 항목은 `_buildTodayMedicationItem()`과 같이 별도의 작은 UI 메서드로 구성할 수 있습니다.

표시 정보:

```text
약 이름
복용 시간
복용 상태
완료 / 취소
```

화면의 역할을 작은 단위로 나누면 전체 화면 코드를 이해하기 쉬워집니다.

---

## 39. 기록 탭 상태 관리

Pet Detail 화면에서는 여러 종류의 기록을 하나의 화면에서 보여주기 때문에 선택된 탭을 상태로 관리할 수 있습니다.

```dart
int selectedRecordTab = 0;
```

예:

```text
0 → 전체
1 → 건강
2 → 예방접종
3 → 약
4 → 체중
```

사용자가 탭을 변경하면 `setState()`를 통해 화면을 다시 그립니다.

```dart
setState(() {
  selectedRecordTab = index;
});
```

이 과정을 통해 하나의 상세 화면에서 여러 종류의 기록을 전환해서 확인할 수 있습니다.

---

## 40. Banner UI 공통화

예방접종과 약 복용처럼 서로 다른 데이터라도 화면에서 "다가오는 일정"이라는 비슷한 형태로 표시할 수 있습니다.

이런 경우 공통 UI 메서드를 사용할 수 있습니다.

```text
예방접종
   ↓
다가오는 일정

약 복용
   ↓
다가오는 일정
```

프로젝트에서는 `_buildBannerItem()`처럼 공통 UI를 만들고 데이터만 다르게 전달하는 방식으로 구조를 개선했습니다.

이런 방식은 동일한 UI가 여러 곳에서 반복되는 것을 줄이는 데 도움이 됩니다.

---

## 41. Core Library Desugaring

`flutter_local_notifications`를 Android에서 사용하면서 다음과 같은 오류가 발생할 수 있습니다.

```text
Dependency ':flutter_local_notifications'
requires core library desugaring to be enabled
```

Android의 `app/build.gradle.kts`에서 설정을 추가합니다.

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    isCoreLibraryDesugaringEnabled = true
}
```

그리고 `dependencies`에 desugaring 라이브러리를 추가합니다.

```kotlin
dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.5"
    )
}
```

Core Library Desugaring은 최신 Java API 기능을 낮은 Android 버전에서도 사용할 수 있도록 변환해 주는 기능입니다.

---

## 42. `flutter analyze`

Flutter 프로젝트의 Dart 코드를 정적으로 분석하여 코드에 문제가 있는지 검사합니다.

```bash
flutter analyze
```

찾아낼 수 있는 문제:

* 문법 오류
* 타입 오류
* 존재하지 않는 변수나 메서드 사용
* 사용하지 않는 import
* 사용하지 않는 변수
* 권장되지 않는 코드
* 기타 정적 분석 경고 및 오류

예:

```text
Analyzing pet_care_manager_mobile...

No issues found!
```

`No issues found!`가 나오면 현재 프로젝트에서 Flutter analyzer가 발견한 문제가 없다는 의미입니다.

---

### `flutter analyze`와 `flutter run`의 차이

| 명령어               | 목적                  |
| ----------------- | ------------------- |
| `flutter analyze` | 코드에 문제가 있는지 정적으로 검사 |
| `flutter run`     | 실제 기기/에뮬레이터에서 앱 실행  |

추천 흐름:

```text
코드 작성
   ↓
flutter analyze
   ↓
오류 / 경고 확인
   ↓
코드 수정
   ↓
flutter run
   ↓
실제 동작 확인
```

---

## 43. Git 기본 명령어

### `git status`

현재 변경된 파일을 확인합니다.

```bash
git status
```

---

### `git add`

변경한 파일을 커밋할 준비를 합니다.

```bash
git add .
```

특정 파일만 추가할 수도 있습니다.

```bash
git add README.md
```

---

### `git commit`

변경 내용을 하나의 기록으로 저장합니다.

```bash
git commit -m "docs: README 업데이트"
```

---

### `git push`

로컬에서 만든 커밋을 GitHub 저장소에 업로드합니다.

```bash
git push
```

---

### `git pull`

GitHub의 최신 변경 내용을 로컬로 가져옵니다.

```bash
git pull
```

---

### 일반적인 Git 작업 흐름

```text
코드 수정
   ↓
git status
   ↓
git add .
   ↓
git commit -m "커밋 메시지"
   ↓
git push
```

---

## 44. 앱 아이콘 변경

Flutter 앱의 기본 아이콘을 원하는 이미지로 변경하기 위해 `flutter_launcher_icons` 패키지를 사용할 수 있습니다.

### 패키지 설치

```bash
flutter pub add --dev flutter_launcher_icons
```

개발 환경에서 앱 아이콘을 생성하기 위한 도구이므로 `dev_dependencies`에 추가합니다.

---

### `pubspec.yaml` 설정

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```

---

### 아이콘 생성

```bash
dart run flutter_launcher_icons
```

설정된 이미지를 기반으로 Android 및 iOS에서 사용할 수 있는 다양한 크기의 앱 아이콘을 자동으로 생성합니다.

---

## 45. 개발하면서 배운 문제 해결

### `databaseFactory not initialized`

`sqflite`와 관련된 DB 초기화 문제입니다.

Flutter에서 사용하는 플랫폼과 SQLite 패키지 설정이 맞지 않을 때 발생할 수 있습니다.

DB를 사용하는 시점과 초기화 방식이 올바른지 확인해야 합니다.

---

### `flutter_local_notifications requires core library desugaring`

`flutter_local_notifications` 패키지를 Android에서 사용하기 위해 Core Library Desugaring 설정이 필요할 수 있습니다.

---

### `Undefined name 'NotificationService'`

`NotificationService` 클래스를 만들었지만 해당 파일을 `import`하지 않았을 때 발생할 수 있습니다.

```dart
import 'services/notification_service.dart';
```

클래스가 있는 경로를 정확하게 import해야 합니다.

---

### `The named parameter 'settings' is required`

사용 중인 패키지 버전에서 `initialize()` 메서드가 `settings`라는 named parameter를 요구할 때 발생할 수 있습니다.

기존 방식:

```dart
await _notifications.initialize(settings);
```

수정:

```dart
await _notifications.initialize(
  settings: settings,
);
```

패키지 버전에 따라 함수의 사용 방식이 달라질 수 있으므로 오류 메시지와 현재 패키지 버전을 함께 확인하는 것이 중요합니다.

---

### `Missing or invalid credentials`

GitHub에 로그인되어 있지 않거나 인증 정보가 올바르지 않을 때 발생할 수 있습니다.

GitHub 계정과 Git 인증 정보를 확인해야 합니다.

---

### 앱 아이콘 변경 후 기존 아이콘이 계속 표시되는 경우

`flutter_launcher_icons`로 아이콘을 변경한 후에도 에뮬레이터에서 기존 아이콘이 보일 수 있습니다.

이 경우 앱을 다시 빌드하거나 필요하면 앱을 삭제한 후 다시 설치하여 확인합니다.

---

## 46. 개발하면서 익힌 문제 해결 흐름

에러가 발생했을 때 무작정 코드를 수정하기보다는 다음과 같은 순서로 확인하는 습관을 익혔습니다.

```text
에러 발생

   ↓

에러 메시지 확인

   ↓

어떤 파일 / 어떤 코드에서 발생했는지 확인

   ↓

관련 패키지 버전 확인

   ↓

Flutter / Android 설정 확인

   ↓

코드 수정

   ↓

flutter analyze

   ↓

flutter run

   ↓

실제 동작 확인
```

특히 패키지를 추가한 이후 발생하는 오류는 현재 설치된 패키지 버전과 공식 문서의 사용법이 일치하는지 확인하는 것이 중요합니다.

---

## 47. 현재 프로젝트에서 사용한 주요 개념 정리

### Flutter

```text
Scaffold
AppBar
SafeArea
SingleChildScrollView
Expanded
ListView
Card
ListTile

StatelessWidget
StatefulWidget
initState()
setState()
mounted

Navigator.push()
Navigator.pop()

TextField
TextEditingController

GestureDetector
InkWell

showDatePicker()

조건부 UI
Collection-if
Spread operator

FileImage

Widget 분리
```

---

### Dart

```text
DateTime
TimeOfDay

DateTimeUtils
todayKst()
nowKst()

?
??
?.
!

List<String>
join()

double.tryParse()

문자열 보간

Future
async
await
try-catch
```

---

### SQLite

```text
sqflite
DatabaseHelper
Singleton

CRUD
Create
Read
Update
Delete

Model
toMap()
Migration

Medication
MedicationLog
```

---

### 로컬 알림

```text
flutter_local_notifications
NotificationService
Singleton

InitializationSettings
zonedSchedule()

Android 알림 권한
정확한 알람 권한

매일 반복
매주 반복
N일마다 반복

알림 취소
```

---

### Timezone

```text
timezone
Asia/Seoul
TZDateTime
```

---

### Android

```text
Core Library Desugaring
JavaVersion.VERSION_17
정확한 알람 권한
Android 알림 권한
```

---

### Git

```text
git status
git add
git commit
git push
git pull
```

---

## 48. 앞으로 추가해서 공부할 내용

### Flutter

* [x] `table_calendar` 사용
* [x] 캘린더에서 날짜 선택하기
* [x] 날짜별 건강 기록 조회
* [x] `StatefulWidget`
* [x] `StatelessWidget`
* [x] `initState()`
* [x] `setState()`
* [x] `mounted`
* [x] `Navigator.push()`
* [x] `Navigator.pop()` 결과 전달
* [x] `TextEditingController`
* [x] `GestureDetector`
* [x] `InkWell`
* [x] `showDatePicker()`
* [x] 조건부 UI
* [x] Collection-if / Spread operator
* [x] `FileImage`
* [x] `ListView`
* [x] `Card`
* [x] `ListTile`
* [x] Widget 분리
* [x] 화면 내부 `_build...()` 메서드 활용
* [x] 탭 상태 관리
* [ ] Flutter 화면 디자인 및 레이아웃 심화
* [ ] 더 복잡한 상태 관리 방식

---

### Dart

* [x] `DateTime`
* [x] `TimeOfDay`
* [x] 날짜 차이 계산
* [x] 날짜 범위 제한
* [x] 한국 시간 기준 날짜 처리
* [x] `??`
* [x] `?.`
* [x] `!`
* [x] 문자열 보간
* [x] `List<String>`
* [x] `join()`
* [x] `double.tryParse()`
* [x] `Future`
* [x] `async`
* [x] `await`
* [x] 예외 처리 (`try-catch`)
* [x] 반복 날짜 계산
* [ ] Class 심화
* [ ] Constructor 심화
* [ ] Enum
* [ ] Extension
* [ ] Generic

---

### SQLite

* [x] SQLite CRUD
* [x] 반려동물 데이터 관리
* [x] 건강 기록 관리
* [x] 예방접종 기록 관리
* [x] 체중 기록 관리
* [x] 약 복용 기록 관리
* [x] 약 복용 완료 로그 관리
* [x] DatabaseHelper Singleton
* [x] Model과 SQLite 연결
* [x] Database Migration
* [ ] SQLite JOIN
* [ ] 복잡한 SQL Query
* [ ] Index
* [ ] 데이터베이스 최적화

---

### 약 복용 기능

* [x] 약 복용 데이터 Model 설계
* [x] 약 복용 시간 관리
* [x] 반복 유형 관리
* [x] 매일 반복
* [x] 매주 반복
* [x] N일마다 반복
* [x] 다음 복용일 계산
* [x] 오늘 복용 일정 분리
* [x] 미래 예정 일정 분리
* [x] 복용 완료 상태 관리
* [x] 복용 완료 취소
* [x] `MedicationLog`
* [x] 복용 시간에 따른 상태 표시
* [x] 오늘 약 목록 UI
* [ ] 약 복용 일정 수정 기능 고도화
* [ ] 복용 이력 상세 화면
* [ ] 약 복용 통계

---

### 로컬 알림

* [x] `flutter_local_notifications` 패키지 설치 및 초기화
* [x] 알림 권한 요청
* [x] 특정 시간 예약 알림
* [x] 약 복용 시간 알림
* [x] 매일 반복 알림
* [x] 매주 반복 알림
* [x] N일마다 반복 알림
* [x] 예약 알림 취소
* [x] Timezone 적용
* [x] 정확한 알람 권한
* [x] 예방접종 예정 알림
* [ ] 즉시 알림
* [ ] 알림 설정 화면
* [ ] 알림 세부 설정

---

### Android

* [x] Core Library Desugaring
* [x] Android 알림 권한 처리
* [x] 정확한 알람 권한 처리
* [ ] Android Manifest 설정 심화
* [ ] Release 빌드
* [ ] APK / AAB 생성

---

### Git

* [x] `git status`
* [x] `git add`
* [x] `git commit`
* [x] `git push`
* [x] `git pull`
* [ ] Branch
* [ ] Merge
* [ ] Rebase
* [ ] GitHub Pull Request

---

### 앱 꾸미기

* [x] 앱 이름 변경
* [x] 앱 아이콘 변경
* [x] `flutter_launcher_icons` 패키지 사용
* [ ] Flutter 화면 디자인 및 레이아웃 심화
* [ ] Theme 설정
* [ ] 공통 색상 관리
* [ ] 공통 TextStyle 관리
* [ ] 다크 모드

---

## 49. 프로젝트를 통해 배운 개발 구조

Pet Care Manager Mobile을 개발하면서 단순히 화면을 만드는 것뿐만 아니라 각 역할을 분리하는 것이 중요하다는 것을 학습했습니다.

현재 프로젝트의 기본적인 구조는 다음과 같습니다.

```text
Screen
  ↓
Model
  ↓
DatabaseHelper
  ↓
SQLite
```

알림 기능은 별도의 Service로 분리했습니다.

```text
Screen
  ↓
NotificationService
  ↓
flutter_local_notifications
  ↓
Android / iOS Notification
```

UI 중 독립적인 기능은 Widget으로 분리했습니다.

```text
Screen
  ├── PetProfileHeader
  └── WeightChart
```

화면 내부에서만 사용하는 작은 UI는 `_build...()` 메서드로 관리할 수 있습니다.

```text
Screen
  ├── _buildTodayMedicationCard()
  ├── _buildTodayMedicationItem()
  └── _buildBannerItem()
```

이러한 구조를 사용하면 프로젝트의 규모가 커지더라도 각 기능을 나누어 관리하기 쉬워집니다.

---

## 50. 개발하면서 가장 중요하게 배운 점

### 기능이 많아질수록 역할을 분리해야 한다

처음에는 하나의 화면 파일에 모든 코드를 넣어도 동작할 수 있지만 기능이 많아질수록 코드가 복잡해집니다.

따라서:

```text
Screen
↓
UI

Model
↓
데이터 구조

DatabaseHelper
↓
DB 처리

Service
↓
외부 기능 처리

Widget
↓
독립적인 UI
```

처럼 역할을 나누는 것이 중요하다는 것을 배웠습니다.

---

### 화면에서 DB 코드를 직접 처리하지 않기

가능하면 화면에서는:

```dart
await DatabaseHelper.instance.insertPet(pet);
```

처럼 DB 처리 객체를 호출하고 실제 SQLite 코드는 `DatabaseHelper`에서 담당하도록 구성합니다.

이렇게 하면 화면 코드가 간결해지고 DB 구조가 변경되더라도 수정 범위를 줄일 수 있습니다.

---

### 반복되는 UI는 Widget으로 분리하기

간단한 UI는:

```dart
_buildSomething()
```

형태의 메서드로 관리할 수 있습니다.

하지만 규모가 커지거나 독립적인 역할을 가지는 UI는:

```text
widgets/
```

아래의 별도 Widget으로 분리하는 것이 유지보수에 유리합니다.

---

### 데이터와 화면을 분리하기

화면에서 직접 데이터를 문자열이나 Map 형태로 관리하기보다 Model을 사용하면 데이터 구조를 명확하게 관리할 수 있습니다.

```text
Database
   ↓
Map
   ↓
Model
   ↓
Widget
```

---

### 오늘 일정과 미래 일정을 분리하기

약 복용 기능을 개발하면서 모든 일정을 하나의 목록으로 보여주는 것보다 사용자가 지금 해야 할 일과 앞으로 해야 할 일을 구분할 수 있도록 만드는 것이 중요하다는 것을 배웠습니다.

```text
오늘 해야 할 일
      ↓
Today

앞으로 해야 할 일
      ↓
Upcoming
```

특히 반복되는 일정은 단순히 날짜를 저장하는 것뿐만 아니라 현재 날짜를 기준으로 다음 일정을 계산해야 합니다.

---

### 반복 일정은 "원본 일정"과 "실제 기록"을 분리하기

약 복용 기능을 구현하면서 반복 일정 자체와 실제 복용 여부를 하나의 데이터로 관리하면 복잡해질 수 있다는 것을 배웠습니다.

따라서:

```text
Medication
↓
복용 규칙 / 일정

MedicationLog
↓
특정 날짜의 실제 복용 상태
```

처럼 분리하면 반복 일정과 실제 수행 기록을 독립적으로 관리할 수 있습니다.

---

## 51. 앞으로의 학습 방향

현재 프로젝트에서는 Flutter 앱 개발에 필요한 기본적인 기능부터 실제 애플리케이션에서 사용할 수 있는 기능까지 직접 구현했습니다.

다음 단계에서는 단순히 기능을 추가하는 것보다 코드 구조와 유지보수성을 높이는 방향으로 학습할 예정입니다.

```text
기본 Flutter
      ↓
Widget
      ↓
State 관리
      ↓
SQLite
      ↓
Model
      ↓
Service
      ↓
Notification
      ↓
반복 일정 관리
      ↓
앱 구조 개선
      ↓
상태 관리 심화
      ↓
Repository
      ↓
배포
```

특히 다음 내용을 추가로 학습할 예정입니다.

* Flutter 상태 관리
* Widget 설계
* Repository 패턴
* Service 구조
* SQLite JOIN
* 데이터베이스 최적화
* Android Release 빌드
* APK / AAB 배포
* Git Branch 전략
* 앱 UI/UX 개선
* 테스트 코드 작성
* 반복 일정 및 기록 데이터 구조 개선

---

## 📝 마무리

`Pet Care Manager Mobile` 프로젝트를 개발하면서 Flutter의 기본적인 화면 구성부터 상태 관리, SQLite 데이터베이스, 날짜와 시간 처리, 차트, 캘린더, 로컬 알림까지 모바일 애플리케이션 개발에 필요한 다양한 기능을 직접 구현했습니다.

특히 단순한 CRUD 구현에 그치지 않고:

* 반려동물별 데이터 관리
* 건강 기록 관리
* 예방접종 일정 관리
* 체중 변화 시각화
* 건강 캘린더
* 약 복용 일정 관리
* 반복 약 복용 일정 계산
* 약 복용 완료 상태 관리
* 오늘의 약 일정 관리
* 미래 예정 일정 관리
* 반복 알림
* Timezone 처리
* Android 알림 권한
* Database Migration
* Widget 분리
* Service 분리
* 오늘 일정과 예정 일정의 데이터 분리

등을 직접 구현하면서 실제 앱 개발 과정에서 발생하는 문제를 해결하는 경험을 쌓았습니다.

앞으로도 이 프로젝트를 계속 개선하면서 Flutter 개발 경험뿐만 아니라 데이터베이스 설계, 반복 일정 데이터 설계, 앱 구조 설계, 유지보수 가능한 코드 작성 방법까지 함께 학습해 나갈 예정입니다.
