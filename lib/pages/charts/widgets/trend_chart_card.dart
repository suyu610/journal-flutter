import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_switch.dart';
import 'package:journal/core/app_theme_colors.dart';
import '../controller.dart';
import 'chart_card_container.dart';

class TrendChartCard extends GetView<ChartsController> {
  const TrendChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<ChartsController>(
      id: "charts",
      builder: (_) {
        final dailyData = controller.charts;
        // 1. 获取上周数据
        final lastWeekData = controller.lastWeekCharts;

        if (dailyData.isEmpty) return const SizedBox.shrink();

        // 2. 计算最大值时，同时考虑两组数据
        final maxVal = _calculateMaxYAxis(dailyData, lastWeekData);
        if (maxVal <= 0) return const SizedBox.shrink();

        final bool showLabels = controller.trendShowLabels.value;

        return ChartCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "最近 7 天消费",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: appColors.primaryText,
                    ),
                  ),
                  JournalSwitch(
                    value: controller.trendShowLabels.value,
                    onChanged: (v) => controller.switchTrendShowLabels(),
                    height: 20,
                    width: 40,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 1.70,
                child: LineChart(
                  // 3. 传入两组数据
                  _mainData(
                      dailyData, lastWeekData, maxVal, appColors, showLabels),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  LineChartData _mainData(
      List<dynamic> currentData,
      List<dynamic> lastWeekData, // 新增参数
      double maxVal,
      AppThemeColors appColors,
      bool showLabels) {
    final budgetColor = (appColors.dangerColor).withOpacity(0.5);
    final mainColor = appColors.chartPalette.isNotEmpty
        ? appColors.chartPalette[0]
        : appColors.primaryText;

    // 上周数据的颜色（灰色，低调显示）
    final lastWeekColor = appColors.secondaryText.withOpacity(0.4);

    // --- A. 构建本周数据线 (Current Week) ---
    final currentLineBarData = LineChartBarData(
      spots: currentData.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value.doubleValue);
      }).toList(),
      isCurved: true,
      curveSmoothness: 0.3,
      color: mainColor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: showLabels ? 2 : 0,
            color: appColors.cardBackground,
            strokeWidth: showLabels ? 2.5 : 0,
            strokeColor: mainColor,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            mainColor.withOpacity(0.15),
            mainColor.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    // --- B. 构建上周数据线 (Last Week) ---
    LineChartBarData? lastWeekLineBarData;
    if (lastWeekData.isNotEmpty) {
      lastWeekLineBarData = LineChartBarData(
        spots: lastWeekData.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.doubleValue);
        }).toList(),
        isCurved: true,
        curveSmoothness: 0.3,
        color: lastWeekColor, // 灰色
        barWidth: 2, // 稍微细一点
        isStrokeCapRound: true,
        dashArray: [5, 5], // 虚线效果
        dotData: const FlDotData(show: false), // 不显示点，避免喧宾夺主
      );
    }

    // --- C. 构建 LineBars 列表 (注意顺序：底层 -> 顶层) ---
    final List<LineChartBarData> lineBars = [];

    // Index 0: 预算线
    lineBars.add(
      LineChartBarData(
        spots: List.generate(currentData.length, (index) {
          return FlSpot(index.toDouble(), controller.dailyBudgetValue);
        }),
        isCurved: false,
        color: budgetColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dashArray: [5, 5],
        dotData: const FlDotData(show: false),
      ),
    );

    // Index 1: 上周 (如果存在)
    if (lastWeekLineBarData != null) {
      lineBars.add(lastWeekLineBarData);
    }

    // Index 2 (or 1): 本周 (最顶层)
    lineBars.add(currentLineBarData);

    // 动态获取本周数据在列表中的索引，用于 Tooltip 匹配
    final currentWeekIndex = lineBars.indexOf(currentLineBarData);
    final lastWeekIndex = lastWeekLineBarData != null
        ? lineBars.indexOf(lastWeekLineBarData)
        : -1;

    // 生成常驻标签 (仅针对本周数据)
    List<ShowingTooltipIndicators> showingTooltipIndicators = [];
    if (showLabels) {
      showingTooltipIndicators = currentData.asMap().entries.map((entry) {
        return ShowingTooltipIndicators([
          LineBarSpot(
            currentLineBarData,
            currentWeekIndex, // 必须匹配 lineBarsData 中的索引
            currentLineBarData.spots[entry.key],
          ),
        ]);
      }).toList();
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxVal / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: appColors.secondaryText.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < currentData.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    currentData[index].name,
                    style: TextStyle(
                      color: appColors.secondaryText,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (currentData.length - 1).toDouble(),
      minY: 0,
      maxY: maxVal,
      showingTooltipIndicators: showingTooltipIndicators,
      lineTouchData: LineTouchData(
        handleBuiltInTouches: !showLabels,
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: appColors.primaryText.withOpacity(0.2),
                strokeWidth: 2,
                dashArray: [5, 5],
              ),
              const FlDotData(show: false),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => showLabels
              ? Colors.transparent
              : appColors.primaryText.withOpacity(0.9),
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: showLabels ? 2 : 16,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            // 对 Tooltip 排序，让本周的数据显示在前面（或者按 Y 轴大小）
            // 这里我们保持默认顺序 (按 lineBarsData 顺序)

            return touchedBarSpots.map((barSpot) {
              // 1. 忽略预算线
              if (barSpot.barIndex == 0) return null;

              // 2. 判断是本周还是上周
              final isCurrentWeek = barSpot.barIndex == currentWeekIndex;
              final isLastWeek = barSpot.barIndex == lastWeekIndex;

              // 样式配置
              Color textColor;
              String prefix = "";

              if (showLabels) {
                // 如果标签常驻模式，只显示数字，无需前缀，颜色跟随主题
                textColor = appColors.primaryText;
              } else {
                // 触摸模式：白色文字 (背景是深色)
                // 为了区分，可以给上周的数据稍微暗一点的颜色，或者都用 cardBackground
                textColor = appColors.cardBackground;
                if (isLastWeek) {
                  prefix = "上周: ";
                  textColor = appColors.cardBackground.withOpacity(0.7);
                }
                // 本周不加前缀，或者加 "本周:" 也可以，看喜好。
                // 这里保持简洁，不加本周前缀，只加该死的上周前缀区分
              }

              return LineTooltipItem(
                '$prefix¥${barSpot.y.toStringAsFixed(1)}',
                TextStyle(
                  color: textColor,
                  fontWeight:
                      isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'SourceCodePro',
                  fontSize: 12.sp,
                ),
              );
            }).toList();
          },
        ),
      ),
      // 核心：使用组装好的 lineBars
      lineBarsData: lineBars,
    );
  }

  double _calculateMaxYAxis(
      List<dynamic> currentData, List<dynamic> lastWeekData) {
    if (currentData.isEmpty) return 0;

    // 辅助函数：找最大值
    double getMax(List<dynamic> list) {
      if (list.isEmpty) return 0.0;
      return list.map((e) => e.doubleValue).reduce((a, b) => a > b ? a : b);
    }

    double maxCurrent = getMax(currentData);
    double maxLast = getMax(lastWeekData);

    // 取两组数据中最大的那个
    double maxDataVal = maxCurrent > maxLast ? maxCurrent : maxLast;

    double maxVal = maxDataVal > controller.dailyBudgetValue
        ? maxDataVal
        : controller.dailyBudgetValue;

    if (maxVal == 0) return 100;
    return maxVal * 1.2;
  }
}
