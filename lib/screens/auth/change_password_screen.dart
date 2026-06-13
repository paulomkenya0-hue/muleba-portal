import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String username;
  const ChangePasswordScreen({super.key, required this.username});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _ob1 = true, _ob2 = true, _ob3 = true;

  @override
  void dispose() {
    _oldCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final ok = await DatabaseHelper.instance
        .changePassword(widget.username, _oldCtrl.text, _newCtrl.text);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.passwordChanged)));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nywila ya zamani si sahihi'),
          backgroundColor: AppTheme.errorRed));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _pwField(TextEditingController c, String label, bool ob,
      VoidCallback toggle, String? Function(String?) validator) {
    return TextFormField(
      controller: c,
      obscureText: ob,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(ob
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined),
          onPressed: toggle)),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badilisha Nywila')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Badilisha Nywila',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Mtumiaji: ${widget.username}',
                      style: const TextStyle(color: AppTheme.textMuted)),
                    const SizedBox(height: 24),
                    _pwField(_oldCtrl, 'Nywila ya Zamani', _ob1,
                      () => setState(() => _ob1 = !_ob1),
                      (v) => v!.isEmpty ? 'Inahitajika' : null),
                    const SizedBox(height: 14),
                    _pwField(_newCtrl, 'Nywila Mpya', _ob2,
                      () => setState(() => _ob2 = !_ob2),
                      (v) => v!.length < 6 ? 'Angalau herufi 6' : null),
                    const SizedBox(height: 14),
                    _pwField(_confirmCtrl, 'Thibitisha Nywila Mpya', _ob3,
                      () => setState(() => _ob3 = !_ob3),
                      (v) => v != _newCtrl.text ? 'Hazifanani' : null),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                      child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2,
                              color: Colors.white))
                        : const Text('Hifadhi Nywila'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
