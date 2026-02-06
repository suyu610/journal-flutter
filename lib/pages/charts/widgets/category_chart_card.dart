import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/app_theme_colors.dart';
import '../controller.dart';
import 'chart_card_container.dart';

class CategoryChartCard extends GetView<ChartsController> {
  const CategoryChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<ChartsController>(
      id: "charts",
      builder: (_) {
        final groupData = controller.groupByTypeCharts;
        if (groupData.isEmpty) return const SizedBox.shrink();

        final totalValue =
            groupData.fold(0.0, (prev, curr) => prev + curr.doubleValue);

        return ChartCardContainer(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "消费分类",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: appColors.primaryText,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: BrnSwitchButton(
                      size: const Size(42, 24),
                      borderColor: appColors.secondaryText.withOpacity(0.3),
                      // 开启状态的颜色可能需要在 Bruno 内部改，或者这里如果支持 activeColor 就传
                      value: controller.showTitleWhenSelected.value,
                      onChanged: (v) =>
                          controller.swtichShowTitleWhenSelected(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                // color: Colors.white, // 移除硬编码背景
                child: BrnDoughnutChart(
                  height: MediaQuery.of(context).size.height / 4.3,
                  ringWidth: 40,
                  selectedItem: controller.selectedItem.value,
                  selectCallback: (selectedItem) {
                    controller.selectItem(selectedItem);
                  },
                  showTitleWhenSelected:
                      !controller.showTitleWhenSelected.value,
                  data: groupData.map((item) {
                    final index = groupData.indexOf(item);
                    return BrnDoughnutDataItem(
                      // 使用主题色盘循环取色
                      color: appColors
                          .chartPalette[index % appColors.chartPalette.length],
                      value:
                          totalValue == 0 ? 0 : item.doubleValue / totalValue,
                      title: "${item.name}\n¥${item.value ?? "0"}",
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
