import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class DBDataNodeModel {
  String? value;
  String name;
  DBDataNodeModel(this.value, this.name);

  // from json
  factory DBDataNodeModel.fromJson(Map<String, dynamic> json) {
    return DBDataNodeModel(json['value']?.toString(), json['name']);
  }
}

class ChartsPage extends GetView<ChartsController> {
  const ChartsPage({super.key});

  // 主视图
  Widget _buildView(context) {
    List<DBDataNodeModel> dailyData = controller.charts;
    List<DBDataNodeModel> groupByTypeData = controller.groupByTypeCharts;
    //
    double totalValue = groupByTypeData.fold(
        0.0, (prev, curr) => prev + double.parse(curr.value ?? '0'));
    // 在 build 方法或 controller 中定义
    List<Color> colors = [
      Colors.blueGrey[900]!, // 深蓝灰
      Colors.blueGrey[700]!,
      Colors.blueGrey[500]!,
      Colors.blueGrey[300]!,
      Colors.blueGrey[100]!, // 浅蓝灰
    ];
    var consumptionPoints = _linePointsForDemo1(dailyData);
    var budgetPoints = _buildBudgetLinePoints(dailyData); // 新增：生成预算点
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(controller.judgeString.value),
            _buildAIJudgeBubble(),
            Visibility(
              visible: _getMaxValueForDemo1(dailyData) > 0,
              child: Text(
                "最近7天消费",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
            Visibility(
              visible: _getMaxValueForDemo1(dailyData) > 0,
              child: const SizedBox(
                height: 14,
              ),
            ),
            Visibility(
              visible: _getMaxValueForDemo1(dailyData) > 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: BrnBrokenLine(
                  size: Size((300).w, MediaQuery.of(context).size.height / 5),
                  lines: [
                    BrnPointsLine(
                      isShowPointText: false,
                      lineWidth: 2,
                      pointRadius: 3,
                      isShowPoint: true,
                      isCurve: true,
                      points: consumptionPoints,
                      shaderColors: [
                        const Color(0xff000000).withOpacity(0.3),
                        const Color(0xff000000).withOpacity(0.01)
                      ],
                      lineColor: const Color(0xff000000).withOpacity(.8),
                    ),
                    // 第二条：预算线（新增的）
                    if (controller.dailyBudgetValue != 0)
                      BrnPointsLine(
                        isShowPointText: false,
                        lineWidth: 1.5, // 稍微细一点
                        pointRadius: 0, // 预算线通常不需要显示圆点
                        isShowPoint: false, // 隐藏圆点
                        isCurve: false, // 预算线是直的，不需要曲线
                        points: budgetPoints,
                        // 预算线通常不需要阴影，或者给一个很淡的警告色
                        shaderColors: [Colors.transparent, Colors.transparent],
                        // 用红色或橙色表示警戒线/标准线
                        lineColor: Colors.redAccent.withOpacity(0.8),
                      ),
                  ],
                  yHintLineOffset: 20,
                  hintLineColor: Colors.grey[300],
                  isShowXHintLine: true,
                  xyDialLineWidth: .1,
                  showPointDashLine: true,
                  isTipWindowAutoDismiss: true,
                  xDialValues: _getXDialValuesForDemo1(dailyData),
                  xDialMin: 0,
                  xDialMax:
                      _getXDialValuesForDemo1(dailyData).length.toDouble(),
                  yDialValues: _getYDialValuesForDemo1(dailyData),
                  yDialMin: 0,
                  yDialMax: _getMaxValueForDemo1(dailyData),
                  isHintLineSolid: false,
                  isShowYDialText: true,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "消费分类",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                BrnSwitchButton(
                    size: const Size(40, 24),
                    borderColor: Colors.grey[300]!,
                    value: controller.showTitleWhenSelected.value,
                    onChanged: (v) {
                      controller.swtichShowTitleWhenSelected();
                    }),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Container(
              width: 500,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: groupByTypeData.isEmpty
                  ? Container()
                  : BrnDoughnutChart(
                      height: MediaQuery.of(context).size.height / 4.3,
                      ringWidth: 50,
                      selectedItem: controller.selectedItem.value,
                      selectCallback: (selectedItem) {
                        controller.selectItem(selectedItem);
                      },
                      showTitleWhenSelected:
                          !controller.showTitleWhenSelected.value,
                      data: groupByTypeData
                          .map((item) => BrnDoughnutDataItem(
                              color: colors[groupByTypeData.indexOf(item) %
                                  colors.length],
                              value: double.parse((item).value!) / totalValue,
                              title: "${item.name}¥${item.value ?? ""}"))
                          .toList(),
                    ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  List<BrnPointData> _linePointsForDemo1(List<DBDataNodeModel> brokenData) {
    return brokenData
        .map((_) => BrnPointData(
            pointText: _.value,
            x: brokenData.indexOf(_).toDouble(),
            y: double.parse(_.value ?? "0"),
            lineTouchData: BrnLineTouchData(
                tipWindowSize: const Size(60, 40),
                onTouch: () {
                  return _.value;
                })))
        .toList();
  }

  List<BrnDialItem> _getYDialValuesForDemo1(List<DBDataNodeModel> brokenData) {
    double min = _getMinValueForDemo1(brokenData);
    double max = _getMaxValueForDemo1(brokenData);
    double dValue = (max - min) / 10;
    List<BrnDialItem> _yDialValue = [];
    for (int index = 0; index <= 10; index++) {
      _yDialValue.add(BrnDialItem(
        dialText: '${(min + index * dValue).ceil()}',
        dialTextStyle:
            const TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
        value: (min + index * dValue).ceilToDouble(),
      ));
    }
    _yDialValue.add(BrnDialItem(
      dialText: '4.5',
      dialTextStyle: const TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
      value: 4.5,
    ));
    return _yDialValue;
  }

  double _getMinValueForDemo1(List<DBDataNodeModel> brokenData) {
    double minValue = brokenData.isEmpty
        ? 0
        : double.tryParse(brokenData[0].value ?? "") ?? 0;
    for (DBDataNodeModel point in brokenData) {
      minValue = min(double.tryParse(point.value ?? "") ?? 0, minValue);
    }
    return minValue;
  }

  double _getMaxValueForDemo1(List<DBDataNodeModel> brokenData) {
    double maxValue = brokenData.isEmpty
        ? 0
        : double.tryParse(brokenData[0].value ?? "") ?? 0;
    for (DBDataNodeModel point in brokenData) {
      maxValue = max(double.tryParse(point.value ?? "") ?? 0, maxValue);
    }

    if (controller.dailyBudgetValue > maxValue) {
      return controller.dailyBudgetValue * 1.2;
    }

    return maxValue;
  }

  // 生成预算线的点数据
  List<BrnPointData> _buildBudgetLinePoints(List<DBDataNodeModel> dailyData) {
    List<BrnPointData> points = [];
    for (int i = 0; i < dailyData.length; i++) {
      points.add(BrnPointData(
        pointText: "", // 预算线通常不需要显示文字
        x: i.toDouble(),
        y: controller.dailyBudgetValue, // Y轴固定为预算值
        lineTouchData: BrnLineTouchData(
          onTouch: () => "预算: ${controller.dailyBudgetValue}",
          tipWindowSize: const Size(60, 40), // 点击显示的提示
        ),
      ));
    }
    return points;
  }

  List<BrnDialItem> _getXDialValuesForDemo1(List<DBDataNodeModel> brokenData) {
    List<BrnDialItem> _xDialValue = [];
    for (int index = 0; index < brokenData.length; index++) {
      _xDialValue.add(BrnDialItem(
        dialText: brokenData[index].name,
        dialTextStyle:
            const TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
        value: index.toDouble(),
      ));
    }
    return _xDialValue;
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey actionKey = GlobalKey();
    return GetBuilder<ChartsController>(
      init: ChartsController(),
      id: "charts",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          appBar: _buildAppbar(context, actionKey),

          //  BrnAppBar(
          //   themeData: BrnAppBarConfig.light(),
          //   automaticallyImplyLeading: false,
          //   leadingWidth: 280.w,
          //
          // ),
          body: SafeArea(
            child: controller.charts.isEmpty ||
                    controller.groupByTypeCharts.isEmpty
                ? _buildEmptyCard()
                : _buildView(context),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppbar(context, actionKey) => TDNavBar(
        useBorderStyle: true,
        height: 48,
        useDefaultBack: false,
        leftBarItems: [
          TDNavBarItem(
            iconWidget: controller.allActivityList.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: BrnTextAction(
                      controller.currentActivity.value.activityName,
                      key: actionKey,
                      iconPressed: () {
                        BrnPopupListWindow.showPopListWindow(context, actionKey,
                            offset: 10, onItemClick: (index, name) {
                          controller.currentActivity.value =
                              controller.allActivityList[index];
                          controller.onInit();
                          controller.update(['charts']);
                          Get.back();
                          return true;
                        },
                            data: controller.allActivityList.isEmpty
                                ? ["加载中"]
                                : controller.allActivityList
                                    .map((e) => e.activityName)
                                    .toList());
                      },
                    ),
                  ),
          )
        ],
        border: TDNavBarItemBorder(width: 0, color: Colors.transparent),
      );

  _buildEmptyCard() {
    return Container(
      color: Colors.white,
      child: Center(
        child: GestureDetector(
          onTap: () {
            controller.onInit();
            controller.update(['charts']);
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),
              Text(
                "暂无数据",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "刷新",
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIJudgeBubble() {
    return Obx(() {
      // === 状态 1：已经有内容了，显示气泡 (你之前的代码) ===
      if (controller.judgeString.value.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                      topLeft: Radius.circular(2.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("本周分析",
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text(controller.judgeString.value,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // === 状态 2：正在请求中，显示 Loading ===
      if (controller.isAnalyzing.value) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black)),
              SizedBox(width: 8.w),
              Text("AI 正在分析本周数据...",
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
            ],
          ),
        );
      }

      // === 状态 3 (默认)：没内容也没点过，显示“召唤 AI”按钮 ===
      return Container(
        margin: EdgeInsets.only(bottom: 24.h),
        alignment: Alignment.center, // 居中显示按钮
        child: TextButton.icon(
          onPressed: () => controller.judgeActivity(), // 点击触发接口
          style: TextButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.08),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r)),
          ),
          // 加个漂亮的 AI 图标
          icon: Icon(Icons.auto_awesome, size: 16.sp, color: Colors.black),
          label: Text(
            "生成本周 AI 总结",
            style: TextStyle(
                color: Colors.black,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
      );
    });
  }
}
