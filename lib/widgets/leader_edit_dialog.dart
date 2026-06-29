import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';

class LeaderEditDialog extends StatefulWidget {
  final Leader leader;
  final VoidCallback onSaved;
  const LeaderEditDialog({super.key, required this.leader, required this.onSaved});

  @override
  State<LeaderEditDialog> createState() => _LeaderEditDialogState();
}

class _LeaderEditDialogState extends State<LeaderEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.leader.fullName);
    _phoneCtrl = TextEditingController(text: widget.leader.phoneNumber);
    _emailCtrl = TextEditingController(text: widget.leader.emailAddress);
    _photoPath = widget.leader.photoPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery, maxWidth: 600, maxHeight: 600,
      imageQuality: 80);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updated = widget.leader.copyWith(
        fullName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        emailAddress: _emailCtrl.text.trim(),
        photoPath: _photoPath);
      await DatabaseHelper.instance.upsertLeader(updated);
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
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen,
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.edit,
                        color: AppTheme.primaryGreen, size: 18)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hariri Kiongozi',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(widget.leader.positionName,
                          style: const TextStyle(color: AppTheme.primaryGreen,
                            fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    )),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                  ]),
                  const Divider(height: 24),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppTheme.lightGreen,
                        backgroundImage: _photoPath != null &&
                          File(_photoPath!).existsSync()
                          ? FileImage(File(_photoPath!)) : null,
                        child: _photoPath == null || !File(_photoPath!).existsSync()
                          ? const Icon(Icons.person,
                              color: AppTheme.primaryGreen, size: 36)
                          : null),
                      Positioned(bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 13))),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  const Text('Gonga kubadilisha picha',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Jina Kamili *',
                      prefixIcon: Icon(Icons.person_outline)),
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.validateName),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nambari ya Simu',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '0712345678'),
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone),
                  const SizedBox(height: 14),
                  TextFormField(
                    TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Kituo cha Kazi',
                      prefixIcon: Icon(Icons.business_center_outlined),
                      hintText: 'Mfano: Ofisi ya Tarafa'),
                    validator: Validators.validateWorkStation),
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
                        : const Text('Hifadhi'))),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
