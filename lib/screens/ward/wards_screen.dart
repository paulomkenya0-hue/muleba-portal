import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/leader_edit_dialog.dart';
import '../division/divisions_screen.dart' show _LeadersPanel;

class WardsScreen extends StatefulWidget {
  const WardsScreen({super.key});
  @override
  State<WardsScreen> createState() => _WardsScreenState();
}

class _WardsScreenState extends State<WardsScreen> {
  List<Division> _divisions = [];
  Map<int, List<Ward>> _wardMap = {};
  bool _loading = true;
  Set<int> _expandedDivs = {};
  int? _expandedWard;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final divs = await DatabaseHelper.instance.getDivisions();
    final map = <int, List<Ward>>{};
    for (final d in divs) {
      map[d.id!] = await DatabaseHelper.instance.getWardsByDivision(d.id!);
    }
    if (mounted) setState(() {
      _divisions = divs; _wardMap = map; _loading = false;
    });
  }

  void _showForm({Ward? ward, int? divId}) {
    if (_divisions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ongeza Tarafa kwanza!')));
      return;
    }
    showDialog(context: context,
      builder: (_) => _WardDialog(
        ward: ward,
        divisions: _divisions,
        initialDivId: divId ?? ward?.divisionId ?? _divisions.first.id!,
        onSaved: _load));
  }

  Future<void> _delete(Ward ward) async {
    final ok = await showConfirmDialog(context,
      title: 'Futa Kata',
      message: 'Futa "${ward.name}"?\n\nViongozi wote watafutwa.');
    if (ok == true) {
      await DatabaseHelper.instance.deleteWard(ward.id!);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.deletedSuccess)));
    }
  }

  int get _total =>
    _wardMap.values.fold(0, (s, w) => s + w.length);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SectionHeader(title: 'Kata ($_total)'),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showForm(),
            icon: const Icon(Icons.add, size: 17),
            label: const Text(AppStrings.addWard)),
        ]),
        const SizedBox(height: 14),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _divisions.isEmpty
            ? const EmptyState(message: 'Ongeza Tarafa kwanza',
                icon: Icons.map_outlined)
            : ListView.builder(
                itemCount: _divisions.length,
                itemBuilder: (_, i) {
                  final div = _divisions[i];
                  final wards = _wardMap[div.id] ?? [];
                  final isExp = _expandedDivs.contains(div.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(children: [
                      ListTile(
                        leading: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(9)),
                          child: const Icon(Icons.location_city,
                            color: Color(0xFF1565C0), size: 20)),
                        title: Text(div.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${wards.length} Kata',
                          style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          TextButton.icon(
                            onPressed: () => _showForm(divId: div.id),
                            icon: const Icon(Icons.add, size: 15),
                            label: const Text('Kata', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen)),
                          IconButton(
                            onPressed: () => setState(() {
                              if (isExp) _expandedDivs.remove(div.id);
                              else _expandedDivs.add(div.id!);
                            }),
                            icon: Icon(isExp
                              ? Icons.expand_less : Icons.expand_more)),
                        ])),
                      if (isExp)
                        Container(
                          color: const Color(0xFFF9FAF9),
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                          child: wards.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Hakuna Kata bado',
                                  style: TextStyle(color: AppTheme.textMuted,
                                    fontStyle: FontStyle.italic, fontSize: 12)))
                            : Column(
                                children: wards.map((w) => Column(children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade200)),
                                    child: ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.map,
                                        color: Color(0xFF1565C0), size: 16),
                                      title: Text(w.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () => _showForm(ward: w),
                                            icon: const Icon(Icons.edit_outlined,
                                              size: 17),
                                            color: AppTheme.primaryGreen),
                                          IconButton(
                                            onPressed: () => _delete(w),
                                            icon: const Icon(
                                              Icons.delete_outline, size: 17),
                                            color: AppTheme.errorRed),
                                          IconButton(
                                            onPressed: () => setState(() =>
                                              _expandedWard =
                                                _expandedWard == w.id
                                                  ? null : w.id),
                                            icon: Icon(
                                              _expandedWard == w.id
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                              size: 17)),
                                        ]))),
                                  if (_expandedWard == w.id)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: _LeadersPanel(
                                        levelId: w.id!,
                                        levelType: 'ward')),
                                ])).toList()),
                        ),
                    ]));
                })),
      ]),
    );
  }
}

class _WardDialog extends StatefulWidget {
  final Ward? ward;
  final List<Division> divisions;
  final int initialDivId;
  final VoidCallback onSaved;
  const _WardDialog({this.ward, required this.divisions,
    required this.initialDivId, required this.onSaved});
  @override
  State<_WardDialog> createState() => _WardDialogState();
}

class _WardDialogState extends State<_WardDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late int _divId;
  bool _saving = false;
  bool get _isEdit => widget.ward != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.ward?.name ?? '');
    _descCtrl = TextEditingController(text: widget.ward?.description ?? '');
    _divId = widget.initialDivId;
  }

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await DatabaseHelper.instance.updateWard(widget.ward!.copyWith(
          name: _nameCtrl.text.trim(), divisionId: _divId,
          description: _descCtrl.text.trim().isEmpty
            ? null : _descCtrl.text.trim()));
      } else {
        await DatabaseHelper.instance.insertWard(Ward(
          divisionId: _divId, name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
            ? null : _descCtrl.text.trim(),
          createdAt: DateTime.now()));
      }
      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.savedSuccess)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(key: _formKey, child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_isEdit ? 'Hariri Kata' : 'Ongeza Kata',
                style: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _divId,
                decoration: const InputDecoration(
                  labelText: 'Tarafa *',
                  prefixIcon: Icon(Icons.location_city_outlined)),
                items: widget.divisions.map((d) => DropdownMenuItem(
                  value: d.id, child: Text(d.name))).toList(),
                onChanged: (v) => setState(() => _divId = v!),
                validator: (v) => v == null ? 'Chagua Tarafa' : null),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jina la Kata *',
                  prefixIcon: Icon(Icons.map_outlined)),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                  Validators.validateRequired(v, 'Jina la Kata')),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Maelezo (Hiari)',
                  prefixIcon: Icon(Icons.notes_outlined)),
                maxLines: 2),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ghairi'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2,
                          color: Colors.white))
                    : Text(_isEdit ? 'Hifadhi' : 'Ongeza'))),
              ]),
            ])),
        ),
      ),
    );
  }
}
