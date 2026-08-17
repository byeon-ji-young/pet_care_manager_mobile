# 📚 Pet Care Manager Mobile Study

Flutter로 `Pet Care Manager Mobile`을 개발하면서 공부한 내용을 정리한 문서입니다.

개발하면서 새롭게 배운 Flutter, Dart, SQLite, Git 등의 개념과 명령어를 기록합니다.

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

예를 들어 캘린더 기능을 추가하기 위해 `table_calendar` 패키지를 사용합니다.

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

StatefulWidget이 처음 생성될 때 한 번 실행됩니다.

```dart
@override
void initState() {
  super.initState();

  loadPets();
}
```

화면이 처음 열릴 때 DB 데이터를 불러오는 등의 작업에 사용할 수 있습니다.

---

### `setState()`

화면에 표시되는 상태가 변경되었음을 Flutter에 알려줍니다.

```dart
setState(() {
  pets = loadedPets;
});
```

`setState()`가 실행되면 해당 위젯이 다시 그려집니다.

---

### `mounted`

비동기 작업이 끝난 후 해당 위젯이 아직 화면에 존재하는지 확인할 때 사용합니다.

```dart
if (!mounted) {
  return;
}

setState(() {
  pets = loadedPets;
});
```

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

처럼 사용할 수 있습니다.

---

## 6. 사용자 입력

### `TextEditingController`

TextField에 입력된 값을 가져오거나 수정할 때 사용합니다.

```dart
final TextEditingController nameController =
    TextEditingController();
```

값 가져오기:

```dart
final name = nameController.text;
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

`GestureDetector`처럼 터치 이벤트를 처리하면서 Material 디자인의 물결(Ripple) 효과를 제공합니다.

```dart
InkWell(
  onTap: () {
    // 터치했을 때 실행
  },
  child: ...,
)
```

---

## 7. SQLite

Pet Care Manager Mobile에서는 SQLite를 사용하여 데이터를 로컬에 저장합니다.

현재 주요 테이블:

```text
pets
health_records
vaccinations
weight_records
```

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

## 8. 날짜 처리

Dart에서는 `DateTime`을 사용하여 날짜와 시간을 관리합니다.

```dart
DateTime today = DateTime.now();
```

날짜 차이를 계산할 수 있습니다.

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

날짜에서 시간 정보를 제거하고 날짜만 비교할 수도 있습니다.

```dart
final todayOnly = DateTime(
  today.year,
  today.month,
  today.day,
);
```

---

## 9. null 처리

Dart에서는 `?`를 사용하여 null이 될 수 있는 값을 표현합니다.

```dart
DateTime? nextDate;
```

`nextDate`가 null일 수도 있다는 의미입니다.

### `??`

왼쪽 값이 null이면 오른쪽 값을 사용합니다.

```dart
nextDate ?? vaccinationDate
```

의미:

```text
nextDate가 있으면 → nextDate 사용
nextDate가 null이면 → vaccinationDate 사용
```

### `!`

해당 값이 null이 아니라고 Dart에게 알려줍니다.

```dart
nextDate!
```

단, 실제 값이 null이면 오류가 발생할 수 있으므로 주의해야 합니다.

---

## 10. 문자열 보간

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

## 11. Git 기본 명령어

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

## 12. 개발하면서 배운 문제 해결

### `databaseFactory not initialized`

`sqflite`와 관련된 DB 초기화 문제.

Flutter에서 사용하는 플랫폼과 SQLite 패키지 설정이 맞지 않을 때 발생할 수 있습니다.

---

### `Missing or invalid credentials`

GitHub에 로그인되어 있지 않거나 인증 정보가 올바르지 않을 때 발생합니다.

Mac에서 VS Code의 GitHub 인증 과정에서 발생할 수 있으며, GitHub 계정과 Git 인증 정보를 확인해야 합니다.

---

## 📝 앞으로 추가할 내용

개발하면서 새롭게 배우는 내용을 계속 추가합니다.

* [ ] `table_calendar` 사용법
* [ ] 캘린더에서 날짜 선택하기
* [ ] 날짜별 건강 기록 조회
* [ ] Flutter 위젯 정리
* [ ] SQLite JOIN
* [ ] 비동기 처리 (`Future`, `async`, `await`)
* [ ] 예외 처리 (`try-catch`)
* [ ] Flutter 화면 디자인 및 레이아웃
