import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/components/navbar/brn_appbar.dart';
import 'package:journal/pages/reminder_settings/controller.dart';

class ReminderSettingsPage extends GetView<ReminderSettingsController> {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // 柔和的背景色
      appBar: BrnAppBar(
        title: "记账提醒",
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _buildView(context),
      ),
    );
  }

  Widget _buildView(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildMainSwitch(context),
            SizedBox(height: 24.h),
            if (controller.service.isEnabled.value) ...[
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                child: Text(
                  '提醒时间',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildTimeList(context),
              SizedBox(height: 24.h),
              _buildAddButton(context),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF000000),
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
              color: Colors.black,
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
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '定时提醒，不再遗漏每一笔开支',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.9),
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

  Widget _buildMainSwitch(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
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
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                controller.service.isEnabled.value ? '已开启' : '已关闭',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
            ],
          ),
          Switch(
            value: controller.service.isEnabled.value,
            activeColor: Colors.black,
            onChanged: (value) {
              controller.toggleReminder(value, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeList(BuildContext context) {
    final times = controller.service.reminderTimes;
    if (times.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 30.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(
              Icons.access_time,
              size: 48.sp,
              color: const Color(0xFFEEEEEE),
            ),
            SizedBox(height: 12.h),
            Text(
              '暂无提醒时间',
              style: TextStyle(
                color: const Color(0xFF999999),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          color: const Color(0xFFF5F5F5),
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
                      color: Colors.black.withAlpha(16),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.access_time_filled,
                      color: Colors.black,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                      fontFamily: 'D-DIN', // 如果有数字字体更好
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: const Color(0xFFFF5B5B),
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

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: () => controller.showTimePicker(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.black,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '添加提醒时间',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
