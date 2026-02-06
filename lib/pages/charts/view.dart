import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/config/theme_config.dart'; // 假设你的主题配置在这里
import 'package:journal/pages/charts/widgets/calendar_chart_card.dart';

import 'index.dart';

// 引入拆分后的组件
import 'widgets/chart_nav_bar.dart';
import 'widgets/ai_analysis_card.dart';
import 'widgets/trend_chart_card.dart';
import 'widgets/category_chart_card.dart';

// 数据模型保持在这里，或者移到 model/chart_model.dart 更好
class ChartDataModel {
  String? value;
  String name;
  ChartDataModel(this.value, this.name);
  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(json['value']?.toString(), json['name']);
  }
  double get doubleValue => double.tryParse(value ?? '0') ?? 0.0;
}

class ChartsPage extends GetView<ChartsController> {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 页面级的 Key，用于 Popup 定位
    final GlobalKey actionKey = GlobalKey();

    return GetBuilder<ChartsController>(
      init: ChartsController(),
      id: "charts",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          backgroundColor: backgroundColor,
          // 使用拆分后的 NavBar
          appBar: ChartNavBar(
            controller: controller,
            actionKey: actionKey,
          ),
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

  Widget _buildMainContent(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SizedBox(
                height: controller.judgeString.value.isEmpty ? 0.h : 16.h)),

            // 1. AI 分析模块
            const AiAnalysisCard(),

            Obx(() => SizedBox(
                height: controller.judgeString.value.isEmpty ? 0.h : 16.h)),

            // 2. 趋势图模块
            const TrendChartCard(),

            SizedBox(height: 16.h),

            // 3. 分类图模块
            const CategoryChartCard(),
            SizedBox(height: 16.h),

            // 【新增】日历卡片
            const CalendarChartCard(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // 空状态稍微简单点，可以保留在 View 里，也可以继续拆
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
