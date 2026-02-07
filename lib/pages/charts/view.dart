import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart'; // 1. 引入 EasyRefresh
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
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<ChartsController>(
      init: ChartsController(),
      id: "charts",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          backgroundColor: appColors.backgroundColor,
          appBar: ChartNavBar(
            controller: controller,
            actionKey: actionKey,
          ),
          body: EasyRefresh(
            controller: controller.refreshController,
            // header: const MaterialHeader(), // 显式指定竖向的 Header，防止歧义
            onRefresh: () async {
              ToastUtil.heavyImpact();
              await controller.initData();
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
    return SingleChildScrollView(
      controller: controller.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
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
          const CalendarChartCard(),
          SizedBox(height: 16.h),
          const CategoryChartCard(),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return CustomScrollView(
      slivers: [
        // 【改动3】修复崩溃 Bug
        // Center 不能直接放在 slivers 里，必须用 SliverFillRemaining 包裹
        // SliverFillRemaining 会占满剩余屏幕空间，保证下拉手势有效
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: GestureDetector(
              onTap: () {
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
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          color: appColors.primaryText)),
                  SizedBox(height: 8.h),
                  Text("下拉或点击刷新",
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
