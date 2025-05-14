import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:journal/models/activity.dart';

class InviteController extends GetxController {
  InviteController();
  Rx<Activity> activity = Activity.empty().obs;
  _initData() {
    activity.value = Get.arguments;
    update(["invite"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void copyInviteCode() {
    // copy
    Clipboard.setData(ClipboardData(
        text: "快来和我一起用【好享记账】吧，我的邀请码是：${activity.value.activityId}"));
    // show snackbar
    Get.snackbar("复制成功", "邀请码已复制到剪贴板",
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
