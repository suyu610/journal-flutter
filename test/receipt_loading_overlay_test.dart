import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/lab/receipt/receipt_loading_overlay.dart';

void main() {
  testWidgets('loading progress leaves the page usable and can be cancelled',
      (tester) async {
    final loaded = ValueNotifier<int>(0);
    addTearDown(loaded.dispose);
    var pageTapped = false;
    var cancelled = false;

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [_colors]),
      home: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () => pageTapped = true,
                child: const Text('页面按钮'),
              ),
            ),
            ReceiptLoadingOverlay(
              wholeLedger: true,
              loadedCount: loaded,
              onCancel: () => cancelled = true,
            ),
          ],
        ),
      ),
    ));

    await tester.tap(find.text('页面按钮'));
    expect(pageTapped, isTrue);
    loaded.value = 24;
    await tester.pump();
    expect(find.text('已读取 24 笔'), findsOneWidget);
    await tester.tap(find.byTooltip('取消读取'));
    expect(cancelled, isTrue);
  });
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
