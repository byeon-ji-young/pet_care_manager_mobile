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

- Android Emulator
- iOS Simulator
- Windows
- Chrome

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

- AppBar
- Body
- FloatingActionButton
- BottomNavigationBar

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

- 반려동물 목록
- 선택한 날짜
- 입력한 데이터
- DB에서 불러온 데이터

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

예를 들어 데이터를 불러오는 동안 사용자가 다른 화면으로 이동했을 경우, 이미 사라진 화면에서 `setState()`를 실행하는 것을 방지할 수 있습니다.

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

`TextField`에 입력된 값을 가져오거나 수정할 때 사용합니다.

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
medications
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

이렇게 하면 시간은 제외하고 날짜만 비교할 수 있습니다.

---

## 9. `TimeOfDay`

Flutter에서는 시간을 선택하거나 표시할 때 `TimeOfDay`를 사용할 수 있습니다.

예:

```dart
TimeOfDay(
  hour: 9,
  minute: 30,
);
```

현재 시간 값을 문자열 형태로 화면에 표시할 때는:

```dart
medication.medicationTime?.format(context)
```

처럼 사용할 수 있습니다.

전체 예시:

```dart
subtitle:
    medication.medicationTime?.format(context) ?? '',
```

여기서:

- `?.` : 값이 null이 아닐 때만 `format()` 실행
- `??` : 왼쪽 값이 null이면 오른쪽 값 사용

즉, 복용 시간이 있으면 화면에 표시하고 없으면 빈 문자열을 사용합니다.

---

## 10. null 처리

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

## 11. 문자열 보간

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

## 12. 로컬 알림

Flutter에서 앱 내부 알림 기능을 구현하기 위해 `flutter_local_notifications` 패키지를 사용할 수 있습니다.

### 패키지 설치

터미널에서 다음 명령어를 실행합니다.

```bash
flutter pub add flutter_local_notifications
```

`flutter pub add` 명령어를 실행하면 패키지가 `pubspec.yaml`의 `dependencies`에 자동으로 추가되고 필요한 패키지가 설치됩니다.

예:

```yaml
dependencies:
  flutter_local_notifications: ^19.5.0
```

`pubspec.yaml`에 패키지를 직접 추가하거나 의존성을 변경한 경우 다음 명령어를 실행합니다.

```bash
flutter pub get
```

`flutter pub add`를 사용한 경우에는 패키지 추가와 의존성 설치가 함께 처리되므로 별도로 `flutter pub get`을 실행하지 않아도 됩니다.

---

### `NotificationService`

알림과 관련된 기능을 하나의 클래스로 관리하기 위해 별도의 서비스를 만들 수 있습니다.

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
    );
  }
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

```dart
final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();
```

실제로 알림 기능을 담당하는 객체입니다.

이 객체를 통해:

- 알림 초기화
- 즉시 알림
- 예약 알림
- 반복 알림

등의 기능을 구현할 수 있습니다.

---

### Android 알림 초기화 설정

```dart
const androidSettings = AndroidInitializationSettings(
  '@mipmap/ic_launcher',
);
```

Android에서 알림을 표시할 때 사용할 기본 아이콘을 설정합니다.

`@mipmap/ic_launcher`는 기본 앱 아이콘을 의미합니다.

---

### iOS 알림 초기화 설정

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

이렇게 만들어진 설정을 알림 플러그인에 전달합니다.

---

### 알림 초기화

```dart
await _notifications.initialize(
  settings: settings,
);
```

앱이 시작될 때 알림 기능을 사용할 수 있도록 초기화합니다.

`await`를 사용하는 이유는 초기화 작업이 완료될 때까지 기다리기 위해서입니다.

---

### 앱 시작 시 알림 서비스 초기화

`main()`에서 앱 실행 전에 알림 서비스를 초기화할 수 있습니다.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  runApp(const PetCareManagerApp());
}
```

실행 순서:

```text
앱 시작

↓

Flutter 엔진 초기화

↓

NotificationService 초기화

↓

알림 기능 준비

↓

runApp()

↓

앱 화면 실행
```

---

## 13. Core Library Desugaring

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

## 14. Git 기본 명령어

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

## 15. 개발하면서 배운 문제 해결

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

## 📝 앞으로 추가할 내용

개발하면서 새롭게 배우는 내용을 계속 추가합니다.

- [x] `table_calendar` 사용
- [x] 캘린더에서 날짜 선택하기
- [x] 날짜별 건강 기록 조회
- [x] 약 복용 기록 관리
- [x] `TimeOfDay`를 이용한 복용 시간 관리
- [x] `flutter_local_notifications` 패키지 설치 및 초기화
- [ ] 알림 권한 요청
- [ ] 즉시 알림
- [ ] 특정 시간 예약 알림
- [ ] 약 복용 시간 알림
- [ ] 예방접종 예정 알림
- [ ] SQLite JOIN
- [ ] 비동기 처리 (`Future`, `async`, `await`)
- [ ] 예외 처리 (`try-catch`)
- [ ] Flutter 화면 디자인 및 레이아웃