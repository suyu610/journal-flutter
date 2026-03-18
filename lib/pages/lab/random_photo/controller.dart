// lib/random_photo/controller.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/photo_item.dart';
import 'package:journal/models/user.dart';
import 'package:journal/request/request.dart';
import 'package:journal/services/kimi_service.dart';
import 'package:journal/util/cos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'model.dart';
import 'state.dart'; // 👇 引入刚建好的 State

class PhotoController extends GetxController {
  // 👇 新增：唤起系统原生相册（自带超强搜索框）
  Future<void> pickAndSearchPhoto(BuildContext context) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        maxAssets: 1, // 每次选一张，或者根据需要调整
        requestType: RequestType.image,
        themeColor: Colors.blueAccent, // 可以定制为你 App 的主题色
      ),
    );

    if (result != null && result.isNotEmpty) {
      final AssetEntity selectedEntity = result.first;

      // 预加载缩略图数据 (复用你现有的 PhotoConfig 配置或默认大小)
      final thumbData = await selectedEntity
          .thumbnailDataWithSize(const ThumbnailSize(500, 500));

      if (thumbData != null) {
        // 构建你现有的 PhotoItem
        final newPhotoItem = PhotoItem(
          entity: selectedEntity,
          thumbData: thumbData,
          albumIndex: -1, // 用 -1 标记这是一张被特意搜索出来的照片
        );

        // 核心玩法：把搜索到的照片“插队”到当前随机卡片的下一张
        final nextIndex = state.currentIndex.value + 1;
        if (nextIndex <= state.photoList.length) {
          state.photoList.insert(nextIndex, newPhotoItem);
        } else {
          state.photoList.add(newPhotoItem);
        }

        // 自动往左滑动一张，展示刚刚选中的照片
        state.swiperController.swipe(CardSwiperDirection.left);

        if (context.mounted) {
          JournalToast.show(context, '已找到并导入照片 📸');
        }
      }
    }
  }

  final PhotoState state = PhotoState();
  Fluwx fluwx = Fluwx();
  initProfile() {
    HttpRequest.request(
      Method.get,
      "/user/profile/me",
      success: (data) {
        user = User.fromJson(data as Map<String, dynamic>).obs;
        Log().d(data.toString());
        update(["profile"]);
      },
      fail: (code, msg) => Log().d(msg),
    );
  }

  @override
  void onInit() {
    super.onInit();
    initProfile();
    fluwx.registerApi(
        doOnIOS: true,
        doOnAndroid: true,
        appId: "wx30e85737940da4af",
        universalLink: "https://journal.uuorb.com/app/");
    initPhotoManager();
  }

  Future<void> initPhotoManager() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || ps.hasAccess) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isNotEmpty) {
        state.allPhotosAlbum = albums.first;
        state.totalPhotos.value = await state.allPhotosAlbum!.assetCountAsync;

        // 清空看过的黑名单
        state.viewedPhotoIds.clear();

        await _fetchRandomPhotos(count: 3);

        if (state.photoList.isNotEmpty) {
          _updateCurrentPhotoState(0);
        }
      }
    } else {
      PhotoManager.openSetting();
    }
    state.isLoading.value = false;
  }

  Future<void> _fetchRandomPhotos({int count = 1}) async {
    if (state.allPhotosAlbum == null) return;

    // 1. 每次抽取前，动态获取相册当前最真实的相片总数
    final currentTotal = await state.allPhotosAlbum!.assetCountAsync;
    state.totalPhotos.value = currentTotal; // 同步更新 UI 上的总数

    if (currentTotal == 0) return;

    int addedCount = 0;
    int maxRetries = 50; // 设置一个最大重试次数，防止用户看完所有照片后陷入死循环
    int currentRetry = 0;

    while (addedCount < count && currentRetry < maxRetries) {
      currentRetry++;

      // 2. 基于实时总数生成随机 Index
      int randomIndex = state.random.nextInt(currentTotal);

      // 3. 拿出这张照片
      List<AssetEntity> assets = await state.allPhotosAlbum!.getAssetListRange(
        start: randomIndex,
        end: randomIndex + 1,
      );

      if (assets.isEmpty) continue;
      final entity = assets.first;

      if (state.viewedPhotoIds.contains(entity.id)) {
        continue;
      }

      state.viewedPhotoIds.add(entity.id);

      final data =
          await entity.thumbnailDataWithSize(const ThumbnailSize(500, 500));
      if (data != null) {
        state.photoList.add(PhotoItem(
            entity: entity, thumbData: data, albumIndex: randomIndex));
        addedCount++;
        currentRetry = 0;
      }
    }

    if (currentRetry >= maxRetries && state.photoList.isEmpty) {
      state.viewedPhotoIds.clear();
    }
  }

  bool onSwipe(
      int previousIndex, int? targetIndex, CardSwiperDirection direction) {
    if (targetIndex != null) {
      state.currentIndex.value = targetIndex;
      _updateCurrentPhotoState(targetIndex);
      _fetchRandomPhotos(count: 1);
    }
    return true;
  }

  Future<void> _updateCurrentPhotoState(int index) async {
    if (index >= state.photoList.length) return;

    final photo = state.photoList[index].entity;
    state.isFavorite.value = photo.isFavorite;
    state.locationInfo.value = '解析位置中...';

    final latlng = await photo.latlngAsync();
    if (latlng != null && (latlng.latitude != 0.0 || latlng.longitude != 0.0)) {
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latlng.latitude, latlng.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          List<String> addressParts = [];

          // 1. 城市 (City)
          String city = place.locality ?? '';
          // ⚠️ 兼容直辖市兜底：有时候北京/上海等直辖市，locality 会为空，此时取 administrativeArea
          if (city.isEmpty &&
              place.administrativeArea != null &&
              place.administrativeArea!.endsWith('市')) {
            city = place.administrativeArea!;
          }
          if (city.isNotEmpty) addressParts.add(city);

          // 2. 区/县 (District)
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            // 防止和城市名重复（有时候定位库解析会把市和区搞混返回一样的值）
            if (addressParts.isEmpty ||
                addressParts.last != place.subLocality) {
              addressParts.add(place.subLocality!);
            }
          }

          // 3. 街道/道路 (Street)
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            addressParts.add(place.thoroughfare!);
          }

          // 👇 重点在这里：你可以选择不同的拼接方式！

          // 方案 A：文艺留白风（推荐，适合海报排版） -> "深圳市 · 南山区 · 深南大道"
          String address = addressParts.join(' · ');

          // 方案 B：紧凑风 -> "深圳市南山区深南大道"
          // String address = addressParts.join('');

          // 方案 C：国际化空格风 -> "深圳市 南山区 深南大道"
          // String address = addressParts.join(' ');

          state.locationInfo.value = address.trim().isEmpty
              ? '${latlng.longitude.toStringAsFixed(2)}, ${latlng.latitude.toStringAsFixed(2)}'
              : address.trim();
        } else {
          state.locationInfo.value = '未知位置';
        }
      } catch (e) {
        state.locationInfo.value =
            '坐标: ${latlng.longitude.toStringAsFixed(2)}, ${latlng.latitude.toStringAsFixed(2)}';
      }
    } else {
      state.locationInfo.value = '无位置信息';
    }
  }

  Rx<User> user = User(
          createTime: "",
          userId: '',
          nickname: '',
          vip: false,
          avatarUrl: 'https://cdn.uuorb.com/blog/suyu_LOGO_Full.png')
      .obs;

// 👇 优化后的 sharePhoto 方法，加入本地压缩策略与用户配置项拦截
  Future<void> sharePhoto(BuildContext context,
      {required bool withBorder}) async {
    if (state.currentIndex.value >= state.photoList.length) return;

    final photoEntity = state.photoList[state.currentIndex.value].entity;

    // 1. 获取最原始的高清文件路径（保留它，用于"分享原图"功能）
    final originalFile = await photoEntity.file;
    if (originalFile == null) {
      if (!context.mounted) return;
      JournalToast.showError(context, '获取图片失败，可能是云端图片');
      return;
    }

    // 2. 获取 1080p 级别的高清压缩图
    final Uint8List? compressedBytes = await photoEntity.thumbnailDataWithSize(
      const ThumbnailSize(1080, 1080),
    );

    if (compressedBytes == null) {
      if (!context.mounted) return;
      JournalToast.showError(context, '图片压缩失败');
      return;
    }

    // 3. 把压缩后的数据写入沙盒临时文件
    final tempDir = await getTemporaryDirectory();
    final compressedFile = File(
        '${tempDir.path}/compressed_upload_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await compressedFile.writeAsBytes(compressedBytes);

    String? url;
    Map<String, dynamic>? aiResult;

    // 👇 4. 判断是否需要上传 COS
    if (state.enableCosUpload.value) {
      if (!context.mounted) return;
      JournalToast.show(context, '正在将照片加密上云...');
      url = await TencentCosService().uploadFile(
          filePath: compressedFile.path,
          userId: user.value.userId,
          prefix: "album",
          context: context);
    }

    // 👇 5. 判断是否需要请求 AI
    if (state.enableAiComment.value) {
      if (!context.mounted) return;
      JournalToast.show(context, 'AI 正在为你撰写日记...');

      const String prompt = """你是一个感情细腻的现代散文家、摄影师和诗人。你擅长从平凡的日常画面中捕捉到诗意、孤独、温情或哲理。
请仔细观察我发给你的这张照片，为它创作一组“手帐日记”风格的文字。文字需要包含一丝“抽离感”和“感性”，不要过度直白，要有文学张力。
请务必以严谨的 JSON 格式输出，不要包含任何额外的 Markdown 标记（如 ```json），直接返回包含以下 2 个字段的 JSON 对象：
{
"aiTitle": "...",
"aiDesc": "...",
}
字段具体要求如下：
1. aiTitle (标题): 2到6个字，像是一篇微小说的名字，文艺、克制。例如：“店门口的晃影”、“昨日边缘”、“等风的间隙”。
2. aiDesc (画面描述): 15到30个字，用白描的手法客观但带有胶片感地描述画面中核心的动作或场景。例如：“金毛犬在街角红色贩卖机旁停驻数秒，等待门内的视线。”
3. 如果是合照，则多描绘美好的事情
确保JSON的合法性，所有引号需正确转义。""";
      aiResult = await KimiVisionService.analyzeImage(compressedFile, prompt);

      if (aiResult == null) {
        if (!context.mounted) return;
        JournalToast.showError(context, '文案生成失败，将使用默认排版');
      }
    } else if (withBorder) {
      // 如果不开 AI 但需要生成海报，给个 UI 提示反馈
      if (!context.mounted) return;
      JournalToast.show(context, '正在排版海报...',
          duration: const Duration(seconds: 1));
    }

    if (!withBorder) {
      // 选项 A: 分享原图
      await Share.shareXFiles([XFile(originalFile.path)], text: '分享一张好看的照片');
    } else {
      // 选项 B: 制作拍立得海报
      final Uint8List fileBytes = compressedBytes;

      final dateStr =
          '${photoEntity.createDateTime.year}.${photoEntity.createDateTime.month.toString().padLeft(2, '0')}.${photoEntity.createDateTime.day.toString().padLeft(2, '0')}';

      final locationStr = state.locationInfo.value == '解析位置中...' ||
              state.locationInfo.value == '无位置信息'
          ? '未知地点'
          : state.locationInfo.value;

      // 👇 兜底文案：贴合“记录，构筑生活秩序”的基调
      final aiTitle = aiResult?['aiTitle'] ?? '无言瞬间';
      final aiDesc = aiResult?['aiDesc'] ?? '留白，也是一种记录。';

      String originalImageUrl = url ?? '';

      final borderWidgetB = Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          elevation: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
            ),
            padding:
                const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 照片区域
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Image.memory(fileBytes, fit: BoxFit.contain),
                ),

                const SizedBox(height: 16),

                // 2. AI 生成的标题与描述
                Text(
                  aiTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  aiDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 18),
                // 细分割线
                Divider(
                    color: Colors.grey.withOpacity(0.3),
                    thickness: 0.5,
                    height: 1),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "SmileySans",
                              color: Colors.black87,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            locationStr.split(' · ').first,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              letterSpacing: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 👇 只有当开启了上传 COS，且获取到了有效 URL 时，才展示二维码区域
                    if (originalImageUrl.isNotEmpty)
                      Opacity(
                        opacity: .7,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.black12, width: 0.5),
                              ),
                              child: QrImageView(
                                data: originalImageUrl,
                                version: QrVersions.auto,
                                size: 46.0,
                                foregroundColor: Colors.black87,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "扫码看原图",
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.black45,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      try {
        if (!context.mounted) return;
        final Uint8List imageBytes =
            await state.screenshotController.captureFromWidget(
          borderWidgetB,
          delay: const Duration(milliseconds: 800),
          context: context,
        );

        final posterTempFile = File(
            '${tempDir.path}/share_poster_${DateTime.now().millisecondsSinceEpoch}.png');
        await posterTempFile.writeAsBytes(imageBytes);

        fluwx.share(WeChatShareImageModel(
            WeChatImageToShare(uint8List: imageBytes),
            scene: WeChatScene.session,
            title: "图片分享"));
      } catch (e) {
        if (!context.mounted) return;
        JournalToast.showError(context, '生成海报失败');
      }
    }
  }

  Future<void> deleteCurrentPhoto(context) async {
    if (state.currentIndex.value >= state.photoList.length) return;
    final photo = state.photoList[state.currentIndex.value].entity;

    final List<String> result =
        await PhotoManager.editor.deleteWithIds([photo.id]);

    if (result.contains(photo.id)) {
      JournalToast.show(context, '照片已删除');
      state.swiperController.swipe(CardSwiperDirection.left);
    } else {
      JournalToast.showError(context, '取消删除或删除失败');
    }
  }

  Future<void> toggleFavorite(context) async {
    if (state.currentIndex.value >= state.photoList.length) return;
    final photo = state.photoList[state.currentIndex.value].entity;

    final currentFav = state.isFavorite.value;
    state.isFavorite.value = !currentFav;

    try {
      await PhotoManager.editor.darwin
          .favoriteAsset(entity: photo, favorite: !currentFav);
      JournalToast.show(context, currentFav ? '已移出个人收藏' : '已加入个人收藏',
          duration: const Duration(seconds: 1));
    } catch (e) {
      state.isFavorite.value = currentFav;
      JournalToast.showError(context, '该功能可能仅支持 iOS，或未授予修改权限。');
    }
  }

  // 👇 新增：获取附近的照片（例如前后各 5 张）
  Future<List<PhotoItem>> getNearbyPhotos({int range = 5}) async {
    if (state.currentIndex.value >= state.photoList.length ||
        state.allPhotosAlbum == null) {
      return [];
    }

    final currentPhoto = state.photoList[state.currentIndex.value];
    final centerIndex = currentPhoto.albumIndex;

    // 计算安全的起止范围，防止越界
    int start = (centerIndex - range).clamp(0, state.totalPhotos.value);
    int end = (centerIndex + range + 1).clamp(0, state.totalPhotos.value);

    // 获取这个区间的所有照片实体
    List<AssetEntity> assets = await state.allPhotosAlbum!.getAssetListRange(
      start: start,
      end: end,
    );

    List<PhotoItem> nearbyItems = [];
    for (int i = 0; i < assets.length; i++) {
      final entity = assets[i];
      // 预加载缩略图
      final data =
          await entity.thumbnailDataWithSize(PhotoConfig.defaultThumbSize);
      if (data != null) {
        nearbyItems.add(PhotoItem(
          entity: entity,
          thumbData: data,
          albumIndex: start + i,
        ));
      }
    }
    return nearbyItems;
  }
}
