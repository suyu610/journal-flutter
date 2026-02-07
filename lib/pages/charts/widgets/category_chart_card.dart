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

        // 获取当前选中的数据对象（如果没选中则为 null）
        ChartDataModel? selectedItem;
        if (touchedIndex != -1 && touchedIndex < groupData.length) {
          selectedItem = groupData[touchedIndex];
        }

        return ChartCardContainer(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "本周消费分类",
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
                            if (event is FlTapUpEvent &&
                                pieTouchResponse != null &&
                                pieTouchResponse.touchedSection != null) {
                              final newIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;

                              setState(() {
                                if (touchedIndex == newIndex) {
                                  touchedIndex = -1;
                                } else {
                                  touchedIndex = newIndex;
                                  // 拿到当前的type
                                  final typeName = groupData[newIndex].name;
                                  // 滚动到对应的位置
                                  controller.loadExpenseList(typeName);
                                }
                              });
                            }
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
                    _buildCenterInfo(totalValue, selectedItem, appColors),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // 3. 底部图例列表 (Legend)
              _buildLegendList(groupData, totalValue, appColors),
              // 4. (新) 账单明细列表区域
              // 使用 AnimatedSize 让展开收起更丝滑
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.topCenter,
                curve: Curves.easeInOut,
                child: selectedItem != null
                    ? _buildDetailList(selectedItem, appColors)
                    : const SizedBox.shrink(), // 没选中时不占位
              ),
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

  // --- 构建明细列表 (核心需求) ---
  Widget _buildDetailList(ChartDataModel item, AppThemeColors appColors) {
    ChartsController controller = Get.find();
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: appColors.secondaryText.withOpacity(0.05), // 浅灰色背景
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 列表头：比如 "餐饮美食 的支出明细"
          Row(
            children: [
              Icon(Icons.list_alt_rounded,
                  size: 16.sp, color: appColors.secondaryText),
              SizedBox(width: 6.w),
              Text(
                "${item.name} 明细",
                style: TextStyle(
                    fontSize: 12.sp,
                    color: appColors.secondaryText,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(
              height: 16.h,
              thickness: 0.5,
              color: appColors.secondaryText.withOpacity(0.2)),

          // 遍历明细
          if (controller.expenseList.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Center(
                  child: Text("暂无明细",
                      style: TextStyle(
                          fontSize: 12.sp, color: appColors.secondaryText))),
            )
          else
            ListView.separated(
              physics:
                  const NeverScrollableScrollPhysics(), // 嵌套在Column里，禁止自身滚动
              shrinkWrap: true, // 根据内容高度自适应
              itemCount: controller.expenseList.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final detail = controller.expenseList[index];
                return Row(
                  children: [
                    // 日期
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        detail.expenseTime.substring(5, 16),
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: appColors.secondaryText,
                            fontFamily: 'SourceCodePro'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // 备注
                    Expanded(
                      child: Text(
                        detail.label,
                        style: TextStyle(
                            fontSize: 13.sp, color: appColors.primaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 金额
                    Text(
                      detail.positive == 0
                          ? "-${detail.price.toStringAsFixed(1)}"
                          : "+${detail.price.toStringAsFixed(1)}", // 加上负号
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: appColors.primaryText,
                        fontFamily: 'SourceCodePro',
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // 3. 底部图例列表 (支持按金额排序 + 保持与饼图联动)
  Widget _buildLegendList(
    List<ChartDataModel> data,
    double totalValue,
    AppThemeColors appColors,
  ) {
    ChartsController controller = Get.find<ChartsController>();
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
              onTap: () {
                setState(() {
                  if (touchedIndex == originalIndex) {
                    touchedIndex = -1; // 再次点击取消
                  } else {
                    touchedIndex = originalIndex;
                    final typeName = item.name;
                    // 滚动到对应的位置
                    controller.loadExpenseList(typeName);
                    // Future.delayed(const Duration(milliseconds: 300), () {
                    //   controller.scrollController.animateTo(
                    //     // 当前位置+100，确保能看到当前项
                    //     controller.scrollController.position.pixels + 100,
                    //     duration: const Duration(milliseconds: 300),
                    //     curve: Curves.easeInOut,
                    //   );
                    // });
                  }
                });
              },
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
  // 中间文字
  Widget _buildCenterInfo(double totalValue, ChartDataModel? selectedItem,
      AppThemeColors appColors) {
    String label = selectedItem?.name ?? "总支出";
    String valueStr = selectedItem?.doubleValue.toStringAsFixed(0) ??
        totalValue.toStringAsFixed(0);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Column(
        key: ValueKey(label), // Key 变化触发动画
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: appColors.secondaryText)),
          SizedBox(height: 4.h),
          Text(valueStr,
              style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceCodePro',
                  color: appColors.primaryText)),
        ],
      ),
    );
  }
}
