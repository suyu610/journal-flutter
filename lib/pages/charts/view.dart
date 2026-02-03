import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/lab/receipt/receipt_card.dart';

import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

/// 数据模型
class ChartDataModel {
  String? value;
  String name;

  ChartDataModel(this.value, this.name);

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(json['value']?.toString(), json['name']);
  }

  // 辅助方法：安全获取数值
  double get doubleValue => double.tryParse(value ?? '0') ?? 0.0;
}

class ChartsPage extends GetView<ChartsController> {
  const ChartsPage({super.key});

  // 定义图表颜色盘 (BlueGrey 系列)
  static final List<Color> _chartPalette = [
    Colors.blueGrey[900]!,
    Colors.blueGrey[700]!,
    Colors.blueGrey[500]!,
    Colors.blueGrey[300]!,
    Colors.blueGrey[100]!,
  ];

  @override
  Widget build(BuildContext context) {
    // 使用 GlobalKey 保持引用
    final GlobalKey actionKey = GlobalKey();

    return GetBuilder<ChartsController>(
      init: ChartsController(),
      id: "charts",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          appBar: _buildNavBar(context, actionKey),
          body: SafeArea(
            child: _shouldShowEmptyState()
                ? _buildEmptyState()
                : _buildMainContent(context),
          ),
        );
      },
    );
  }

  // 判断是否显示空状态
  bool _shouldShowEmptyState() {
    return controller.charts.isEmpty || controller.groupByTypeCharts.isEmpty;
  }

  // 主内容区域
  Widget _buildMainContent(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAIAnalysisSection(), // AI 分析气泡
            _buildTrendChartSection(context), // 趋势折线图
            SizedBox(height: 24.h),
            _buildCategoryChartSection(context), // 分类饼图
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. AI 分析模块
  // ==========================================
  Widget _buildAIAnalysisSection() {
    return Obx(() {
      // 场景 A: 分析完成，显示结果
      if (controller.judgeString.value.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                        fontSize: 14, color: Colors.black87, height: 1.5)),
              ],
            ),
          ),
        );
      }

      // 场景 B: 分析中
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

      // 场景 C: 初始状态，显示按钮
      return Container(
        margin: EdgeInsets.only(bottom: 24.h),
        alignment: Alignment.center,
        child: TextButton.icon(
          onPressed: () => controller.judgeActivity(),
          style: TextButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.08),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r)),
          ),
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

  // ==========================================
  // 2. 消费趋势图 (折线图) 模块
  // ==========================================
  Widget _buildTrendChartSection(BuildContext context) {
    final dailyData = controller.charts;
    final maxVal = _calculateMaxYAxis(dailyData);

    // 如果数据都为0，则不展示
    if (maxVal <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "最近7天消费",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        SizedBox(height: 14.h),
        Container(
          color: Colors.white,
          // 移除 padding，让图表更舒展，或者保留看设计需求
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: BrnBrokenLine(
            size: Size(300.w, MediaQuery.of(context).size.height / 5),
            lines: [
              // 实际消费线
              BrnPointsLine(
                isShowPointText: false,
                lineWidth: 2,
                pointRadius: 3,
                isShowPoint: true,
                isCurve: true,
                points: _generateTrendPoints(dailyData),
                shaderColors: [
                  _chartPalette[2].withAlpha(50),
                  _chartPalette[2].withAlpha(10)
                ],
                lineColor: _chartPalette[0].withOpacity(.8),
              ),
              // 预算参考线 (如果有预算)
              if (controller.dailyBudgetValue > 0)
                BrnPointsLine(
                  isShowPointText: false,
                  lineWidth: 1.5,
                  pointRadius: 0,
                  isShowPoint: false,
                  isCurve: false,
                  points: _generateBudgetPoints(dailyData.length),
                  shaderColors: [Colors.transparent, Colors.transparent],
                  lineColor: Colors.redAccent.withOpacity(0.8),
                ),
            ],
            // 坐标轴配置
            yHintLineOffset: 20,
            hintLineColor: Colors.grey[300],
            isShowXHintLine: true,
            xyDialLineWidth: .1,
            showPointDashLine: true,
            isTipWindowAutoDismiss: true,
            isHintLineSolid: false,
            isShowYDialText: true,
            // 刻度计算
            xDialValues: _generateXAxisLabels(dailyData),
            xDialMin: 0,
            xDialMax: dailyData.length.toDouble(),
            yDialValues: _generateYAxisLabels(dailyData),
            yDialMin: 0,
            yDialMax: maxVal,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. 消费分类图 (甜甜圈图) 模块
  // ==========================================
  Widget _buildCategoryChartSection(BuildContext context) {
    final groupData = controller.groupByTypeCharts;
    if (groupData.isEmpty) return const SizedBox.shrink();

    // 计算总额用于百分比
    final totalValue =
        groupData.fold(0.0, (prev, curr) => prev + curr.doubleValue);

    return Column(
      children: [
        // 标题栏 + 开关
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "消费分类",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            BrnSwitchButton(
              size: const Size(40, 24),
              borderColor: Colors.grey[300]!,
              value: controller.showTitleWhenSelected.value,
              onChanged: (v) => controller.swtichShowTitleWhenSelected(),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        // 饼图本体
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: BrnDoughnutChart(
            height: MediaQuery.of(context).size.height / 4.3,
            ringWidth: 50,
            selectedItem: controller.selectedItem.value,
            selectCallback: (selectedItem) {
              controller.selectItem(selectedItem);
            },
            showTitleWhenSelected: !controller.showTitleWhenSelected.value,
            data: groupData.map((item) {
              final index = groupData.indexOf(item);
              return BrnDoughnutDataItem(
                color: _chartPalette[index % _chartPalette.length],
                value: totalValue == 0 ? 0 : item.doubleValue / totalValue,
                title: "${item.name} ¥${item.value ?? "0"}",
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. 辅助方法 & 数据处理
  // ==========================================

  // 生成折线图数据点
  List<BrnPointData> _generateTrendPoints(List<ChartDataModel> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BrnPointData(
        pointText: item.value,
        x: index.toDouble(),
        y: item.doubleValue,
        lineTouchData: BrnLineTouchData(
          tipWindowSize: const Size(60, 40),
          onTouch: () => item.value,
        ),
      );
    }).toList();
  }

  // 生成预算线数据点
  List<BrnPointData> _generateBudgetPoints(int count) {
    return List.generate(count, (index) {
      return BrnPointData(
        pointText: "",
        x: index.toDouble(),
        y: controller.dailyBudgetValue,
        lineTouchData: BrnLineTouchData(
          onTouch: () => "预算: ${controller.dailyBudgetValue}",
          tipWindowSize: const Size(80, 40),
        ),
      );
    });
  }

  // 生成X轴标签
  List<BrnDialItem> _generateXAxisLabels(List<ChartDataModel> data) {
    return data.asMap().entries.map((entry) {
      return BrnDialItem(
        dialText: entry.value.name,
        dialTextStyle:
            const TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
        value: entry.key.toDouble(),
      );
    }).toList();
  }

  // 计算Y轴刻度 (0到最大值分10份)
  List<BrnDialItem> _generateYAxisLabels(List<ChartDataModel> data) {
    double minVal = 0; // 消费图表通常Y轴从0开始比较直观
    double maxVal = _calculateMaxYAxis(data);
    double step = maxVal / 5; // 分5档或者10档

    // 避免除以0
    if (step == 0) step = 100;

    List<BrnDialItem> yDialValues = [];
    for (int i = 0; i <= 5; i++) {
      double val = minVal + i * step;
      yDialValues.add(BrnDialItem(
        dialText: '${val.ceil()}',
        dialTextStyle:
            const TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
        value: val,
      ));
    }
    return yDialValues;
  }

  // 计算Y轴最大值 (包含预算逻辑)
  double _calculateMaxYAxis(List<ChartDataModel> data) {
    if (data.isEmpty) return 100;

    // 获取数据中的最大值
    double maxDataVal = data
        .map((e) => e.doubleValue)
        .fold(0.0, (prev, curr) => max(prev, curr));

    // 如果预算更高，就用预算作为基准，并留出 20% 的顶部空间
    double targetMax = max(maxDataVal, controller.dailyBudgetValue);

    return targetMax == 0 ? 100 : targetMax * 1.2;
  }

  // ==========================================
  // 5. 顶部导航栏 & 空状态
  // ==========================================

  PreferredSizeWidget _buildNavBar(BuildContext context, GlobalKey key) {
    return TDNavBar(
      useBorderStyle: true,
      height: 48,
      useDefaultBack: false,
      leftBarItems: [
        TDNavBarItem(
          iconWidget: controller.allActivityList.isEmpty
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 10),
                  child: BrnTextAction(
                    controller.currentActivity.value.activityName,
                    key: key,
                    iconPressed: () {
                      _showActivityPicker(context, key);
                    },
                  ),
                ),
        )
      ],
      rightBarItems: [
        TDNavBarItem(
            icon: Icons.print_outlined,
            action: () async {
              TDToast.showLoading(context: context);

              /// 展示电子小票弹窗
              List<Expense> expenseItems =
                  await controller.getTodayExpenseItemList() ?? [];
              if (expenseItems.isEmpty) {
                if (context.mounted) {
                  TDToast.dismissAll();
                  TDToast.showFail("暂无数据", context: context);
                }
                return;
              }
              TDToast.dismissAll();

              List<String> nicknameList = expenseItems
                  .map((e) => e.userNickname ?? '')
                  .toSet()
                  .toList();
              Get.dialog(Material(
                type: MaterialType.transparency,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // === 直接使用封装好的打印动画 ===
                        PrintingReceiptAnim(
                          onPrintFinished: () {
                            // 可选：在这里调用震动反馈
                            // HapticFeedback.mediumImpact();
                          },
                          child: ReceiptCard(
                            nickname: nicknameList.join(' | '),
                            budget: controller.dailyBudgetValue,
                            items: expenseItems,

                            // yyyy-mm-dd
                            date: DateTime.now().toString().substring(0, 10),
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // 关闭按钮
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.cancel,
                              color: Colors.white, size: 36),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
              // 2. 呼出弹窗
            })
      ],
      border: TDNavBarItemBorder(width: 0, color: Colors.transparent),
    );
  }

  // 显示活动选择弹窗
  void _showActivityPicker(BuildContext context, GlobalKey key) {
    BrnPopupListWindow.showPopListWindow(
      context,
      key,
      offset: 10,
      data: controller.allActivityList.isEmpty
          ? ["加载中"]
          : controller.allActivityList.map((e) => e.activityName).toList(),
      onItemClick: (index, name) {
        if (controller.allActivityList.isNotEmpty) {
          controller.currentActivity.value = controller.allActivityList[index];
          controller.onInit();
          controller.update(['charts']);
        }
        Get.back();
        return true; // 返回true自动关闭
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: GestureDetector(
          onTap: () {
            controller.onInit();
            controller.update(['charts']);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("暂无数据",
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
              SizedBox(height: 8.h),
              Text("点击刷新",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
