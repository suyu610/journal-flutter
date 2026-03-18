// lib/random_photo/view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/image_preview_page.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'controller.dart';

class RandomPhotoPage extends StatelessWidget {
  RandomPhotoPage({Key? key}) : super(key: key);

  final PhotoController controller = Get.put(PhotoController());

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

// 在 view.dart 的 _showShareOptions 方法内修改：

  void _showShareOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding:
            const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '分享与生成',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 👇 新增：配置项区域
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Obx(() => SwitchListTile(
                          title: const Text('上传原图生成二维码',
                              style: TextStyle(fontSize: 14)),
                          subtitle: const Text('开启后他人扫码可看高清原图',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          value: controller.state.enableCosUpload.value,
                          activeColor: Colors.blueAccent,
                          onChanged: (val) =>
                              controller.state.enableCosUpload.value = val,
                        )),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    Obx(() => SwitchListTile(
                          title: const Text('AI 撰写手帐文案',
                              style: TextStyle(fontSize: 14)),
                          subtitle: const Text('让 AI 为这张照片写一段散文',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          value: controller.state.enableAiComment.value,
                          activeColor: Colors.orangeAccent,
                          onChanged: (val) =>
                              controller.state.enableAiComment.value = val,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 原有的分享原图卡片
              _buildShareCard(
                context,
                title: '分享原图',
                subtitle: '保持原本的画面比例与画质',
                icon: Icons.image_outlined,
                color: Colors.blueAccent,
                onTap: () {
                  Get.back();
                  controller.sharePhoto(context, withBorder: false);
                },
              ),

              const SizedBox(height: 16),

              // 原有的海报卡片
              _buildShareCard(
                context,
                title: '制作拍立得海报',
                subtitle: '包含拍摄日期与地点信息的精美边框',
                icon: Icons.auto_awesome_outlined,
                color: Colors.orangeAccent,
                onTap: () {
                  Get.back();
                  controller.sharePhoto(context, withBorder: true);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // 👇 新增的 UI 辅助方法，专门用来画好看的卡片
  Widget _buildShareCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          // 背景用主题色的 10% 透明度，非常高级
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(16),
          // 加一圈极细的边框增加立体感
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            // 左侧图标：用一个白底/黑底的圆圈包起来
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: isDark ? Colors.black26 : Colors.white,
            //     boxShadow: [
            //       if (!isDark)
            //         BoxShadow(
            //           color: color.withOpacity(0.1),
            //           blurRadius: 8,
            //           offset: const Offset(0, 2),
            //         )
            //     ],
            //   ),
            //   child: Icon(icon, color: color, size: 26),
            // ),
            // const SizedBox(width: 16),

            // 中间文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // 右侧小箭头
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      appBar: JournalNavBar(
        title: '随机照片',
        rightBarItems: [
          NavBarItem(
            iconWidget: IconButton(
              icon: Icon(Icons.search_rounded, color: appColors.primaryText),
              onPressed: () => controller.pickAndSearchPhoto(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.state.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.state.photoList.isEmpty) {
            return const Center(child: Text('相册中没有照片啦！'));
          }

          return CardSwiper(
            controller: controller.state.swiperController,
            cardsCount: controller.state.photoList.length,
            onSwipe: controller.onSwipe,
            numberOfCardsDisplayed: 3,
            backCardOffset: const Offset(0, 30),
            padding: const EdgeInsets.all(16.0),
            cardBuilder:
                (context, index, percentThresholdX, percentThresholdY) {
              // 👇 直接拿到包含 entity 和预加载数据的 photoItem
              final photoItem = controller.state.photoList[index];
              final photoEntity = photoItem.entity;

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. 底图 & 点击预览 (直接使用内存中预加载的图片数据！)
                    GestureDetector(
                      onTap: () async {
                        final file = await photoEntity.file;
                        if (file != null && context.mounted) {
                          Get.to(
                            () => ImagePreviewPage(
                                urls: [file.path], initialIndex: 0),
                            opaque: false,
                            transition: Transition.fadeIn,
                          );
                        } else if (context.mounted) {
                          JournalToast.show(context, '获取图片文件失败，可能是云端图片。');
                        }
                      },
                      // 零延迟，完美渲染
                      child:
                          Image.memory(photoItem.thumbData, fit: BoxFit.cover),
                    ),

                    // 2. 信息面板
                    if (index == controller.state.currentIndex.value)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '拍摄时间: ${_formatDate(photoEntity.createDateTime)}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11),
                              ),
                              Text(
                                '分辨率: ${photoEntity.width} x ${photoEntity.height}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11),
                              ),
                              Obx(() => Text(
                                    '经纬度: ${controller.state.locationInfo.value}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 11),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    if (index == controller.state.currentIndex.value)
                      Positioned(
                        bottom: 64, // 放在收藏按钮上方
                        right: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.history,
                                size: 22, color: Colors.white),
                            onPressed: () => _showNearbyPhotos(context),
                          ),
                        ),
                      ),
                    // 3. 收藏按钮
                    if (index == controller.state.currentIndex.value)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Obx(() {
                          final isFav = controller.state.isFavorite.value;
                          return CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 22,
                                color: isFav ? Colors.redAccent : Colors.white,
                              ),
                              onPressed: () =>
                                  controller.toggleFavorite(context),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              );
            },
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => controller.deleteCurrentPhoto(context),
                label: const Text('删除'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent, // 字体和图标颜色
                  backgroundColor:
                      Colors.redAccent.withOpacity(0.1), // 10% 透明度的淡红底色
                  elevation: 0, // 去除沉重的阴影
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 圆润的边角
                  ),
                ),
              ),
              // 2. 新增的分享按钮
              ElevatedButton.icon(
                onPressed: () => _showShareOptions(context),
                label:
                    Text('分享', style: TextStyle(color: appColors.primaryText)),
                style: ElevatedButton.styleFrom(
                  shadowColor: appColors.cardBackground.withOpacity(0.4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.state.swiperController
                    .swipe(CardSwiperDirection.right),
                label:
                    Text('下一张', style: TextStyle(color: appColors.primaryText)),
                style: ElevatedButton.styleFrom(
                  shadowColor: appColors.cardBackground.withOpacity(0.4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 👇 新增：呼出附近照片的“记忆胶卷”
  void _showNearbyPhotos(BuildContext context) async {
    JournalToast.show(context, '正在翻找那天的记忆...',
        duration: const Duration(seconds: 1));

    final nearbyPhotos = await controller.getNearbyPhotos(range: 5);

    if (nearbyPhotos.isEmpty) {
      if (context.mounted) JournalToast.showError(context, '未找到相关照片');
      return;
    }
    if (!context.mounted) return;
    Get.bottomSheet(
      Container(
        height: 260,
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '那天前后的记忆',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // 水平滑动的照片列表
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: nearbyPhotos.length,
                itemBuilder: (context, index) {
                  final item = nearbyPhotos[index];
                  // 判断是否是当前正在看的那张（C位）
                  final isCurrent = item.albumIndex ==
                      controller
                          .state
                          .photoList[controller.state.currentIndex.value]
                          .albumIndex;

                  return GestureDetector(
                    onTap: () async {
                      final file = await item.entity.file;
                      if (file != null && context.mounted) {
                        // 点击直接全屏预览该图
                        Get.to(
                          () => ImagePreviewPage(
                              urls: [file.path], initialIndex: 0),
                          opaque: false,
                          transition: Transition.fadeIn,
                        );
                      }
                    },
                    child: Container(
                      width: 120, // 固定缩略图宽度
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrent
                            ? Border.all(
                                color: Colors.blueAccent,
                                width: 2) // 当前图片给个高亮边框
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(isCurrent ? 10 : 12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(item.thumbData, fit: BoxFit.cover),
                            if (isCurrent)
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                  child: Text('当前',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
