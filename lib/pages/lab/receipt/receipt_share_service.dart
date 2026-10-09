import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:journal/pages/lab/receipt/receipt_card.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

typedef ReceiptImageCapture = Future<Uint8List> Function(
    ReceiptCard receipt, BuildContext context);
typedef ReceiptImageShare = Future<void> Function(Uint8List image, Rect origin);

class ReceiptShareService {
  final ReceiptImageCapture _capture;
  final ReceiptImageShare _share;

  ReceiptShareService({ReceiptImageCapture? capture, ReceiptImageShare? share})
      : _capture = capture ?? _captureReceipt,
        _share = share ?? _shareImage;

  Future<void> shareReceipt(
    ReceiptCard receipt,
    BuildContext context,
    Rect origin,
  ) async {
    final image = await _capture(receipt, context);
    if (image.isEmpty) throw StateError('小票图片为空');
    await _share(image, origin);
  }

  static Future<Uint8List> _captureReceipt(
    ReceiptCard receipt,
    BuildContext context,
  ) {
    return ScreenshotController().captureFromLongWidget(
      receipt,
      context: context,
      constraints: BoxConstraints(maxWidth: receipt.width),
      pixelRatio: 2,
      delay: const Duration(milliseconds: 100),
    );
  }

  static Future<void> _shareImage(Uint8List image, Rect origin) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(image, mimeType: 'image/png')],
      fileNameOverrides: [
        'journal-receipt-${DateTime.now().millisecondsSinceEpoch}.png'
      ],
      sharePositionOrigin: origin,
    ));
  }
}
