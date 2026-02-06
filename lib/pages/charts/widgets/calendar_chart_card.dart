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
          id: 'calendar_card',
          builder: (_) {
            return Column(
              children: [
                _buildHeader(appColors),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  child: TableCalendar(
                    availableGestures: AvailableGestures.horizontalSwipe,
                    locale: 'zh_CN',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: controller.focusedDay.value,
                    currentDay: DateTime.now(),
                    headerVisible: false, // 隐藏默认头部，使用自定义
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    // 自定义构建器
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) =>
                          _buildCell(context, day, appColors, isDark),
                      todayBuilder: (context, day, focusedDay) =>
                          _buildCell(context, day, appColors, isDark),
                      outsideBuilder: (context, day, focusedDay) =>
                          const SizedBox(), // 隐藏非本月日期
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('yyyy年MM月').format(controller.focusedDay.value),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: appColors.primaryText,
            ),
          ),
          Row(
            children: [
              // _arrowBtn(Icons.chevron_left,
              //     () => controller.mont(previous: true), appColors),
              SizedBox(width: 16.w),
              // _arrowBtn(Icons.chevron_right,
              //     () => controller.changeMonth(previous: false), appColors),
            ],
          )
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _arrowBtn(
      IconData icon, VoidCallback onTap, AppThemeColors appColors) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 24, color: appColors.secondaryText),
      ),
    );
  }

  // 自定义日期格子
  Widget _buildCell(BuildContext context, DateTime day,
      AppThemeColors appColors, bool isDark) {
    DailyStats? stats = controller.getStatsForDay(day);
    bool hasData = stats != null && (stats.income > 0 || stats.expense > 0);

    // 计算背景色
    Color? bgColor;
    if (hasData) {
      bool hasExpense = stats.expense > 0;
      bool hasIncome = stats.income > 0;

      if (hasExpense && hasIncome) {
        // 混合：深色模式用深橙色，亮色模式用米色
        bgColor = isDark ? const Color(0xFF5D4037) : const Color(0xFFFFFAF0);
      } else if (hasExpense) {
        // 支出：深色模式用深红半透明，亮色模式用浅粉
        bgColor = isDark
            ? const Color(0xFFE53935).withOpacity(0.2)
            : const Color(0xFFFFF5F5);
      } else {
        // 收入：深色模式用深蓝半透明，亮色模式用浅蓝
        bgColor = isDark
            ? const Color(0xFF1E88E5).withOpacity(0.2)
            : const Color(0xFFF0FAFF);
      }
    }

    // 字体颜色
    final textExpense =
        isDark ? const Color(0xFFFF8A80) : const Color(0xFFFF6B6B);
    final textIncome =
        isDark ? const Color(0xFF82B1FF) : const Color(0xFF4DA9FF);

    return Container(
      margin: const EdgeInsets.all(2),
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        // border: isSameDay(day, DateTime.now())
        //     ? Border.all(color: appColors.primaryText, width: 1) // 今天加个框
        //     : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 4.h),
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 12,
              color: appColors.primaryText,
            ),
          ),
          if (hasData) ...[
            SizedBox(height: 2.h),
            if (stats.income > 0)
              Text(
                "+${_formatNum(stats.income)}",
                style: TextStyle(
                    fontSize: 8.sp,
                    color: textIncome,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (stats.expense > 0)
              Text(
                "-${_formatNum(stats.expense)}",
                style: TextStyle(
                    fontSize: 8.sp,
                    color: textExpense,
                    fontWeight: FontWeight.w500),
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
