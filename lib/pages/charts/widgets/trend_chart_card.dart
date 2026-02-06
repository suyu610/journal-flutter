import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import '../controller.dart';
import '../view.dart'; // 引用 DataModel
import 'chart_card_container.dart';

class TrendChartCard extends GetView<ChartsController> {
  // 配色方案也可以抽离到 config，这里暂时保留在组件内
  static final List<Color> _chartPalette = [
    const Color(0xFF263238),
    const Color(0xFF607D8B),
    const Color(0xFFCFD8DC),
  ];

  const TrendChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 监听数据变化
    return GetBuilder<ChartsController>(
      id: "charts",
      builder: (_) {
        final dailyData = controller.charts;
        if (dailyData.isEmpty) return const SizedBox.shrink();

        final maxVal = _calculateMaxYAxis(dailyData);
        if (maxVal <= 0) return const SizedBox.shrink();

        return ChartCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "最近 7 天消费",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              BrnBrokenLine(
                size: Size(330.w, MediaQuery.of(context).size.height / 5),
                lines: [
                  BrnPointsLine(
                    isShowPointText: false,
                    lineWidth: 2.5,
                    pointRadius: 4,
                    isShowPoint: false,
                    isCurve: false,
                    points: _generateTrendPoints(dailyData),
                    shaderColors: [
                      _chartPalette[1].withOpacity(0.3),
                      _chartPalette[1].withOpacity(0.01)
                    ],
                    lineColor: _chartPalette[0],
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
                      lineColor: Colors.redAccent.withOpacity(1),
                    ),
                ],
                isShowYHintLine: false,
                yHintLineOffset: 0,
                hintLineColor: const Color(0xFFEEEEEE),
                isShowXHintLine: true,
                xyDialLineWidth: 0,
                xDialColor: Colors.blueGrey[400],
                showPointDashLine: false,
                isTipWindowAutoDismiss: true,
                isHintLineSolid: false,
                isShowYDialText: false,
                xDialValues: _generateXAxisLabels(dailyData),
                xDialMin: 0,
                xDialMax: dailyData.length.toDouble(),
                yDialValues: _generateYAxisLabels(dailyData, maxVal),
                yDialMin: 0,
                yDialMax: maxVal,
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 私有辅助方法 (从 View 中移入) ---

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
          onTouch: () =>
              "预算\n${controller.dailyBudgetValue.toStringAsFixed(0)}",
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
          fontSize: 10.sp,
          color: const Color(0xFF9E9E9E),
        ),
        value: entry.key.toDouble(),
      );
    }).toList();
  }

  List<BrnDialItem> _generateYAxisLabels(
      List<ChartDataModel> data, double maxVal) {
    double minVal = 0;
    double step = maxVal / 5;
    if (step == 0) step = 100;

    List<BrnDialItem> yDialValues = [];
    for (int i = 0; i <= 5; i++) {
      double val = minVal + i * step;
      yDialValues.add(BrnDialItem(
        dialText: '${val.ceil()}',
        dialTextStyle: const TextStyle(color: Colors.transparent),
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
}
