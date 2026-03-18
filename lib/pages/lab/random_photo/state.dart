// lib/random_photo/state.dart
import 'dart:math';
import 'package:get/get.dart';
import 'package:journal/models/photo_item.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:screenshot/screenshot.dart';

class PhotoState {
  // --- 响应式状态 (UI 会随之变化的变量) ---
  var isLoading = true.obs;
  var totalPhotos = 0.obs;
  var photoList = <PhotoItem>[].obs;
  var currentIndex = 0.obs;
  var isFavorite = false.obs;
  var locationInfo = '读取中...'.obs;
  var enableCosUpload = false.obs; // 默认不上云（保护隐私）
  var enableAiComment = true.obs; // 默认开启 AI 润色

  Set<String> viewedPhotoIds = {}; // 新增这行：记录已经看过的照片 ID
  // --- 普通变量与工具类 ---
  AssetPathEntity? allPhotosAlbum;
  final Random random = Random();

  // --- UI 相关的控制器 ---
  final CardSwiperController swiperController = CardSwiperController();
  final ScreenshotController screenshotController = ScreenshotController();
}
