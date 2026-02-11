import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/request/request.dart';

class ActivityListController extends GetxController {
  ActivityListController();

  late EasyRefreshController refreshController;
  late ScrollController scrollController;

  initData() {
    // fetchSelfActivityList();
    // fetchJoinedActivityList();
    fetchAllActivityList();
  }

  RxList<Activity> activityList = <Activity>[].obs;
  RxList<Activity> joinedActivityList = <Activity>[].obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    Log().d("activityList controller activity list onInit");

    initData();
  }

  @override
  void onReady() {
    super.onReady();
    Log().d("activityList controller onReady");
    eventBus.on<NeedRefreshData>().listen((NeedRefreshData data) {
      Log().d("need refresh data: $data");
      if (data.refreshActivityList) {
        initData();
      }
    });
  }

  void fetchAllActivityList() {
    Log().d("fetchAllActivityList");
    HttpRequest.request(
      Method.get,
      "/activity/list/all",
      success: (data) {
        Log().d("activityList data: ${activityList.toString()}");

        activityList.value =
            (data as List).map((e) => Activity.fromJson(e)).toList();
        refreshController.finishRefresh();
        refreshController.resetFooter();
        update(["activity_list"]);
      },
      fail: (code, msg) {},
    );
  }
}
