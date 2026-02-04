import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/config/theme_config.dart';

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

  // 优化后的配色：保留 BlueGrey 基调，但增加一点层次
  static final List<Color> _chartPalette = [
    const Color(0xFF263238), // BlueGrey 900
    const Color(0xFF455A64), // BlueGrey 700
    const Color(0xFF607D8B), // BlueGrey 500
    const Color(0xFF90A4AE), // BlueGrey 300
    const Color(0xFFCFD8DC), // BlueGrey 100
  ];

  @override
  Widget build(BuildContext context) {
    final GlobalKey actionKey = GlobalKey();

    return GetBuilder<ChartsController>(
      init: ChartsController(),
      id: "charts",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          backgroundColor: backgroundColor,
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

  bool _shouldShowEmptyState() {
    return controller.charts.isEmpty || controller.groupByTypeCharts.isEmpty;
  }

  // 主内容区域
  Widget _buildMainContent(BuildContext context) {
    return Container(
      color: backgroundColor,
      // 增加整体左右间距，让卡片不要贴边
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SizedBox(
                height: controller.judgeString.value.isEmpty ? 0.h : 16.h)),
            _buildAIAnalysisSection(), // AI 分析
            Obx(() => SizedBox(
                height: controller.judgeString.value.isEmpty ? 0.h : 16.h)),
            _buildTrendChartCard(context), // 趋势图卡片
            SizedBox(height: 16.h),
            _buildCategoryChartCard(context), // 分类图卡片
            SizedBox(height: 30.h), // 底部留白
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 通用卡片容器 (关键修改)
  // ==========================================
  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r), // 更圆润的圆角
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // 极淡的阴影
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: child,
    );
  }

  // ==========================================
  // 1. AI 分析模块 (美化版)
  // ==========================================
  Widget _buildAIAnalysisSection() {
    return Obx(() {
      if (controller.judgeString.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            // 使用渐变色或柔和的强调色背景
            gradient: LinearGradient(
              colors: [Colors.blueGrey[50]!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.blueGrey[100]!, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16.sp, color: Colors.amber),
                  SizedBox(width: 8.w),
                  Text(
                    "本周 AI 洞察",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blueGrey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                controller.judgeString.value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  height: 1.6, // 增加行高，提升阅读体验
                ),
              ),
            ],
          ),
        );
      }

      if (controller.isAnalyzing.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.blueGrey),
                ),
                SizedBox(width: 12.w),
                Text("AI 正在分析本周数据...",
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
              ],
            ),
          ),
        );
      }
      return const SizedBox();
    });
  }

  // ==========================================
  // 2. 消费趋势图卡片
  // ==========================================
  Widget _buildTrendChartCard(BuildContext context) {
    final dailyData = controller.charts;
    final maxVal = _calculateMaxYAxis(dailyData);
    if (maxVal <= 0) return const SizedBox.shrink();

    // 使用 _buildCard 包裹
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题现在在卡片内部
          Text(
            "最近 7 天消费",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 24.h), // 增加图表与标题的间距
          BrnBrokenLine(
            size: Size(300.w, MediaQuery.of(context).size.height / 5),
            lines: [
              BrnPointsLine(
                isShowPointText: false,
                lineWidth: 2.5, // 稍微加粗线条
                pointRadius: 4,
                isShowPoint: true,
                isCurve: true,
                points: _generateTrendPoints(dailyData),
                shaderColors: [
                  _chartPalette[2].withOpacity(0.3), // 调整透明度更柔和
                  _chartPalette[2].withOpacity(0.01)
                ],
                lineColor: _chartPalette[0], // 使用最深的颜色作为线颜色
              ),
              if (controller.dailyBudgetValue > 0)
                BrnPointsLine(
                  isShowPointText: false,
                  lineWidth: 1,
                  pointRadius: 0,
                  isShowPoint: false,
                  isCurve: false,
                  points: _generateBudgetPoints(dailyData.length),
                  shaderColors: [Colors.transparent, Colors.transparent],
                  lineColor: Colors.redAccent.withOpacity(0.5), // 预算线淡一点
                  // isDash: true, // 预算线改为虚线更直观（如果Bruno支持的话，不支持则保持实线）
                ),
            ],
            yHintLineOffset: 30, // 调整 Y 轴文字间距
            hintLineColor: const Color(0xFFEEEEEE), // 辅助线更淡
            isShowXHintLine: true,
            xyDialLineWidth: 0, // 隐藏坐标轴实线，只保留网格
            showPointDashLine: true,
            isTipWindowAutoDismiss: true,
            isHintLineSolid: false,
            isShowYDialText: true,
            xDialValues: _generateXAxisLabels(dailyData),
            xDialMin: 0,
            xDialMax: dailyData.length.toDouble(),
            yDialValues: _generateYAxisLabels(dailyData),
            yDialMin: 0,
            yDialMax: maxVal,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. 消费分类图卡片
  // ==========================================
  Widget _buildCategoryChartCard(BuildContext context) {
    final groupData = controller.groupByTypeCharts;
    if (groupData.isEmpty) return const SizedBox.shrink();

    final totalValue =
        groupData.fold(0.0, (prev, curr) => prev + curr.doubleValue);

    return _buildCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "消费分类",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Colors.black87,
                ),
              ),
              // 开关稍微缩小一点
              Transform.scale(
                scale: 0.9,
                child: BrnSwitchButton(
                  size: const Size(42, 24),
                  borderColor: Colors.grey[200]!,
                  value: controller.showTitleWhenSelected.value,
                  onChanged: (v) => controller.swtichShowTitleWhenSelected(),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            width: double.infinity,
            color: Colors.white,
            child: BrnDoughnutChart(
              height: MediaQuery.of(context).size.height / 4.3,
              ringWidth: 40,
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
                  title: "${item.name}\n¥${item.value ?? "0"}", // 换行显示金额
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // 4. 数据处理逻辑 (保持原逻辑不变，微调样式)
  // ==========================================

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

  List<BrnPointData> _generateBudgetPoints(int count) {
    return List.generate(count, (index) {
      return BrnPointData(
        pointText: "",
        x: index.toDouble(),
        y: controller.dailyBudgetValue,
        lineTouchData: BrnLineTouchData(
          onTouch: () => "预算\n${controller.dailyBudgetValue}",
          tipWindowSize: const Size(80, 50),
        ),
      );
    });
  }

  List<BrnDialItem> _generateXAxisLabels(List<ChartDataModel> data) {
    return data.asMap().entries.map((entry) {
      return BrnDialItem(
        dialText: entry.value.name,
        dialTextStyle: TextStyle(
          fontSize: 10.sp, // 稍微调小字体
          color: const Color(0xFF9E9E9E),
        ),
        value: entry.key.toDouble(),
      );
    }).toList();
  }

  List<BrnDialItem> _generateYAxisLabels(List<ChartDataModel> data) {
    double minVal = 0;
    double maxVal = _calculateMaxYAxis(data);
    double step = maxVal / 5;
    if (step == 0) step = 100;

    List<BrnDialItem> yDialValues = [];
    for (int i = 0; i <= 5; i++) {
      double val = minVal + i * step;
      yDialValues.add(BrnDialItem(
        dialText: '${val.ceil()}',
        dialTextStyle: TextStyle(
          fontSize: 10.sp,
          color: const Color(0xFFCFD8DC), // Y轴文字颜色更淡，减少视觉干扰
        ),
        value: val,
      ));
    }
    return yDialValues;
  }

  double _calculateMaxYAxis(List<ChartDataModel> data) {
    if (data.isEmpty) return 100;
    double maxDataVal = data
        .map((e) => e.doubleValue)
        .fold(0.0, (prev, curr) => max(prev, curr));
    double targetMax = max(maxDataVal, controller.dailyBudgetValue);
    return targetMax == 0 ? 100 : targetMax * 1.2;
  }

  // ==========================================
  // 5. 导航栏 & 其他
  // ==========================================

  PreferredSizeWidget _buildNavBar(BuildContext context, GlobalKey key) {
    return TDNavBar(
      useBorderStyle: false,
      backgroundColor: backgroundColor,
      height: 48,
      useDefaultBack: false,
      leftBarItems: [
        TDNavBarItem(
            iconWidget: controller.allActivityList.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 10),
                    child: GestureDetector(
                      key: key,
                      onTap: () => _showActivityPicker(context, key),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.currentActivity.value.activityName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              size: 20.sp, color: Colors.black),
                        ],
                      ),
                    ),
                  ))
      ],
      rightBarItems: [
        TDNavBarItem(
          icon: Icons.auto_awesome_outlined,
          iconColor: Colors.black87,
          padding: EdgeInsets.only(right: 12.w),
          action: () => controller.judgeActivity(),
        ),
        TDNavBarItem(
          icon: Icons.print_outlined,
          iconColor: Colors.black87,
          action: () async {
            controller.handlePrintAction(context);
          },
        )
      ],
    );
  }

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
        return true;
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: backgroundColor,
      child: Center(
        child: GestureDetector(
          onTap: () {
            controller.onInit();
            controller.update(['charts']);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart_rounded,
                  size: 60.sp, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text("暂无数据",
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
              SizedBox(height: 8.h),
              Text("点击屏幕刷新",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
