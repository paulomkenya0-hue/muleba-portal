import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../utils/validators.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({super.key, required this.title, required this.count,
    required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 22)),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, size: 12,
                    color: Colors.grey.shade400),
              ]),
              const SizedBox(height: 14),
              Text(count.toString(),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                  color: color, height: 1)),
              const SizedBox(height: 4),
              Text(title,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen, letterSpacing: 1.2))),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class LeaderTile extends StatelessWidget {
  final Leader leader;
  final VoidCallback onEdit;

  const LeaderTile({super.key, required this.leader, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final hasData = !leader.isEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: _avatar(),
        title: Text(leader.positionName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12,
            color: AppTheme.primaryGreen)),
        subtitle: hasData
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 2),
              Text(leader.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                  color: AppTheme.textDark)),
              if (leader.phoneNumber.isNotEmpty)
                Row(children: [
                  const Icon(Icons.phone, size: 11, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(leader.phoneNumber,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ]),
              if (leader.emailAddress.isNotEmpty)
                Row(children: [
                  const Icon(Icons.email, size: 11, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Expanded(child: Text(leader.emailAddress,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    overflow: TextOverflow.ellipsis)),
                ]),
            ])
          : const Text('Nafasi Wazi',
              style: TextStyle(color: AppTheme.textMuted,
                fontStyle: FontStyle.italic, fontSize: 12)),
        trailing: IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _avatar() {
    if (leader.photoPath != null && File(leader.photoPath!).existsSync()) {
      return CircleAvatar(radius: 22,
        backgroundImage: FileImage(File(leader.photoPath!)));
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppTheme.lightGreen,
      child: Text(
        leader.isEmpty ? '?' :
          leader.fullName.isNotEmpty ? leader.fullName[0].toUpperCase() : '?',
        style: const TextStyle(color: AppTheme.primaryGreen,
          fontWeight: FontWeight.w700, fontSize: 15)));
  }
}

Future<bool?> showConfirmDialog(BuildContext context,
    {required String title, required String message,
     String confirmText = 'Futa',
     Color confirmColor = AppTheme.errorRed}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
        style: const TextStyle(fontWeight: FontWeight.w700)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(AppStrings.cancel)),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          child: Text(confirmText)),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.message,
    this.icon = Icons.inbox_outlined, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final String message;
  const LoadingOverlay({super.key, this.message = 'Tafadhali subiri...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppTheme.primaryGreen),
                const SizedBox(height: 14),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
