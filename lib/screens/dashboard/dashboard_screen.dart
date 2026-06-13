import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import '../auth/change_password_screen.dart';
import '../district/district_screen.dart';
import '../division/divisions_screen.dart';
import '../ward/wards_screen.dart';
import '../search/search_screen.dart';
import '../reports/reports_screen.dart';
import '../backup/backup_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, int> _stats = {'divisions': 0, 'wards': 0, 'leaders': 0};

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    final stats = await DatabaseHelper.instance.getStatistics();
    if (mounted) setState(() => _stats = stats);
  }

  Widget _screen() {
    switch (_selectedIndex) {
      case 0: return _HomeTab(stats: _stats,
          onNavigate: (i) => setState(() => _selectedIndex = i));
      case 1: return const DistrictScreen();
      case 2: return const DivisionsScreen();
      case 3: return const WardsScreen();
      case 4: return const SearchScreen();
      case 5: return const ReportsScreen();
      case 6: return const BackupScreen();
      default: return const SizedBox();
    }
  }

  final _navItems = const [
    _Nav(Icons.dashboard_outlined, Icons.dashboard, 'Dashibodi'),
    _Nav(Icons.account_balance_outlined, Icons.account_balance, 'Wilaya'),
    _Nav(Icons.location_city_outlined, Icons.location_city, 'Tarafa'),
    _Nav(Icons.map_outlined, Icons.map, 'Kata'),
    _Nav(Icons.search_outlined, Icons.search, 'Tafuta'),
    _Nav(Icons.bar_chart_outlined, Icons.bar_chart, 'Ripoti'),
    _Nav(Icons.backup_outlined, Icons.backup, 'Hifadhi'),
  ];

  void _logout() async {
    final ok = await showConfirmDialog(context,
      title: 'Toka', message: 'Una uhakika wa kutaka kutoka?',
      confirmText: 'Toka', confirmColor: AppTheme.primaryGreen);
    if (ok == true && mounted) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        // Side nav
        Container(
          width: 76,
          color: AppTheme.darkNavy,
          child: Column(children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.account_balance,
                color: AppTheme.textDark, size: 22)),
            const SizedBox(height: 20),
            Expanded(child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (_, i) {
                final item = _navItems[i];
                final sel = _selectedIndex == i;
                return Tooltip(
                  message: item.label,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = i);
                      if (i == 2 || i == 3) _loadStats();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                          ? const Color(0xFF2A3A4A)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: sel ? const Border(left: BorderSide(
                          color: AppTheme.accentGold, width: 3)) : null),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(sel ? item.activeIcon : item.icon,
                          color: sel ? AppTheme.accentGold : Colors.white38,
                          size: 22),
                        const SizedBox(height: 3),
                        Text(item.label,
                          style: TextStyle(fontSize: 8.5,
                            color: sel ? AppTheme.accentGold : Colors.white24,
                            fontWeight: sel
                              ? FontWeight.w600 : FontWeight.normal),
                          textAlign: TextAlign.center, maxLines: 2),
                      ]),
                    ),
                  ),
                );
              },
            )),
            Tooltip(message: 'Badilisha Nywila',
              child: IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChangePasswordScreen(
                    username: widget.username))),
                icon: const Icon(Icons.settings_outlined,
                  color: Colors.white38, size: 20))),
            Tooltip(message: 'Toka',
              child: IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout,
                  color: Colors.white38, size: 20))),
            const SizedBox(height: 12),
          ]),
        ),
        // Content
        Expanded(child: Column(children: [
          // Top bar
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            child: Row(children: [
              const Icon(Icons.account_balance,
                color: AppTheme.primaryGreen, size: 18),
              const SizedBox(width: 8),
              const Text('WILAYA YA MULEBA',
                style: TextStyle(fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen, fontSize: 15,
                  letterSpacing: 0.5)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.person,
                    color: AppTheme.primaryGreen, size: 15),
                  const SizedBox(width: 5),
                  Text(widget.username,
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600, fontSize: 13)),
                ])),
            ])),
          const Divider(height: 1),
          Expanded(child: _screen()),
        ])),
      ]),
    );
  }
}

class _Nav {
  final IconData icon, activeIcon;
  final String label;
  const _Nav(this.icon, this.activeIcon, this.label);
}

class _HomeTab extends StatelessWidget {
  final Map<String, int> stats;
  final Function(int) onNavigate;
  const _HomeTab({required this.stats, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Habari za Wilaya ya Muleba',
                style: TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Mfumo wa Usimamizi wa Viongozi — Offline',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 13)),
            ])),
            const Icon(Icons.account_balance,
              color: Colors.white12, size: 56),
          ])),
        const SizedBox(height: 24),
        SectionHeader(title: 'Takwimu'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            StatCard(title: 'Tarafa', count: stats['divisions'] ?? 0,
              icon: Icons.location_city, color: AppTheme.primaryGreen,
              onTap: () => onNavigate(2)),
            StatCard(title: 'Kata', count: stats['wards'] ?? 0,
              icon: Icons.map, color: const Color(0xFF1565C0),
              onTap: () => onNavigate(3)),
            StatCard(title: 'Viongozi', count: stats['leaders'] ?? 0,
              icon: Icons.people, color: const Color(0xFF6A1B9A),
              onTap: () => onNavigate(4)),
          ]),
        const SizedBox(height: 24),
        SectionHeader(title: 'Ufikiaji wa Haraka'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 3.0,
          children: [
            _Quick(Icons.account_balance, 'Viongozi wa Wilaya',
              () => onNavigate(1)),
            _Quick(Icons.add_business, 'Ongeza Tarafa',
              () => onNavigate(2)),
            _Quick(Icons.add_location, 'Ongeza Kata',
              () => onNavigate(3)),
            _Quick(Icons.search, 'Tafuta Kiongozi',
              () => onNavigate(4)),
            _Quick(Icons.file_download, 'Hamisha Excel',
              () => onNavigate(5)),
            _Quick(Icons.backup, 'Nakala Kumbukumbu',
              () => onNavigate(6)),
          ]),
      ]),
    );
  }
}

class _Quick extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Quick(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                color: AppTheme.textDark))),
            const Icon(Icons.chevron_right,
              color: AppTheme.textMuted, size: 16),
          ])),
      ),
    );
  }
}
