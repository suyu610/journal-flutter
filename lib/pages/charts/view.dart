import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart'; // 1. 引入 EasyRefresh
// 引入你的工具类 (用于震动)
import 'package:journal/util/toast_util.dart';

import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/charts/widgets/calendar_chart_card.dart';

import 'index.dart';
import 'widgets/chart_nav_bar.dart';
import 'widgets/ai_analysis_card.dart';
import 'widgets/trend_chart_card.dart';
import 'widgets/category_chart_card.dart';

class ChartsPage extends GetView<ChartsController> {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey actionKey = GlobalKey();

    return GetBuilder<ChartsController>(
      init: ChartsController(),
      id: "charts",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: ChartNavBar(
            controller: controller,
            actionKey: actionKey,
          ),
          body: EasyRefresh(
            controller: controller.refreshController, // 绑定 Controller
            onRefresh: () async {
              // 3. 调用刷新逻辑
              ToastUtil.heavyImpact(); // 震动
              await controller.initData(); // 调用你的 public 初始化方法
            },
            child: _shouldShowEmptyState()
                ? _buildEmptyState(context)
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      // EasyRefresh 会自动处理这个 SingleChildScrollView
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SizedBox(
                height: controller.judgeString.value.isEmpty ? 0.h : 16.h)),
            const AiAnalysisCard(),
            Obx(() => SizedBox(
                height: controller.judgeString.value.isEmpty ? 0.h : 16.h)),
            const TrendChartCard(),
            SizedBox(height: 16.h),
            const CategoryChartCard(),
            SizedBox(height: 16.h),
            const CalendarChartCard(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // 4. 改造空状态：必须是可滚动的，否则无法触发下拉刷新
  Widget _buildEmptyState(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    // 使用 ListView 或 LayoutBuilder + SingleChildScrollView 确保占满屏幕且可滚动
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: GestureDetector(
              onTap: () {
                // 点击也可以刷新，双重保障
                controller.refreshController.callRefresh();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded,
                      size: 60.sp,
                      color: appColors.secondaryText.withOpacity(0.3)),
                  SizedBox(height: 16.h),
                  Text("暂无数据",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: appColors.primaryText)),
                  SizedBox(height: 8.h),
                  Text("下拉或点击刷新", // 提示文案修改
                      style: TextStyle(
                          fontSize: 14.sp, color: appColors.secondaryText)),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
