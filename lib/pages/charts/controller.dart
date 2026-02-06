import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:journal/components/bruno/bruno.dart'; // 假设这是你的引用
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/charts/models/daily_stats.dart';
import 'package:journal/pages/charts/view.dart';
import 'package:journal/pages/lab/receipt/receipt_card.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

import 'package:tdesign_flutter/tdesign_flutter.dart'; // 必须引入，用于 utf8 解码

class ChartsController extends GetxController {
  RxString judgeString = "".obs;
  double dailyBudgetValue = 0.0;
  RxList<ChartDataModel> charts = RxList<ChartDataModel>.empty(growable: true);

  RxList<ChartDataModel> groupByTypeCharts =
      RxList<ChartDataModel>.empty(growable: true);

  RxList<Activity> allActivityList = RxList<Activity>.empty(growable: true);
  Rx<Activity> currentActivity = Rx<Activity>(Activity.empty());

  Rx<BrnDoughnutDataItem> selectedItem =
      BrnDoughnutDataItem(value: 0, title: "").obs;
  RxBool showTitleWhenSelected = false.obs;

  //////// 日历相关
  Rx<DateTime> focusedDay = DateTime.now().obs; // 当前日历聚焦的月份
  Rx<DateTime?> selectedDay = Rx<DateTime?>(null); // 用户选中的具体某天
  RxMap<String, DailyStats> calendarData = <String, DailyStats>{}.obs; // 日历数据源
  RxDouble currentMonthExpense = 0.0.obs;
  RxDouble currentMonthIncome = 0.0.obs;

  void loadCalendarData(DateTime month) async {
    // 模拟构造 API 请求参数：获取整月的每一天数据
    String monthStr = DateFormat('yyyy-MM').format(month);
    String activityId = _getCurrentActivityId();

    try {
      // 假设你的接口返回如下结构：

      List<DailyStats> data = [
        DailyStats(date: "2026-02-01", expense: 100.0, income: 0),
        DailyStats(date: "2026-02-02", expense: 50.0, income: 200),
        DailyStats(date: "2026-02-03", expense: 30.0, income: 150),
        DailyStats(date: "2026-02-04", expense: 20.0, income: 100),
        DailyStats(date: "2026-02-05", expense: 40.0, income: 150),
      ];
      // await _getAsync("/charts/calendar/$activityId",
      // params: {"month": monthStr});

      Map<String, DailyStats> newMap = {};
      for (var item in data) {
        String dateKey = item.date; // "2023-10-01"
        newMap[dateKey] = DailyStats(
          date: dateKey,
          expense: double.tryParse(item.expense.toString()) ?? 0,
          income: double.tryParse(item.income.toString()) ?? 0,
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

      // TODO: 这里可以弹出一个 BottomSheet 显示当天的详细账单列表
      // showDailyDetail(selected);
    }
  }

  // 辅助：获取某天的统计数据
  DailyStats? getStatsForDay(DateTime day) {
    String key = DateFormat('yyyy-MM-dd').format(day);
    print("key: $key");
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
  _initData({bool forceRefreshActivity = false}) async {
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
        _getAsync("/activity/list"),
        _getAsync("/activity/list/joined"),
      ]);

      var selfListRaw = results[0];
      var joinedListRaw = results[1];

      List<Activity> mergedList = [];

      // 处理逻辑封装
      String targetId = _getCurrentActivityId();

      if (selfListRaw != null) {
        mergedList
            .addAll((selfListRaw as List).map((e) => Activity.fromJson(e)));
      }
      if (joinedListRaw != null) {
        mergedList
            .addAll((joinedListRaw as List).map((e) => Activity.fromJson(e)));
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

  var isAnalyzing = false.obs; // 【新增】标记是否正在请求中
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

  selectItem(BrnDoughnutDataItem? item) {
    if (item == null) return;
    selectedItem.value = item;
    update(["charts"]);
  }

  void swtichShowTitleWhenSelected() {
    showTitleWhenSelected.value = !showTitleWhenSelected.value;
    update(["charts"]);
  }

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onReady() {
    super.onReady();
    eventBus.on<NeedRefreshData>().listen((NeedRefreshData data) {
      Log().d("need refresh data: $data");
      if (data.refreshChartsList) {
        // 这里如果是单纯刷新图表，不需要强制刷新 ActivityList
        _initData(forceRefreshActivity: false);
      }
    });
  }

  Future<List<Expense>?> getTodayExpenseItemList() async {
    String nowDate = DateFormat("yyyy-MM-dd").format(DateTime.now());

    try {
      print("_getCurrentActivityId():${_getCurrentActivityId()}");
      var data = await HttpRequest.request(
        Method.get,
        "/expense/list/${_getCurrentActivityId()}/date?date=$nowDate",
        params: {},
      );
      // print(data);
      // 拿到数据直接转
      if (data != null && data["data"] != null && data["data"] is List) {
        // 【修改点 1】 使用 List<Expense>.from 来强转，这比 map.toList() 更安全
        // 它会遍历列表并把每个元素都 cast 成 Expense，如果有元素类型不对会报错，比 dynamic 安全
        List<Expense> result = List<Expense>.from(
            (data["data"] as List).map((e) => Expense.fromJson(e)));

        print("result type:${result.runtimeType}");
        return result;
      }

      return <Expense>[];
    } catch (e) {
      print("获取今日账单失败: $e");
      TDToast.dismissAll();
      return null;
    }
  }

  // 抽离打印逻辑代码，保持 build 整洁
  void handlePrintAction(BuildContext context) async {
    TDToast.showLoading(context: context);
    List<Expense> expenseItems = await getTodayExpenseItemList() ?? [];
    Log().d("expenseItems: $expenseItems");
    if (expenseItems.isEmpty) {
      if (context.mounted) {
        TDToast.dismissAll();
        TDToast.showFail("暂无数据", context: context);
      }
      return;
    }
    TDToast.dismissAll();

    List<String> nicknameList =
        expenseItems.map((e) => e.userNickname ?? '').toSet().toList();
    Get.dialog(Material(
      type: MaterialType.transparency,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrintingReceiptAnim(
                onPrintFinished: () {},
                child: ReceiptCard(
                  nickname: nicknameList.join(' | '),
                  budget: dailyBudgetValue,
                  items: expenseItems,
                  date: DateTime.now().toString().substring(0, 10),
                ),
              ),
              SizedBox(height: 30.h),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.cancel, color: Colors.white, size: 36),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
