import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<XFile?> compressAndGetFile(File file, String targetPath) async {
  CompressFormat format = CompressFormat.jpeg;
  if (targetPath.endsWith("png")) {
    format = CompressFormat.png;
  }
  return await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 30,
    format: format,
  );
}
