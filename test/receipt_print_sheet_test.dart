import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/lab/receipt/receipt_print_mode.dart';
import 'package:journal/pages/lab/receipt/receipt_print_sheet.dart';

void main() {
  testWidgets('shows four print ranges on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ReceiptPrintMode? selected;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [_colors]),
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () async =>
                selected = await ReceiptPrintSheet.show(context),
            child: const Text('打开'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.text('分类汇总'), findsOneWidget);
    expect(find.text('完整明细'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('指定日期'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('完整明细'));
    await tester.pumpAndSettle();
    expect(selected, ReceiptPrintMode.ledgerDetailed);
  });
}

const _colors = AppThemeColors(
  backgroundColor: Colors.white,
  primaryText: Color(0xFF202124),
  secondaryText: Color(0xFF666666),
  cardBackground: Colors.white,
  chartLine: Colors.black,
  chartPalette: [Color(0xFF1677FF)],
  navActive: Colors.black,
  navInactive: Colors.grey,
  mainButtonBg: Colors.black,
  mainButtonIcon: Colors.white,
  brandColor: Color(0xFF16806A),
  onBrandColor: Colors.white,
  dangerColor: Colors.red,
  outlineBorder: Color(0xFFE5E5E5),
);
