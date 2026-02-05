import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/components/navbar/brn_appbar.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class InvitePage extends GetView<InviteController> {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InviteController>(
      init: InviteController(),
      id: "invite",
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA), // 浅灰底色衬托深色卡片
          appBar: BrnAppBar(
            backgroundColor: Colors.transparent, // 导航栏透明，透出背景
            // 如果背景是深色，这里要把标题改为白色；如果是浅色背景则黑色
            // 这里我们让头部有一部分深色背景，所以AppBar可以设为无色
            title: const Text(""), // 标题放到底下的卡片里更美观
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: Colors.blueGrey[900], size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          // 让内容延伸到顶部，制造沉浸感（可选）
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // 1. 顶部深色背景装饰
              _buildHeaderBackground(),

              // 2. 主要内容区域
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 10.h), // 避开AppBar高度
                    // 账本信息卡片
                    _buildLedgerInfoCard(),

                    SizedBox(height: 20.h),

                    // 成员列表标题
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          Text(
                            "成员列表 (${controller.activity.value.userList.length})",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // 成员列表
                    Expanded(child: _buildMemberList(context)),

                    // 底部按钮
                    _buildBottomButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. 顶部的深色背景块 + 邀请码展示
  Widget _buildLedgerInfoCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900], // 你喜欢的颜色
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.4),
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
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 24),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  controller.activity.value.activityName,
                  style: TextStyle(
                    fontSize: 22.sp,
                    // fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: "SmileySans",
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            "邀请码",
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
          SizedBox(height: 8.h),
          // 邀请码展示区
          GestureDetector(
            onTap: () => controller.copyInviteCode(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.activity.value.activityId,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: "Monospace", // 等宽字体更有“码”的感觉
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.copy_rounded, color: Colors.white70, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 背景装饰（可选，增加层次感）
  Widget _buildHeaderBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 250.h,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[50]!,
              const Color(0xFFF5F7FA),
            ],
          ),
        ),
      ),
    );
  }

  // 2. 成员列表
  Widget _buildMemberList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: controller.activity.value.userList.length,
      itemBuilder: (context, index) {
        final user = controller.activity.value.userList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
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
                TDToast.showText("查看该用户的记账记录", context: context);
              },
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // 头像
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          user.avatarUrl,
                          fit: BoxFit.cover,
                          width: 48.r,
                          height: 48.r,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                  width: 48.r,
                                  height: 48.r,
                                  color: Colors.grey[300]),
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
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "记了 [todo] 笔账", // 这里放真实数据
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 右侧箭头或状态
                    Icon(Icons.chevron_right, color: Colors.grey[300]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 3. 底部按钮区
  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 30.h),
      child: TDButton(
        text: "复制完整邀请链接",
        icon: Icons.share,
        size: TDButtonSize.large,
        type: TDButtonType.outline, // 使用轮廓风格，避免和顶部深色抢眼，或者用 fill
        theme: TDButtonTheme.primary,
        isBlock: true,
        style: TDButtonStyle(
          radius: BorderRadius.circular(12.r),
          backgroundColor: Colors.white, // 白色背景
          textColor: Colors.blueGrey[900], // 深色文字
          frameColor: Colors.blueGrey[900], // 深色边框
          frameWidth: 1.5,
        ),
        onTap: () => controller.copyInviteCode(),
      ),
    );
  }
}
