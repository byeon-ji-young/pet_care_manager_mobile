# 📚 Pet Care Manager Mobile Study

Flutter로 `Pet Care Manager Mobile`을 개발하면서 공부한 내용을 정리한 문서입니다.

개발하면서 새롭게 배운 Flutter, Dart, SQLite, 날짜/시간 처리, 로컬 알림, 이미지 및 파일 처리, 데이터 백업/복원, 검색 기능, Android 설정, Git 등의 개념과 실제 프로젝트에 적용한 내용을 기록합니다.

이 문서는 단순한 기능 설명보다 **기능을 구현하면서 어떤 개념을 배웠고, 왜 그렇게 구현했는지**를 중심으로 정리합니다.

---

# 1. Flutter 기본 명령어

## `flutter doctor`

Flutter 개발 환경에 문제가 없는지 확인합니다.

```bash
flutter doctor
```

Flutter SDK, Android SDK, 연결된 기기 등의 상태를 확인할 수 있습니다.

---

## `flutter devices`

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

## `flutter run`

Flutter 앱을 실행합니다.

```bash
flutter run
```

특정 기기에서 실행하려면:

```bash
flutter run -d <device_id>
```

---

## `flutter emulators`

설치된 에뮬레이터를 확인합니다.

```bash
flutter emulators
```

에뮬레이터 실행:

```bash
flutter emulators --launch <emulator_id>
```

---

# 2. Flutter 패키지 관리

Flutter에서는 외부 라이브러리(패키지)를 `pubspec.yaml`에서 관리합니다.

예를 들어 캘린더 기능을 추가하기 위해 `table_calendar` 패키지를 사용할 수 있습니다.

```yaml
dependencies:
  table_calendar: ^3.2.0
```

---

## `flutter pub get`

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

## `flutter pub add`

패키지를 추가하면서 `pubspec.yaml`에 의존성을 자동으로 등록하고 설치합니다.

```bash
flutter pub add table_calendar
```

개발용 패키지는 `--dev` 옵션을 사용할 수 있습니다.

```bash
flutter pub add --dev flutter_launcher_icons
```

---

## `flutter pub outdated`

현재 사용 중인 패키지와 업데이트 가능한 패키지를 확인합니다.

```bash
flutter pub outdated
```

---

## `flutter pub upgrade`

패키지를 가능한 최신 버전으로 업데이트합니다.

```bash
flutter pub upgrade
```

---

# 3. Flutter 화면 개발

## `Scaffold`

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

## `AppBar`

화면 상단의 앱 바를 구성합니다.

```dart
AppBar(
  title: const Text('펫몽'),
)
```

오른쪽에 버튼을 배치하려면 `actions`를 사용할 수 있습니다.

```dart
AppBar(
  title: const Text('펫몽'),
  actions: [
    IconButton(
      onPressed: () {},
      icon: const Icon(Icons.settings_outlined),
    ),
  ],
)
```

`actions`는 AppBar의 오른쪽 영역을 구성합니다.

---

## `SafeArea`

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

## `SingleChildScrollView`

화면의 내용이 화면보다 길어질 경우 스크롤할 수 있도록 합니다.

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

등록 화면처럼 입력 항목이 여러 개 있는 화면에서 사용할 수 있습니다.

---

## `Expanded`

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

등록 화면에서 입력 영역은 남은 공간을 차지하고 저장 버튼은 화면 하단에 배치하는 방식으로 사용할 수 있습니다.

---

## `ListView`

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

가로로 넘길 수 있는 사진 목록에도 사용할 수 있습니다.

```dart
ListView.separated(
  scrollDirection: Axis.horizontal,
  itemCount: images.length,
  itemBuilder: (context, index) {
    return ...;
  },
  separatorBuilder: (_, _) => const SizedBox(width: 8),
)
```

---

## `Card`

정보를 하나의 카드 형태로 묶을 때 사용합니다.

```dart
Card(
  child: ListTile(
    title: Text(pet.name),
  ),
)
```

---

## `ListTile`

목록에서 제목, 설명, 아이콘 등을 일정한 형태로 배치할 때 편리합니다.

```dart
ListTile(
  leading: const Icon(Icons.pets),
  title: Text(pet.name),
  subtitle: Text(pet.breed ?? '품종 미입력'),
)
```

설정 화면의 데이터 백업/복원 메뉴와 같은 UI에도 활용할 수 있습니다.

---

# 4. StatelessWidget

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

# 5. StatefulWidget

화면의 데이터가 변경될 수 있을 때 사용합니다.

예:

* 반려동물 목록
* 선택한 날짜
* 입력한 데이터
* DB에서 불러온 데이터
* 완료 여부
* 선택된 탭
* 검색 상태
* 선택된 사진

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

`StatefulWidget` 자체와 실제 변경되는 상태를 관리하는 `State` 객체가 분리되어 있습니다.

---

# 6. `initState()`

`StatefulWidget`이 처음 생성될 때 한 번 실행됩니다.

```dart
@override
void initState() {
  super.initState();

  loadPets();
}
```

화면이 처음 열릴 때 DB 데이터를 불러오거나 기존 데이터를 입력창에 표시하는 등의 작업에 사용할 수 있습니다.

수정 화면에서는 기존 데이터를 입력창에 넣는 데 사용할 수 있습니다.

```dart
if (record != null) {
  weightController.text = record.weight.toString();
  memoController.text = record.memo ?? '';
  selectedDate = record.date;
}
```

건강 기록 수정 화면에서는 기존 사진을 불러오는 작업도 `initState()`에서 시작할 수 있습니다.

---

# 7. `setState()`

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
* 검색 상태 변경
* 검색어 변경
* 선택한 사진 추가/삭제

---

# 8. `mounted`

비동기 작업이 끝난 후 해당 위젯이 아직 화면에 존재하는지 확인할 때 사용합니다.

```dart
if (!mounted) {
  return;
}
```

예를 들어 DB 저장이 완료되기 전에 사용자가 화면을 닫았을 경우, 이미 사라진 화면에서 `Navigator`나 `setState()`를 실행하는 것을 방지할 수 있습니다.

비동기 작업 이후 UI를 변경할 때 유용한 안전 장치입니다.

최근 코드에서는 다음과 같은 형태도 사용했습니다.

```dart
if (!context.mounted) {
  return;
}
```

---

# 9. 화면 이동

## `Navigator.push()`

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

## `Navigator.pop()`

현재 화면을 닫고 이전 화면으로 돌아갑니다.

```dart
Navigator.pop(context);
```

---

## `Navigator.pop()`으로 결과 전달

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

# 10. 사용자 입력

## `TextEditingController`

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

검색창에서도 동일하게 사용할 수 있습니다.

```dart
final TextEditingController searchController =
    TextEditingController();
```

---

## `TextField`

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

## `TextInputType.numberWithOptions`

숫자 입력에 적합한 키보드를 표시할 때 사용할 수 있습니다.

체중처럼 소수점이 필요한 값은 `decimal: true`를 사용할 수 있습니다.

```dart
keyboardType: const TextInputType.numberWithOptions(
  decimal: true,
)
```

---

## `double.tryParse()`

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

# 11. 터치 이벤트

## `GestureDetector`

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
onTap         한 번 탭

onDoubleTap   두 번 탭

onLongPress   길게 누르기

onTapDown     누르는 순간

onTapUp       손가락을 뗀 순간
```

프로젝트에서는 건강 기록 사진을 눌러 확대 화면을 열 때 사용했습니다.

---

## `InkWell`

`GestureDetector`처럼 터치 이벤트를 처리하면서 Material 디자인의 Ripple 효과를 제공합니다.

```dart
InkWell(
  onTap: () {
    // 터치했을 때 실행
  },
  child: ...,
)
```

날짜 선택 영역이나 사진 추가 버튼 등에 사용할 수 있습니다.

---

# 12. 조건부 UI

Flutter에서는 조건에 따라 특정 위젯을 표시할 수 있습니다.

## 일반적인 `if`

```dart
if (isEditing)
  IconButton(
    onPressed: _deleteVaccination,
    icon: const Icon(Icons.delete_outline),
  ),
```

`isEditing`이 `true`일 때만 삭제 버튼이 표시됩니다.

---

## Collection-if

여러 위젯을 조건에 따라 추가할 수도 있습니다.

```dart
if (nextDate != null) ...[
  Text(...),
  IconButton(...),
] else ...[
  Text('날짜 선택'),
]
```

---

## Spread operator `...`

여러 위젯을 한 번에 리스트에 추가할 때 사용합니다.

```dart
...[
  Text(...),
  Icon(...),
]
```

검색 결과를 기존 기록 목록에 넣을 때도 `...`를 활용할 수 있습니다.

---

# 13. 리스트와 문자열 처리

## `List<String>`

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

## `join()`

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

검색 기능에서는 여러 필드를 하나의 문자열로 합쳐 검색하기도 했습니다.

```dart
final searchableText = [
  record.title,
  record.hospital,
  record.description,
  record.examinationType,
  record.examinationResult,
].whereType<String>().join(' ').toLowerCase();
```

---

# 14. 문자열 보간

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

# 15. null 처리

Dart에서는 `?`를 사용하여 null이 될 수 있는 값을 표현합니다.

```dart
DateTime? nextDate;
```

`nextDate`가 null일 수도 있다는 의미입니다.

---

## `??`

왼쪽 값이 null이면 오른쪽 값을 사용합니다.

```dart
nextDate ?? vaccinationDate
```

---

## `?.`

값이 null이 아닐 때만 뒤의 함수나 속성을 실행합니다.

```dart
medication.medicationTime?.format(context)
```

---

## `!`

해당 값이 null이 아니라고 Dart에게 알려줍니다.

```dart
nextDate!
```

실제 값이 null이면 오류가 발생할 수 있으므로 주의해야 합니다.

---

# 16. 날짜 처리

Dart에서는 `DateTime`을 사용하여 날짜와 시간을 관리합니다.

```dart
final today = DateTime.now();
```

---

## `DateTime.now()`

현재 날짜와 시간을 가져옵니다.

```dart
final now = DateTime.now();
```

---

## `DateTime` 날짜 직접 생성

```dart
final date = DateTime(
  2026,
  8,
  21,
);
```

---

## 날짜 차이 계산

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

## 날짜만 비교하기

`DateTime.now()`에는 시간 정보까지 포함되어 있기 때문에 날짜만 비교하고 싶다면 시간 정보를 제거할 수 있습니다.

```dart
final todayOnly = DateTime(
  today.year,
  today.month,
  today.day,
);
```

---

## `showDatePicker()`

Flutter에서 날짜를 선택할 수 있는 달력 UI를 표시합니다.

```dart
final pickedDate = await showDatePicker(
  context: context,
  initialDate: selectedDate,
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
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

## 날짜 표시 형식 만들기

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

# 17. 한국 시간 기준 날짜/시간 처리

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

# 18. `TimeOfDay`

Flutter에서는 시간을 선택하거나 표시할 때 `TimeOfDay`를 사용할 수 있습니다.

```dart
TimeOfDay(
  hour: 9,
  minute: 30,
)
```

현재 프로젝트에서는 약 복용 시간과 병원 방문 시간 관리에 사용합니다.

```dart
medication.medicationTime?.format(context)
```

---

# 19. 이미지 파일 처리

프로젝트에서는 반려동물 프로필 이미지와 건강 기록 사진을 로컬 파일로 관리합니다.

## `dart:io`

```dart
import 'dart:io';
```

파일 경로를 이용하여 `File` 객체를 만들 수 있습니다.

```dart
File(pet.imagePath!)
```

---

## `FileImage`

로컬 파일을 이미지로 표시할 수 있습니다.

```dart
backgroundImage: pet.imagePath != null
    ? FileImage(File(pet.imagePath!))
    : null,
```

---

## `image_picker`

갤러리에서 사진을 선택하기 위해 `image_picker`를 사용했습니다.

```dart
final ImagePicker _imagePicker = ImagePicker();
```

여러 장을 선택하려면:

```dart
final pickedImages =
    await _imagePicker.pickMultiImage(
  imageQuality: 85,
);
```

선택한 사진은 `XFile` 형태로 받을 수 있습니다.

```dart
final image = pickedImages[index];
```

---

## `Image.file()`

선택한 로컬 사진을 화면에 표시할 수 있습니다.

```dart
Image.file(
  File(image.path),
  width: 80,
  height: 80,
  fit: BoxFit.cover,
)
```

---

# 20. 로컬 파일 저장

건강 기록 사진은 사진 파일 자체를 SQLite에 저장하지 않고 앱 전용 저장공간에 저장합니다.

이를 위해 `path_provider`를 사용합니다.

```dart
final appDirectory =
    await getApplicationDocumentsDirectory();
```

앱 전용 저장공간 경로를 가져온 후:

```dart
final recordDirectory = Directory(
  p.join(
    appDirectory.path,
    'health_records',
    healthRecordId.toString(),
  ),
);
```

처럼 건강 기록별 폴더를 만들 수 있습니다.

---

## `Directory()`와 `create()`

다음 코드는:

```dart
final directory = Directory('/a/b/c');
```

실제 폴더를 생성하는 것이 아니라 **해당 경로를 나타내는 `Directory` 객체를 만드는 것**입니다.

실제 폴더를 생성하려면:

```dart
await directory.create();
```

를 사용합니다.

---

## `recursive: true`

```dart
await directory.create(
  recursive: true,
);
```

`recursive: true`를 사용하면 부모 폴더가 없는 경우 필요한 중간 폴더까지 함께 생성합니다.

예:

```text
/a
 └─ /b
     └─ /c
```

`a`와 `b`가 없더라도 필요한 폴더를 생성할 수 있습니다.

---

# 21. 비동기 처리

Flutter에서는 DB 작업이나 알림 예약처럼 시간이 걸릴 수 있는 작업에 비동기 처리를 사용합니다.

## `Future`

나중에 결과가 반환될 수 있는 작업을 나타냅니다.

```dart
Future<void> saveWeightRecord() async {
  ...
}
```

---

## `async`

함수 안에서 비동기 작업을 처리할 수 있도록 합니다.

```dart
Future<void> saveWeightRecord() async {
  await DatabaseHelper.instance.insertWeightRecord(record);
}
```

---

## `await`

비동기 작업이 완료될 때까지 기다립니다.

```dart
await DatabaseHelper.instance.insertWeightRecord(record);
```

---

## `try-catch`

비동기 작업이나 DB 작업 중 발생할 수 있는 예외를 처리할 수 있습니다.

```dart
try {
  await DatabaseHelper.instance.insertWeightRecord(record);
} catch (e) {
  debugPrint(e.toString());
}
```

---

# 22. SQLite

Pet Care Manager Mobile에서는 SQLite를 사용하여 데이터를 로컬에 저장합니다.

주요 테이블:

```text
pets

health_records
health_record_images

vaccinations

weight_records

medications
medication_logs
```

---

## DatabaseHelper

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

## Singleton 패턴

`DatabaseHelper`를 Singleton으로 구성하면 앱 전체에서 하나의 DB 접근 객체를 사용할 수 있습니다.

```text
화면 A ─┐

화면 B ─┼→ DatabaseHelper → SQLite

화면 C ─┘
```

---

## 데이터 조회

```dart
final maps = await db.query(
  'pets',
);
```

---

## 데이터 추가

```dart
await db.insert(
  'pets',
  pet.toMap(),
);
```

---

## 데이터 수정

```dart
await db.update(
  'pets',
  pet.toMap(),
  where: 'id = ?',
  whereArgs: [pet.id],
);
```

---

## 데이터 삭제

```dart
await db.delete(
  'pets',
  where: 'id = ?',
  whereArgs: [pet.id],
);
```

---

# 23. CRUD

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
* 건강 기록 사진

---

# 24. 등록과 수정 구분

등록 화면 하나에서 신규 등록과 기존 데이터 수정을 함께 처리할 수 있습니다.

```dart
if (widget.record == null) {
  await DatabaseHelper.instance.insertWeightRecord(record);
} else {
  await DatabaseHelper.instance.updateWeightRecord(record);
}
```

`widget.record`가 `null`이면 신규 등록이고, 값이 있으면 수정입니다.

건강 기록 사진에서도 신규 등록과 수정의 흐름이 달라집니다.

```text
신규 등록
   ↓
HealthRecord 저장
   ↓
새로운 record ID 획득
   ↓
사진 저장

수정
   ↓
기존 HealthRecord 수정
   ↓
기존 사진 조회
   ↓
사진 추가 / 삭제
```

---

# 25. SQLite Migration

데이터베이스 구조가 변경되면 데이터베이스 버전을 올리고 Migration을 처리할 수 있습니다.

```text
DB Version 1
    ↓
기본 테이블 생성

DB Version 2
    ↓
새로운 컬럼 추가

DB Version 3
    ↓
반복 일정 컬럼 추가

...

DB Version 9
    ↓
health_record_images 추가
```

프로젝트에서는 기능이 추가될 때마다 기존 사용자의 데이터를 유지하면서 DB 구조를 변경할 수 있도록 Migration 구조를 적용했습니다.

현재 DB 버전은 `9`입니다.

---

# 26. 건강 기록 사진 DB 설계

건강 기록 하나에 여러 장의 사진을 저장할 수 있도록 사진 정보를 별도 테이블로 분리했습니다.

```text
health_records
      │
      │ 1 : N
      ↓
health_record_images
```

테이블 구조:

```text
health_record_images

id
health_record_id
image_path
```

이렇게 하면 건강 기록 하나에 여러 장의 사진을 연결할 수 있습니다.

```text
건강 기록
 ├─ 검사 결과지
 ├─ 영수증
 └─ 처방전
```

이미지 자체는 SQLite에 넣지 않고 파일 경로만 저장합니다.

---

# 27. Model 설계

데이터베이스의 데이터를 화면에서 사용하기 쉽게 Dart Model로 분리했습니다.

주요 Model:

```text
Pet

HealthRecord
HealthRecordImage

Vaccination

WeightRecord

Medication
MedicationLog
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

## `HealthRecordImage`

건강 기록 사진 정보를 관리하는 별도의 Model입니다.

```dart
class HealthRecordImage {
  final int? id;
  final int healthRecordId;
  final String imagePath;
}
```

사진 파일 자체를 저장하는 것이 아니라 사진과 건강 기록의 관계와 파일 경로를 관리합니다.

---

# 28. Widget 분리

화면의 코드가 너무 길어지거나 특정 UI가 독립적인 역할을 가지게 되면 Widget을 별도 파일로 분리할 수 있습니다.

현재 프로젝트에서는 다음과 같은 Widget을 분리했습니다.

```text
widgets/

├── pet_profile_header.dart
├── today_health_tasks.dart
├── upcoming_health_tasks.dart
└── weight_chart.dart
```

---

## 별도 Widget으로 분리하기 좋은 경우

* 여러 화면에서 재사용되는 UI
* 하나의 독립적인 역할을 가지는 UI
* 코드가 길어지는 UI
* 상태나 동작을 자체적으로 관리하는 UI
* 화면의 핵심 로직과 분리하고 싶은 UI

---

## 화면 내부 메서드와 Widget의 차이

간단한 UI를 화면 안에서만 사용한다면:

```dart
Widget _buildTodayHealthTasks() {
  return ...;
}
```

형태의 메서드로 만들 수 있습니다.

반면 독립적인 UI이거나 재사용 가능성이 있거나 코드 규모가 커진다면 별도의 Widget으로 분리할 수 있습니다.

```text
화면 내부에서만 사용하는 간단한 UI
        ↓
_buildSomething()

독립적 / 재사용 / 규모가 큰 UI
        ↓
별도 Widget
```

---

# 29. 체중 변화 그래프

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

# 30. 건강 캘린더

`table_calendar`를 사용하여 날짜별 건강 기록을 확인할 수 있도록 구현했습니다.

캘린더에서 특정 날짜를 선택하면 해당 날짜에 등록된 건강 관련 데이터를 확인할 수 있습니다.

관리 가능한 기록:

* 🏥 건강 기록
* 💉 예방접종 기록
* ⚖️ 체중 기록
* 💊 약 복용 기록

---

# 31. 기록 탭 상태 관리

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

---

# 32. 기록 검색 기능

기록이 많아지면서 캘린더에서 날짜를 직접 찾는 것보다 검색 기능이 편리한 경우가 생겼습니다.

검색 상태를 별도로 관리합니다.

```dart
bool isSearching = false;

String searchQuery = '';

final TextEditingController searchController =
    TextEditingController();
```

---

## 검색 UI 상태 전환

평소에는:

```text
🔍 기록 검색
```

을 표시하고 검색 버튼을 누르면 같은 영역이 검색 입력창으로 바뀝니다.

```text
🔍 [ 검색할 기록을 입력하세요. ] ✕
```

검색이 종료되면 다시 검색 버튼으로 돌아갑니다.

검색창과 검색 버튼에 동일한 높이를 사용하여 검색 상태로 변경되어도 주변 UI가 움직이지 않도록 구성했습니다.

---

## 검색어 변경

```dart
onChanged: (value) {
  setState(() {
    searchQuery = value;
  });
}
```

입력할 때마다 검색어 상태를 변경하고 화면을 다시 그립니다.

---

## 전체 기록 검색

검색 중에는 현재 캘린더에서 선택한 날짜와 상관없이 전체 기간의 데이터를 대상으로 검색합니다.

```text
일반 상태
→ 선택된 날짜의 기록

검색 상태
→ 전체 기록 검색
```

검색 대상:

```text
HealthRecord
Vaccination
Medication
WeightRecord
```

---

## 여러 필드를 하나의 검색 문자열로 만들기

건강 기록은 다음과 같은 여러 필드를 검색할 수 있습니다.

* 진료 제목
* 병원명
* 진료 내용
* 검사 종류
* 검사 결과

예:

```dart
final searchableText = [
  record.title,
  record.hospital,
  record.description,
  record.examinationType,
  record.examinationResult,
].whereType<String>().join(' ').toLowerCase();
```

그리고:

```dart
if (searchableText.contains(query)) {
  results.add(record);
}
```

와 같이 검색합니다.

예방접종, 약, 체중 기록도 같은 방식으로 필요한 필드를 합쳐 검색할 수 있습니다.

---

## 검색 결과 카드 재사용

검색 기능을 만들 때 기존 기록 카드 UI를 새로 만드는 대신 `_SelectedRecordCard`를 재사용했습니다.

```text
검색 데이터
   ↓
기존 카드 UI
   ↓
기존 수정 화면
```

이렇게 하면 검색 결과에서도 기존 기록과 동일한 UI와 수정 기능을 사용할 수 있습니다.

---

# 33. 이미지 확대 보기

건강 기록에 첨부한 사진은 썸네일만 보는 것이 아니라 크게 볼 수 있도록 구현했습니다.

```dart
showDialog(
  context: context,
  ...
)
```

다이얼로그 안에 `InteractiveViewer`를 사용했습니다.

```dart
InteractiveViewer(
  minScale: 0.8,
  maxScale: 4.0,
  child: Image.file(...),
)
```

이를 통해:

* 확대
* 축소
* 사진 드래그

가 가능합니다.

---

# 34. 여러 장 사진 갤러리

사진이 여러 장인 경우 `PageView`를 사용하여 좌우로 넘겨볼 수 있도록 구현했습니다.

```dart
PageView.builder(
  controller: pageController,
  itemCount: imagePaths.length,
  onPageChanged: (index) {
    ...
  },
)
```

---

## `PageController`

처음 어떤 사진부터 보여줄지 지정할 수 있습니다.

```dart
final pageController = PageController(
  initialPage: initialIndex,
);
```

예를 들어 세 번째 사진을 눌렀다면 확대 화면도 세 번째 사진부터 시작합니다.

---

## `currentIndex`

현재 보고 있는 사진의 위치를 관리합니다.

```dart
int currentIndex = initialIndex;
```

페이지가 변경되면:

```dart
onPageChanged: (index) {
  setDialogState(() {
    currentIndex = index;
  });
}
```

현재 사진 번호를 갱신합니다.

화면에는:

```text
1 / 3
2 / 3
3 / 3
```

형태로 표시할 수 있습니다.

---

## `PageView` + `InteractiveViewer`

두 기능을 함께 사용하면:

```text
좌우 스와이프
      +
확대 / 축소
      +
드래그
```

가 가능한 사진 갤러리를 만들 수 있습니다.

---

# 35. `Transform.translate`

UI 요소를 아주 조금 위아래 또는 좌우로 이동할 때 사용할 수 있습니다.

```dart
Transform.translate(
  offset: const Offset(0, -2),
  child: IconButton(
    ...
  ),
)
```

여기서:

```text
Offset(x, y)
```

형태로 이동량을 지정합니다.

```text
Offset(0, -2)
→ 위로 2px

Offset(3, 0)
→ 오른쪽으로 3px

Offset(0, 2)
→ 아래로 2px
```

프로젝트에서는 검색 아이콘의 위치를 탭과 자연스럽게 맞추기 위해 사용했습니다.

---

# 36. 데이터 백업

앱의 데이터를 보존할 수 있도록 백업 기능을 구현했습니다.

백업에는 다음 데이터가 포함됩니다.

```text
pets
health_records
health_record_images
vaccinations
weight_records
medications
medication_logs
```

---

## 백업 데이터 조회

`DatabaseHelper`에서 전체 데이터를 하나의 Map으로 구성합니다.

```dart
Future<Map<String, dynamic>> getBackupData() async {
  ...
}
```

결과는 JSON으로 변환할 수 있는 구조입니다.

```text
{
  "version": 1,
  "created_at": "...",
  "pets": [...],
  "health_records": [...],
  ...
}
```

---

# 37. ZIP 백업 구조

단순히 DB 데이터만 백업하면 건강 기록 사진은 복원할 수 없습니다.

그래서 JSON 데이터와 실제 사진 파일을 하나의 ZIP 파일에 함께 넣는 구조로 만들었습니다.

```text
petcare_backup_YYYYMMDD.zip

├── data.json
└── images/
    ├── health_record_1.jpg
    ├── health_record_2.jpg
    └── ...
```

---

## `archive`

ZIP 파일을 생성하고 압축을 해제하기 위해 `archive` 패키지를 사용했습니다.

```dart
final archive = Archive();
```

파일을 추가:

```dart
archive.addFile(
  ArchiveFile(
    'data.json',
    jsonBytes.length,
    jsonBytes,
  ),
);
```

ZIP 생성:

```dart
final zipBytes =
    ZipEncoder().encodeBytes(archive);
```

---

# 38. 백업 파일 저장

사용자가 원하는 위치에 백업 파일을 저장하기 위해 `file_picker`를 사용했습니다.

```dart
final result = await FilePicker.saveFile(
  dialogTitle: 'PetCareManager 백업 파일 저장',
  fileName: fileName,
  bytes: zipBytes,
  mimeType: 'application/zip',
);
```

사용자가 저장을 취소하면:

```dart
if (result == null) {
  return false;
}
```

처럼 처리할 수 있습니다.

---

# 39. 데이터 복원

복원은 백업과 반대 순서로 진행합니다.

```text
ZIP 선택
   ↓
ZIP 읽기
   ↓
data.json 찾기
   ↓
JSON 파싱
   ↓
백업 데이터 검증
   ↓
사진 복원
   ↓
DB 복원
   ↓
복원 완료
```

---

## 백업 데이터 검증

필수 데이터가 모두 존재하는지 먼저 확인합니다.

```dart
final requiredKeys = [
  'pets',
  'health_records',
  'health_record_images',
  'vaccinations',
  'weight_records',
  'medications',
  'medication_logs',
];
```

그리고:

```dart
for (final key in requiredKeys) {
  if (!backupData.containsKey(key)) {
    throw Exception(
      '백업 데이터가 올바르지 않습니다.',
    );
  }
}
```

처럼 잘못된 백업 파일을 걸러냅니다.

---

# 40. 복원 시 부모/자식 데이터 순서

SQLite의 Foreign Key 관계를 유지하기 위해 데이터 복원 순서가 중요합니다.

```text
pets
   ↓
health_records
   ↓
health_record_images

medications
   ↓
medication_logs
```

따라서 부모 테이블을 먼저 복원하고 자식 테이블을 나중에 복원합니다.

---

## ID 유지

복원 시 백업 당시의 ID를 그대로 삽입합니다.

예:

```text
pets
id = 1

health_records
pet_id = 1
```

이 관계를 유지하려면 `pets`의 ID를 새롭게 생성하지 않고 백업 당시 ID를 그대로 복원해야 합니다.

같은 이유로:

```text
health_record_images.health_record_id

medication_logs.medication_id
```

등의 관계도 유지할 수 있습니다.

---

# 41. 데이터 복원과 Transaction

DB 복원은 여러 테이블에 데이터를 한 번에 넣어야 하기 때문에 `transaction`을 사용합니다.

```dart
await db.transaction((txn) async {
  ...
});
```

이렇게 하면 복원 도중 DB 삽입 오류가 발생했을 때 전체 작업을 하나의 단위로 처리할 수 있습니다.

복원 전에 기존 데이터를 삭제하고 백업 데이터를 삽입하는 과정도 하나의 transaction으로 관리합니다.

---

# 42. 복원 시 사진 처리

백업 ZIP의 사진은:

```text
images/health_record_4.jpg
```

같은 ZIP 내부 경로를 사용합니다.

하지만 이 경로는 휴대폰에서 실제로 사용할 수 있는 경로가 아닙니다.

따라서 복원할 때 앱 전용 저장공간의 실제 경로로 다시 바꿔야 합니다.

```text
ZIP 내부 경로
        ↓
앱 전용 저장공간
        ↓
health_records/8/health_record_4.jpg
```

그리고 DB의 `image_path`도 실제 복원된 경로를 저장하도록 변경합니다.

---

# 43. 복원 시 임시 폴더 사용

사진은 바로 최종 `health_records` 폴더에 복원하지 않고:

```text
health_records_restore/
```

라는 임시 폴더에서 먼저 복원합니다.

이유는 복원 과정이 중간에 실패했을 때 기존 사진과 새 사진이 섞이지 않도록 하기 위해서입니다.

구조:

```text
기존 사진
health_records/
      ↓
새 사진을 임시 폴더에 복원
      ↓
health_records_restore/
      ↓
복원 과정 완료
      ↓
기존 폴더 교체
      ↓
health_records/
```

---

## `Directory()`와 `create()`의 차이

```dart
final directory = Directory(path);
```

는 실제 폴더를 만드는 것이 아니라 해당 경로를 나타내는 `Directory` 객체를 생성합니다.

실제 폴더 생성은:

```dart
await directory.create(
  recursive: true,
);
```

에서 이루어집니다.

따라서:

```text
Directory()
→ 폴더를 나타내는 객체 생성

create()
→ 실제 폴더 생성
```

으로 구분할 수 있습니다.

---

# 44. 데이터 복원 확인 UI

복원은 기존 데이터를 삭제할 수 있기 때문에 사용자 확인창을 먼저 표시합니다.

```text
데이터 복원

현재 저장된 모든 데이터가 삭제되고
백업 파일의 데이터로 복원됩니다.

[취소] [복원]
```

확인 후 실제 백업 파일을 선택하도록 합니다.

반면 백업은 데이터를 삭제하지 않기 때문에 상대적으로 가벼운 확인 메시지를 사용할 수 있습니다.

---

# 45. 설정 화면

백업/복원 기능을 추가하면서 별도의 `SettingsScreen`을 만들었습니다.

현재 설정 화면에서는:

```text
설정

데이터 관리

💾 데이터 백업
↩️ 데이터 복원
```

기능을 제공합니다.

앞으로 알림 설정, 앱 정보 등 추가 기능을 이 화면에 확장할 수 있습니다.

---

# 46. 로컬 알림

Flutter에서 앱 내부 알림 기능을 구현하기 위해 `flutter_local_notifications` 패키지를 사용했습니다.

설치:

```bash
flutter pub add flutter_local_notifications
```

현재 프로젝트에서는 `NotificationService`를 별도로 만들어 알림 기능을 관리합니다.

---

# 47. NotificationService

알림과 관련된 기능을 하나의 클래스로 관리하기 위해 별도의 서비스를 만들었습니다.

```dart
class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();
}
```

---

## Singleton 패턴

```dart
NotificationService._();
```

외부에서 객체를 계속 생성하지 못하도록 private 생성자를 사용합니다.

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

# 48. Android 알림 초기화

Android에서 사용할 알림 아이콘을 설정할 수 있습니다.

```dart
const androidSettings =
    AndroidInitializationSettings(
  '@mipmap/ic_launcher',
);
```

iOS:

```dart
const iosSettings =
    DarwinInitializationSettings();
```

Android와 iOS 설정을 하나로 묶습니다.

```dart
const settings = InitializationSettings(
  android: androidSettings,
  iOS: iosSettings,
);
```

---

# 49. Android 알림 권한

Android 13 이상에서는 알림 권한을 요청해야 합니다.

```dart
await androidPlugin?.requestNotificationsPermission();
```

정확한 시간에 알림을 예약하기 위해 정확한 알람 권한도 요청할 수 있습니다.

```dart
await androidPlugin?.requestExactAlarmsPermission();
```

---

# 50. Timezone

특정 시간에 알림을 예약하려면 날짜와 시간을 정확하게 처리해야 합니다.

Flutter에서는 `timezone` 패키지를 사용하여 시간대를 관리할 수 있습니다.

```bash
flutter pub add timezone
```

한국 시간대:

```dart
tz_data.initializeTimeZones();

tz.setLocalLocation(
  tz.getLocation('Asia/Seoul'),
);
```

예약 알림:

```dart
scheduledDate: tz.TZDateTime.from(
  scheduledDate,
  tz.local,
),
```

이를 통해 예약 시간을 명확한 시간대 기준으로 처리할 수 있습니다.

---

# 51. 예약 알림

`zonedSchedule()`을 사용하여 특정 날짜와 시간에 알림을 예약합니다.

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

# 52. 반복 알림

약 복용 알림은 반복 유형에 따라 예약 방식을 다르게 처리합니다.

```text
none

daily

weekly

interval
```

---

## 반복 없음

특정 날짜와 시간에 한 번만 알림을 예약합니다.

---

## 매일 반복

```dart
matchDateTimeComponents:
    DateTimeComponents.time,
```

시간만 일치하도록 설정하여 매일 같은 시간에 알림을 반복합니다.

---

## 매주 반복

```dart
matchDateTimeComponents:
    DateTimeComponents.dayOfWeekAndTime,
```

요일과 시간을 기준으로 반복합니다.

---

## N일마다 반복

`N일마다`는 여러 개의 개별 알림을 미리 예약하는 방식으로 구현했습니다.

예:

```text
8월 28일
   ↓
8월 31일
   ↓
9월 3일
   ↓
9월 6일
```

다음 예약일은:

```dart
nextScheduledDate =
    nextScheduledDate.add(
  Duration(days: repeatInterval),
);
```

처럼 계산합니다.

---

# 53. 약 복용 일정 데이터 설계

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
repeatType
repeatInterval
memo
```

약 복용 일정:

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

# 54. 약 복용 완료 상태

약 복용 일정과 실제 복용 완료 여부를 구분하기 위해 `Medication`과 `MedicationLog`를 분리했습니다.

```text
Medication

→ 약 자체의 복용 일정


MedicationLog

→ 특정 날짜에 실제로 복용했는지 기록
```

예:

```text
Medication

매일 오전 9시 복용

      ↓

MedicationLog

2026-08-28
복용 완료

      ↓

MedicationLog

2026-08-29
미복용
```

---

# 55. 오늘 일정과 예정 일정 분리

약 복용 기능을 구현하면서 모든 약을 하나의 목록으로 보여주는 것보다 날짜 기준으로 나누는 것이 사용자에게 이해하기 쉽다는 것을 학습했습니다.

```text
오늘 복용할 약
      ↓
todayMedications

앞으로 복용할 약
      ↓
upcomingMedications
```

오늘 일정에서는 실제 복용 완료 여부까지 함께 표시합니다.

미래 일정에서는 다음 복용 예정일을 중심으로 표시합니다.

---

# 56. 반복 약의 다음 복용일 계산

반복 약은 오늘 일정과 미래 일정을 구분하기 위해 다음 복용일을 계산해야 합니다.

반복 유형:

```text
none
daily
weekly
interval
```

---

## 반복하지 않는 약

```text
오늘 이후
→ 예정 일정

오늘
→ 오늘 일정

과거
→ 과거 기록
```

---

## 매일 복용

```dart
while (!baseDate.isAfter(today)) {
  baseDate = baseDate.add(
    const Duration(days: 1),
  );
}
```

오늘이거나 과거라면 하루씩 이동하여 오늘 이후의 가장 가까운 날짜를 찾습니다.

---

## 매주 복용

```dart
while (!baseDate.isAfter(today)) {
  baseDate = baseDate.add(
    const Duration(days: 7),
  );
}
```

---

## N일마다 복용

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

# 57. 약 복용 이력 설계

복용 이력 화면에서는 단순히 DB에 저장된 `MedicationLog`만 표시하지 않고 **실제 복용 예정일을 기준으로 이력 데이터를 생성**합니다.

```text
Medication
    ↓
반복 규칙 확인
    ↓
복용 예정 날짜 생성
    ↓
MedicationLog 존재 여부 확인
    ↓
MedicationHistoryItem 생성
    ↓
화면 표시
```

예:

```text
8/28 → 로그 있음 → 복용 완료
8/29 → 로그 없음 → 복용하지 않음
8/30 → 로그 있음 → 복용 완료
```

이 구조를 사용하면 실제 완료된 날뿐만 아니라 **복용 예정이었지만 복용하지 않은 날도 표시**할 수 있습니다.

---

# 58. 오늘의 건강 일정 UI

특정 기능만 보여주는 것보다 사용자가 오늘 해야 할 건강 관련 일정을 한 곳에서 확인할 수 있도록 구성했습니다.

```text
오늘의 건강 일정

🏥 병원
💉 예방접종
💊 약 복용
⚖️ 체중
```

약 복용에서는:

```text
약 이름
복용 시간
복용 상태
완료 / 취소
```

등을 표시합니다.

---

# 59. 기록 검색과 날짜 조회의 역할 분리

기록 화면에서는 두 가지 조회 방식을 분리했습니다.

```text
캘린더
→ 특정 날짜의 기록

검색
→ 전체 기간의 기록
```

이렇게 하면:

```text
"오늘 무엇을 해야 하지?"
→ 캘린더

"예전에 혈액검사했던 기록을 찾고 싶어."
→ 검색
```

처럼 사용 목적에 따라 다른 기능을 이용할 수 있습니다.

---

# 60. Banner UI 공통화

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

공통 UI 메서드를 활용하면 동일한 UI가 여러 곳에서 반복되는 것을 줄일 수 있습니다.

---

# 61. Core Library Desugaring

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

# 62. `flutter analyze`

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

---

## `flutter analyze`와 `flutter run`의 차이

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

# 63. Git 기본 명령어

## `git status`

현재 변경된 파일을 확인합니다.

```bash
git status
```

---

## `git add`

변경한 파일을 커밋할 준비를 합니다.

```bash
git add .
```

특정 파일만 추가할 수도 있습니다.

```bash
git add README.md
```

---

## `git commit`

변경 내용을 하나의 기록으로 저장합니다.

```bash
git commit -m "docs: README 업데이트"
```

---

## `git push`

로컬에서 만든 커밋을 GitHub 저장소에 업로드합니다.

```bash
git push
```

---

## `git pull`

GitHub의 최신 변경 내용을 로컬로 가져옵니다.

```bash
git pull
```

---

## Tag

릴리즈 버전을 표시할 수 있습니다.

```bash
git tag v1.1.0
```

원격 저장소에 태그를 올리려면:

```bash
git push origin v1.1.0
```

---

# 64. 앱 아이콘 변경

Flutter 앱의 기본 아이콘을 원하는 이미지로 변경하기 위해 `flutter_launcher_icons` 패키지를 사용할 수 있습니다.

설치:

```bash
flutter pub add --dev flutter_launcher_icons
```

`pubspec.yaml` 설정:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```

아이콘 생성:

```bash
dart run flutter_launcher_icons
```

설정된 이미지를 기반으로 Android 및 iOS에서 사용할 수 있는 앱 아이콘을 자동으로 생성합니다.

---

# 65. 개발하면서 배운 문제 해결

## `databaseFactory not initialized`

`sqflite`와 관련된 DB 초기화 문제입니다.

Flutter에서 사용하는 플랫폼과 SQLite 패키지 설정이 맞지 않을 때 발생할 수 있습니다.

DB를 사용하는 시점과 초기화 방식이 올바른지 확인해야 합니다.

---

## `flutter_local_notifications requires core library desugaring`

`flutter_local_notifications` 패키지를 Android에서 사용하기 위해 Core Library Desugaring 설정이 필요할 수 있습니다.

---

## `Undefined name 'NotificationService'`

`NotificationService` 클래스를 만들었지만 해당 파일을 import하지 않았을 때 발생할 수 있습니다.

```dart
import 'services/notification_service.dart';
```

클래스가 있는 경로를 정확하게 import해야 합니다.

---

## `The named parameter 'settings' is required`

사용 중인 패키지 버전에서 `initialize()` 메서드가 `settings`라는 named parameter를 요구할 때 발생할 수 있습니다.

패키지 버전에 맞게 API를 확인해야 합니다.

```dart
await _notifications.initialize(
  settings: settings,
);
```

패키지 버전에 따라 함수의 사용 방식이 달라질 수 있으므로 오류 메시지와 현재 패키지 버전을 함께 확인하는 것이 중요합니다.

---

## `MissingPluginException`

플러그인을 추가하거나 변경한 후 Hot Reload만 수행하면 네이티브 플러그인이 정상적으로 등록되지 않을 수 있습니다.

예:

```text
MissingPluginException
No implementation found for method save
```

이런 경우 앱을 완전히 종료하고 다시 빌드해야 합니다.

```bash
flutter clean
flutter pub get
flutter run
```

Hot Reload와 Full Restart의 차이를 이해하는 계기가 되었습니다.

---

## `PathNotFoundException`

파일은 DB에 저장되어 있지만 실제 파일이 존재하지 않으면 발생할 수 있습니다.

예:

```text
PathNotFoundException
Cannot retrieve length of file
```

프로젝트의 백업/복원 기능을 구현하면서 **DB에 저장된 이미지 경로와 실제 파일 위치가 항상 일치해야 한다는 점**을 학습했습니다.

---

## 백업 복원 후 사진 경로 문제

초기 복원 구현에서는:

```text
health_records_restore/
```

임시 폴더의 경로를 DB에 저장한 뒤 폴더를:

```text
health_records/
```

로 변경하는 과정에서 경로가 일치하지 않는 문제가 발생했습니다.

즉:

```text
DB
→ health_records_restore/...

실제 파일
→ health_records/...
```

처럼 서로 다른 경로를 가리키게 되었습니다.

이 문제를 통해 **파일을 이동하거나 폴더 이름을 변경할 때 DB에 저장된 파일 경로도 함께 고려해야 한다는 것**을 배웠습니다.

---

# 66. 개발하면서 익힌 문제 해결 흐름

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

특히 패키지를 추가한 이후 발생하는 오류는 현재 설치된 패키지 버전과 사용 중인 API가 일치하는지 확인하는 것이 중요합니다.

---

# 67. 현재 프로젝트에서 사용한 주요 개념 정리

## Flutter

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
Image.file

PageView
PageController
InteractiveViewer
Transform.translate

Widget 분리
탭 상태 관리
검색 상태 관리
```

---

## Dart

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

Future
async
await
try-catch

문자열 보간
반복 날짜 계산
```

---

## SQLite

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
fromMap()

Migration

Foreign Key
Transaction

health_record_images
```

---

## 이미지 / 파일

```text
image_picker
path_provider
dart:io
File
Directory
Image.file
FileImage
```

---

## 백업 / 복원

```text
file_picker
archive
JSON
ZIP
data.json
백업 파일
복원
임시 폴더
```

---

## 로컬 알림

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

## Timezone

```text
timezone
Asia/Seoul
TZDateTime
```

---

## Android

```text
Core Library Desugaring
JavaVersion.VERSION_17
정확한 알람 권한
Android 알림 권한
```

---

## Git

```text
git status
git add
git commit
git push
git pull
git tag
```

---

# 68. 앞으로 추가해서 공부할 내용

## Flutter

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
* [x] `Image.file`
* [x] `ListView`
* [x] `Card`
* [x] `ListTile`
* [x] `PageView`
* [x] `PageController`
* [x] `InteractiveViewer`
* [x] `Transform.translate`
* [x] Widget 분리
* [x] 화면 내부 `_build...()` 메서드 활용
* [x] 탭 상태 관리
* [x] 검색 상태 관리
* [ ] Flutter 화면 디자인 및 레이아웃 심화
* [ ] 더 복잡한 상태 관리 방식

---

## Dart

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

## SQLite

* [x] SQLite CRUD
* [x] 반려동물 데이터 관리
* [x] 건강 기록 관리
* [x] 예방접종 기록 관리
* [x] 체중 기록 관리
* [x] 약 복용 기록 관리
* [x] 약 복용 완료 로그 관리
* [x] 건강 기록 사진 테이블 설계
* [x] DatabaseHelper Singleton
* [x] Model과 SQLite 연결
* [x] Database Migration
* [x] Foreign Key
* [x] Transaction
* [ ] SQLite JOIN
* [ ] 복잡한 SQL Query
* [ ] Index
* [ ] 데이터베이스 최적화

---

## 이미지 / 파일 관리

* [x] `image_picker`
* [x] 갤러리에서 여러 장 사진 선택
* [x] `dart:io`
* [x] `File`
* [x] `Directory`
* [x] `path_provider`
* [x] 앱 전용 저장공간 사용
* [x] 사진 파일 복사
* [x] 사진 파일 삭제
* [x] 건강 기록 사진 DB 연결
* [x] `PageView`
* [x] 사진 확대 / 축소
* [x] 사진 좌우 스와이프
* [x] 이미지 백업
* [x] 이미지 복원

---

## 백업 / 복원

* [x] 백업 데이터 조회
* [x] JSON 데이터 생성
* [x] `archive`
* [x] ZIP 생성
* [x] `file_picker`
* [x] 백업 파일 저장
* [x] 백업 파일 선택
* [x] JSON 데이터 검증
* [x] DB 데이터 복원
* [x] ID 유지
* [x] 사진 파일 복원
* [x] 임시 폴더를 이용한 안전한 사진 복원
* [ ] 백업 파일 암호화
* [ ] 클라우드 백업

---

## 검색 기능

* [x] 검색 UI
* [x] 검색 상태 관리
* [x] `TextEditingController`
* [x] 검색어 실시간 반영
* [x] 전체 기간 검색
* [x] 건강 기록 검색
* [x] 예방접종 검색
* [x] 약 검색
* [x] 체중 검색
* [x] 여러 필드를 하나의 문자열로 결합
* [x] 검색 결과 정렬
* [x] 기존 카드 UI 재사용
* [ ] SQLite 기반 검색 Query
* [ ] 검색 결과 하이라이트
* [ ] 검색 기록 저장

---

## 약 복용 기능

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
* [x] 복용 이력 예정일 기반 표시
* [ ] 약 복용 일정 수정 기능 고도화
* [ ] 복용 이력 상세 화면
* [ ] 약 복용 통계

---

## 로컬 알림

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

## Android

* [x] Core Library Desugaring
* [x] Android 알림 권한 처리
* [x] 정확한 알람 권한 처리
* [x] Android 플러그인 변경 후 Full Restart
* [ ] Android Manifest 설정 심화
* [ ] Release 빌드
* [ ] APK / AAB 생성

---

## Git

* [x] `git status`
* [x] `git add`
* [x] `git commit`
* [x] `git push`
* [x] `git pull`
* [x] Git Tag
* [ ] Branch
* [ ] Merge
* [ ] Rebase
* [ ] GitHub Pull Request

---

## 앱 꾸미기

* [x] 앱 이름 변경
* [x] 앱 아이콘 변경
* [x] `flutter_launcher_icons` 패키지 사용
* [x] 검색 UI 개선
* [ ] Flutter 화면 디자인 및 레이아웃 심화
* [ ] Theme 설정
* [ ] 공통 색상 관리
* [ ] 공통 TextStyle 관리
* [ ] 다크 모드

---

# 69. 프로젝트를 통해 배운 개발 구조

Pet Care Manager Mobile을 개발하면서 단순히 화면을 만드는 것뿐만 아니라 각 역할을 분리하는 것이 중요하다는 것을 학습했습니다.

현재 프로젝트의 기본적인 구조:

```text
Screen
  ↓
Model
  ↓
DatabaseHelper
  ↓
SQLite
```

알림 기능:

```text
Screen
  ↓
NotificationService
  ↓
flutter_local_notifications
  ↓
Android / iOS Notification
```

백업 기능:

```text
Screen
  ↓
BackupService
  ├── JSON
  ├── ZIP
  ├── 파일 처리
  └── DatabaseHelper
          ↓
        SQLite
```

UI:

```text
Screen
  ├── PetProfileHeader
  ├── TodayHealthTasks
  ├── UpcomingHealthTasks
  └── WeightChart
```

화면 내부에서만 사용하는 작은 UI:

```text
Screen
  ├── _buildTodayMedicationCard()
  ├── _buildTodayMedicationItem()
  ├── _buildBannerItem()
  └── _buildSearchBar()
```

기능이 커질수록 화면 하나에 모든 역할을 넣기보다 적절한 위치로 분리하는 것이 중요하다는 것을 배웠습니다.

---

# 70. 개발하면서 가장 중요하게 배운 점

## 기능이 많아질수록 역할을 분리해야 한다

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

## 화면에서 DB 코드를 직접 처리하지 않기

가능하면 화면에서는:

```dart
await DatabaseHelper.instance.insertPet(pet);
```

처럼 DB 처리 객체를 호출하고 실제 SQLite 코드는 `DatabaseHelper`에서 담당하도록 구성합니다.

이렇게 하면 화면 코드가 간결해지고 DB 구조가 변경되더라도 수정 범위를 줄일 수 있습니다.

---

## 파일 자체와 DB 데이터를 분리하기

건강 기록 사진 기능을 구현하면서 이미지 파일과 DB 데이터를 같은 방식으로 관리할 필요가 없다는 것을 배웠습니다.

```text
이미지 파일
→ 앱 전용 저장공간

사진 정보
→ SQLite
```

즉 SQLite에는 파일 자체를 저장하는 것이 아니라:

```text
health_record_id
image_path
```

와 같은 연결 정보를 저장했습니다.

---

## 백업에서는 데이터와 파일을 함께 생각해야 한다

DB만 백업하면:

```text
health_record_images
→ 경로만 존재

실제 이미지
→ 없음
```

이라는 문제가 생길 수 있습니다.

그래서:

```text
data.json
+
images/
```

를 하나의 ZIP으로 묶는 구조를 사용했습니다.

이 과정에서 **DB 데이터와 실제 파일 시스템 데이터의 관계**를 이해할 수 있었습니다.

---

## 파일 경로는 이동 과정까지 고려해야 한다

복원 중 임시 폴더를 사용하는 과정에서 DB가 가리키는 경로와 실제 파일 위치가 달라지는 문제가 발생했습니다.

이를 해결하면서:

```text
DB에 저장된 경로
        =
실제 파일의 경로
```

가 항상 유지되어야 한다는 것을 배웠습니다.

---

## 반복되는 UI는 Widget으로 분리하기

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

## 데이터와 화면을 분리하기

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

## 오늘 일정과 미래 일정을 분리하기

약 복용 기능을 개발하면서 모든 일정을 하나의 목록으로 보여주는 것보다 사용자가 지금 해야 할 일과 앞으로 해야 할 일을 구분할 수 있도록 만드는 것이 중요하다는 것을 배웠습니다.

```text
오늘 해야 할 일
      ↓
Today

앞으로 해야 할 일
      ↓
Upcoming
```

---

## 반복 일정은 "원본 일정"과 "실제 기록"을 분리하기

약 복용 기능에서는:

```text
Medication
↓

복용 규칙 / 일정

MedicationLog
↓

특정 날짜의 실제 복용 상태
```

처럼 분리했습니다.

이 구조를 사용하면 반복 일정과 실제 수행 기록을 독립적으로 관리할 수 있습니다.

---

## 검색은 기존 기능을 재사용하는 방향으로 설계하기

검색 기능을 추가하면서 검색 결과만을 위한 새로운 카드 UI를 만드는 대신 기존 기록 카드 UI를 재사용했습니다.

```text
검색
 ↓
기존 Model
 ↓
기존 카드
 ↓
기존 수정 화면
```

이렇게 하면 새로운 기능을 추가하더라도 기존 UI와 데이터 구조를 최대한 재사용할 수 있습니다.

---

# 71. 앞으로의 학습 방향

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
이미지 / 파일 관리
      ↓
백업 / 복원
      ↓
검색
      ↓
앱 구조 개선
      ↓
상태 관리 심화
      ↓
Repository
      ↓
테스트
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
* 백업 데이터 암호화
* 클라우드 저장

---

# 72. 마무리

`Pet Care Manager Mobile` 프로젝트를 개발하면서 Flutter의 기본적인 화면 구성부터 상태 관리, SQLite 데이터베이스, 날짜와 시간 처리, 차트, 캘린더, 로컬 알림, 이미지 처리, 파일 관리, 데이터 백업/복원, 검색 기능까지 모바일 애플리케이션 개발에 필요한 다양한 기능을 직접 구현했습니다.

특히 단순한 CRUD 구현에 그치지 않고:

* 반려동물별 데이터 관리
* 건강 기록 관리
* 건강 기록 사진 관리
* 예방접종 일정 관리
* 체중 변화 시각화
* 건강 캘린더
* 약 복용 일정 관리
* 반복 약 복용 일정 계산
* 약 복용 완료 상태 관리
* 복용 이력 예정일 기반 표시
* 오늘의 약 일정 관리
* 미래 예정 일정 관리
* 반복 알림
* Timezone 처리
* Android 알림 권한
* Database Migration
* Widget 분리
* Service 분리
* 이미지 파일 관리
* ZIP 기반 데이터 백업
* 데이터 복원
* 기록 검색
* 검색 결과 UI 재사용

등을 직접 구현하면서 실제 앱 개발 과정에서 발생하는 문제를 해결하는 경험을 쌓았습니다.

특히 기능이 추가될수록 단순히 코드를 작성하는 것보다:

```text
데이터 구조
+
화면 구조
+
파일 구조
+
서비스 구조
+
사용자 흐름
```

을 함께 생각하는 것이 중요하다는 것을 배웠습니다.

앞으로도 이 프로젝트를 계속 개선하면서 Flutter 개발 경험뿐만 아니라 데이터베이스 설계, 반복 일정 데이터 설계, 파일 관리, 백업/복원, 앱 구조 설계, 유지보수 가능한 코드 작성 방법까지 함께 학습해 나갈 예정입니다.
