import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/routers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class ProfilePage extends GetView<ProfileController> {
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      id: "profile",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          appBar: _navibar(context),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _navibar(BuildContext context) {
    return const TDNavBar(
      useBorderStyle: true,
      height: 48,
      useDefaultBack: false,
      titleWidget: TDImage(
        assetUrl: 'assets/images/logo_navi_bar.png',
        width: 70,
        height: 24,
      ),
    );
  }

  static Future<String> appVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // 主视图
  Widget _buildView(context) {
    return Column(
      children: [
        _buildUserCard(context),
        const SizedBox(height: 16),
        TDCellGroup(theme: TDCellGroupTheme.cardTheme, cells: [
          TDCell(
            leftIconWidget: const Icon(
              Icons.supervisor_account_outlined,
              size: 18,
            ),
            arrow: true,
            title: "选择角色",
            onClick: (v) {
              Get.toNamed(Routers.AIConfigPageV2Url);
            },
          ),
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.notifications_outlined,
              size: 18,
            ),
            title: "记账提醒",
            onClick: (v) {
              Get.toNamed(Routers.ReminderSettingsPageUrl);
            },
          ),
        ]),
        const SizedBox(height: 10),
        TDCellGroup(theme: TDCellGroupTheme.cardTheme, cells: [
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.question_answer_outlined,
              size: 18,
            ),
            title: "联系我们",
            onClick: (v) {
              controller.contact();
            },
          ),
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.wysiwyg_outlined,
              size: 18,
            ),
            title: "隐私协议",
            onClick: (v) {
              Get.toNamed(Routers.WebViewPageUrl, arguments: {
                "url": "https://blog.uuorb.com/archives/journal-privacy",
                "title": "隐私协议"
              });
            },
          ),
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.checkroom_outlined,
              size: 18,
            ),
            title: "实验室",
            onClick: (v) {
              Get.toNamed(Routers.LabPageUrl, arguments: {});
            },
          ),
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.exit_to_app_outlined,
              size: 18,
            ),
            title: "退出登录",
            onClick: (v) {
              controller.logout(context);
            },
          ),
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.delete_outlined,
              size: 18,
            ),
            title: "注销账号",
            onClick: (v) {
              controller.deleteAccount(context);
            },
          ),
        ]),
        SizedBox(height: 30.h),
        FutureBuilder(
          future: appVersion(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Text(
              "v${snapshot.data ?? ""}",
              style: TextStyle(color: Colors.grey[500]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserCard(context) {
    var user = controller.user.value;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              controller.changeUserAvatar(context);
            },
            child: Stack(
              children: [
                ClipOval(
                  child: Image.network(
                    user.avatarUrl,
                    height: 55.r,
                    width: 55.r,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(88)),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 12,
                        ))),
              ],
            ),
          ),
          const SizedBox(
            width: 18,
          ),
          GestureDetector(
            onTap: () {
              controller.nicknameTextEditController.text = user.nickname;
              showGeneralDialog(
                  context: context,
                  pageBuilder: (BuildContext buildContext,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return TDInputDialog(
                      title: "修改昵称",
                      textEditingController:
                          controller.nicknameTextEditController,
                      rightBtn: TDDialogButtonOptions(
                          action: () {
                            if (controller
                                .nicknameTextEditController.text.isEmpty) {
                              Get.back();
                            } else {
                              controller.modifyNickname(
                                  controller.nicknameTextEditController.text,
                                  context);
                            }
                          },
                          type: TDButtonType.fill,
                          title: '确认',
                          theme: TDButtonTheme.primary),
                    );
                  });
              return;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      user.nickname,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    const Icon(
                      Icons.edit_outlined,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                            ClipboardData(text: user.userId.toString()))
                        .then((v) {
                      TDToast.showSuccess("复制成功",
                          context: context,
                          duration: const Duration(milliseconds: 500));
                    });
                  },
                  child: Row(
                    children: [
                      const Text(
                        "ID: ",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      Text(
                        user.userId,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      const Icon(
                        Icons.copy,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
