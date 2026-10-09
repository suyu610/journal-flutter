import 'package:flutter/material.dart';
import 'package:journal/core/app_theme_colors.dart';

enum BackupAction { export, restore }

class BackupActionsSheet extends StatelessWidget {
  const BackupActionsSheet({super.key});

  static Future<BackupAction?> show(BuildContext context) {
    return showModalBottomSheet<BackupAction>(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => const BackupActionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '备份与恢复',
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ActionTile(
                icon: Icons.file_upload_outlined,
                label: '导出 JSON 备份',
                onTap: () => Navigator.of(context).pop(BackupAction.export),
              ),
              Divider(height: 1, color: colors.outlineBorder),
              _ActionTile(
                icon: Icons.restore_page_outlined,
                label: '从 JSON 恢复',
                onTap: () => Navigator.of(context).pop(BackupAction.restore),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primaryText),
      title: Text(label, style: TextStyle(color: colors.primaryText)),
      trailing: Icon(Icons.chevron_right, color: colors.secondaryText),
      onTap: onTap,
    );
  }
}
