import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:journal/components/journal_toast.dart';

// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/core/log.dart';
import 'package:journal/core/theme_controller.dart';
import 'package:journal/models/user.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';

import 'package:journal/util/cos.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:journal/util/media_util.dart';
import 'package:journal/util/sp_util.dart';

class ProfileController extends GetxController {
  var nicknameTextEditController = TextEditingController();
  Fluwx fluwx = Fluwx();

  ProfileController();
  Rx<User> user = User(
          createTime: "",
          userId: '',
          nickname: '',
          vip: false,
          avatarUrl: 'https://cdn.uuorb.com/blog/suyu_LOGO_Full.png')
      .obs;

  _initData() {
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

  void onTap() {}

  @override
  void onReady() {
    super.onReady();
    fluwx.registerApi(
        doOnIOS: true,
        doOnAndroid: true,
        appId: "wx30e85737940da4af",
        universalLink: "https://journal.uuorb.com/app/");
    _initData();
  }

  void modifyNickname(String nickname, BuildContext context) {
    JournalToast.showLoading(context);
    HttpRequest.request(
      Method.patch,
      "/user",
      params: {
        "nickname": nickname,
      },
      success: (data) {
        JournalToast.dismiss();
        user.value.nickname = nickname;
        JournalToast.show(context, "修改成功");
        Get.back();

        update(["profile"]);
      },
    );
  }

  void changeUserAvatar(BuildContext context) async {
    // 1. 选图
    File? file = await MediaHelper.pickImageWithPermission(context);
    if (file == null) return; // 用户取消或没权限

    // 2. 上传 (自动处理 Loading UI)
    String userId = user.value.userId;
    if (context.mounted) {
      String? url = await TencentCosService().uploadFile(
          filePath: file.path,
          userId: userId,
          prefix: "avatar",
          context: context // 传入 context 自动展示 loading
          );
      if (url == null) return; // 上传失败内部已经处理了 Toast

      // 3. 更新业务数据
      if (context.mounted) {
        _updateAvatarApi(url, context);
      }
    }
  }

  void _updateAvatarApi(String url, BuildContext context) {
    HttpRequest.request(Method.patch, "/user", params: {
      "avatarUrl": url,
    }, success: (data) {
      // 更新本地状态
      user.value.avatarUrl = url;
      update(['profile']);
      // 如果需要同步更新 LayoutController
      var layoutCtrl = Get.find<LayoutController>();
      layoutCtrl.user.value.avatarUrl = url;
      layoutCtrl.update(["user"]);

      JournalToast.showSuccess(context, "更新成功");
    });
  }

  void contact() {
    fluwx.open(
        target: CustomerServiceChat(
            corpId: 'ww9d9a8a9c7211e1f8',
            url: 'https://work.weixin.qq.com/kfid/kfc001bab61abbb134c'));
  }

  void logout(context) {
    PremiumGlassDialog.show(
      context,
      title: "确认退出登录？",
      content: "确定要退出当前账号吗？退出后无法收到新消息通知。",
      onConfirm: () {
        SpUtil.removeToken();
        Get.offAllNamed('/login');
      },
    );
  }

  void deleteAccount(BuildContext context) {
    PremiumGlassDialog.show(context, title: "确认注销账号？", onConfirm: () {
      SpUtil.removeToken();
      Get.offAllNamed('/login');
    });
  }

  // ---------------------------------------------------------
  // 改造区域 1: 评分弹窗 (适配主题色)
  // ---------------------------------------------------------
  void showRatingDialog(BuildContext context) {
    // 获取主题颜色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent, // 背景透明，由 Container 接管
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: appColors.cardBackground, // 适配深色背景
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // 统一的弥散阴影
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 顶部大图标装饰
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  // 使用主色极低透明度作为背景
                  color: appColors.primaryText.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.thumb_up_alt_rounded,
                  size: 36,
                  color: Color(0xFFFFC107), // 琥珀色，深浅模式通用
                ),
              ),
              const SizedBox(height: 24),

              // 2. 标题与文案
              Text(
                "喜欢 好享记账 吗？",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryText), // 适配文字颜色
              ),
              const SizedBox(height: 12),
              Text(
                "您的支持是我们最大的动力。\n如果觉得好用，请花几秒钟给我们一个好评吧！",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: appColors.secondaryText, // 适配次要文字
                    height: 1.5),
              ),

              const SizedBox(height: 24),

              // 3. 装饰性的五星
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.star_rounded,
                              color: const Color(0xFFFFD700).withOpacity(0.8),
                              size: 28),
                        )),
              ),

              const SizedBox(height: 32),

              // 4. 按钮组
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: appColors.secondaryText, // 适配按钮文字
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: const Text("下次再说", style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _openAppStoreRating(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.mainButtonBg, // 适配主按钮背景
                        foregroundColor: appColors.mainButtonIcon, // 适配主按钮文字
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("去评分",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 200),
      transitionCurve: Curves.easeOut,
    );
  }

  void _openAppStoreRating(BuildContext context) async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.openStoreListing(
        appStoreId: '6736673372',
      );
      _saveLastRatingTime();
    } else {
      if (context.mounted) {
        JournalToast.show(context, "无法打开应用商店");
      }
    }
  }

  void _saveLastRatingTime() {
    DateTime now = DateTime.now();
    SpUtil.putString("last_rating_time", now.toIso8601String());
  }

  bool shouldShowRatingPrompt() {
    String? lastRatingTime = SpUtil.getString("last_rating_time");
    if (lastRatingTime == null) return true;

    DateTime lastTime = DateTime.parse(lastRatingTime);
    DateTime now = DateTime.now();
    Duration difference = now.difference(lastTime);

    return difference.inDays >= 90;
  }

  // ---------------------------------------------------------
  // 改造区域 2: 主题设置弹窗 (适配主题色)
  // ---------------------------------------------------------
  // ---------------------------------------------------------
  // 改造区域 2: 主题设置 (底部大卡片直选模式)
  // ---------------------------------------------------------
  void showThemeDialog(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    // 获取当前模式字符串: 'system', 'light', 'dark'
    final currentMode = SpUtil.getThemeMode();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 顶部小把手 (Handle Bar)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: appColors.secondaryText.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 2. 标题
              Text(
                "外观设置",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryText,
                ),
              ),
              const SizedBox(height: 32),

              // 3. 三个大卡片横向排列
              Row(
                children: [
                  Expanded(
                    child: _buildThemeCard(
                      context: context,
                      title: "跟随系统",
                      modeKey: "system",
                      currentKey: currentMode,
                      icon: Icons.brightness_auto_rounded,
                      appColors: appColors,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildThemeCard(
                      context: context,
                      title: "浅色",
                      modeKey: "light",
                      currentKey: currentMode,
                      icon: Icons.wb_sunny_rounded,
                      appColors: appColors,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildThemeCard(
                      context: context,
                      title: "深色",
                      modeKey: "dark",
                      currentKey: currentMode,
                      icon: Icons.dark_mode_rounded,
                      appColors: appColors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // 这里的设置让它更像原生 BottomSheet
      isScrollControlled: true,
      enterBottomSheetDuration: const Duration(milliseconds: 250),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }

  // 构建单个主题卡片
  Widget _buildThemeCard({
    required BuildContext context,
    required String title,
    required String modeKey,
    required String currentKey,
    required IconData icon,
    required AppThemeColors appColors,
  }) {
    final bool isSelected = modeKey == currentKey;

    return GestureDetector(
      onTap: () {
        // 1. 立即执行切换逻辑
        ThemeMode themeMode;
        switch (modeKey) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          default:
            themeMode = ThemeMode.system;
        }
        ThemeController.to.setThemeMode(themeMode);

        // 2. 关闭弹窗 (稍微延迟一点点，让用户看到点击反馈，体验更好)
        Future.delayed(const Duration(milliseconds: 150), () {
          if (Get.isBottomSheetOpen ?? false) {
            Get.back();
          }
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          // 选中状态：淡色背景 + 边框；未选中：透明 + 细边框
          color: isSelected
              ? appColors.primaryText.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? appColors.primaryText
                : appColors.secondaryText.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color:
                  isSelected ? appColors.primaryText : appColors.secondaryText,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? appColors.primaryText
                    : appColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
