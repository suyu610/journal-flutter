import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/user.dart';
import 'package:journal/pages/ai_config/index.dart';
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
    BrnLoadingDialog.show(context);
    HttpRequest.request(
      Method.patch,
      "/user",
      params: {
        "nickname": nickname,
      },
      success: (data) {
        BrnLoadingDialog.dismiss(context);
        user.value.nickname = nickname;
        BrnToast.show("修改成功", context);
        Get.back();

        update(["profile"]);
      },
    );
  }

  void generateAiAvatar(context) {
    BrnLoadingDialog.show(context,
        content: "大约需要25秒", barrierDismissible: false);
    Random random = Random();
    String model = random.nextInt(2) == 0 ? "二次元" : "人像";
    HttpRequest.request(
      Method.get,
      "/ai/image?model=$model&description=${user.value.personality}&role=${user.value.relationship}",
      success: (data) {
        user.value.aiAvatarUrl = data as String;
        HttpRequest.request(
          Method.patch,
          "/user",
          params: {
            "aiAvatarUrl": user.value.aiAvatarUrl,
          },
          success: (data) {},
        );

        BrnLoadingDialog.dismiss(context);

        AiConfigController aiConfigController = Get.find<AiConfigController>();
        Get.find<LayoutController>().user.value.aiAvatarUrl =
            user.value.aiAvatarUrl;
        aiConfigController.update(["ai_config"]);
      },
      fail: (code, msg) =>
          {BrnLoadingDialog.dismiss(context), BrnToast.show("生成失败", context)},
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

      BrnToast.showInCenter(text: "更新成功", context: context);
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

  void showRatingDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent, // 背景透明，由 Container 接管
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
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
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7E6), // 淡金色背景
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.thumb_up_alt_rounded, // 或者 use Icons.star_rounded
                  size: 36,
                  color: Color(0xFFFFC107), // 琥珀色
                ),
              ),
              const SizedBox(height: 24),

              // 2. 标题与文案
              const Text(
                "喜欢 好享记账 吗？",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text(
                "您的支持是我们最大的动力。\n如果觉得好用，请花几秒钟给我们一个好评吧！",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
              ),

              const SizedBox(height: 24),

              // 3. 装饰性的五星 (心理暗示)
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
                        foregroundColor: Colors.grey,
                        splashFactory: NoSplash.splashFactory, // 去掉水波纹显得更克制
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
                        backgroundColor: Colors.black87, // 高级黑
                        foregroundColor: Colors.white,
                        elevation: 0, // 扁平化
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
      barrierDismissible: true, // 点击背景可关闭
      transitionDuration: const Duration(milliseconds: 200), // 动画时长
      transitionCurve: Curves.easeOut, // 动画曲线
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
        BrnToast.show("无法打开应用商店", context);
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
}
