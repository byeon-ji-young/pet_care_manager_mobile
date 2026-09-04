import 'dart:convert'; // JSON 변환과 UTF-8 변환에 사용
import 'dart:io'; // 파일을 다루기 위해 사용

import 'package:archive/archive.dart'; // ZIP 같은 압축파일을 만들기 위한 패키지
import 'package:file_picker/file_picker.dart'; // 어디에 백업 파일을 저장할지 선택하는 창을 띄우기 위해 사용
import 'package:path/path.dart' as p; // 파일 경로를 안전하게 조합하거나 확장자를 가져올 때 사용
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';

class BackupService {
  BackupService._(); // _()는 private 생성자

  static final BackupService instance =
      BackupService._(); // 싱글톤 패턴. 앱 전체에서 BackupService 객체 하나만 공유

  // 데이터 백업
  Future<bool> createBackup() async {
    // 1. DB 전체 데이터 조회
    final backupData = await DatabaseHelper.instance.getBackupData();

    // 2. ZIP 파일 구성
    final archive = Archive();

    // 2-1. JSON 데이터 준비
    final data = Map<String, dynamic>.from(backupData);

    final healthRecordImages = (data['health_record_images'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    // 2-2. 건강 기록 사진 준비
    for (final imageData in healthRecordImages) {
      final originalPath = imageData['image_path'] as String;

      final file = File(originalPath);

      if (!await file.exists()) {
        continue;
      }

      final imageId = imageData['id'];

      // ZIP 내부에서 사용할 상대 경로 ★
      final backupImagePath =
          'images/health_record_$imageId${p.extension(originalPath)}';

      final imageBytes = await file.readAsBytes();

      // 사진을 ZIP에 추가
      archive.addFile(
        ArchiveFile(backupImagePath, imageBytes.length, imageBytes),
      );

      // 절대 경로 대신 ZIP 내부 경로 저장 ★
      imageData['image_path'] = backupImagePath;
    }

    // 수정된 사진 경로를 다시 데이터에 반영
    data['health_record_images'] = healthRecordImages;

    // 2-3. data.json 추가
    final jsonString = const JsonEncoder.withIndent(' ').convert(data);

    // JSON을 바이트로 변환
    final jsonBytes = utf8.encode(jsonString);

    // data.json을 ZIP에 추가
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));

    // 3. ZIP 생성
    final zipBytes = ZipEncoder().encodeBytes(archive);

    // 4. 저장할 파일 이름
    final now = DateTime.now();

    final fileName =
        'petcare_backup_'
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '.zip';

    // 5. 사용자에게 저장 위치 선택하도록 요청
    final result = await FilePicker.saveFile(
      dialogTitle: 'PetCareManager 백업 파일 저장',
      fileName: fileName,
      bytes: zipBytes,
      mimeType: 'application/zip',
    );

    // 사용자가 취소한 경우
    if (result == null) {
      return false;
    }

    return true;
  }

  // 데이터 복원
  Future<bool> restoreBackup() async {
    // 1. 백업 ZIP 파일 선택
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (files.isEmpty) {
      return false;
    }

    final zipPath = files.first.path;

    if (zipPath == null) {
      throw Exception('선택한 백업 파일의 경로를 가져올 수 없습니다.');
    }

    // 2. ZIP 파일 읽기
    final zipFile = File(zipPath);
    final zipBytes = await zipFile.readAsBytes();

    // 3. ZIP 압축 해제 - 압축을 실제 폴더에 풀어놓는 게 아니라 메모리에서 ZIP 내부 파일들을 읽을 수 있게 만드는 것
    final archive = ZipDecoder().decodeBytes(zipBytes);

    // 4. data.json 찾기
    ArchiveFile? dataFile;

    for (final file in archive) {
      if (file.name == 'data.json') {
        dataFile = file;
        break;
      }
    }

    if (dataFile == null) {
      throw Exception('백업 파일에 data.json이 없습니다.');
    }

    // 5. data.json 읽기
    final jsonString = utf8.decode(dataFile.content as List<int>);
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    // 6. 백업 데이터 구조 확인
    final requiredKeys = [
      'pets',
      'health_records',
      'health_record_images',
      'vaccinations',
      'weight_records',
      'medications',
      'medication_logs',
    ];

    for (final key in requiredKeys) {
      if (!backupData.containsKey(key)) {
        throw Exception('백업 데이터가 올바르지 않습니다. ($key 누락)');
      }
    }

    // 7. 앱 전용 저장공간
    final appDirectory =
        await getApplicationDocumentsDirectory(); // getApplicationDocumentsDirectory(): 앱이 사용할 수 있는 전용 문서 저장공간의 위치를 가져옴

    /* 
    Directory(): 폴더 생성이 아니라 경로를 나타내는 객체 생성
    create(): 실제 폴더 생성
    */
    // 최종 사진 저장 위치
    final healthRecordDirectory = Directory(
      p.join(appDirectory.path, 'health_records'),
    );

    // 복원 과정에서 임시로 사용할 폴더
    final restoredImagesDirectory = Directory(
      p.join(appDirectory.path, 'health_records_restore'),
    );

    // 기존 임시 폴더가 있다면 삭제
    if (await restoredImagesDirectory.exists()) {
      await restoredImagesDirectory.delete(recursive: true);
    }

    await restoredImagesDirectory.create(recursive: true);
    /*
    Documents/
    ├── health_records/ (기존)
    └── health_records_restore/ (복원용)
    */

    // 8. ZIP에 있는 건강 기록 사진을 앱 저장 공간으로 복원
    final imageDataList = (backupData['health_record_images'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    for (final imageData in imageDataList) {
      final imageId = imageData['id'];

      if (imageId == null) {
        throw Exception('건강 기록 사진 ID가 없습니다.');
      }

      // ZIP 내부의 사진 경로
      final backupImagePath = imageData['image_path'] as String;

      // ZIP에서 해당 사진 찾기
      ArchiveFile? imageFile;

      for (final file in archive) {
        if (file.name == backupImagePath) {
          imageFile = file;
          break;
        }
      }

      if (imageFile == null) {
        throw Exception('백업 파일에 사진이 없습니다. ($backupImagePath)');
      }

      final healthRecordId = imageData['health_record_id'];

      if (healthRecordId == null) {
        throw Exception('건강 기록 ID가 없습니다.');
      }

      final extension = p.extension(backupImagePath);

      final fileName = 'health_record_$imageId$extension';

      // 임시 폴더에 사진 복원
      final tempRecordDirectory = Directory(
        p.join(restoredImagesDirectory.path, healthRecordId.toString()),
      );

      await tempRecordDirectory.create(
        recursive: true,
      ); // recursive: true는 중간 폴더까지 필요한 경우 알아서 만들어주라는 의미

      final tempTargetPath = p.join(tempRecordDirectory.path, fileName);

      final tempTargetFile = File(tempTargetPath);

      await tempTargetFile.writeAsBytes(imageFile.content as List<int>);

      // DB에는 최종 경로를 저장
      final finalRecordDirectory = Directory(
        p.join(healthRecordDirectory.path, healthRecordId.toString()),
      );

      imageData['image_path'] = p.join(finalRecordDirectory.path, fileName);
    }

    // 수정된 사진 경로를 백업 데이터에 반영
    backupData['health_record_images'] = imageDataList;

    // 9. 기존 DB 삭제 + 백업 데이터 복원
    await DatabaseHelper.instance.restoreBackupData(backupData);

    // 10. 기존 사진 폴더 삭제
    if (await healthRecordDirectory.exists()) {
      await healthRecordDirectory.delete(recursive: true);
    }

    // 11. 복원 폴더를 실제 사진 폴더 이름으로 변경
    await restoredImagesDirectory.rename(healthRecordDirectory.path);

    debugPrint('백업 데이터 복원 완료');

    return true;
  }
}
