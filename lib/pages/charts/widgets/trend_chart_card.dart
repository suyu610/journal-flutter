import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/app_theme_colors.dart';
import '../controller.dart';
import 'chart_card_container.dart';

class TrendChartCard extends GetView<ChartsController> {
  const TrendChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 获取主题配置
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

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
              Text(
                "最近 7 天消费",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: appColors.primaryText, // 适配标题色
                ),
              ),
              BrnBrokenLine(
                xDialMax: dailyData.length.toDouble(),
                xDialMin: 0,
                yDialMin: 0,
                yDialMax: maxVal,
                size: Size(330.w, 180.h),
                yDialValues: _generateYAxisLabels(dailyData, maxVal),
                xDialValues: _generateXAxisLabels(dailyData, appColors),
                isShowYDialText: false,
                lines: [
                  // 1. 实际消费曲线
                  _buildLineData(dailyData, appColors),
                  // 2. 预算参考线 (修复：加回此逻辑)
                  _buildBudgetLine(dailyData, appColors),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // 构建消费曲线 (实线，深色)
  BrnPointsLine _buildLineData(
      List<ChartDataModel> data, AppThemeColors appColors) {
    return BrnPointsLine(
      // 使用主题色盘的主色
      lineColor: appColors.chartPalette[0],
      points: data.map((e) {
        return BrnPointData(
          x: data.indexOf(e).toDouble(),
          y: e.doubleValue,
          lineTouchData: BrnLineTouchData(
            onTouch: () =>
                "${e.name}\n${e.doubleValue.toStringAsFixed(0)}", // 显示日期+金额
            tipWindowSize: const Size(60, 40),
          ),
        );
      }).toList(),
      isShowPointText: false,
    );
  }

  // 构建预算线 (建议做成淡色或虚线)
  BrnPointsLine _buildBudgetLine(
      List<ChartDataModel> data, AppThemeColors appColors) {
    return BrnPointsLine(
      // 使用次要颜色的低透明度，防止喧宾夺主，同时适配深色模式
      lineColor: appColors.secondaryText.withOpacity(0.4),
      // 如果 Bruno 支持 isDash: true 最好，不支持则靠颜色区分
      points: List.generate(data.length, (index) {
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
      }),
      isShowPointText: false,
    );
  }

  // 生成 X 轴标签
  List<BrnDialItem> _generateXAxisLabels(
      List<ChartDataModel> data, AppThemeColors appColors) {
    return data.asMap().entries.map((entry) {
      return BrnDialItem(
        dialText: entry.value.name,
        dialTextStyle: TextStyle(
          fontSize: 10.sp,
          color: appColors.secondaryText, // 适配轴文字颜色
        ),
        value: entry.key.toDouble(),
      );
    }).toList();
  }

  // 生成 Y 轴刻度
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
    if (data.isEmpty) return 0;
    // 同时也考虑预算值，防止预算很高但消费很低时，预算线画在图表外面
    double maxDataVal =
        data.map((e) => e.doubleValue).reduce((a, b) => a > b ? a : b);
    double maxVal = maxDataVal > controller.dailyBudgetValue
        ? maxDataVal
        : controller.dailyBudgetValue;

    return maxVal * 1.2; // 留出 20% 顶部空间
  }
}
