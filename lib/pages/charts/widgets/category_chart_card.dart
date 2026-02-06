import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_switch.dart';
import 'package:journal/core/app_theme_colors.dart';
import '../controller.dart';
import 'chart_card_container.dart';

class CategoryChartCard extends StatefulWidget {
  const CategoryChartCard({super.key});

  @override
  State<CategoryChartCard> createState() => _CategoryChartCardState();
}

class _CategoryChartCardState extends State<CategoryChartCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final ChartsController controller = Get.find();

    return GetBuilder<ChartsController>(
      id: "charts",
      builder: (_) {
        final List<ChartDataModel> groupData = controller.groupByTypeCharts;
        if (groupData.isEmpty) return const SizedBox.shrink();

        final totalValue =
            groupData.fold(0.0, (prev, curr) => prev + curr.doubleValue);

        final bool showPercentageOnChart =
            controller.showTitleWhenSelected.value;

        return ChartCardContainer(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "消费分类",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: appColors.primaryText,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8.w),
                      JournalSwitch(
                        value: controller.showTitleWhenSelected.value,
                        onChanged: (v) =>
                            controller.swtichShowTitleWhenSelected(),
                        height: 20,
                        width: 40,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // 2. 图表主体
              SizedBox(
                height: 200.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 55.r,
                        sections: _buildPieSections(
                          groupData,
                          totalValue,
                          appColors,
                          showPercentageOnChart,
                        ),
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    // 中间文字 (总额)
                    _buildCenterInfo(totalValue, appColors),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // 3. 底部图例列表 (Legend)
              _buildLegendList(groupData, totalValue, appColors),
            ],
          ),
        );
      },
    );
  }

  // 构建扇区
  List<PieChartSectionData> _buildPieSections(
    List<ChartDataModel> data,
    double totalValue,
    AppThemeColors appColors,
    bool showPercentageOnChart,
  ) {
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final item = data[i];
      final double value = item.doubleValue;
      final double percentage = totalValue == 0 ? 0 : (value / totalValue);

      final double radius = isTouched ? 70.r : 60.r;
      final color = appColors.chartPalette[i % appColors.chartPalette.length];

      return PieChartSectionData(
        color: color,
        value: value,
        // 如果开关打开，显示百分比；否则不显示任何文字，保持干净
        title: showPercentageOnChart && percentage > 0.04
            ? '${(percentage * 100).toStringAsFixed(0)}%'
            : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14.sp : 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.9),
          fontFamily: 'SourceCodePro',
        ),
        titlePositionPercentageOffset: 0.55,
        badgeWidget: null, // 彻底移除任何外部挂件
      );
    });
  }

  // 3. 底部图例列表 (支持按金额排序 + 保持与饼图联动)
  Widget _buildLegendList(
    List<ChartDataModel> data,
    double totalValue,
    AppThemeColors appColors,
  ) {
    // A. 预处理：生成排序后的索引列表
    // 1. 生成 [0, 1, 2, ... length-1]
    List<int> sortedIndices = List.generate(data.length, (index) => index);

    // 2. 根据金额降序排序 (从大到小)
    sortedIndices.sort((a, b) {
      return data[b].doubleValue.compareTo(data[a].doubleValue);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // 三栏布局计算
        final double itemWidth = (constraints.maxWidth - 24.w) / 3;

        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          // B. 遍历排序后的索引列表
          children: sortedIndices.map((originalIndex) {
            // 通过原始索引去拿数据，确保颜色和点击逻辑与饼图一致
            final item = data[originalIndex];
            final isTouched = originalIndex == touchedIndex;

            // 关键：颜色必须用 originalIndex 取，否则会和饼图颜色对不上
            final color = appColors
                .chartPalette[originalIndex % appColors.chartPalette.length];

            final percentage =
                totalValue == 0 ? 0.0 : (item.doubleValue / totalValue);

            return GestureDetector(
              // 关键：点击时设置的是 originalIndex
              onTapDown: (_) => setState(() => touchedIndex = originalIndex),
              onTapUp: (_) => setState(() => touchedIndex = -1),
              onTapCancel: () => setState(() => touchedIndex = -1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: itemWidth,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                decoration: BoxDecoration(
                    color: isTouched
                        ? color.withOpacity(0.1)
                        : appColors.secondaryText.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: isTouched
                            ? color.withOpacity(0.3)
                            : Colors.transparent,
                        width: 1)),
                child: Row(
                  children: [
                    // 色块
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // 信息区域
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: appColors.primaryText,
                              fontWeight:
                                  isTouched ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "¥${item.doubleValue.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: 'SourceCodePro',
                                    color: appColors.primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                WidgetSpan(child: SizedBox(width: 4.w)),
                                TextSpan(
                                  text:
                                      "${(percentage * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontFamily: 'SourceCodePro',
                                    color: appColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 中间文字只显示总额，不再变来变去，保持稳定
  Widget _buildCenterInfo(double totalValue, AppThemeColors appColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "总支出",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: appColors.secondaryText,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          totalValue.toStringAsFixed(0), // 取整显示，更简洁
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'SourceCodePro',
            color: appColors.primaryText,
          ),
        ),
      ],
    );
  }
}
