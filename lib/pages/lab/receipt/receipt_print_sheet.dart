import 'package:flutter/material.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/lab/receipt/receipt_print_mode.dart';

class ReceiptPrintSheet extends StatelessWidget {
  const ReceiptPrintSheet({super.key});

  static Future<ReceiptPrintMode?> show(BuildContext context) {
    return showModalBottomSheet<ReceiptPrintMode>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => const ReceiptPrintSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final ledgerAccent = colors.chartPalette.first;
    final dayAccent = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFDDA279)
        : const Color(0xFF9C5B39);

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .85),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ledgerAccent.withOpacity(.11),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.print_outlined, color: ledgerAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '打印小票',
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '关闭',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: colors.secondaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _SectionLabel(title: '整个账本', color: ledgerAccent),
                const SizedBox(height: 5),
                _PrintModeTile(
                  icon: Icons.category_outlined,
                  title: '分类汇总',
                  subtitle: '同一分类合并为一行',
                  accent: ledgerAccent,
                  mode: ReceiptPrintMode.ledgerByCategory,
                ),
                _PrintModeTile(
                  icon: Icons.receipt_long_outlined,
                  title: '完整明细',
                  subtitle: '逐条打印全部账单',
                  accent: ledgerAccent,
                  mode: ReceiptPrintMode.ledgerDetailed,
                  showDivider: false,
                ),
                const SizedBox(height: 21),
                _SectionLabel(title: '单日账单', color: dayAccent),
                const SizedBox(height: 5),
                _PrintModeTile(
                  icon: Icons.today_outlined,
                  title: '今天',
                  subtitle: '打印本日账单',
                  accent: dayAccent,
                  mode: ReceiptPrintMode.today,
                ),
                _PrintModeTile(
                  icon: Icons.calendar_month_outlined,
                  title: '指定日期',
                  subtitle: '选择任意一天打印',
                  accent: dayAccent,
                  mode: ReceiptPrintMode.selectedDate,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionLabel({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).extension<AppThemeColors>()!.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PrintModeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final ReceiptPrintMode mode;
  final bool showDivider;

  const _PrintModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.mode,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            border: showDivider
                ? Border(bottom: BorderSide(color: colors.outlineBorder))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: colors.secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 20, color: colors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
