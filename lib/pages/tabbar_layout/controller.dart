import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/user.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/cos.dart';

class LayoutController extends GetxController {
  late PageController pageController;

  RxMap systemConfig = {}.obs;

  RxInt currentIndex = 0.obs;
  Rx<User> user = User(
          createTime: "",
          userId: '',
          nickname: '',
          vip: false,
          avatarUrl: 'https://cdn.uuorb.com/blog/suyu_LOGO_Full.png')
      .obs;
  void jumpToPage(int index) {
    pageController.jumpToPage(index);
    currentIndex.value = index;
  }
  @override
 void dispose() {
    super.dispose();
    pageController.dispose();
  }
  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0, keepPage: true);
    initTencentCos();

    // 获取用户profile
    HttpRequest.request(
      Method.get,
      "/user/profile/me",
      success: (data) {
        user.value = User.fromJson(data as Map<String, dynamic>);
        Log().d(data.toString());
        update();
      },
      fail: (code, msg) => Log().d(msg),
    );

// 获取系统设置
    HttpRequest.request(
      Method.get,
      "/system/config/all",
      success: (data) {
        for (var item in data as List<dynamic>) {
          systemConfig[item['key']] = item['value'];
          Log().d(item['key']);
          Log().d(item['value']);
        }
      },
      fail: (code, msg) => Log().d(msg),
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
    Log().d("layout onClose");
  }
}
