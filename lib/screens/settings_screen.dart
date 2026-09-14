import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';

import '../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime? lastBackupTime;

  @override
  void initState() {
    super.initState();

    _loadLastBackupTime();
  }

  // 마지막 백업 시간 조회
  Future<void> _loadLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTime = prefs.getString('last_backup_time');

    if (savedTime == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      lastBackupTime = DateTime.tryParse(savedTime);
    });
  }

  // 마지막 백업 시간 표시용
  String _formatLastBackupTime() {
    if (lastBackupTime == null) {
      return '마지막 백업: 없음';
    }

    final year = lastBackupTime!.year;
    final month = lastBackupTime!.month;
    final day = lastBackupTime!.day;
    final hour = lastBackupTime!.hour.toString().padLeft(2, '0');
    final minute = lastBackupTime!.minute.toString().padLeft(2, '0');

    return '마지막 백업: $year.$month.$day $hour:$minute';
  }

  // 데이터 백업
  Future<void> _backupData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: const Text('데이터 백업'),
          content: const Text(
            '현재 저장된 반려동물 데이터를\n'
            '백업 파일로 저장할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('백업'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final success = await BackupService.instance.createBackup();

      // 마지막 백업 시간 다시 조회
      await _loadLastBackupTime();

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('데이터 백업이 완료되었어요.')));
      }
    } catch (e) {
      debugPrint('데이터 백업 실패: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('데이터 백업에 실패했어요.')));
    }
  }

  // 데이터 복원
  Future<void> _restoreData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: const Text('데이터 복원'),
          content: const Text(
            '현재 저장된 모든 데이터가 삭제되고\n'
            '백업 파일의 데이터로 복원됩니다.\n\n'
            '계속하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('복원'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final success = await BackupService.instance.restoreBackup();

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('데이터 복원이 완료되었어요.')));

        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('데이터 복원 실패: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('데이터 복원에 실패했어요.')));
    }
  }

  // 전체 데이터 초기화
  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text(
            '저장된 모든 반려동물과 기록이 삭제됩니다.\n\n'
            '삭제된 데이터는 복구할 수 없습니다.\n'
            '정말 초기화하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await DatabaseHelper.instance.clearAllData();

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 데이터가 삭제되었어요.')));

      // 설정 화면을 닫고 이전 화면으로 돌아가기
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('전체 데이터 초기화 실패: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('데이터 초기화에 실패했어요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '데이터 관리',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.backup_outlined, color: Colors.blue),
              ),
              title: const Text(
                '데이터 백업',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(_formatLastBackupTime()),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _backupData(context),
            ),
          ),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.restore_outlined, color: Colors.green),
              ),
              title: const Text(
                '데이터 복원',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('백업 파일에서 데이터를 복원해요.'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _restoreData(context),
            ),
          ),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBEE),
                child: Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
              title: const Text(
                '전체 데이터 초기화',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  // color: Colors.redAccent,
                ),
              ),
              subtitle: const Text('저장된 모든 반려동물과 기록을 삭제해요.'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _clearAllData(context),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '앱 정보',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: const ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFF3E5F5),
                child: Icon(Icons.info_outline, color: Colors.deepPurple),
              ),
              title: Text(
                '앱 정보',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Text('ver 1.2.0', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
