import 'dart:async';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart'; // 假设这是你的引用
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/pages/charts/view.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';
import 'dart:convert'; // 必须引入，用于 utf8 解码

class ChartsController extends GetxController {
  RxString judgeString = "".obs;
  double dailyBudgetValue = 0.0;
  RxList<DBDataNodeModel> charts =
      RxList<DBDataNodeModel>.empty(growable: true);

  RxList<DBDataNodeModel> groupByTypeCharts =
      RxList<DBDataNodeModel>.empty(growable: true);

  RxList<Activity> allActivityList = RxList<Activity>.empty(growable: true);
  Rx<Activity> currentActivity = Rx<Activity>(Activity.empty());

  Rx<BrnDoughnutDataItem> selectedItem =
      BrnDoughnutDataItem(value: 0, title: "").obs;
  RxBool showTitleWhenSelected = false.obs;

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
            .map((e) => DBDataNodeModel.fromJson(e))
            .toList();
      }

      // 处理 Type Charts
      if (results[1] != null) {
        groupByTypeCharts.value = (results[1] as List)
            .map((e) => DBDataNodeModel.fromJson(e))
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
}
