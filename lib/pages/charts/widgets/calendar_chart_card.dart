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
    // 不需要单独判断 isDark，完全依赖 appColors

    return ChartCardContainer(
      padding: EdgeInsets.zero,
      child: GetBuilder<ChartsController>(
        id: 'calendar_chart',
        builder: (_) {
          return Column(
            children: [
              _buildHeader(appColors),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                child: TableCalendar(
                  rowHeight: 58,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  locale: 'zh_CN',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: controller.focusedDay.value,
                  currentDay: DateTime.now(),
                  headerVisible: false,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  // 星期栏样式
                  daysOfWeekHeight: 15,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                        color: appColors.secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                    weekendStyle: TextStyle(
                        color: appColors.secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                  ),

                  calendarBuilders: CalendarBuilders(
                    // 1. 默认格子
                    defaultBuilder: (context, day, focusedDay) => _buildCell(
                        context, day, appColors, controller.dailyBudgetValue,
                        isToday: false),

                    // 2. 今天 (高亮)
                    todayBuilder: (context, day, focusedDay) => _buildCell(
                        context, day, appColors, controller.dailyBudgetValue,
                        isToday: true),

                    // 3. 禁用/范围外
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
        },
      ),
    );
  }

  // 头部月份
  Widget _buildHeader(AppThemeColors appColors) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 这里的日期格式化可以根据喜好调整
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
          // 这里可以放一个“回到今天”的小按钮，或者留白
        ],
      ),
    );
  }

  // 核心：构建日期格子
  Widget _buildCell(
      BuildContext context, DateTime day, AppThemeColors appColors, num? budget,
      {required bool isToday}) {
    DailyStats? stats = controller.getStatsForDay(day);
    bool hasIncome = stats != null && stats.income > 0;
    bool hasExpense = stats != null && stats.expense > 0;

    // 判断是否超支
    bool isBudgetExceeded =
        budget != null && hasExpense && stats.expense > budget;

    // 背景色逻辑
    Color bgColor = Colors.transparent;
    BoxDecoration? decoration;

    if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(
            color: appColors.dangerColor.withOpacity(0.3), width: 1.w),
        borderRadius: BorderRadius.circular(10.r),
      );
    } else if (hasExpense || hasIncome) {
      bgColor = isBudgetExceeded
          ? (appColors.dangerColor).withOpacity(0.08)
          : appColors.secondaryText.withOpacity(0.05);

      decoration = BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r), // 方圆形 (Squaricle)
      );
    }

    // 文字颜色逻辑
    Color dayTextColor = appColors.primaryText;

    // 金额颜色
    final textExpense = appColors.primaryText; // 支出用主色，干净
    // 如果想要支出显示红色：final textExpense = appColors.dangerColor ?? Colors.red;

    const textIncome = Color(0xFF00A870); // 收入用绿色，保持固定

    return Container(
      margin: EdgeInsets.all(3.w), // 单元格间距
      decoration: decoration,
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 4,
          ),
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: dayTextColor,
            ),
          ),

          // 仅当有数据时显示，且只显示非0数据
          if (hasIncome || hasExpense) ...[
            SizedBox(height: 1.h),
            if (hasIncome)
              Text(
                "+${_formatNum(stats.income)}",
                style: TextStyle(
                    fontSize: 8.sp,
                    fontFamily: 'SourceCodePro',
                    color: textIncome,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
              ),

            // 支出 (-xx)
            if (hasExpense)
              Text(
                "-${_formatNum(stats.expense)}",
                style: TextStyle(
                    fontSize: 8.sp,
                    fontFamily: 'SourceCodePro',
                    color: textExpense,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            SizedBox(height: 2.h),
          ] else ...[
            // SizedBox(height: 12.h),
          ]
        ],
      ),
    );
  }

  String _formatNum(double num) {
    if (num >= 10000) {
      return "${(num / 10000).toStringAsFixed(1)}w";
    }
    // 这种小格子里的数字，如果太大可以截断或者去掉小数位
    if (num > 999) {
      return num.toStringAsFixed(0);
    }
    return num.toStringAsFixed(0); // 默认不显示小数，保持干净
  }
}
