import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import '../controller.dart';
import 'chart_card_container.dart';

class CategoryChartCard extends GetView<ChartsController> {
  static final List<Color> _chartPalette = [
    const Color(0xFF263238),
    const Color(0xFF455A64),
    const Color(0xFF607D8B),
    const Color(0xFF90A4AE),
    const Color(0xFFCFD8DC),
  ];

  const CategoryChartCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    "消费分类",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: BrnSwitchButton(
                      size: const Size(42, 24),
                      borderColor: Colors.grey[200]!,
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
                color: Colors.white,
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
                      color: _chartPalette[index % _chartPalette.length],
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
