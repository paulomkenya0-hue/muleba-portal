import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/leader_edit_dialog.dart';

class DistrictScreen extends StatefulWidget {
  const DistrictScreen({super.key});
  @override
  State<DistrictScreen> createState() => _DistrictScreenState();
}

class _DistrictScreenState extends State<DistrictScreen> {
  List<Leader> _leaders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final l = await DatabaseHelper.instance.getLeaders(1, 'district');
    if (mounted) setState(() { _leaders = l; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, Color(0xFF388E3C)]),
            borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.account_balance, color: Colors.white, size: 28),
            SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('WILAYA YA MULEBA',
                style: TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w800)),
              Text('Viongozi wa Wilaya',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ])),
        const SizedBox(height: 20),
        SectionHeader(title: 'Nafasi za Uongozi'),
        const SizedBox(height: 8),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _leaders.length,
              itemBuilder: (_, i) => LeaderTile(
                leader: _leaders[i],
                onEdit: () => showDialog(
                  context: context,
                  builder: (_) => LeaderEditDialog(
                    leader: _leaders[i], onSaved: _load))))),
      ]),
    );
  }
}
