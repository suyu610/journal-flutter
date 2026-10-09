import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/lab/medical_card/view.dart';
import 'package:journal/pages/lab/receipt/receipt_card.dart';
import 'package:journal/pages/lab/receipt/receipt_share_service.dart';

void main() {
  testWidgets('long paper scrolls while the printer stays fixed',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final entries = List.generate(
      40,
      (index) => Expense(
        expenseId: '$index',
        type: '日常',
        price: 10,
        label: '账单 $index',
        userId: 'user',
        expenseTime: '2026-10-08 12:00:00',
        createTime: '2026-10-08 12:00:00',
        activityId: 'ledger',
        positive: 0,
      ),
    );
    ReceiptCard? capturedReceipt;
    Uint8List? sharedImage;
    Rect? shareOrigin;
    final shareService = ReceiptShareService(
      capture: (receipt, _) async {
        capturedReceipt = receipt;
        return Uint8List.fromList([1, 2, 3]);
      },
      share: (image, origin) async {
        sharedImage = image;
        shareOrigin = origin;
      },
    );

    await tester.pumpWidget(MaterialApp(
      home: MedicalPrinterCard(
        shareService: shareService,
        data: ReceiptData(
          nickname: 'USER',
          budget: 0,
          items: entries,
          date: '2026-10-08',
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pump();
    await tester.pumpAndSettle();

    final printer = find.byKey(const Key('receipt-printer'));
    final paper = find.byKey(const Key('receipt-paper'));
    final fold = find.byKey(const Key('receipt-paper-fold'));
    final scroll = find.byKey(const Key('receipt-paper-scroll'));
    final printerTop = tester.getTopLeft(printer);
    final paperTop = tester.getTopLeft(paper);
    final flatFold = tester.widget<CustomPaint>(fold).painter!;

    final gesture = await tester.startGesture(tester.getCenter(scroll));
    await gesture.moveBy(const Offset(0, -60));
    await gesture.moveBy(const Offset(0, -200));
    await tester.pump();
    final bentFold = tester.widget<CustomPaint>(fold).painter!;
    expect(bentFold.shouldRepaint(flatFold), isTrue);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(printer), printerTop);
    expect(tester.getTopLeft(paper).dy, lessThan(paperTop.dy));
    expect(tester.widget<CustomPaint>(fold).painter!.shouldRepaint(bentFold),
        isTrue);
    await tester.tap(find.byTooltip('分享小票'));
    await tester.pump();
    expect(capturedReceipt?.items, hasLength(40));
    expect(capturedReceipt?.width, 264);
    expect(sharedImage, [1, 2, 3]);
    expect(shareOrigin!.width, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
