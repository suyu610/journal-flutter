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
import 'package:journal/services/widget_service.dart';

class CurrentActivityController extends GetxController {
  CurrentActivityController();
  ScrollController scrollController = ScrollController();
  Rx<Activity> currentActivity = Activity.empty().obs;
  RxList<ExpenseDateGroup> expenseDateGroupList = <ExpenseDateGroup>[].obs;
  RxList<ExpenseDateGroup> expenseDateGroupListByType =
      <ExpenseDateGroup>[].obs;

  RxInt pageNum = 1.obs;
  RxBool hasNextPage = true.obs;
  RxBool isLoading = false.obs;

  void updateView() {
    update(["current_activity"]);
  }

  // 修改：增加 targetPage 参数，默认为 1
  void getExpenseList({int targetPage = 1}) {
    // 1. 上锁
    isLoading.value = true;

    print("正在请求第 $targetPage 页数据...");

    HttpRequest.request(Method.get,
        "/expense/list/${currentActivity.value.activityId}?pageNum=$targetPage",
        success: (data) {
      // 2. 请求结束，解锁（成功情况）
      isLoading.value = false;

      if (data == null) {
        Log().d("无数据");
      } else {
        Paging pageInfo = Paging.fromJson(data as Map<String, dynamic>);

        // 更新分页状态
        hasNextPage.value = pageInfo.hasNextPage;
        // 【关键】只有成功获取数据后，才更新当前的 pageNum
        pageNum.value = targetPage;

        List<Expense> expenseList =
            (pageInfo.list).map((e) => Expense.fromJson(e)).toList();

        // --- 数据合并逻辑开始 ---

        // 1. 将新数据按日期分组
        Map<String, List<Expense>> newPageMap = {};
        for (var element in expenseList) {
          // 容错处理：防止 substring 报错
          if (element.expenseTime.length >= 10) {
            String date = element.expenseTime.substring(0, 10);
            newPageMap.putIfAbsent(date, () => []).add(element);
          }
        }

        // 2. 遍历现有列表，进行 Merge（追加到已有日期）
        for (var group in expenseDateGroupList) {
          if (newPageMap.containsKey(group.date)) {
            group.expenses.addAll(newPageMap[group.date]!);
            // 既然已经合并了，从 Map 中移除，避免后续重复添加
            newPageMap.remove(group.date);
          }
        }

        // 3. 处理剩下的（现有列表中没有的日期），直接作为新组添加
        newPageMap.forEach((date, list) {
          expenseDateGroupList.add(ExpenseDateGroup(date, list));
        });

        // 4. 【关键】重新排序，保证日期顺序正确（通常是日期倒序）
        expenseDateGroupList.sort((a, b) => b.date.compareTo(a.date));

        // 5. 重新计算总金额
        for (var element in expenseDateGroupList) {
          double totalExpense = 0.0;
          for (var expense in element.expenses) {
            if (expense.positive == 0) {
              // 假设 0 是支出
              totalExpense += expense.price;
            }
          }
          element.totalExpense = totalExpense;
        }

        // 更新 UI
        update(["current_activity"]);
      }
    }, fail: (code, msg) {
      // 2. 请求结束，解锁（失败情况）
      isLoading.value = false;
      Log().d(msg);
      // 可以在这里加一个 Toast 提示失败
    });
  }

  initData() {
    currentActivity.value = Activity.empty();
    expenseDateGroupList.value = [];

    pageNum.value = 1;
    hasNextPage.value = true;
    isLoading.value = false; // 重置锁
    HttpRequest.request(
      Method.get,
      "/activity/current",
      success: (data) async {
        if (data == null) {
          currentActivity.value = Activity.empty();
        } else {
          currentActivity.value =
              Activity.fromJson(data as Map<String, dynamic>);
          // 获取expenseList
          getExpenseList(targetPage: 1);
          // 3. 同步给小组件
          await WidgetSyncService.updateWidget(
            budgetType: currentActivity.value.budgetType ?? "total",
            todayExpense:
                (currentActivity.value.todayExpense ?? 0.0).toDouble(),
            weekExpense: (currentActivity.value.weekExpense ?? 0.0).toDouble(),
            monthExpense:
                (currentActivity.value.monthExpense ?? 0.0).toDouble(),
            totalExpense:
                (currentActivity.value.totalExpense ?? 0.0).toDouble(),
            budgetAmount: (currentActivity.value.budget ?? 0.0).toDouble(),
          );
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
    isLoading.value = false;
    expenseDateGroupList.clear();
    update(["current_activity"]);
  }

  RxBool shouldShowAddButton = false.obs;

// 【新增】专门处理加载更多的逻辑
  void _loadMore() {
    if (isLoading.value || !hasNextPage.value) {
      return;
    }
    // 请求下一页：当前页码 + 1
    getExpenseList(targetPage: pageNum.value + 1);
  }

  @override
  void onReady() {
    super.onReady();
    initData();
    // 触底加载更多
    scrollController.addListener(() {
      shouldShowAddButton.value = scrollController.position.pixels > 200;

      // 触底加载更多
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50) {
        // 提示：留出 50 像素的缓冲区域，体验更好
        _loadMore();
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

  RxBool isExpenseListShowMode = true.obs;
  void switchExpenseListShowMode() {
    isExpenseListShowMode.value = !isExpenseListShowMode.value;
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
