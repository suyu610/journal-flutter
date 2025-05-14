import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/components/toast/brn_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/user.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class CreateActivityController extends GetxController {
  var activityNameController = TextEditingController();

  var budgetController = TextEditingController();

  var creatorController = TextEditingController();
  RxBool isOwner = false.obs;
  CreateActivityController();

  Rx<Activity> activity = Activity.empty().obs;

  _initData() {
    if (Get.arguments != null) {
      activity.value = Get.arguments;

      activity.value.activated = activity.value.activityId ==
          Get.find<LayoutController>().user.value.currentActivityId;

      isOwner.value = activity.value.userId ==
          Get.find<LayoutController>().user.value.userId;

      activityNameController.text = activity.value.activityName;
      creatorController.text = activity.value.creatorName;
      budgetController.text = (activity.value.budget ?? 0).toString();
    } else {
      activity.value = Activity.empty();
      activityNameController.text = "";
      creatorController.text = "";

      budgetController.text = "";
    }

    update(["createactivitypage"]);
  }

  void onTap() {}

  @override
  void onInit() {
    super.onInit();
    Log().d("create activity onInit");
  }

  @override
  void onReady() {
    super.onReady();
    Log().d("create activity onReady");
    _initData();
  }

  void updateActivated(bool newValue) {
    activity.value.activated = newValue;
    // 如果不是自己的账本，则修改用户当前的账本
    if (!isOwner.value) {
      User user = Get.find<LayoutController>().user.value;

      user.currentActivityId = activity.value.activityId;
      HttpRequest.request(Method.patch, "/user", params: {
        "userId": user.userId,
        "currentActivityId": user.currentActivityId
      }, success: (data) {
        eventBus.fire(const NeedRefreshData(
            refreshChartsList: true,
            refreshActivityList: true,
            refreshCurrentActivity: true));
      });
    }
    update(["createactivitypage"]);
  }

  void createActivity(context) {
    if (activityNameController.text.isEmpty) {
      BrnToast.show("请输入名称", context);
      return;
    }

    // 预算
    activity.value.budget = num.tryParse(budgetController.text) ?? 0;

    // 账本名称
    activity.value.activityName = activityNameController.text;
    Log().d(activity.value.toString());

    TDToast.showLoading(context: context, text: "处理中");

    // 创建
    if (activity.value.activityId == "") {
      HttpRequest.request(Method.post, "/activity",
          params: activity.value.toJson(), success: (data) {
        BrnToast.showInCenter(text: "创建成功", context: context);
        eventBus.fire(const NeedRefreshData(
            refreshChartsList: true,
            refreshActivityList: true,
            refreshCurrentActivity: true));
        TDToast.dismissLoading();
        TDToast.showSuccess("创建成功", context: context);
        Get.back(result: true);
      }, fail: (code, msg) {
        Log().d(msg.toString());
      });
    } else {
      // 更新
      HttpRequest.request(Method.patch, "/activity",
          params: activity.value.toJson(), success: (data) {
        Log().d(data.toString());
        BrnToast.showInCenter(text: "更新成功", context: context);
        Get.find<LayoutController>().user.value.currentActivityId =
            activity.value.activityId;
        eventBus.fire(const NeedRefreshData(
            refreshChartsList: true,
            refreshActivityList: true,
            refreshCurrentActivity: true));
        TDToast.dismissLoading();
        TDToast.showSuccess("修改成功", context: context);
        Get.back(result: true);
      }, fail: (code, msg) {
        Log().d(msg.toString());
      });
    }
  }

  @override
  void onClose() {
    super.onClose();
    // Get.find<ActivityListController>().fetchSelfActivityList();
    activity.value = Activity.empty();
  }

  void deleteActivity(context) {
    HttpRequest.request(Method.delete, "/activity/${activity.value.activityId}",
        success: (data) {
      Get.back();
      Get.back();

      eventBus.fire(const NeedRefreshData(
          refreshChartsList: true,
          refreshActivityList: true,
          refreshCurrentActivity: true));
    }, fail: (code, msg) {
      Log().d(msg.toString());
      BrnToast.show(msg, context);
    });
  }

  void exitActivity(context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return TDAlertDialog(
          buttonStyle: TDDialogButtonStyle.text,
          title: "确认退出账本吗？",
          rightBtnAction: () {
            HttpRequest.request(
              Method.post,
              "/activity/exit/${activity.value.activityId}",
              success: (d) {
                Get.back();
                Get.back();
                eventBus.fire(const NeedRefreshData(
                    refreshChartsList: true,
                    refreshActivityList: true,
                    refreshCurrentActivity: true));
              },
              fail: (code, msg) {
                Log().d(msg.toString());
                BrnToast.show(msg, context);
              },
            );
          },
        );
      },
    );
  }
}
