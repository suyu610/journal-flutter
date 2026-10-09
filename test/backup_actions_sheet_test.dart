import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/profile/backup_actions_sheet.dart';

void main() {
  for (final option in <(String, BackupAction)>[
    ('导出 JSON 备份', BackupAction.export),
    ('从 JSON 恢复', BackupAction.restore),
  ]) {
    testWidgets('backup sheet returns ${option.$2.name}', (tester) async {
      BackupAction? selected;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: const [_colors]),
        home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              onPressed: () async =>
                  selected = await BackupActionsSheet.show(context),
              child: const Text('打开'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(find.text('备份与恢复'), findsOneWidget);
      expect(find.text('导出 JSON 备份'), findsOneWidget);
      expect(find.text('从 JSON 恢复'), findsOneWidget);

      await tester.tap(find.text(option.$1));
      await tester.pumpAndSettle();
      expect(selected, option.$2);
    });
  }
}

const _colors = AppThemeColors(
  backgroundColor: Colors.white,
  primaryText: Colors.black,
  secondaryText: Colors.grey,
  cardBackground: Colors.white,
  chartLine: Colors.black,
  chartPalette: [],
  navActive: Colors.black,
  navInactive: Colors.grey,
  mainButtonBg: Colors.black,
  mainButtonIcon: Colors.white,
  brandColor: Colors.black,
  onBrandColor: Colors.white,
  dangerColor: Colors.red,
  outlineBorder: Colors.grey,
);
