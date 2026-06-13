import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/leader_edit_dialog.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  List<Division> _divisions = [];
  List<Ward> _wards = [];
  Division? _selDiv;
  Ward? _selWard;
  List<SearchResult> _results = [];
  bool _searched = false, _searching = false;

  @override
  void initState() { super.initState(); _loadDivs(); }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose();
  }

  Future<void> _loadDivs() async {
    final d = await DatabaseHelper.instance.getDivisions();
    if (mounted) setState(() => _divisions = d);
  }

  Future<void> _loadWards(Division? d) async {
    if (d == null) { setState(() { _wards = []; _selWard = null; }); return; }
    final w = await DatabaseHelper.instance.getWardsByDivision(d.id!);
    if (mounted) setState(() { _wards = w; _selWard = null; });
  }

  Future<void> _search() async {
    setState(() => _searching = true);
    final r = await DatabaseHelper.instance.searchLeaders(
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      divisionId: _selDiv?.id,
      wardId: _selWard?.id);
    if (mounted) setState(() {
      _results = r; _searched = true; _searching = false;
    });
  }

  void _clear() {
    _nameCtrl.clear(); _phoneCtrl.clear();
    setState(() {
      _selDiv = null; _selWard = null;
      _wards = []; _results = []; _searched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title: 'Tafuta Kiongozi'),
        const SizedBox(height: 12),
        Card(child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Row(children: [
              Expanded(child: TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tafuta kwa Jina',
                  prefixIcon: Icon(Icons.person_search_outlined),
                  hintText: 'Andika jina...'),
                onFieldSubmitted: (_) => _search())),
              const SizedBox(width: 14),
              Expanded(child: TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tafuta kwa Simu',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '0712345678'),
                keyboardType: TextInputType.phone,
                onFieldSubmitted: (_) => _search())),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: DropdownButtonFormField<Division>(
                value: _selDiv,
                decoration: const InputDecoration(
                  labelText: 'Tarafa',
                  prefixIcon: Icon(Icons.location_city_outlined)),
                items: [
                  const DropdownMenuItem<Division>(
                    value: null, child: Text('Zote')),
                  ..._divisions.map((d) => DropdownMenuItem(
                    value: d, child: Text(d.name))),
                ],
                onChanged: (d) {
                  setState(() => _selDiv = d);
                  _loadWards(d);
                })),
              const SizedBox(width: 14),
              Expanded(child: DropdownButtonFormField<Ward>(
                value: _selWard,
                decoration: const InputDecoration(
                  labelText: 'Kata',
                  prefixIcon: Icon(Icons.map_outlined)),
                items: [
                  const DropdownMenuItem<Ward>(
                    value: null, child: Text('Zote')),
                  ..._wards.map((w) => DropdownMenuItem(
                    value: w, child: Text(w.name))),
                ],
                onChanged: _selDiv == null ? null
                  : (w) => setState(() => _selWard = w))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              TextButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.clear),
                label: const Text('Futa Vichujio')),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _searching ? null : _search,
                icon: _searching
                  ? const SizedBox(height: 15, width: 15,
                      child: CircularProgressIndicator(strokeWidth: 2,
                        color: Colors.white))
                  : const Icon(Icons.search, size: 17),
                label: const Text('Tafuta')),
            ]),
          ]))),
        const SizedBox(height: 16),
        if (_searched)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('Matokeo: ${_results.length}',
              style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 13))),
        Expanded(child: !_searched
          ? const EmptyState(
              message: 'Weka neno la kutafuta\nkisha bonyeza Tafuta',
              icon: Icons.manage_search)
          : _results.isEmpty
            ? const EmptyState(
                message: AppStrings.noResults, icon: Icons.search_off)
            : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final r = _results[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.lightGreen,
                        child: Text(
                          r.leader.fullName.isNotEmpty
                            ? r.leader.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w700))),
                      title: Text(r.leader.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.leader.positionName,
                            style: const TextStyle(
                              color: AppTheme.primaryGreen, fontSize: 12)),
                          Row(children: [
                            const Icon(Icons.location_on,
                              size: 11, color: AppTheme.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              r.divisionName != null
                                ? '${r.divisionName} › ${r.levelName}'
                                : r.levelName,
                              style: const TextStyle(fontSize: 11,
                                color: AppTheme.textMuted)),
                          ]),
                          if (r.leader.phoneNumber.isNotEmpty)
                            Text(r.leader.phoneNumber,
                              style: const TextStyle(fontSize: 11,
                                color: AppTheme.textMuted)),
                        ]),
                      trailing: Chip(
                        label: Text(
                          r.leader.levelType == 'district' ? 'Wilaya'
                            : r.leader.levelType == 'division' ? 'Tarafa'
                            : 'Kata',
                          style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero),
                      onTap: () => showDialog(context: context,
                        builder: (_) => LeaderEditDialog(
                          leader: r.leader, onSaved: _search)),
                    ));
                })),
      ]),
    );
  }
}
