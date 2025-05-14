import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/user.dart';
import 'package:journal/pages/ai_config/index.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/cos.dart';
import 'package:journal/util/photo.dart';
import 'package:journal/util/sp_util.dart';
import 'package:journal/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

class ProfileController extends GetxController {
  var nicknameTextEditController = TextEditingController();

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

  Future<bool> getPhotosPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        return await Permission.storage
            .request()
            .then((e) => e == PermissionStatus.granted);
      } else {
        return await Permission.photos
            .request()
            .then((e) => e == PermissionStatus.granted);
      }
    }

    if (Platform.isIOS) {
      return await Permission.photos
          .request()
          .then((e) => e == PermissionStatus.granted);
    }
    return false;
  }

  void showImagePicker(context) async {
    final photoPermissionGranted = await getPhotosPermission();

    if (!photoPermissionGranted) {
      showGeneralDialog(
          context: Get.context!,
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return TDAlertDialog(
              buttonStyle: TDDialogButtonStyle.text,
              title: "希望读取你的相册，用于上传图片",
              rightBtnAction: () async {
                openAppSettings();
              },
            );
          });
      return;
    }

    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    String userId = Get.find<LayoutController>().user.value.userId;
    if (result != null) {
      var fileUrl = result.path;
      var fileName = fileUrl.split('/').last;
      var filePath = fileUrl.substring(0, fileUrl.length - fileName.length);
      var file = File(fileUrl);
      var targetPath = '${filePath}compress_$fileName';
      Log().d("fileUrl:$fileUrl");

      await compressAndGetFile(file, targetPath);
      await File(targetPath).readAsBytes();
      await FetchCredentials().upload(
        targetPath,
        userId,
        "avatar",
        context,
        (Map<String?, String?>? header, CosXmlResult? cosResult) {
          if (cosResult != null) {
            Future.delayed(const Duration(seconds: 1), () {
              ToastUtil.hideLoading();
            });
            var imageUrl = cosResult.accessUrl == null
                ? ""
                : cosResult.accessUrl!.replaceAll(
                    "https://uuorb-1254798469.cos.ap-beijing.myqcloud.com",
                    "https://cdn.uuorb.com");
            Log().d("图片上传地址：$imageUrl");

            HttpRequest.request(Method.patch, "/user", params: {
              "avatarUrl": imageUrl,
            }, success: (data) {
              update(['profile']);
              user.value.avatarUrl = imageUrl;
              Get.find<LayoutController>().user.value.avatarUrl = imageUrl;
              Get.find<LayoutController>().update(["user"]);
            });
          } else {
            Log().d("upload:${cosResult.toString()}");
            ToastUtil.hideLoading();
          }
        },
      );
    }
  }

  Fluwx fluwx = Fluwx();

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
