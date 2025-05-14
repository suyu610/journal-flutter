import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/models/paging.dart';
import 'package:journal/request/request.dart';

class CurrentActivityController extends GetxController {
  CurrentActivityController();
  ScrollController scrollController = ScrollController();
  Rx<Activity> currentActivity = Activity.empty().obs;
  RxList<ExpenseDateGroup> expenseDateGroupList = <ExpenseDateGroup>[].obs;

  RxInt pageNum = 1.obs;
  RxBool hasNextPage = true.obs;

  void updateView() {
    update(["current_activity"]);
  }

  getExpenseList() {
    if (!hasNextPage.value) {
      return;
    }

    HttpRequest.request(Method.get,
        "/expense/list/${currentActivity.value.activityId}?pageNum=${pageNum.value}",
        success: (data) {
      if (data == null) {
        Log().d("无");
      } else {
        Paging pageInfo = Paging.fromJson(data as Map<String, dynamic>);
        // Log().d(pageInfo.total.toString());
        hasNextPage.value = pageInfo.hasNextPage;

        List<Expense> expenseList =
            (pageInfo.list).map((e) => Expense.fromJson(e)).toList();
        Map<String, List<Expense>> expenseMap = {};
        expenseList.forEach((element) {
          String date = element.expenseTime.substring(0, 10);
          if (expenseMap[date] == null) {
            expenseMap[date] = [];
          }
          expenseMap[date]!.add(element);
        });
        Log().d(expenseMap.toString());
        // 处理已存在的
        expenseDateGroupList.forEach((element) {
          if (expenseMap.containsKey(element.date)) {
            element.expenses.addAll(expenseMap[element.date]!);
          }
        });

        // 提取 expenseDateGroupList 中的 date 形成list
        Set<String> existDateSet =
            expenseDateGroupList.map((e) => e.date).toSet();

        // 相减
        Set<String> expenseDateSet =
            expenseMap.entries.map((e) => e.key).toSet();

        expenseDateSet.difference(existDateSet).forEach((element) {
          expenseDateGroupList
              .add(ExpenseDateGroup(element, expenseMap[element]!));
        });
        update(["current_activity"]);
        // Log().d("expenseList: ${expenseDateGroupList.toString()}");
      }
    }, fail: (code, msg) {
      Log().d(msg);
    });
  }

  initData() {
    currentActivity.value = Activity.empty();
    expenseDateGroupList.value = [];

    pageNum.value = 1;
    hasNextPage.value = true;

    HttpRequest.request(
      Method.get,
      "/activity/current",
      success: (data) {
        if (data == null) {
          Log().d("无当前账本");
          currentActivity.value = Activity.empty();
        } else {
          currentActivity.value =
              Activity.fromJson(data as Map<String, dynamic>);
          // 获取expenseList
          getExpenseList();
        }
        update(["current_activity"]);
      },
      fail: (code, msg) {
        Log().d("获取当前账本失败:$msg");
      },
    );
  }

  void onTap() {}

  void reset() {
    pageNum.value = 1;
    hasNextPage.value = true;
    expenseDateGroupList.clear();
    update(["current_activity"]);
  }

  @override
  void onReady() {
    super.onReady();
    initData();
    // 触底加载更多
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        pageNum.value++;
        getExpenseList();
      }
    });
    eventBus.on<NeedRefreshData>().listen((NeedRefreshData data) {
      Log().d("need refresh data: $data");
      if (data.refreshCurrentActivity) {
        reset();
        initData();
      }
    });
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
