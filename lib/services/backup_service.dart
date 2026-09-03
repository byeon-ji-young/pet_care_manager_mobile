import 'dart:convert'; // JSON 변환과 UTF-8 변환에 사용
import 'dart:io'; // 파일을 다루기 위해 사용

import 'package:archive/archive.dart'; // ZIP 같은 압축파일을 만들기 위한 패키지
import 'package:file_picker/file_picker.dart'; // 어디에 백업 파일을 저장할지 선택하는 창을 띄우기 위해 사용
import 'package:path/path.dart' as p; // 파일 경로를 안전하게 조합하거나 확장자를 가져올 때 사용

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
}
