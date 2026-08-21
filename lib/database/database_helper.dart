import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import '../models/pet.dart';
import '../models/health_record.dart';
import '../models/vaccination.dart';
import '../models/weight_record.dart';
import '../models/medication.dart';

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
    final path = join(databasePath, 'pet_care_manager.db');

    /*
      openDatabase: DB 파일이 없으면 새로 만들고, 이미 존재하면 열어줌
      onCreate: DB 파일이 처음 생성되는 시점에 딱 한 번 실행되는 콜백 함수. SQL 문법으로 pets라는 표(Table)를 생성합니다.
      INTEGER PRIMARY KEY AUTOINCREMENT: 반려동물이 등록될 때마다 1, 2, 3... 번호(ID)를 자동으로 매겨줌
      name TEXT NOT NULL: 이름은 필수(Null 불가) 텍스트
      weight REAL: 몸무게는 소수점이 들어가는 실수(Float/Double) 타입
    */
    return await openDatabase(
      path,
      version: 3, // DB 구조가 바뀔 때만 올림
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // pets
        await db.execute('''
          CREATE TABLE pets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            birth_date TEXT,
            gender TEXT,
            breed TEXT,
            weight REAL,
            image_path TEXT
          )
        ''');

        // health_records
        await db.execute('''
          CREATE TABLE health_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pet_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            hospital TEXT,
            title TEXT NOT NULL,
            description TEXT,
            cost INTEGER,
            FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
          )
        ''');

        // vaccinations
        await db.execute('''
          CREATE TABLE vaccinations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pet_id INTEGER NOT NULL,
            vaccine_name TEXT NOT NULL,
            vaccination_date TEXT NOT NULL,
            next_date TEXT,
            hospital TEXT,
            memo TEXT,
            FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
          )
        ''');

        // weight_records
        await db.execute('''
          CREATE TABLE weight_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pet_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            weight REAL NOT NULL,
            memo TEXT,
            FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
          )
        ''');

        // medications
        await db.execute('''
          CREATE TABLE medications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pet_id INTEGER NOT NULL,
            medication_name TEXT NOT NULL,
            medication_date TEXT NOT NULL,
            medication_time TEXT,
            next_date TEXT,
            repeat_type TEXT NOT NULL DEFAULT 'none',
            repeat_interval INTEGER,
            memo TEXT,
            FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        // 1->2. 약 복용 테이블에 복용 시간 컬럼 추가
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE medications ADD COLUMN medication_time TEXT',
          );
        }

        // 2 → 3. 약 복용 테이블에 반복 복용 관련 컬럼 추가
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE medications ADD COLUMN repeat_type TEXT NOT NULL DEFAULT 'none'",
          );

          await db.execute(
            'ALTER TABLE medications ADD COLUMN repeat_interval INTEGER',
          );
        }
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
  // ========================================================= pets =========================================================
  // 반려동물 추가
  Future<int> insertPet(Pet pet) async {
    final db = await database; // 준비된 DB 가져오기

    return await db.insert(
      'pets', // 저장할 테이블 이름
      {
        'name': pet.name,
        'birth_date': pet.birthDate
            ?.toIso8601String(), // 날짜를 문자열 형태(2026-08-11...)로 변환
        'gender': pet.gender,
        'breed': pet.breed,
        'weight': pet.weight,
        'image_path': pet.imagePath,
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

    return maps.map((map) {
      // SQLite 데이터 -> Map -> Pet 객체
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
        imagePath: map['image_path'] as String?,
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
        'weight': pet.weight,
        'image_path': pet.imagePath,
      },
      where: 'id = ?',
      whereArgs: [pet.id],
    );
  }

  // 반려동물 조회
  Future<Pet?> getPetById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    final map = maps.first;

    return Pet(
      id: map['id'] as int,
      name: map['name'] as String,
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'] as String)
          : null,
      gender: map['gender'] as String?,
      breed: map['breed'] as String?,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      imagePath: map['image_path'] as String?,
    );
  }

  // 반려동물 삭제
  Future<int> deletePet(int id) async {
    final db = await database;

    return await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }

  // ========================================================= health_records =========================================================
  // 병원 기록 추가
  Future<int> insertHealthRecord(HealthRecord record) async {
    final db = await database;

    return await db.insert('health_records', {
      'pet_id': record.petId,
      'date': record.date.toIso8601String(),
      'hospital': record.hospital,
      'title': record.title,
      'description': record.description,
      'cost': record.cost,
    });
  }

  // 반려동물별 동물기록 조회
  Future<List<HealthRecord>> getHealthRecordByPetId(int petId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'date DESC',
    );

    return List.generate(
      // List.generate(개수, 함수): 정해진 개수만큼 리스트 만들어주는 함수
      maps.length,
      (i) {
        return HealthRecord(
          id: maps[i]['id'],
          petId: maps[i]['pet_id'],
          date: DateTime.parse(maps[i]['date']),
          hospital: maps[i]['hospital'],
          title: maps[i]['title'],
          description: maps[i]['description'],
          cost: maps[i]['cost'],
        );
      },
    );
  }

  // 병원기록 삭제
  Future<int> deleteHealthRecord(int id) async {
    final db = await database;

    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  // 병원기록 수정
  Future<int> updateHealthRecord(HealthRecord record) async {
    final db = await database;

    return await db.update(
      'health_records',
      {
        'pet_id': record.petId,
        'date': record.date.toIso8601String(),
        'hospital': record.hospital,
        'title': record.title,
        'description': record.description,
        'cost': record.cost,
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // ========================================================= vaccination =========================================================
  // 예방접종 등록
  Future<int> insertVaccination(Vaccination vaccination) async {
    final db = await database;

    return await db.insert('vaccinations', vaccination.toMap());
  }

  //반려동물별 예방접종 조회
  Future<List<Vaccination>> getVaccinationsByPetId(int petId) async {
    final db = await database;

    final maps = await db.query(
      'vaccinations',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'vaccination_date DESC',
    );

    return maps.map((map) => Vaccination.fromMap(map)).toList();
  }

  // 예방접종 수정
  Future<int> updateVaccination(Vaccination vaccination) async {
    final db = await database;

    return db.update(
      'vaccinations',
      {
        'pet_id': vaccination.petId,
        'vaccine_name': vaccination.vaccineName,
        'vaccination_date': vaccination.vaccinationDate.toIso8601String(),
        'next_date': vaccination.nextDate?.toIso8601String(),
        'hospital': vaccination.hospital,
        'memo': vaccination.memo,
      },
      where: 'id = ?',
      whereArgs: [vaccination.id],
    );
  }

  // 예방접종 삭제
  Future<int> deleteVaccination(int id) async {
    final db = await database;

    return db.delete('vaccinations', where: 'id = ?', whereArgs: [id]);
  }

  // 예방 접종일 조회
  Future<List<Vaccination>> getUpcomingVaccinations(int petId) async {
    final db = await database;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final maps = await db.query(
      'vaccinations',
      where: 'pet_id = ? AND next_date IS NOT NULL AND next_date >= ?',
      whereArgs: [petId, todayOnly.toIso8601String()],
      orderBy: 'next_date ASC',
    );

    return maps.map((map) {
      return Vaccination.fromMap(map);
    }).toList();
  }

  // 다음 접종일 조회
  Future<Vaccination?> getNextVaccination(int petId) async {
    final db = await database;

    final today = DateTime.now();
    final todayString =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'vaccinations',
      where: 'pet_id = ? AND next_date IS NOT NULL and next_date >= ?',
      whereArgs: [petId, todayString],
      orderBy: 'next_date ASC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Vaccination.fromMap(maps.first);
  }

  // ========================================================= weight_records =========================================================
  // 체중 등록
  Future<int> insertWeightRecord(WeightRecord record) async {
    final db = await database;

    return db.insert('weight_records', record.toMap());
  }

  // 반려동물별 체중 조회
  Future<List<WeightRecord>> getWeightRecordsByPetId(int petId) async {
    final db = await database;

    final maps = await db.query(
      'weight_records',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => WeightRecord.fromMap(map)).toList();
  }

  // 체중 수정
  Future<int> updateWeightRecord(WeightRecord record) async {
    final db = await database;

    return db.update(
      'weight_records',
      {
        'pet_id': record.petId,
        'date': record.date.toIso8601String(),
        'weight': record.weight,
        'memo': record.memo,
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // 체중 삭제
  Future<int> deleteWeightRecord(int id) async {
    final db = await database;

    return db.delete('weight_records', where: 'id = ?', whereArgs: [id]);
  }

  // ========================================================= medication =========================================================
  // 약 복용 기록 추가
  Future<int> insertMedication(Medication medication) async {
    final db = await database;

    return db.insert('medications', medication.toMap());
  }

  // 반려동물별 약 복용 기록 조회
  Future<List<Medication>> getMedicationsByPetId(int petId) async {
    final db = await database;

    final maps = await db.query(
      'medications',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'medication_date DESC',
    );

    return maps.map((map) => Medication.fromMap(map)).toList();
  }

  // 약 복용 기록 수정
  Future<int> updateMedication(Medication medication) async {
    final db = await database;

    return db.update(
      'medications',
      {
        'pet_id': medication.petId,
        'medication_name': medication.medicationName,
        'medication_date': medication.medicationDate.toIso8601String(),
        'medication_time': medication.medicationTime != null
            ? '${medication.medicationTime!.hour.toString().padLeft(2, '0')}:${medication.medicationTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'next_date': medication.nextDate?.toIso8601String(),
        'repeat_type': medication.repeatType,
        'repeat_interval': medication.repeatInterval,
        'memo': medication.memo,
      }, // toMap() 사용 안하고 직접 만든 이유: UPDATE에서는 ID를 수정할 필요가 없으니까 우리가 수정할 컬럼만 명시
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  // 약 복용 기록 삭제
  Future<int> deleteMedication(int id) async {
    final db = await database;

    return db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // 다가오는 약 복용일 조회
  Future<List<Medication>> getUpcomingMedications(int petId) async {
    final db = await database;

    final maps = await db.query(
      'medications',
      where: 'pet_id = ?',
      whereArgs: [petId],
    );

    final medications = maps
        .map((map) => Medication.fromMap(map))
        .map((medication) {
          final nextMedicationDate = _calculateNextMedicationDate(medication);

          if (nextMedicationDate == null) {
            return null;
          }

          // DB의 next_date를 변경하는 것이 아니라 조회할 때 계산한 다음 복용일을 Medication 객체에 넣어준다.
          return Medication(
            id: medication.id,
            petId: medication.petId,
            medicationName: medication.medicationName,
            medicationDate: medication.medicationDate,
            medicationTime: medication.medicationTime,
            nextDate: nextMedicationDate,
            repeatType: medication.repeatType,
            repeatInterval: medication.repeatInterval,
            memo: medication.memo,
          );
        })
        .whereType<Medication>()
        .toList();

    // 다음 복용일이 가까운 순으로 정렬
    medications.sort((a, b) {
      return a.nextDate!.compareTo(b.nextDate!);
    });

    return medications;
  }

  // 다음 약 복용일 조회
  Future<Medication?> getNextMedication(int petId) async {
    final medications = await getUpcomingMedications(petId);

    if (medications.isEmpty) {
      return null;
    }

    return medications.first;
  }

  // 반복 복용 약의 실제 다음 복용일 계산
  DateTime? _calculateNextMedicationDate(Medication medication) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // 다음 복용일이 지정되어 있는 경우
    DateTime baseDate = medication.nextDate ?? medication.medicationDate;

    // 반복하지 않는 약
    if (medication.repeatType == 'none') {
      if (baseDate.isBefore(todayOnly)) {
        return null;
      }

      return baseDate;
    }
    // 매일
    else if (medication.repeatType == 'daily') {
      while (baseDate.isBefore(todayOnly)) {
        baseDate = baseDate.add(const Duration(days: 1));
      }

      return baseDate;
    }
    // 매주
    else if (medication.repeatType == 'weekly') {
      while (baseDate.isBefore(todayOnly)) {
        baseDate = baseDate.add(const Duration(days: 7));
      }

      return baseDate;
    }
    // n일 마다
    if (medication.repeatType == 'interval' &&
        medication.repeatInterval != null &&
        medication.repeatInterval! > 0) {
      final interval = medication.repeatInterval!;

      while (baseDate.isBefore(todayOnly)) {
        baseDate = baseDate.add(Duration(days: interval));
      }

      return baseDate;
    }

    return null;
  }
}
