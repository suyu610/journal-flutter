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
        if (dailyData.isEmpty) return const SizedBox.shrink();

        final maxVal = _calculateMaxYAxis(dailyData);
        if (maxVal <= 0) return const SizedBox.shrink();

        // 获取开关状态
        final bool showLabels = controller.trendShowLabels.value;

        return ChartCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题与开关
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
              // 图表主体
              AspectRatio(
                aspectRatio: 1.70,
                child: LineChart(
                  _mainData(dailyData, maxVal, appColors, showLabels),
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

  // 构建图表核心数据配置
  LineChartData _mainData(List<dynamic> data, double maxVal,
      AppThemeColors appColors, bool showLabels) {
    final budgetColor = (appColors.dangerColor).withOpacity(0.5);
    final mainColor = appColors.chartPalette.isNotEmpty
        ? appColors.chartPalette[0]
        : appColors.primaryText;

    // 1. 定义消费曲线的数据 (为了后面引用，先提取出来)
    final consumptionLineBarData = LineChartBarData(
      spots: data.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value.doubleValue);
      }).toList(),
      isCurved: true,
      curveSmoothness: 0.3,
      color: mainColor,
      barWidth: 3,
      isStrokeCapRound: true,

      // === 关键修改：空心点配置 ===
      dotData: FlDotData(
        show: true, // 始终显示点
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: showLabels ? 2 : 0, // 点的大小
            color: appColors.cardBackground, // 核心：内部颜色=背景色=空心效果
            strokeWidth: showLabels ? 2.5 : 0, // 边框粗细
            strokeColor: mainColor, // 边框颜色
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

    // 2. 生成强制显示的 Tooltip 指示器 (当开关打开时)
    List<ShowingTooltipIndicators> showingTooltipIndicators = [];
    if (showLabels) {
      showingTooltipIndicators = data.asMap().entries.map((entry) {
        return ShowingTooltipIndicators([
          LineBarSpot(
            consumptionLineBarData,
            1,
            consumptionLineBarData.spots[entry.key],
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
              if (index >= 0 && index < data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data[index].name,
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
      maxX: (data.length - 1).toDouble(),
      minY: 0,
      maxY: maxVal,
      showingTooltipIndicators: showingTooltipIndicators,
      lineTouchData: LineTouchData(
        // 如果开启了显示标签，禁用触摸交互，避免冲突（或者你可以保留，看需求）
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
              const FlDotData(show: false), // 触摸时不额外画大圆点了，因为我们有点了
            );
          }).toList();
        },

        touchTooltipData: LineTouchTooltipData(
          // 技巧：如果开关打开，背景透明；如果开关关闭(手按)，背景深色
          getTooltipColor: (_) => showLabels
              ? Colors.transparent
              : appColors.primaryText.withOpacity(0.9),

          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          // 调整 margin 让文字离点近一点
          tooltipMargin: showLabels ? 2 : 16,

          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              if (barSpot.barIndex == 0) return null;

              final textColor =
                  showLabels ? appColors.primaryText : appColors.cardBackground;

              return LineTooltipItem(
                '¥${flSpot.y.toStringAsFixed(1)}', // 这里的 1 可以改为 0 去掉小数位
                TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceCodePro', // 保持数字字体风格
                  fontSize: 12.sp,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        // A. 预算线 (index 0)
        LineChartBarData(
          spots: List.generate(data.length, (index) {
            return FlSpot(index.toDouble(), controller.dailyBudgetValue);
          }),
          isCurved: false,
          color: budgetColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dashArray: [5, 5],
          dotData: const FlDotData(show: false),
        ),

        // B. 消费线 (index 1) - 使用上面定义好的变量
        consumptionLineBarData,
      ],
    );
  }

  // 辅助方法保持不变...
  double _calculateMaxYAxis(List<dynamic> data) {
    if (data.isEmpty) return 0;
    double maxDataVal =
        data.map((e) => e.doubleValue).reduce((a, b) => a > b ? a : b);
    double maxVal = maxDataVal > controller.dailyBudgetValue
        ? maxDataVal
        : controller.dailyBudgetValue;
    if (maxVal == 0) return 100;
    return maxVal * 1.2;
  }
}
