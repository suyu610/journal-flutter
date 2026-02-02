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
        hasNextPage.value = pageInfo.hasNextPage;

        List<Expense> expenseList =
            (pageInfo.list).map((e) => Expense.fromJson(e)).toList();

        // 1. 将新获取的一页数据，先按日期归类成 Map
        Map<String, List<Expense>> newPageMap = {};
        expenseList.forEach((element) {
          String date = element.expenseTime.substring(0, 10);
          if (newPageMap[date] == null) {
            newPageMap[date] = [];
          }
          newPageMap[date]!.add(element);
        });

        // 2. 处理【已有】的日期组 (Merge)
        // 遍历现有的 UI 列表，如果新数据里有这一天，就追加进去
        expenseDateGroupList.forEach((group) {
          if (newPageMap.containsKey(group.date)) {
            group.expenses.addAll(newPageMap[group.date]!);
            // 只要 expenses 变了，expensesByType 自动就会变，因为它是 getter
          }
        });

        // 3. 处理【新增】的日期组 (Add)
        // 找出 UI 列表里没有，但新数据里有的日期
        Set<String> existDateSet =
            expenseDateGroupList.map((e) => e.date).toSet();
        Set<String> newPageDateSet =
            newPageMap.entries.map((e) => e.key).toSet();

        newPageDateSet.difference(existDateSet).forEach((date) {
          expenseDateGroupList.add(ExpenseDateGroup(date, newPageMap[date]!));
        });

        // 排序（可选）：为了保证日期顺序，通常建议在这里对 expenseDateGroupList 按日期排个序
        // expenseDateGroupList.sort((a, b) => b.date.compareTo(a.date));

        // 4. 重新计算每天的总金额
        expenseDateGroupList.forEach((element) {
          double totalExpense = 0.0;
          element.expenses.forEach((expense) {
            if (expense.positive == 0) {
              totalExpense += expense.price;
            }
          });
          element.totalExpense = totalExpense;
        });

        update(["current_activity"]);
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
      success: (data) async {
        if (data == null) {
          Log().d("无当前账本");
          currentActivity.value = Activity.empty();
        } else {
          currentActivity.value =
              Activity.fromJson(data as Map<String, dynamic>);
          // 获取expenseList
          getExpenseList();

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

  RxBool isExpenseListShowMode = true.obs;
  void switchExpenseListShowMode() {
    isExpenseListShowMode.value = !isExpenseListShowMode.value;
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
