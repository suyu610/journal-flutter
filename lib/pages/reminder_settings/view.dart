import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/reminder_settings/controller.dart';

class ReminderSettingsPage extends GetView<ReminderSettingsController> {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 获取主题颜色扩展
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      // 2. 适配背景色
      backgroundColor: appColors.backgroundColor,
      appBar: const JournalNavBar(title: "记账提醒"),
      body: SafeArea(
        child: _buildView(context, appColors),
      ),
    );
  }

  Widget _buildView(BuildContext context, AppThemeColors appColors) {
    return Obx(() {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(appColors),
            SizedBox(height: 24.h),
            _buildMainSwitch(context, appColors),
            SizedBox(height: 24.h),
            if (controller.service.isEnabled.value) ...[
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                child: Text(
                  '提醒时间',
                  style: TextStyle(
                    fontSize: 14.sp,
                    // 适配次要文字颜色
                    color: appColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildTimeList(context, appColors),
              SizedBox(height: 24.h),
              _buildAddButton(context, appColors),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildHeader(AppThemeColors appColors) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        // 适配边框颜色，使用 primaryText 的低透明度，确保深色模式可见
        border: Border.all(
          color: appColors.primaryText.withOpacity(0.15),
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            child: Icon(
              Icons.notifications_active_outlined,
              // 适配图标颜色
              color: appColors.primaryText,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '养成记账好习惯',
                  style: TextStyle(
                    // 适配主标题颜色
                    color: appColors.primaryText,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '定时提醒，不再遗漏每一笔开支',
                  style: TextStyle(
                    // 适配副标题颜色
                    color: appColors.secondaryText,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSwitch(BuildContext context, AppThemeColors appColors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        // 适配卡片背景色
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            // 阴影颜色稍微淡一点
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '开启每日提醒',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  // 适配文字颜色
                  color: appColors.primaryText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                controller.service.isEnabled.value ? '已开启' : '已关闭',
                style: TextStyle(
                  fontSize: 13.sp,
                  // 适配文字颜色
                  color: appColors.secondaryText,
                ),
              ),
            ],
          ),
          Switch(
            value: controller.service.isEnabled.value,
            // 开关激活颜色适配为主文字颜色（或者你可以用 primaryColor）
            activeColor: appColors.primaryText,
            activeTrackColor: appColors.primaryText.withOpacity(0.2), // 轨道颜色
            onChanged: (value) {
              controller.toggleReminder(value, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeList(BuildContext context, AppThemeColors appColors) {
    final times = controller.service.reminderTimes;
    if (times.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 30.h),
        decoration: BoxDecoration(
          // 适配背景
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(
              Icons.access_time,
              size: 48.sp,
              // 适配空状态图标颜色
              color: appColors.secondaryText.withOpacity(0.2),
            ),
            SizedBox(height: 12.h),
            Text(
              '暂无提醒时间',
              style: TextStyle(
                // 适配空状态文字颜色
                color: appColors.secondaryText,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 适配背景
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: times.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          // 适配分割线颜色
          color: appColors.primaryText.withOpacity(0.05),
          indent: 20.w,
          endIndent: 20.w,
        ),
        itemBuilder: (context, index) {
          final time = times[index];
          return InkWell(
            onTap: () {}, // 可以添加编辑功能
            borderRadius: index == 0
                ? BorderRadius.vertical(top: Radius.circular(16.r))
                : index == times.length - 1
                    ? BorderRadius.vertical(bottom: Radius.circular(16.r))
                    : BorderRadius.zero,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      // 适配图标背景：使用主色调的极低透明度
                      color: appColors.primaryText.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.access_time_filled,
                      color: appColors.primaryText, // 适配图标
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: appColors.primaryText, // 适配文字
                      fontFamily: 'D-DIN',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: const Color(0xFFFF5B5B), // 红色保留，深色模式下红色通常也适用
                      size: 22.sp,
                    ),
                    onPressed: () => controller.removeTime(time, context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, AppThemeColors appColors) {
    return InkWell(
      onTap: () => controller.showTimePicker(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: appColors.cardBackground, // 适配背景
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            // 适配边框
            color: appColors.primaryText.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: appColors.primaryText, // 适配图标
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '添加提醒时间',
              style: TextStyle(
                color: appColors.primaryText, // 适配文字
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
