# 📚 Pet Care Manager Mobile Study

Flutter로 `Pet Care Manager Mobile`을 개발하면서 공부한 내용을 정리한 문서입니다.

개발하면서 새롭게 배운 Flutter, Dart, SQLite, Git 등의 개념과 실제 프로젝트에 적용한 내용을 기록합니다.

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

### `flutter pub get`

`pubspec.yaml`에 추가하거나 변경한 패키지를 프로젝트에 적용합니다.

```bash
flutter pub get
```

예:

```text
pubspec.yaml 수정
       ↓
table_calendar 추가
       ↓
flutter pub get
       ↓
패키지 다운로드 및 적용
```

패키지를 코드에서 사용할 때는 `import`합니다.

```dart
import 'package:table_calendar/table_calendar.dart';
```

---

### `flutter pub add`

패키지를 추가하면서 `pubspec.yaml`에 의존성을 자동으로 등록하고 설치합니다.

```bash
flutter pub add table_calendar
```

개발용 패키지는:

```bash
flutter pub add --dev flutter_launcher_icons
```

처럼 `--dev` 옵션을 사용할 수 있습니다.

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

Row나 Column 안에서 남은 공간을 차지하도록 합니다.

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

등록 화면에서는 입력 영역이 남은 공간을 차지하고 저장 버튼은 화면 하단에 고정되도록 사용할 수 있습니다.

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

### `StatelessWidget`

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

## 4. Flutter 상태 관리

### `StatefulWidget`

화면의 데이터가 변경될 수 있을 때 사용합니다.

예:

* 반려동물 목록
* 선택한 날짜
* 입력한 데이터
* DB에서 불러온 데이터

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

---

### `initState()`

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

### `setState()`

화면에 표시되는 상태가 변경되었음을 Flutter에 알려줍니다.

```dart
setState(() {
  selectedDate = pickedDate;
});
```

`setState()`가 실행되면 해당 위젯이 다시 그려집니다.

날짜 선택, 다음 접종일 설정/삭제 등에 사용할 수 있습니다.

---

### `mounted`

비동기 작업이 끝난 후 해당 위젯이 아직 화면에 존재하는지 확인할 때 사용합니다.

```dart
if (!mounted) {
  return;
}
```

예를 들어 DB 저장이 완료되기 전에 사용자가 화면을 닫았을 경우, 이미 사라진 화면에서 `Navigator`나 `setState()`를 실행하는 것을 방지할 수 있습니다.

---

## 5. 화면 이동

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

---

### `Navigator.pop()`

현재 화면을 닫고 이전 화면으로 돌아갑니다.

```dart
Navigator.pop(context);
```

데이터를 이전 화면으로 전달할 수도 있습니다.

```dart
Navigator.pop(context, true);
```

이 경우 이전 화면에서:

```dart
final result = await Navigator.push(...);

if (result == true) {
  loadPets();
}
```

처럼 결과를 받을 수 있습니다.

실제 프로젝트에서는 날짜나 삭제 결과를 전달하기도 합니다.

```dart
Navigator.pop(context, selectedDate);
```

또는:

```dart
Navigator.pop(context, true);
```

---

## 6. 사용자 입력

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
  decoration: InputDecoration(
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
),
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

## 7. 터치 이벤트

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

프로젝트에서는 다음 접종일 옆의 `X` 버튼처럼 작은 터치 영역을 만들 때 사용할 수 있습니다.

---

### `InkWell`

`GestureDetector`처럼 터치 이벤트를 처리하면서 Material 디자인의 물결(Ripple) 효과를 제공합니다.

```dart
InkWell(
  onTap: () {
    // 터치했을 때 실행
  },
  child: ...,
)
```

날짜 선택 영역처럼 사용자가 터치할 수 있는 큰 UI에 사용했습니다.

---

## 8. SQLite

Pet Care Manager Mobile에서는 SQLite를 사용하여 데이터를 로컬에 저장합니다.

현재 주요 테이블:

```text
pets
health_records
vaccinations
weight_records
medications
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

예방접종이나 체중 기록을 등록할 때도 동일한 CRUD 구조를 사용합니다.

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

## 9. 날짜 처리

Dart에서는 `DateTime`을 사용하여 날짜와 시간을 관리합니다.

```dart
DateTime today = DateTime.now();
```

---

### `DateTime.now()`

현재 날짜와 시간을 가져옵니다.

```dart
final now = DateTime.now();
```

예방접종 등록 화면에서는 기본 접종 날짜를 오늘로 설정할 수 있습니다.

```dart
DateTime vaccinationDate = DateTime.now();
```

---

### `DateTime` 날짜 직접 생성

```dart
DateTime date = DateTime(
  2026,
  8,
  21,
);
```

연도, 월, 일을 지정하여 날짜를 만들 수 있습니다.

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

예를 들어 접종 날짜는 미래 날짜를 선택하지 못하도록 할 수 있습니다.

```dart
firstDate: DateTime(2000),
lastDate: DateTime.now(),
```

다음 접종일은 현재 접종일보다 이전 날짜를 선택하지 못하도록 할 수 있습니다.

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
1 → 01
8 → 08
12 → 12
```

처럼 두 자리로 맞출 수 있습니다.

---

## 10. `TimeOfDay`

Flutter에서는 시간을 선택하거나 표시할 때 `TimeOfDay`를 사용할 수 있습니다.

예:

```dart
TimeOfDay(
  hour: 9,
  minute: 30,
);
```

현재 프로젝트에서는 약 복용 시간 관리에 사용합니다.

```dart
medication.medicationTime?.format(context)
```

여기서:

* `?.` : 값이 null이 아닐 때만 `format()` 실행
* `??` : 왼쪽 값이 null이면 오른쪽 값 사용

즉, 복용 시간이 있으면 화면에 표시하고 없으면 빈 문자열을 사용할 수 있습니다.

```dart
subtitle:
    medication.medicationTime?.format(context) ?? '',
```

---

## 11. null 처리

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

의미:

```text
nextDate가 있으면
→ nextDate 사용

nextDate가 null이면
→ vaccinationDate 사용
```

---

### `?.`

값이 null이 아닐 때만 뒤의 함수나 속성을 실행합니다.

```dart
medication.medicationTime?.format(context)
```

`medicationTime`이 null이면 `format()`을 실행하지 않습니다.

---

### `!`

해당 값이 null이 아니라고 Dart에게 알려줍니다.

```dart
nextDate!
```

단, 실제 값이 null이면 오류가 발생할 수 있으므로 주의해야 합니다.

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

`nextDate`가 있으면 날짜와 삭제 버튼을 표시하고, 없으면 날짜 선택 안내 문구를 표시할 수 있습니다.

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
details.join('  •  ')
```

예를 들어:

```text
['푸들', '남아', '3.5kg']
```

를:

```text
푸들  •  남아  •  3.5kg
```

처럼 표시할 수 있습니다.

---

## 14. 이미지 파일 처리

반려동물 프로필 이미지처럼 로컬 파일을 화면에 표시할 수 있습니다.

먼저 `dart:io`를 import합니다.

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

이미지가 없으면 기본 아이콘을 표시하도록 할 수도 있습니다.

```dart
child: pet.imagePath == null
    ? Icon(Icons.pets, size: 48)
    : null,
```

---

## 15. 문자열 보간

Dart에서는 `$`를 사용하여 문자열 안에 변수를 넣을 수 있습니다.

```dart
final name = '프리다';

print('우리 아이는 $name입니다.');
```

객체의 속성이나 계산식에는 `${}`를 사용할 수 있습니다.

```dart
print('${pet.name}의 몸무게는 ${pet.weight}kg입니다.');
```

단순한 변수는 중괄호 없이 사용할 수 있습니다.

```dart
'$difference일 남았어요.'
```

---

## 16. 비동기 처리

Flutter에서는 DB 작업이나 알림 예약처럼 시간이 걸릴 수 있는 작업에 비동기 처리를 사용합니다.

### `Future`

나중에 결과가 반환될 수 있는 작업을 나타냅니다.

```dart
Future<void> saveWeightRecord() async {
  ...
}
```

`Future<void>`는 비동기 작업이 끝난 후 별도의 값을 반환하지 않는다는 의미입니다.

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

DB 저장이 완료된 후 다음 코드가 실행됩니다.

---

### 실제 사용 예

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

## 17. 로컬 알림

Flutter에서 앱 내부 알림 기능을 구현하기 위해 `flutter_local_notifications` 패키지를 사용할 수 있습니다.

### 패키지 설치

```bash
flutter pub add flutter_local_notifications
```

현재 프로젝트에서는 다음 버전을 사용합니다.

```yaml
flutter_local_notifications: ^22.3.0
```

---

### `NotificationService`

알림과 관련된 기능을 하나의 클래스로 관리하기 위해 별도의 서비스를 만들 수 있습니다.

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

### 싱글톤 패턴

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

이 객체를 통해:

* 알림 초기화
* 예약 알림
* 반복 알림
* 알림 취소

등을 구현할 수 있습니다.

---

### Android 알림 초기화

```dart
const androidSettings = AndroidInitializationSettings(
  '@mipmap/ic_launcher',
);
```

Android에서 알림을 표시할 때 사용할 기본 아이콘을 설정합니다.

---

### iOS 알림 초기화

```dart
const iosSettings = DarwinInitializationSettings();
```

iOS 알림 기능을 초기화하기 위한 설정입니다.

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

### Android 알림 권한

Android 13 이상에서는 알림 권한을 요청해야 합니다.

```dart
await androidPlugin?.requestNotificationsPermission();
```

정확한 시간에 알림을 예약하기 위해 정확한 알람 권한도 요청할 수 있습니다.

```dart
await androidPlugin?.requestExactAlarmsPermission();
```

---

## 18. 시간대(Timezone)와 예약 알림

특정 시간에 알림을 예약하려면 날짜와 시간을 정확하게 처리해야 합니다.

Flutter에서는 `timezone` 패키지를 사용하여 시간대(Timezone)를 관리할 수 있습니다.

### 패키지 설치

```bash
flutter pub add timezone
```

현재 프로젝트에서는 다음 버전을 사용합니다.

```yaml
timezone: ^0.11.1
```

---

### 한국 시간대 설정

Timezone 데이터를 초기화한 후 한국 시간대를 명시적으로 설정할 수 있습니다.

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

이를 통해 예약 시간을 현재 설정된 시간대 기준으로 처리할 수 있습니다.

---

## 19. 예약 알림

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

Android가 절전 상태(Doze/idle)에 있더라도 예약한 시간에 최대한 정확하게 알림을 실행하도록 요청합니다.

```dart
androidScheduleMode:
    AndroidScheduleMode.exactAllowWhileIdle,
```

정확한 알림 예약을 사용하기 때문에 Android에서는 정확한 알람 권한이 필요할 수 있습니다.

---

## 20. 반복 알림

약 복용 알림은 반복 유형에 따라 예약 방식을 다르게 처리할 수 있습니다.

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

```dart
const repeatCount = 30;
```

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

처럼 일정 간격으로 날짜를 계산합니다.

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

## 21. Core Library Desugaring

`flutter_local_notifications`를 Android에서 사용하면서 다음과 같은 오류가 발생할 수 있습니다.

```text
Dependency ':flutter_local_notifications'
requires core library desugaring to be enabled
```

이 경우 Android의 `app/build.gradle.kts`에서 설정을 추가해야 합니다.

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

최신 Java API 기능을 낮은 Android 버전에서도 사용할 수 있도록 변환해 주는 기능입니다.

설정 후 다시:

```bash
flutter run
```

을 실행합니다.

---

## 22. Git 기본 명령어

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

## 23. 개발하면서 배운 문제 해결

### `databaseFactory not initialized`

`sqflite`와 관련된 DB 초기화 문제입니다.

Flutter에서 사용하는 플랫폼과 SQLite 패키지 설정이 맞지 않을 때 발생할 수 있습니다.

---

### `flutter_local_notifications requires core library desugaring`

`flutter_local_notifications` 패키지를 Android에서 사용하기 위해 Core Library Desugaring 설정이 필요할 수 있습니다.

오류 메시지:

```text
Dependency ':flutter_local_notifications'
requires core library desugaring to be enabled
```

해결 방법:

```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}
```

그리고:

```kotlin
dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.5"
    )
}
```

를 추가합니다.

---

### `Undefined name 'NotificationService'`

`NotificationService` 클래스를 만들었지만 해당 파일을 `import`하지 않았을 때 발생할 수 있습니다.

예:

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

패키지 버전에 따라 함수의 사용 방식이 달라질 수 있으므로 오류 메시지를 확인하는 것이 중요합니다.

---

### `Missing or invalid credentials`

GitHub에 로그인되어 있지 않거나 인증 정보가 올바르지 않을 때 발생합니다.

Mac에서 VS Code의 GitHub 인증 과정에서 발생할 수 있으며, GitHub 계정과 Git 인증 정보를 확인해야 합니다.

---

### 앱 아이콘 변경 후 기존 아이콘이 계속 표시되는 경우

`flutter_launcher_icons`로 아이콘을 변경한 후에도 에뮬레이터에서 기존 아이콘이 보일 수 있습니다.

이 경우 앱을 다시 빌드하거나 필요하면 앱을 삭제한 후 다시 설치하여 확인합니다.

---

## 24. 앱 아이콘 변경

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

`image_path`에는 준비한 앱 아이콘 이미지의 경로를 지정합니다.

---

### 아이콘 생성

```bash
dart run flutter_launcher_icons
```

설정된 이미지를 기반으로 Android 및 iOS에서 사용할 수 있는 다양한 크기의 앱 아이콘을 자동으로 생성합니다.

실행 과정:

```text
앱 아이콘 이미지 준비
        ↓
pubspec.yaml에 이미지 경로 설정
        ↓
flutter_launcher_icons 설정
        ↓
dart run flutter_launcher_icons
        ↓
Android / iOS 아이콘 자동 생성
```

---

### 앱 아이콘과 알림 아이콘

`flutter_local_notifications`의 Android 초기화에서도 다음과 같이 앱 아이콘을 사용할 수 있습니다.

```dart
const androidSettings = AndroidInitializationSettings(
  '@mipmap/ic_launcher',
);
```

`@mipmap/ic_launcher`는 Android 앱의 기본 런처 아이콘을 참조합니다.

---

## 📝 앞으로 추가할 내용

개발하면서 새롭게 배우는 내용을 계속 추가합니다.

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

### Dart

* [x] `DateTime`
* [x] `TimeOfDay`
* [x] 날짜 차이 계산
* [x] 날짜 범위 제한
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
* [ ] 예외 처리 (`try-catch`)

### SQLite

* [x] SQLite CRUD
* [x] 반려동물 데이터 관리
* [x] 건강 기록 관리
* [x] 예방접종 기록 관리
* [x] 체중 기록 관리
* [x] 약 복용 기록 관리
* [ ] SQLite JOIN

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
* [ ] 즉시 알림
* [ ] 예방접종 예정 알림

### Android

* [x] Core Library Desugaring
* [x] Android 알림 권한 처리
* [x] 정확한 알람 권한 처리

### Git

* [x] `git status`
* [x] `git add`
* [x] `git commit`
* [x] `git push`
* [x] `git pull`

### 앱 꾸미기

* [x] 앱 이름 변경
* [x] 앱 아이콘 변경
* [x] `flutter_launcher_icons` 패키지 사용
* [ ] Flutter 화면 디자인 및 레이아웃 심화
