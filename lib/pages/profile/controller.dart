import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/user.dart';
import 'package:journal/pages/ai_config/index.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/cos.dart';
import 'package:journal/util/media_util.dart';
import 'package:journal/util/sp_util.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

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
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return TDAlertDialog(
          buttonStyle: TDDialogButtonStyle.text,
          title: "确认退出登录？",
          rightBtnAction: () {
            SpUtil.removeToken();
            Get.offAllNamed('/login');
          },
        );
      },
    );
  }

  void deleteAccount(BuildContext context) {
    // dialog
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return TDAlertDialog(
          buttonStyle: TDDialogButtonStyle.text,
          title: "确认注销账号？",
          rightBtnAction: () {
            SpUtil.removeToken();
            Get.offAllNamed('/login');
          },
        );
      },
    );
  }
}
