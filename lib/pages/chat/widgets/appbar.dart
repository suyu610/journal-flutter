import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/sp_util.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

PreferredSizeWidget buildAppbar(context, controller) {
  return TDNavBar(
    height: 48,
    title: controller.activity.value.activityName,
    titleFontWeight: FontWeight.w600,
    centerTitle: true,
    useDefaultBack: true,
    useBorderStyle: false,
    rightBarItems: Get.find<LayoutController>().user.value.vip
        ? [
            TDNavBarItem(
                padding: const EdgeInsets.only(right: 10),
                icon: Icons.photo_library_outlined,
                iconColor: Colors.black,
                iconSize: 20,
                action: () {
                  List<String> imageList = [
                    "",
                    "assets/chat_bg/test.webp",
                    "assets/chat_bg/1.jpg",
                    "assets/chat_bg/2.jpg"
                  ];
                  var index = imageList
                      .indexOf(controller.bgImage.value); // 获取当前背景图片的索引
                  if (index == -1) {
                    index = 0;
                  }

                  var newImageUrl =
                      imageList[(index + 1) % imageList.length]; // 更新背景图片
                  controller.bgImage.value = newImageUrl;
                  SpUtil.setChatBg(newImageUrl);
                  controller.update(["chat"]);
                }),
            TDNavBarItem(
                icon: Icons.settings_outlined,
                iconColor: Colors.black,
                iconSize: 20,
                action: () {
                  // 改背景
                  Get.toNamed(Routers.CreateActivityUrl,
                      arguments: controller.activity.value);
                })
          ]
        : [
            TDNavBarItem(
                icon: Icons.settings_outlined,
                iconColor: Colors.grey[700],
                iconSize: 18,
                action: () {
                  // 改背景
                  Get.toNamed(Routers.CreateActivityUrl,
                      arguments: controller.activity.value);
                })
          ],
  );
}
