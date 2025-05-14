import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/toast_util.dart';

class JoinActivityController extends GetxController {
  TextEditingController textEditController = TextEditingController();
  RxString id = "".obs;
  Rx<Activity> activity = Activity.empty().obs;
  JoinActivityController();

  _initData() {
    update(["join_activity"]);
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

  String? regInviteId(String? text) {
    if (text == null) return null;
    // 快来和我一起用【好享记账】吧，我的邀请码是：aca120b534f3b04eb8
    // 快来和我一起用【好享记账】吧，我的邀请码是：ac0f05629ba46e41a0

    var reg = RegExp(r'ac[a-zA-Z0-9]{16}');
    var match = reg.firstMatch(text);
    if (match != null) {
      var pureId = match.group(0);

      return pureId;
      // print();
    } else {
      print("No invite code found.");
      return null;
    }
  }

  void readClipboard() {
    Clipboard.getData('text/plain').then((value) {
      Log().d(value!.text!);
      // String reg = regInviteId(value.text) ?? "";
      id.value = value.text!;
      textEditController.text = value.text!;
    });
  }

  void searchActivity(context) {
    HttpRequest.request(
      Method.get,
      "/activity/search/${regInviteId(id.value)}",
      success: (data) {
        // Get.back(result: true);
        BrnToast.show("搜索到一个账本", context);
        activity.value = Activity.fromJson(data as Map<String, dynamic>);
        eventBus.fire(const NeedRefreshData(refreshActivityList: true));
        update(["join_activity"]);
      },
      fail: (code, msg) {
        if (code == 404) {
          // Get.snackbar("提示", "未找到该账本",);
          ToastUtil.showSnackBar("提示", "未找到该账本");
        } else if (code == 423) {
          ToastUtil.showSnackBar("提示", "不允许加入自己的活动");
        } else if (code == 424) {
          ToastUtil.showSnackBar("提示", "不允许重复加入活动");
        } else {
          ToastUtil.showSnackBar("提示", msg);
        }
      },
    );
  }

  void joinActivity() {
    HttpRequest.request(
      Method.post,
      "/activity/join/${regInviteId(id.value)}",
      success: (data) {
        Get.back(result: true);
      },
      fail: (code, msg) {
        if (code == 404) {
          // Get.snackbar("提示", "未找到该账本",);
          ToastUtil.showSnackBar("提示", "未找到该账本");
        } else if (code == 423) {
          ToastUtil.showSnackBar("提示", "不允许加入自己的活动");
        } else if (code == 424) {
          ToastUtil.showSnackBar("提示", "不允许重复加入活动");
        } else {
          ToastUtil.showSnackBar("提示", msg);
        }
      },
    );
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
