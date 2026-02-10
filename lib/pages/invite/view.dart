import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_button.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/components/journal_toast.dart';

import 'index.dart';

class InvitePage extends GetView<InviteController> {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 获取主题扩展颜色 (关键步骤)
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<InviteController>(
      init: InviteController(),
      id: "invite",
      builder: (_) {
        return Scaffold(
          // 背景色跟随主题
          backgroundColor: appColors.backgroundColor,
          appBar: JournalNavBar(
            titleWidget: Text(
              "邀请成员",
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "SmileySans",
                  fontWeight: FontWeight.w500,
                  color: appColors.primaryText), // 适配标题色
            ),
          ), // 假设你的 NavBar 支持传入 title
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 16.h),

                // 1. 账本信息卡片
                _buildLedgerInfoCard(context, appColors),

                SizedBox(height: 32.h),

                // 2. 成员列表标题
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Text(
                        "成员列表 (${controller.activity.value.userList.length})",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: appColors.primaryText, // 适配文字颜色
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // 3. 成员列表
                Expanded(child: _buildMemberList(context, appColors)),

                // 4. 底部按钮
                _buildBottomButton(context, appColors),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. 顶部账本卡片 (完全适配深色模式)
  Widget _buildLedgerInfoCard(BuildContext context, AppThemeColors appColors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 关键：使用适配的卡片背景色
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            // 阴影颜色也稍微适配一下，深色模式下阴影可以更深或者不可见
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  // 图标背景使用主文字颜色的 10% 透明度，自动适配黑白
                  color: appColors.primaryText.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: appColors.primaryText, // 图标颜色跟随文字
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  controller.activity.value.activityName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: "SmileySans",
                    color: appColors.primaryText, // 适配标题颜色
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            "邀请码",
            style: TextStyle(
              color: appColors.secondaryText, // 适配次要文字颜色
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),

          // 邀请码展示区
          GestureDetector(
            onTap: () {
              controller.copyInviteCode(context);
              HapticFeedback.lightImpact(); // 加个震动反馈更爽
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: appColors.primaryText.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12.r),
                border:
                    Border.all(color: appColors.primaryText.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.activity.value.activityId,
                    style: TextStyle(
                        color: appColors.primaryText, // 码的颜色
                        fontSize: 16,
                        fontFamily: "Monospace",
                        letterSpacing: 3, // 字间距大一点更好看
                        fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.copy_rounded,
                      color: appColors.secondaryText, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. 成员列表
  Widget _buildMemberList(BuildContext context, AppThemeColors appColors) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: controller.activity.value.userList.length,
      itemBuilder: (context, index) {
        final user = controller.activity.value.userList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: appColors.cardBackground, // 适配列表项背景
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () {
                JournalToast.show(context, "开发中...");
              },
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // 头像
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // 边框颜色适配：用极淡的背景色
                        border: Border.all(
                            color: appColors.primaryText.withOpacity(0.1),
                            width: 1),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          user.avatarUrl,
                          fit: BoxFit.cover,
                          width: 44.r,
                          height: 44.r,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 44.r,
                            height: 44.r,
                            color: appColors.primaryText.withOpacity(0.1),
                            child: Icon(Icons.person,
                                color: appColors.secondaryText),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // 信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nickname,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: appColors.primaryText, // 适配文字
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "加入于 2024-03-21", // 示例数据
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: appColors.secondaryText, // 适配次要文字
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton(BuildContext context, AppThemeColors appColors) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 30.h),
      child: JournalButton(
        text: "复制完整邀请链接",
        icon: Icons.share_rounded,
        type: JournalButtonType.outline,
        onTap: () => controller.copyInviteCode(context),
      ),
    );
  }
}
