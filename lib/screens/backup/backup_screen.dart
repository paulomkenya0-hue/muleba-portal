import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common_widgets.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _loading = false;
  String? _lastBackup;

  Future<void> _backup() async {
    setState(() => _loading = true);
    try {
      final dir = await getExternalStorageDirectory()
        ?? await getApplicationDocumentsDirectory();
      final ds = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${dir.path}/muleba_backup_$ds.db';
      final ok = await DatabaseHelper.instance.backupDatabase(path);
      if (!mounted) return;
      if (ok) {
        setState(() => _lastBackup = path.split('/').last);
        await Share.shareXFiles([XFile(path)],
          subject: 'Nakala ya Database — Wilaya ya Muleba');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.backupSuccess)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu: $e'),
          backgroundColor: AppTheme.errorRed));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    final ok = await showConfirmDialog(context,
      title: 'Rejesha Taarifa',
      message: 'TAHADHARI: Data yote ya sasa itabadilishwa.\nUna uhakika?',
      confirmText: 'Rejesha', confirmColor: Colors.orange);
    if (ok != true) return;
    try {
      final r = await FilePicker.platform.pickFiles(type: FileType.any);
      if (r == null || r.files.first.path == null) return;
      if (!r.files.first.name.endsWith('.db')) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chagua faili la .db tu'),
            backgroundColor: AppTheme.errorRed));
        return;
      }
      setState(() => _loading = true);
      final success = await DatabaseHelper.instance
        .restoreDatabase(r.files.first.path!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
          ? AppStrings.restoreSuccess : AppStrings.errorOccurred),
        backgroundColor: success ? null : AppTheme.errorRed));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title: 'Hifadhi na Rejesha Data'),
          const SizedBox(height: 16),
          // Backup card
          Card(child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen,
                    borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.backup,
                    color: AppTheme.primaryGreen, size: 26)),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Nakala Kumbukumbu',
                    style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700)),
                  Text('Hifadhi data yote kwa usalama',
                    style: TextStyle(color: AppTheme.textMuted,
                      fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 14),
              const Text(
                'Hifadhi nakala ya database yote. Unaweza kutuma kwa WhatsApp, Email, au Bluetooth.',
                style: TextStyle(color: AppTheme.textMuted,
                  fontSize: 13, height: 1.5)),
              if (_lastBackup != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen,
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.check_circle,
                      color: AppTheme.primaryGreen, size: 15),
                    const SizedBox(width: 7),
                    Expanded(child: Text(_lastBackup!,
                      style: const TextStyle(
                        color: AppTheme.primaryGreen, fontSize: 12))),
                  ])),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _backup,
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Tengeneza Nakala Sasa'))),
            ]))),
          const SizedBox(height: 14),
          // Restore card
          Card(child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.restore,
                    color: Colors.orange, size: 26)),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Rejesha Taarifa',
                    style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700)),
                  Text('Rejesha kutoka kwa nakala',
                    style: TextStyle(color: AppTheme.textMuted,
                      fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3))),
                child: const Row(children: [
                  Icon(Icons.warning_amber,
                    color: Colors.orange, size: 16),
                  SizedBox(width: 7),
                  Expanded(child: Text(
                    'TAHADHARI: Data ya sasa itafutwa kabisa.',
                    style: TextStyle(color: Colors.orange, fontSize: 12))),
                ])),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _restore,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Chagua Faili la Nakala'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange)))),
            ]))),
        ])),
      if (_loading) const LoadingOverlay(message: 'Inafanya kazi...'),
    ]);
  }
}
