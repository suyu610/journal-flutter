import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controller.dart';
import '../models/daily_stats.dart';
import 'chart_card_container.dart';

class CalendarChartCard extends GetView<ChartsController> {
  const CalendarChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChartCardContainer(
      padding: EdgeInsets.zero, // 移除容器默认内边距
      child: GetBuilder<ChartsController>(
          id: 'calendar_chart',
          builder: (_) {
            return Column(
              children: [
                _buildHeader(appColors),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
                  child: TableCalendar(
                    rowHeight: 65,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    locale: 'zh_CN',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: controller.focusedDay.value,
                    currentDay: DateTime.now(),
                    headerVisible: false, // 隐藏默认头部，使用自定义
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) => _buildCell(
                          context,
                          day,
                          appColors,
                          isDark,
                          controller.dailyBudgetValue),
                      todayBuilder: (context, day, focusedDay) => _buildCell(
                          context,
                          day,
                          appColors,
                          isDark,
                          controller.dailyBudgetValue),
                      outsideBuilder: (context, day, focusedDay) =>
                          const SizedBox(),
                      disabledBuilder: (context, day, focusedDay) =>
                          const SizedBox(),
                    ),
                    onPageChanged: (focusedDay) =>
                        controller.onPageChanged(focusedDay),
                  ),
                ),
              ],
            );
          }),
    );
  }

  // 头部月份切换
  Widget _buildHeader(AppThemeColors appColors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Obx(() => Text(
                DateFormat('yyyy年MM月').format(controller.focusedDay.value),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryText,
                ),
              )),
        ],
      ),
    );
  }

  // 自定义日期格子
  Widget _buildCell(BuildContext context, DateTime day,
      AppThemeColors appColors, bool isDark, num? budget) {
    DailyStats? stats = controller.getStatsForDay(day);
    bool hasData = stats != null && (stats.income > 0 || stats.expense > 0);
    // Color? bgColor = isDark ? const Color(0xFF5D4037) : const Color(0xFFFFFAF0);
    Color? bgColor;
    if (hasData) {
      // bool hasExpense = stats.expense > 0;
      // bool hasIncome = stats.income > 0;
      bool isBudgetExceeded = budget != null && stats.expense > budget;
      bgColor = isDark ? const Color(0xFF5D4037) : const Color(0xFFFFFAF0);
      if (isBudgetExceeded) {
        bgColor = isDark
            ? const Color(0xFFE53935).withOpacity(0.2)
            : const Color(0xFFFFF5F5);
      }

      // if (hasExpense && hasIncome) {
      // } else if (hasExpense) {
      //   bgColor = isDark
      //       ? const Color(0xFFE53935).withOpacity(0.2)
      //       : const Color(0xFFFFF5F5);
      // } else {
      //   bgColor = isDark
      //       ? const Color(0xFF1E88E5).withOpacity(0.2)
      //       : const Color(0xFFF0FAFF);
      // }
    }

    // 字体颜色
    final textExpense =
        isDark ? const Color(0xFFFF8A80) : const Color(0xFFFF6B6B);
    final textIncome =
        isDark ? const Color(0xFF82B1FF) : const Color(0xFF4DA9FF);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      width: 40,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 12,
              color: appColors.primaryText,
            ),
          ),
          if (hasData) ...[
            Text(
              "+${_formatNum(stats.income)}",
              style: TextStyle(
                  fontSize: 8, color: textIncome, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "-${_formatNum(stats.expense)}",
              style: TextStyle(
                  fontSize: 8, color: textExpense, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            SizedBox(height: 22.h), // 占位
          ]
        ],
      ),
    );
  }

  String _formatNum(double num) {
    if (num >= 10000) {
      return "${(num / 10000).toStringAsFixed(1)}w";
    }
    return num.toStringAsFixed(0);
  }
}
