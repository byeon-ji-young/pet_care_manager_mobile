import 'package:flutter/material.dart';

import '../services/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _backupData(BuildContext context) async {
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
        ],
      ),
    );
  }
}
