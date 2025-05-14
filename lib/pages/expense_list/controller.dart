import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/models/paging.dart';
import 'package:journal/request/request.dart';

class ExpenseListController extends GetxController {
  ExpenseListController();

  void onTap() {}

  @override
  void onReady() {
    super.onReady();
    activity.value = Get.arguments as Activity;

    initData();
  }

  ScrollController scrollController = ScrollController();
  Rx<Activity> activity = Activity.empty().obs;
  RxList<ExpenseDateGroup> expenseDateGroupList = <ExpenseDateGroup>[].obs;

  RxInt pageNum = 1.obs;
  RxBool hasNextPage = true.obs;
  getExpenseList() {
    if (!hasNextPage.value) {
      return;
    }

    HttpRequest.request(Method.get,
        "/expense/list/${activity.value.activityId}?pageNum=${pageNum.value}",
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
        update(["expense_list"]);
        // Log().d("expenseList: ${expenseDateGroupList.toString()}");
      }
    }, fail: (code, msg) {
      Log().d(msg);
    });
  }

  initData() {
    getExpenseList();

    // 触底加载更多
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        pageNum.value++;
        getExpenseList();
      }
    });
  }


  void reset() {

    pageNum.value = 1;
    hasNextPage.value = true;
    expenseDateGroupList.clear();
    update(["expense_list"]);
  }
}
