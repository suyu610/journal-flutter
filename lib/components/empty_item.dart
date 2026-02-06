import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';

Widget buildEmptyItem({
  required String title,
  required String operateText,
  required void Function() action,
}) {
  // 使用 Builder 获取 context，确保能读取到 Theme
  return Builder(builder: (context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Center(
      child: Container(
        width: 300.w,
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
        // 升级为高端卡片样式
        decoration: BoxDecoration(
          color: appColors.backgroundColor, // 适配深色
          borderRadius: BorderRadius.circular(24), // 统一 24px 圆角
        ),
        child: GestureDetector(
          onTap: action.call,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min, // 包裹内容
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 可以加一个装饰性图标，提升视觉层次
              Icon(Icons.bar_chart_rounded,
                  size: 60.sp, color: appColors.secondaryText.withOpacity(0.3)),
              SizedBox(height: 16.h),

              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: appColors.primaryText, // 适配文字颜色
                ),
              ),
              SizedBox(height: 16.h),

              // 按钮样式美化
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  // 使用淡雅的主题色背景
                  color: appColors.primaryText.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: appColors.primaryText),
                    SizedBox(width: 4.w),
                    Text(
                      operateText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: appColors.primaryText,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}
