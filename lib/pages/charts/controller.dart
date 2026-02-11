import 'dart:async';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/charts/models/daily_stats.dart';
import 'package:journal/pages/lab/medical_card/view.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

class ChartDataModel {
  String? value;
  String name;

  ChartDataModel(this.value, this.name);

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
        json['value']?.toString(), json['name']?.toString() ?? "");
  }

  double get doubleValue => double.tryParse(value ?? '0') ?? 0.0;
}

enum ChartDimension { week, month, year } // 定义枚举

class ChartsController extends GetxController {
  // 1. 定义当前选中的维度，默认为周
  final currentDimension = ChartDimension.week.obs;

  // 2. 切换维度的方法
  void changeDimension(ChartDimension dimension) {
    if (currentDimension.value == dimension) return;

    currentDimension.value = dimension;

    // 3. 这里触发刷新数据逻辑，比如：
    // updateParams(dimension);
    // initData();
  }

  RxString judgeString = "".obs;
  double dailyBudgetValue = 0.0;
  RxList<ChartDataModel> charts = RxList<ChartDataModel>.empty(growable: true);

  RxList<ChartDataModel> groupByTypeCharts =
      RxList<ChartDataModel>.empty(growable: true);

  EasyRefreshController refreshController = EasyRefreshController();
  RxList<Activity> allActivityList = RxList<Activity>.empty(growable: true);
  Rx<Activity> currentActivity = Rx<Activity>(Activity.empty());

  RxBool showTitleWhenSelected = false.obs;
  RxBool trendShowLabels = false.obs;

  //////// 日历相关
  Rx<DateTime> focusedDay = DateTime.now().obs; // 当前日历聚焦的月份
  Rx<DateTime?> selectedDay = Rx<DateTime?>(null); // 用户选中的具体某天
  RxMap<String, DailyStats> calendarData = <String, DailyStats>{}.obs; // 日历数据源
  RxDouble currentMonthExpense = 0.0.obs;
  RxDouble currentMonthIncome = 0.0.obs;
  ScrollController scrollController = ScrollController();

  RxList<Expense> expenseList = RxList<Expense>.empty(growable: true);

  void loadExpenseList(String typeName) async {
    var data = await HttpRequest.request(
      Method.get,
      "/expense/list/${_getCurrentActivityId()}/type?type=$typeName",
      params: {},
    );
    if (data != null && data["data"] != null && data["data"] is List) {
      List<Expense> result = List<Expense>.from(
          (data["data"] as List).map((e) => Expense.fromJson(e)));

      expenseList.value = result;
      update(["expense_list", "charts"]);
    }
  }

  void loadCalendarData(DateTime month) async {
    focusedDay.value = month;
    String monthStr = DateFormat('yyyy-MM').format(month);
    String activityId = _getCurrentActivityId();

    try {
      // 假设你的接口返回如下结构：

      List<dynamic> data =
          await _getAsync("/charts/calendar/$activityId?month=$monthStr");

      Map<String, DailyStats> newMap = {};
      for (var item in data) {
        String dateKey = item['date']; // "2023-10-01"
        newMap[dateKey] = DailyStats(
          date: dateKey,
          expense: double.tryParse(item['expense'].toString()) ?? 0,
          income: double.tryParse(item['income'].toString()) ?? 0,
        );
      }
      calendarData.value = newMap; // 更新数据
      print("calendarData: $calendarData");
      update(["calendar_chart", "charts"]);
    } catch (e) {
      Log().d("加载日历数据失败: $e");
    }
  }

  // 3. 页面交互：切换月份
  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
    loadCalendarData(focused); // 懒加载：滑到哪个月，加载哪个月的数据
  }

  // 4. 页面交互：点击某一天
  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay.value, selected)) {
      selectedDay.value = selected;
      focusedDay.value = focused;

      // showDailyDetail(selected);
    }
  }

  // 辅助：获取某天的统计数据
  DailyStats? getStatsForDay(DateTime day) {
    String key = DateFormat('yyyy-MM-dd').format(day);
    return calendarData[key];
  }

  // 将原本的回调风格请求转换为 Future，以便使用 await 和 Future.wait
  Future<dynamic> _getAsync(String url, {Map<String, dynamic>? params}) {
    Completer<dynamic> completer = Completer();
    HttpRequest.request(
      Method.get,
      url,
      params: params,
      success: (data) => completer.complete(data),
      fail: (code, msg) {
        Log().d("Request failed: $url, $msg");
        completer.complete(null); // 失败返回 null 或根据需要抛出异常
      },
    );
    return completer.future;
  }

  // 1. 初始化数据入口
  initData({bool forceRefreshActivity = false}) async {
    loadCalendarData(DateTime(2026, 2, 1));
    // 只有在列表为空，或者强制刷新时，才请求 ActivityList
    isAnalyzing.value = false;
    judgeString.value = "";
    if (allActivityList.isEmpty || forceRefreshActivity) {
      await _loadActivityList();
    }

    // 加载完 Activity 后（确保有了 currentActivityId），再并行加载图表
    await _loadChartData();
  }

  // 2. 加载 Activity 列表 (并行加载个人的和加入的)
  Future<void> _loadActivityList() async {
    try {
      // 并行请求：个人列表 和 加入的列表
      final results = await Future.wait([
        _getAsync("/activity/list/all"),
      ]);

      var selfListRaw = results[0];

      List<Activity> mergedList = [];

      // 处理逻辑封装
      String targetId = _getCurrentActivityId();

      if (selfListRaw != null) {
        mergedList
            .addAll((selfListRaw as List).map((e) => Activity.fromJson(e)));
      }

      // 更新 currentActivity 对象状态
      for (var act in mergedList) {
        if (act.activityId == targetId) {
          currentActivity.value = act;
          break; // 找到了就跳出
        }
      }

      allActivityList.value = mergedList;
    } catch (e) {
      Log().d("Error loading activities: $e");
    }
  }

  // 3. 加载图表数据 (完全并行)
  Future<void> _loadChartData() async {
    String currentId = _getCurrentActivityId();
    if (currentId.isEmpty) return;

    charts.clear();
    groupByTypeCharts.clear();

    try {
      // 并行请求所有图表相关接口
      final results = await Future.wait([
        _getAsync("/charts/weekly/$currentId"), // Index 1
        _getAsync("/charts/weekly/type/$currentId"), // Index 2
        _getAsync("/activity/search/$currentId"), // Index 3
      ]);

      // 处理 AI Judge

      // 处理 Weekly Charts
      if (results[0] != null) {
        charts.value = (results[0] as List)
            .map((e) => ChartDataModel.fromJson(e))
            .toList();
      }

      // 处理 Type Charts
      if (results[1] != null) {
        groupByTypeCharts.value = (results[1] as List)
            .map((e) => ChartDataModel.fromJson(e))
            .toList();
      }

      if (results[2] != null) {
        currentActivity.value =
            Activity.fromJson(results[2] as Map<String, dynamic>);
        print("currentActivity:${currentActivity.value}");
        dailyBudgetValue = _toDouble(currentActivity.value.budget) / 30;
      }
      update(["charts"]); // 统一刷新 UI
    } catch (e) {
      Log().d("Error loading charts: $e");
    }
  }

  var isAnalyzing = false.obs;

// 模拟数据源
  bool hasClickedPrintToday = false; // 用户是否点击过

  bool hasRecordToday = true; // 用户今日是否有记账

  // 【核心逻辑】判断是否需要提醒
  bool get shouldRemindPrint {
    return false;
    final now = DateTime.now();

    // 1. 时间是否超过 21 点
    bool isLate = now.hour >= 21;

    // 2. 且用户没有点击过
    bool notClicked = !hasClickedPrintToday;

    // 3. 且用户今日有记账 (如果没有记账，打印也没数据，就不提醒了)
    bool hasData = hasRecordToday;

    return isLate && notClicked && hasData;
  }

  void judgeActivity() {
    String currentId = _getCurrentActivityId();
    if (currentId.isEmpty) return;

    // 1. 设置状态为正在分析，清空旧数据
    isAnalyzing.value = true;
    judgeString.value = "";

    HttpRequest.request<Stream>(
      Method.get,
      "/ai/judge?activityId=$currentId",
      isStream: true,
      params: {},
      success: (data) {
        isAnalyzing.value = true;
        processStreamResponse(data);
      },
      fail: (code, msg) {
        // 失败处理：关掉 loading，允许用户重试
        isAnalyzing.value = false;
      },
      // 如果你的网络库有 onFinish/onClose 回调，最好在那里 set isAnalyzing.value = false
    );
  }

  /// 处理流式响应
  Future<void> processStreamResponse(Stream stream) async {
    final StringBuffer buffer = StringBuffer();

    // 处理流式响应
    await for (var data in stream) {
      final bytes = data as List<int>;
      final decodedData = utf8.decode(bytes);
      List<String> jsonData = decodedData.split('data: ');
      jsonData = jsonData.where((element) => element.isNotEmpty).toList();
      for (var content in jsonData) {
        if (content == '[DONE]') {
          isAnalyzing.value = false;
          break;
        }

        try {
          if (content.isNotEmpty) {
            buffer.write(content);
            judgeString.value = buffer.toString();

            update(["chat"]);
          }
          if (content == 'stop') {
            print(buffer.toString());
            break;
          }
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      }
    }
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // 辅助方法：获取当前 ID
  String _getCurrentActivityId() {
    if (currentActivity.value.activityId.isNotEmpty) {
      return currentActivity.value.activityId;
    }
    LayoutController layoutController = Get.find<LayoutController>();
    return layoutController.user.value.currentActivityId ?? "";
  }

  void switchTrendShowLabels() {
    trendShowLabels.value = !trendShowLabels.value;
    update(["charts"]);
  }

  void swtichShowTitleWhenSelected() {
    showTitleWhenSelected.value = !showTitleWhenSelected.value;
    update(["charts"]);
  }

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  void onReady() {
    super.onReady();
    eventBus.on<NeedRefreshData>().listen((NeedRefreshData data) {
      Log().d("need refresh data: $data");
      if (data.refreshChartsList) {
        // 这里如果是单纯刷新图表，不需要强制刷新 ActivityList
        initData(forceRefreshActivity: false);
      }
    });
  }

  Future<List<Expense>?> getTodayExpenseItemList(context) async {
    String nowDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

    try {
      print("_getCurrentActivityId():${_getCurrentActivityId()}");
      var data = await HttpRequest.request(
        Method.get,
        "/expense/list/${_getCurrentActivityId()}/date?date=$nowDate",
        params: {},
      );
      if (data != null && data["data"] != null && data["data"] is List) {
        List<Expense> result = List<Expense>.from(
            (data["data"] as List).map((e) => Expense.fromJson(e)));

        print("result type:${result.runtimeType}");
        return result;
      }

      return <Expense>[];
    } catch (e) {
      print("获取今日账单失败: $e");
      JournalToast.showError(context, "获取今日账单失败");
      return null;
    }
  }

// 替换原来的 handlePrintAction
  void handlePrintAction(BuildContext context) async {
    JournalToast.showLoading(context);
    hasClickedPrintToday = true;
    // 1. 获取数据
    List<Expense> expenseItems = await getTodayExpenseItemList(context) ?? [];

    if (expenseItems.isEmpty) {
      if (context.mounted) {
        JournalToast.dismiss();
        JournalToast.showError(context, "今日暂无账单数据");
      }
      return;
    }
    JournalToast.dismiss();

    List<String> nicknameList =
        expenseItems.map((e) => e.userNickname ?? '').toSet().toList();

    final receiptData = ReceiptData(
      nickname: nicknameList.join(' | '),
      budget: dailyBudgetValue,
      items: expenseItems,
      date: DateTime.now().toString().substring(0, 10),
    );

    // 3. 使用自定义弹性动画路由跳转
    if (context.mounted) {
      Navigator.of(context).push(_createPrinterRoute(receiptData));
    }
  }

  Route _createPrinterRoute(ReceiptData data) {
    return PageRouteBuilder(
      opaque: false, // 必须是 false，否则看不到下面的页面
      barrierColor: Colors.black26, // 【修改这里】去掉默认的半透明黑底
      barrierDismissible: true, // 保持点击背景关闭
      transitionDuration: const Duration(milliseconds: 600),

      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: MedicalPrinterCard(data: data),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
