import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controller.dart';
import '../models/daily_stats.dart';
import 'chart_card_container.dart';

class CalendarChartCard extends GetView<ChartsController> {
  const CalendarChartCard({super.key});

  // 参考图的配色
  static const Color _bgExpense = Color(0xFFFFF5F5); // 支出背景（浅粉）
  static const Color _bgIncome = Color(0xFFF0FAFF); // 收入背景（浅蓝）
  static const Color _bgMixed = Color(0xFFFFFAF0); // 收支都有（浅橙/米色）

  static const Color _textExpense = Color(0xFFFF6B6B); // 支出红字
  static const Color _textIncome = Color(0xFF4DA9FF); // 收入蓝字
  static const Color _borderColor = Colors.black87; // 选中框颜色

  @override
  Widget build(BuildContext context) {
    return ChartCardContainer(
      padding: EdgeInsets.zero, // 移除容器默认内边距
      child: GetBuilder<ChartsController>(
          id: 'calendar_card',
          builder: (_) {
            return Column(
              children: [
                // 1. 头部信息
                _buildHeader(),

                // 2. 日历主体
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: TableCalendar(
                    locale: 'zh_CN',
                    availableGestures: AvailableGestures.horizontalSwipe,
                    pageAnimationEnabled: false,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: controller.focusedDay.value,
                    currentDay: DateTime.now(),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selectedDayPredicate: (day) =>
                        isSameDay(controller.selectedDay.value, day),
                    onDaySelected: controller.onDaySelected,
                    onPageChanged: controller.onPageChanged,

                    headerVisible: false,

                    // 【关键参数】调整行高，确保格子是微长方形，不是细长条
                    rowHeight: 55.h,
                    daysOfWeekHeight: 24.h,

                    // 样式配置
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      tablePadding: EdgeInsets.zero,
                    ),

                    // 自定义构建器
                    calendarBuilders: CalendarBuilders(
                      // 默认日期
                      defaultBuilder: (context, day, focusedDay) =>
                          _buildCell(day),
                      // 今天
                      todayBuilder: (context, day, focusedDay) =>
                          _buildCell(day, isToday: true),
                      // 选中日期
                      selectedBuilder: (context, day, focusedDay) =>
                          _buildCell(day, isSelected: true),
                      // 禁用的日期
                      disabledBuilder: (context, day, focusedDay) =>
                          const SizedBox(),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            );
          }),
    );
  }

  // 头部构建：月份 + 统计
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：月份 + 下拉箭头
          Row(
            children: [
              Text(
                DateFormat('yyyy年MM月').format(controller.focusedDay.value),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.black54),
            ],
          ),
          SizedBox(height: 6.h),
          // 第二行：总收支
          Obx(() => Row(
                children: [
                  Text(
                    "支出 ¥${controller.currentMonthExpense.value.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "收入 ¥${controller.currentMonthIncome.value.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  // 【核心】构建单个日历格
  Widget _buildCell(DateTime day,
      {bool isSelected = false, bool isToday = false}) {
    DailyStats? stats = controller.getStatsForDay(day);
    print("stats: $stats");
    bool hasData = stats != null && stats.hasData;

    // 1. 计算背景色
    Color bgColor = Colors.white;
    if (hasData) {
      if (stats.expense > 0 && stats.income > 0) {
        bgColor = _bgMixed;
      } else if (stats.expense > 0) {
        bgColor = _bgExpense;
      } else {
        bgColor = _bgIncome;
      }
    }

    // 2. 今天的特殊背景（如果没有数据时，给个极淡的灰色区分）
    // if (isToday && !hasData) {
    //   bgColor = Colors.grey[50]!;
    // }

    return Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r), // 圆角 8-12 比较好看
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 垂直居中
        children: [
          const SizedBox(height: 4),

          // A. 日期数字
          Text(
            '${day.day}',
            style: const TextStyle(
              fontSize: 12,
              // 今天如果没选中，数字显示蓝色；选中了显示黑色
              color: Colors.black87,
            ),
          ),

          // B. 收支数据 (根据空间显示)
          if (hasData) ...[
            SizedBox(height: 2.h),
            // 收入 (蓝色)
            if (stats.income > 0)
              Text(
                "+${_formatNum(stats.income)}",
                style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.blueGrey[900],
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            // 支出 (红色)
            if (stats.expense > 0)
              Text(
                "-${_formatNum(stats.expense)}",
                style: TextStyle(
                    fontSize: 8.sp,
                    color: _textExpense,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ] else ...[
            // 占位，保持格子高度一致
            SizedBox(height: 22.h),
          ]
        ],
      ),
    );
  }

  // 数字格式化：去掉 .0，过大显示 w
  String _formatNum(double num) {
    if (num >= 10000) {
      return "${(num / 10000).toStringAsFixed(1)}w";
    }
    String s = num.toStringAsFixed(1);
    if (s.endsWith('.0')) return s.substring(0, s.length - 2);
    return s;
  }
}
