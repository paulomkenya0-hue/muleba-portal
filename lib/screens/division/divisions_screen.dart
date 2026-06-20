import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/leader_edit_dialog.dart';

class DivisionsScreen extends StatefulWidget {
  const DivisionsScreen({super.key});
  @override
  State<DivisionsScreen> createState() => _DivisionsScreenState();
}

class _DivisionsScreenState extends State<DivisionsScreen> {
  List<Division> _divisions = [];
  bool _loading = true;
  int? _expanded;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await DatabaseHelper.instance.getDivisions();
    if (mounted) setState(() { _divisions = d; _loading = false; });
  }

  void _showForm({Division? div}) => showDialog(
    context: context,
    builder: (_) => _DivisionDialog(division: div, onSaved: _load));

  Future<void> _delete(Division div) async {
    final ok = await showConfirmDialog(context,
      title: 'Futa Tarafa',
      message: 'Futa "${div.name}"?\n\nKata na Viongozi wote watafutwa.');
    if (ok == true) {
      await DatabaseHelper.instance.deleteDivision(div.id!);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.deletedSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SectionHeader(title: 'Tarafa (${_divisions.length})'),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showForm(),
            icon: const Icon(Icons.add, size: 17),
            label: const Text(AppStrings.addDivision)),
        ]),
        const SizedBox(height: 14),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _divisions.isEmpty
            ? EmptyState(message: 'Hakuna Tarafa bado.\nOngeza ya kwanza.',
                icon: Icons.location_city_outlined,
                actionLabel: AppStrings.addDivision,
                onAction: () => _showForm())
            : ListView.builder(
                itemCount: _divisions.length,
                itemBuilder: (_, i) {
                  final div = _divisions[i];
                  final isExp = _expanded == div.id;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGreen,
                            borderRadius: BorderRadius.circular(9)),
                          child: const Icon(Icons.location_city,
                            color: AppTheme.primaryGreen, size: 20)),
                        title: Text(div.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: div.description != null
                          ? Text(div.description!,
                              style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 12))
                          : null,
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(onPressed: () => _showForm(div: div),
                            icon: const Icon(Icons.edit_outlined),
                            color: AppTheme.primaryGreen, iconSize: 20),
                          IconButton(onPressed: () => _delete(div),
                            icon: const Icon(Icons.delete_outline),
                            color: AppTheme.errorRed, iconSize: 20),
                          IconButton(
                            onPressed: () => setState(() =>
                              _expanded = isExp ? null : div.id),
                            icon: Icon(isExp
                              ? Icons.expand_less : Icons.expand_more),
                            iconSize: 20),
                        ])),
                      if (isExp) _DivisionLeadersPanel(divisionId: div.id!),
                    ]));
                })),
      ]),
    );
  }
}

class _DivisionLeadersPanel extends StatefulWidget {
  final int divisionId;
  const _DivisionLeadersPanel({required this.divisionId});
  @override
  State<_DivisionLeadersPanel> createState() => _DivisionLeadersPanelState();
}

class _DivisionLeadersPanelState extends State<_DivisionLeadersPanel> {
  List<Leader> _leaders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final l = await DatabaseHelper.instance
      .getLeaders(widget.divisionId, 'division');
    if (mounted) setState(() { _leaders = l; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAF9),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('VIONGOZI',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen, letterSpacing: 1.2))),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          ..._leaders.map((l) => LeaderTile(leader: l,
            onEdit: () => showDialog(context: context,
              builder: (_) => LeaderEditDialog(leader: l, onSaved: _load)))),
      ]));
  }
}

class _DivisionDialog extends StatefulWidget {
  final Division? division;
  final VoidCallback onSaved;
  const _DivisionDialog({this.division, required this.onSaved});
  @override
  State<_DivisionDialog> createState() => _DivisionDialogState();
}

class _DivisionDialogState extends State<_DivisionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  bool _saving = false;
  bool get _isEdit => widget.division != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.division?.name ?? '');
    _descCtrl = TextEditingController(text: widget.division?.description ?? '');
  }

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await DatabaseHelper.instance.updateDivision(
          widget.division!.copyWith(
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
              ? null : _descCtrl.text.trim()));
      } else {
        await DatabaseHelper.instance.insertDivision(Division(
          name: _nameCtrl.text.trim(),
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
              Text(_isEdit ? 'Hariri Tarafa' : 'Ongeza Tarafa',
                style: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jina la Tarafa *',
                  prefixIcon: Icon(Icons.location_city_outlined)),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                  Validators.validateRequired(v, 'Jina la Tarafa')),
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
