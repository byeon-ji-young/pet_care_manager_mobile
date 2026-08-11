import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pet.dart';

class DatabaseHelper {
  /*
    싱글톤 패턴
    - 앱 전체에서 DatabaseHelper의 객체(인스턴스)를 딱 1개만 만들어서 돌려쓰겠다는 뜻
    - 데이터베이스 연결 통로는 1개만 열려있어야 안전함. 화면마다 DB 연결을 여러 개 만들면 데이터 충돌이나 메모리 낭비가 생길 수 있기 때문
    - 다른 파일에서 DatabaseHelper.instance.insertPet(...) 처럼 바로 접근할 수 있음

    DatabaseHelper._privateConstructor();

    static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  */
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // 변수명 앞의 _(밑줄)은 "이 파일 밖에서는 함부로 손대지 마!" 하고 감춰두는 비밀(Private) 표시
  Database? _database;

  // DB 가져오기(DB 열기/생성)
  /*
    게터(Getter)와 널 처리 (database)
    - 지연 초기화 (Lazy Initialization): 앱이 켜지자마자 무거운 DB를 바로 생성하지 않고, 최초로 데이터 저장이 필요할 때만 DB 초기화
    - _database!: "_database는 Null이 될 수도 있지만, 위에서 Null 검사를 통과했으니 절대 Null이 아니라고 100% 보장해!"라는 의미

    Database? _database;

    Future<Database> get database async {
      if (_database != null) {
        return _database!;
      }

      _database = await _initDatabase();
      return _database!;
    }
  */
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  // DB 초기화
  /*
    DB 파일 생성 및 테이블 정의 (_initDatabase)
    - getDatabasesPath(): 스마트폰 기기 내부의 안전한 DB 전용 폴더 경로를 가져옴
    - join(...): 폴더 경로와 파일 이름(pet_care_manager.db)을 깔끔하게 하나로 합쳐줌

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'pet_care_manager.db');
  */
  Future<Database> _initDatabase() async { 
    final databasePath = await getDatabasesPath();

    // async = 비동기 작업을 할 수 있게 함수 만들기
    // await = 그 작업의 결과를 기다리기
    final path = join(
      databasePath,
      'pet_care_manager.db',
    );

    /*
      openDatabase: DB 파일이 없으면 새로 만들고, 이미 존재하면 열어줌
      onCreate: DB 파일이 처음 생성되는 시점에 딱 한 번 실행되는 콜백 함수. SQL 문법으로 pets라는 표(Table)를 생성합니다.
      INTEGER PRIMARY KEY AUTOINCREMENT: 반려동물이 등록될 때마다 1, 2, 3... 번호(ID)를 자동으로 매겨줌
      name TEXT NOT NULL: 이름은 필수(Null 불가) 텍스트
      weight REAL: 몸무게는 소수점이 들어가는 실수(Float/Double) 타입
    */
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            birth_date TEXT,
            gender TEXT,
            breed TEXT,
            weight REAL
          )
        ''');
      },
    );
  }

  /*
    - toIso8601String(): SQLite DB에는 DateTime 타입이 따로 없어서 보통 표준 문자열 형식으로 바꿔서 저장
    - 리턴값 Future<int>: 
      - insert(): 성공적으로 저장되면 생성된 데이터의 ID 번호(1, 2, 3...)를 숫자로 반환. 즉, 새로 만들어진 행의 ID 반환
      - update(): 수정된 행의 개수
      - delete(): 삭제된 행의 개수
  */
  // 반려동물 추가
  Future<int> insertPet(Pet pet) async {
    final db = await database; // 준비된 DB 가져오기

    return await db.insert(
      'pets', // 저장할 테이블 이름
      {
        'name': pet.name,
        'birth_date': pet.birthDate?.toIso8601String(), // 날짜를 문자열 형태(2026-08-11...)로 변환
        'gender': pet.gender,
        'breed': pet.breed,
        'weight': pet.weight,
      },
    );
  }

  // 반려동물 전체 조회
  Future<List<Pet>> getPets() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'pets',
      orderBy: 'id DESC',
    );

    return maps.map((map) { // SQLite 데이터 -> Map -> Pet 객체
      return Pet(
        id: map['id'] as int,
        name: map['name'] as String,
        birthDate: map['birth_date'] != null
            ? DateTime.parse(map['birth_date'] as String)
            : null,
        gender: map['gender'] as String?,
        breed: map['breed'] as String?,
        weight: map['weight'] != null
            ? (map['weight'] as num).toDouble()
            : null,
      );
    }).toList();
  }

  // 반려동물 수정
  Future<int> updatePet(Pet pet) async { 
    final db = await database;

    return await db.update(
      'pets', 
      {
        'name': pet.name,
        'birth_date': pet.birthDate?.toIso8601String(),
        'gender': pet.gender,
        'breed': pet.breed,
        'weight': pet.weight
      },
      where: 'id = ?',
      whereArgs: [pet.id]
    );
  }

  // 반려동물 조회
  Future<Pet?> getPetById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );

    if(maps.isEmpty) {
      return null;
    }

    final map = maps.first;

    return Pet(
      id: map['id'] as int,
      name: map['name'] as String,
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date'] as String) : null,
      gender: map['gender'] as String?,
      breed: map['breed'] as String?,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null
    );
  }

  // 반려동물 삭제
  Future<int> deletePet(int id) async {
    final db = await database;

    return await db.delete(
      'pets',
      where: 'id = ?',
      whereArgs: [id]
    );
  }
}