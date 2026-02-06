import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
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

  void copyInviteCode(BuildContext context) {
    // copy
    Clipboard.setData(ClipboardData(
        text: "快来和我一起用【好享记账】吧，我的邀请码是：${activity.value.activityId}"));

    JournalToast.show(context, "复制成功");
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
