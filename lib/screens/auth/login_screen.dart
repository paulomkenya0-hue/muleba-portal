import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMessage = null; });
    try {
      final ok = await DatabaseHelper.instance.authenticate(
        _usernameCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => DashboardScreen(
            username: _usernameCtrl.text.trim().toUpperCase())));
      } else {
        setState(() => _errorMessage = AppStrings.invalidCredentials);
      }
    } catch (e) {
      setState(() => _errorMessage = AppStrings.errorOccurred);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    if (isWide) return _buildTabletLayout();
    return _buildPhoneLayout();
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.account_balance,
                        color: AppTheme.textDark, size: 40),
                    ),
                    const SizedBox(height: 32),
                    const Text('WILAYA YA\nMULEBA',
                      style: TextStyle(color: Colors.white, fontSize: 36,
                        fontWeight: FontWeight.w800, height: 1.2)),
                    const SizedBox(height: 16),
                    const Text('Mfumo wa Usimamizi\nwa Viongozi',
                      style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.5)),
                    const SizedBox(height: 48),
                    _infoRow(Icons.location_city, 'Wilaya ya Muleba'),
                    const SizedBox(height: 12),
                    _infoRow(Icons.wifi_off, 'Inafanya kazi bila mtandao'),
                    const SizedBox(height: 12),
                    _infoRow(Icons.security, 'Salama na ya uhakika'),
                  ],
                ),
              ),
            ),
            Container(
              width: 440,
              color: AppTheme.surfaceWhite,
              child: Center(child: _loginForm()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.account_balance,
                        color: AppTheme.textDark, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text('WILAYA YA MULEBA',
                      style: TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w800)),
                    const Text('Mfumo wa Usimamizi wa Viongozi',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(20)),
                child: _loginForm(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Karibu!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
            const SizedBox(height: 6),
            const Text('Tafadhali ingia ili kuendelea',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorRed.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!,
                    style: const TextStyle(color: AppTheme.errorRed, fontSize: 13))),
                ]),
              ),
            TextFormField(
              controller: _usernameCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Jina la Mtumiaji',
                prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => Validators.validateRequired(v, 'Jina la mtumiaji'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Nywila',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                  onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) => Validators.validateRequired(v, 'Nywila'),
              onFieldSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                  ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2,
                        color: Colors.white))
                  : const Text('INGIA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, color: AppTheme.accentGold, size: 18),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    ]);
  }
}
