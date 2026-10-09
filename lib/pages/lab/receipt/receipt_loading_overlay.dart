import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:journal/core/app_theme_colors.dart';

class ReceiptLoadingOverlay extends StatelessWidget {
  final bool wholeLedger;
  final ValueListenable<int> loadedCount;
  final VoidCallback onCancel;

  const ReceiptLoadingOverlay({
    super.key,
    required this.wholeLedger,
    required this.loadedCount,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return Positioned(
      top: MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
      left: 16,
      right: 16,
      child: Material(
        color: colors.cardBackground,
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: loadedCount,
                  builder: (_, count, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wholeLedger ? '正在读取账本' : '正在读取账单',
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (wholeLedger)
                        Text(
                          '已读取 $count 笔',
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: '取消读取',
                onPressed: onCancel,
                icon: Icon(Icons.close, color: colors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
