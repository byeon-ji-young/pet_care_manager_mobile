import 'package:flutter/material.dart';

import '../services/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // 데이터 백업
  Future<void> _backupData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: const Text('데이터 백업'),
          content: const Text(
            '현재 저장된 반려동물 데이터와\n'
            '건강 기록 사진을 백업 파일로 저장할까요?',
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
      }
    } catch (e) {
      debugPrint('데이터 복원 실패: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('데이터 복원에 실패했어요.')));
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
              subtitle: const Text('반려동물 데이터를 파일로 저장해요.'),
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
        ],
      ),
    );
  }
}
