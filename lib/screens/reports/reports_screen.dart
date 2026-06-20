import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _exporting = false;

  Future<void> _export(String type, String? levelFilter) async {
    setState(() => _exporting = true);
    try {
      var rows = await DatabaseHelper.instance.getAllLeadersForExport();
      if (levelFilter != null) {
        final m = {'district': 'Wilaya', 'division': 'Tarafa', 'ward': 'Kata'};
        rows = rows.where((r) => r['Ngazi'] == m[levelFilter]).toList();
      }
      if (rows.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hakuna data ya kuhamisha')));
        return;
      }
      final excel = Excel.createExcel();
      final sheet = excel['Viongozi'];
      excel.delete('Sheet1');

      final headers = ['Ngazi', 'Jina la Eneo', 'Tarafa', 'Cheo',
        'Jina Kamili', 'Simu', 'Barua Pepe'];
      for (int c = 0; c < headers.length; c++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
        cell.value = TextCellValue(headers[c]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#1B5E20'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'));
      }
      for (int r = 0; r < rows.length; r++) {
        for (int c = 0; c < headers.length; c++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
          cell.value = TextCellValue(rows[r][headers[c]]?.toString() ?? '');
          if (r % 2 == 0) {
            cell.cellStyle = CellStyle(
              backgroundColorHex: ExcelColor.fromHexString('#F1F8E9'));
          }
        }
      }
      sheet.setColumnWidth(0, 10);
      sheet.setColumnWidth(1, 25);
      sheet.setColumnWidth(2, 25);
      sheet.setColumnWidth(3, 35);
      sheet.setColumnWidth(4, 30);
      sheet.setColumnWidth(5, 15);
      sheet.setColumnWidth(6, 30);

      final dir = await getExternalStorageDirectory()
        ?? await getApplicationDocumentsDirectory();
      final ds = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fname = 'Muleba_${type.replaceAll(' ', '_')}_$ds.xlsx';
      final file = File('${dir.path}/$fname');
      await file.writeAsBytes(excel.encode()!);
      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)],
        subject: 'Ripoti ya Viongozi — Wilaya ya Muleba');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.exportSuccess} $fname')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hitilafu: $e'),
          backgroundColor: AppTheme.errorRed));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title: 'Ripoti na Hamisha Excel'),
          const SizedBox(height: 16),
          Expanded(child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: [
              _ExCard('Viongozi Wote',
                'Wilaya + Tarafa + Kata',
                Icons.people, AppTheme.primaryGreen,
                () => _export('Viongozi_Wote', null)),
              _ExCard('Viongozi wa Wilaya',
                'Viongozi 6 wa Wilaya',
                Icons.account_balance, AppTheme.accentGold,
                () => _export('Wilaya', 'district')),
              _ExCard('Viongozi wa Tarafa',
                'Tarafa zote',
                Icons.location_city, const Color(0xFF1565C0),
                () => _export('Tarafa', 'division')),
              _ExCard('Viongozi wa Kata',
                'Kata zote',
                Icons.map, const Color(0xFF6A1B9A),
                () => _export('Kata', 'ward')),
            ])),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.dividerGreen.withOpacity(0.4))),
            child: const Row(children: [
              Icon(Icons.info_outline,
                color: AppTheme.primaryGreen, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Faili la Excel litashirikiwa moja kwa moja kupitia WhatsApp, Email n.k.',
                style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12))),
            ])),
        ])),
      if (_exporting) const LoadingOverlay(message: 'Inaandaa Excel...'),
    ]);
  }
}

class _ExCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ExCard(this.title, this.subtitle, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: color, size: 22)),
              const Spacer(),
              const Icon(Icons.file_download_outlined,
                color: AppTheme.textMuted, size: 18),
            ]),
            const Spacer(),
            Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 3),
            Text(subtitle,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ])),
      ),
    );
  }
}
