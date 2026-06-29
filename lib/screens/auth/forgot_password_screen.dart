import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../utils/email_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _usernameCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  int _step = 1; // 1=username, 2=otp+newpassword
  bool _loading = false;
  bool _obscure1 = true, _obscure2 = true;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Andika jina la mtumiaji');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final exists = await DatabaseHelper.instance.userExists(_usernameCtrl.text.trim());
    if (!exists) {
      setState(() {
        _error = 'Jina la mtumiaji halipo';
        _loading = false;
      });
      return;
    }

    final otp = await DatabaseHelper.instance.generateAndSaveOtp(_usernameCtrl.text.trim());
    final sent = await EmailService.sendOtpEmail(otp, _usernameCtrl.text.trim().toUpperCase());

    if (!mounted) return;
    setState(() => _loading = false);

    if (sent) {
      setState(() => _step = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.otpSent)));
    } else {
      setState(() => _error = 'Imeshindwa kutuma barua pepe. Hakikisha mtandao upo.');
    }
  }

  Future<void> _resetPassword() async {
    if (_otpCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Andika nambari ya uthibitisho');
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      setState(() => _error = 'Nywila lazima iwe angalau herufi 6');
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Nywila hazifanani');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final valid = await DatabaseHelper.instance.verifyOtp(
      _usernameCtrl.text.trim(), _otpCtrl.text.trim());

    if (!valid) {
      if (!mounted) return;
      setState(() {
        _error = AppStrings.otpInvalid;
        _loading = false;
      });
      return;
    }

    await DatabaseHelper.instance.resetPasswordWithOtp(
      _usernameCtrl.text.trim(), _newPassCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.resetPasswordSuccess)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Nimesahau Nywila'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _step == 1 ? Icons.lock_reset : Icons.mark_email_read,
                  size: 56, color: AppTheme.primaryGreen),
                const SizedBox(height: 16),
                Text(
                  _step == 1 ? 'Rejesha Nywila' : 'Weka Nywila Mpya',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  _step == 1
                    ? 'Andika jina lako la mtumiaji. Nambari ya uthibitisho itatumwa kwa barua pepe ya msimamizi.'
                    : 'Nambari ya uthibitisho imetumwa. Weka nambari hiyo na nywila mpya.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 24),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                        style: const TextStyle(color: AppTheme.errorRed, fontSize: 13))),
                    ])),

                if (_step == 1) ...[
                  TextFormField(
                    controller: _usernameCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Jina la Mtumiaji',
                      prefixIcon: Icon(Icons.person_outline)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _sendOtp,
                    child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('TUMA NAMBARI YA UTHIBITISHO')),
                ] else ...[
                  TextFormField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nambari ya Uthibitisho (OTP)',
                      prefixIcon: Icon(Icons.pin_outlined)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _newPassCtrl,
                    obscureText: _obscure1,
                    decoration: InputDecoration(
                      labelText: 'Nywila Mpya',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure1 = !_obscure1))),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: _obscure2,
                    decoration: InputDecoration(
                      labelText: 'Thibitisha Nywila Mpya',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure2 = !_obscure2))),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _resetPassword,
                    child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('REJESHA NYWILA')),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _step = 1),
                    child: const Text('Rudi nyuma')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
