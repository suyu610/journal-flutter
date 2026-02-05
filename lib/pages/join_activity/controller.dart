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
  // 增加一个辅助状态，用于控制按钮文案
  Rx<Activity> activity = Activity.empty().obs;

  JoinActivityController();

  _initData() {
    update(["join_activity"]);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  // 处理输入框变化
  void onInputChanged(String val) {
    id.value = val;
    // 关键点：一旦用户修改了文字，之前的搜索结果就失效了，必须重置
    // 否则会导致“显示的卡片”和“实际加入的ID”不一致的严重Bug
    if (activity.value.activityId.isNotEmpty) {
      activity.value = Activity.empty();
    }
  }

  // 核心逻辑：智能按钮点击事件
  void onMainButtonTap(BuildContext context) {
    if (id.value.isEmpty) {
      ToastUtil.showSnackBar("提示", "请输入邀请码");
      return;
    }

    if (activity.value.activityId.isEmpty) {
      // 状态1：还没数据 -> 执行搜索
      searchActivity(context);
    } else {
      // 状态2：已有数据 -> 执行加入
      joinActivity();
    }
  }

  String? regInviteId(String? text) {
    if (text == null) return null;
    var reg = RegExp(r'ac[a-zA-Z0-9]{16}');
    var match = reg.firstMatch(text);
    if (match != null) {
      return match.group(0);
    } else {
      // print("No invite code found.");
      return null;
    }
  }

  void readClipboard(BuildContext context) {
    Clipboard.getData('text/plain').then((value) {
      if (value == null || value.text == null) {
        ToastUtil.showSnackBar("提示", "剪贴板为空");
        return;
      }
      Log().d(value.text!);
      id.value = value.text!;
      textEditController.text = value.text!;

      // 粘贴后自动重置状态并搜索，体验更丝滑
      activity.value = Activity.empty();
      if (context.mounted) {
        searchActivity(context);
      }
    });
  }

  void searchActivity(context) {
    String? inviteId = regInviteId(id.value);
    if (inviteId == null) {
      ToastUtil.showSnackBar("提示", "无效的邀请码格式");
      return;
    }

    HttpRequest.request(
      Method.get,
      "/activity/search/$inviteId",
      success: (data) {
        // 搜索成功，展示卡片，不弹Toast了，直接显示结果更直观
        activity.value = Activity.fromJson(data as Map<String, dynamic>);
        // 键盘收起，方便用户看卡片
        FocusScope.of(context).unfocus();
        update(["join_activity"]);
      },
      fail: (code, msg) {
        _handleError(code, msg);
      },
    );
  }

  void joinActivity() {
    HttpRequest.request(
      Method.post,
      "/activity/join/${regInviteId(id.value)}",
      success: (data) {
        eventBus.fire(const NeedRefreshData(refreshActivityList: true));
        BrnToast.show("加入成功", Get.context!);
        Get.back(result: true);
      },
      fail: (code, msg) {
        _handleError(code, msg);
      },
    );
  }

  void _handleError(int? code, String msg) {
    if (code == 404) {
      ToastUtil.showSnackBar("提示", "未找到该账本");
    } else if (code == 423) {
      ToastUtil.showSnackBar("提示", "不允许加入自己的账本");
    } else if (code == 424) {
      ToastUtil.showSnackBar("提示", "你已在账本成员列表中");
    } else {
      ToastUtil.showSnackBar("提示", msg);
    }
  }
}
