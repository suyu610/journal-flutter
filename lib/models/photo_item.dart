import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class PhotoItem {
  final AssetEntity entity;
  final Uint8List thumbData;
  final int albumIndex; // 👇 新增：记录它在整个相册中的绝对索引
  PhotoItem(
      {required this.entity,
      required this.thumbData,
      required this.albumIndex});
}
