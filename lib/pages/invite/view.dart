import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// 假设你有一个自定义的按钮组件和主题配置
import 'package:journal/components/journal_button.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/components/journal_toast.dart';

// 假设你的 Controller 和模型定义在这里
import 'index.dart';

class InvitePage extends GetView<InviteController> {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取你的主题色配置。如果你的配置方式不同，请自行调整。
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    // 这里定义一些页面专属的样式常量，方便微调
    const double kCardRadius = 24.0;
    const double kMemberCardRadius = 20.0;

    return GetBuilder<InviteController>(
      init: InviteController(),
      id: "invite",
      builder: (_) {
        return Scaffold(
          backgroundColor: appColors.backgroundColor,
          appBar: JournalNavBar(
            backgroundColor: Colors.transparent, // 沉浸式
            titleWidget: Text(
              "邀请成员",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: "SmileySans",
                  fontWeight: FontWeight.w500,
                  color: appColors.primaryText),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 16.h),

                // 1. 高级凭证式卡片 (核心修改)
                _buildPremiumTicketCard(context, appColors, kCardRadius),

                SizedBox(height: 32.h),

                // 2. 成员列表标题
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "已加入成员",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: appColors.primaryText,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Obx(() => Text(
                            "${controller.activity.value.userList.length} 人",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: appColors.secondaryText,
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // 3. 内聚式成员列表
                Expanded(
                    child: _buildGroupedMemberList(
                        context, appColors, kMemberCardRadius)),

                // 4. 底部大按钮
                _buildBottomButton(context, appColors),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 核心升级：凭证式邀请卡片 (Premium Ticket Design)
  // ==========================================
  Widget _buildPremiumTicketCard(
      BuildContext context, AppThemeColors appColors, double radius) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(radius.r),
        // 增加更柔和、更有深度的阴影
        // boxShadow: [
        //   BoxShadow(
        //     color: appColors.primaryText.withOpacity(0.06),
        //     blurRadius: 24,
        //     offset: const Offset(0, 12),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          // --- 上半部分：账本信息 ---
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
            child: Row(
              children: [
                // 更有质感的 Icon 容器
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    // 使用主题色渐变作为背景，增加高级感
                    gradient: LinearGradient(
                      colors: [
                        appColors.mainButtonBg.withOpacity(0.15),
                        appColors.mainButtonBg.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    // 换一个更有“通行证”感觉的图标
                    Icons.confirmation_number_outlined,
                    color: appColors.mainButtonBg,
                    size: 26.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "邀请加入",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: appColors.secondaryText,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Obx(() => Text(
                            controller.activity.value.activityName,
                            style: TextStyle(
                              fontSize: 22.sp, // 字体加大，更突出
                              fontFamily: "SmileySans",
                              color: appColors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 分割线：虚线效果 (Ticket 隐喻) ---
          Row(
            children: [
              _buildTicketNotch(appColors.backgroundColor, isLeft: true),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dashWidth = 5.0.w;
                    final dashSpace = 5.0.w;
                    final count =
                        (constraints.constrainWidth() / (dashWidth + dashSpace))
                            .floor();
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: List.generate(
                        count,
                        (index) => SizedBox(
                          width: dashWidth,
                          height: 1.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: appColors.secondaryText.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildTicketNotch(appColors.backgroundColor, isLeft: false),
            ],
          ),

          // --- 下半部分：邀请码令牌区 (核心重构) ---
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.copyInviteCode(context);
              HapticFeedback.mediumImpact();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
              decoration: BoxDecoration(
                // 给下半部分一个极淡的背景色区分
                // color: appColors.primaryText.withOpacity(0.015),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(radius.r)),
              ),
              child: Column(
                children: [
                  Text(
                    "专属邀请码 (点击复制)",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: appColors.secondaryText.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // 核心：图文合一的“令牌”容器
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      // 使用深色背景强调，让它成为视觉中心
                      color: appColors.mainButtonBg.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14.r),
                      // 极细的主题色边框增加精致感
                      border: Border.all(
                        color: appColors.mainButtonBg.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 宽度包裹内容
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy_all_rounded,
                            color: appColors.mainButtonBg, size: 20.sp),
                        SizedBox(width: 12.w),
                        // 使用 Flexible 防止溢出
                        Flexible(
                          child: Obx(() => Text(
                                controller.activity.value.activityId
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: appColors.primaryText,
                                  fontSize: 20.sp,
                                  fontFamily: "SourceCodePro",
                                  letterSpacing: 2.5, // 字间距收缩，更凝聚
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // 溢出显示省略号
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 门票两侧的半圆缺口
  Widget _buildTicketNotch(Color color, {required bool isLeft}) {
    return Container(
      width: 12.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: color, // 颜色必须和外层 Scaffold 背景色一致
        borderRadius: isLeft
            ? BorderRadius.horizontal(right: Radius.circular(12.r))
            : BorderRadius.horizontal(left: Radius.circular(12.r)),
      ),
    );
  }

  // ==========================================
  // 核心升级 2：内聚式成员列表 (iOS Style)
  // ==========================================
  Widget _buildGroupedMemberList(
      BuildContext context, AppThemeColors appColors, double radius) {
    return Obx(() {
      if (controller.activity.value.userList.isEmpty) return const SizedBox();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(radius.r),
          // 极细边框替代重阴影，更清爽
          border: Border.all(color: appColors.primaryText.withOpacity(0.04)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius.r),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: controller.activity.value.userList.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              indent: 76.w, // 头像宽度 + padding，对齐文字
              endIndent: 0, // 延伸到最右侧
              color: appColors.primaryText.withOpacity(0.06),
            ),
            itemBuilder: (context, index) {
              final user = controller.activity.value.userList[index];
              final isCreator = index == 0; // 假设第一个是创建者

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => JournalToast.show(context, "开发中..."),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                    child: Row(
                      children: [
                        // 头像
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: appColors.primaryText.withOpacity(0.05),
                            border: Border.all(
                                color: appColors.primaryText.withOpacity(0.08),
                                width: 1),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              user.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person_rounded,
                                color: appColors.secondaryText.withOpacity(0.5),
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
                              Row(
                                children: [
                                  Text(
                                    user.nickname,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: appColors.primaryText,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  if (isCreator)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color:
                                            appColors.mainButtonBg, // 使用主题色高亮
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        "创建者",
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.white, // 反色显示
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "1970-01-01 加入",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: appColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildBottomButton(BuildContext context, AppThemeColors appColors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: JournalButton(
        text: "分享完整邀请链接",
        icon: Icons.ios_share_rounded,
        // 建议使用实心按钮 (primary) 作为页面的核心行动点
        type: JournalButtonType.filled,
        onTap: () {
          controller.copyInviteCode(context);
          HapticFeedback.lightImpact();
        },
      ),
    );
  }
}
