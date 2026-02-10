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
            header: const ClassicHeader(
              position: IndicatorPosition.locator,
              dragText: '下拉刷新',
              armedText: '释放立即刷新',
              readyText: '正在刷新...',
              processingText: '正在刷新...',
              processedText: '刷新完成',
              messageText: '上次更新于 %T',
              safeArea: false, // 通常设为 false，防止刘海屏留白过多
            ),
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
    return CustomScrollView(
      controller: controller.scrollController,
      slivers: [
        const HeaderLocator.sliver(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 原有的内容...
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
          ),
        ),
      ],
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

// 在 ChartsPage 文件底部或者单独的文件中添加这个类
class ChartTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color backgroundColor;

  ChartTabHeaderDelegate({
    required this.child,
    required this.height,
    required this.backgroundColor,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 外层包裹 Container 设置背景色，防止内容滚动到下方时透视文字重叠
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height; // 最小高度等于最大高度，保持高度不变

  @override
  bool shouldRebuild(covariant ChartTabHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
