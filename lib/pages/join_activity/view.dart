import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_search_bar.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';

import 'index.dart';

class JoinActivityPage extends GetView<JoinActivityController> {
  const JoinActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<JoinActivityController>(
      init: JoinActivityController(),
      id: "join_activity",
      builder: (_) {
        return Scaffold(
          // 背景跟随主题
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context, appColors),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), // 点击空白收起键盘
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        _buildSearchSection(context, appColors),
                        SizedBox(height: 16.h),
                        // 结果展示区域
                        Obx(() =>
                            controller.activity.value.activityId.isNotEmpty
                                ? _buildResultCard(context, appColors)
                                : _buildEmptyHint(appColors)),
                      ],
                    ),
                  ),
                ),
                _buildBottomAction(context, appColors),
              ],
            ),
          ),
        );
      },
    );
  }

  // 替换为原生 AppBar 以完美适配颜色
  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppThemeColors appColors) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new,
            color: appColors.primaryText, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "加入账本",
        style: TextStyle(
          fontSize: 18.sp,
          fontFamily: "SmileySans",
          fontWeight: FontWeight.w500,
          color: appColors.primaryText,
        ),
      ),
    );
  }

  // 1. 搜索区
  Widget _buildSearchSection(BuildContext context, AppThemeColors appColors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 适配卡片背景
        borderRadius: BorderRadius.circular(24.r), // 统一 24px 圆角
        boxShadow: [
          // 统一弥散阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("邀请码 / 口令",
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryText)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: JournalSearchBar(
                  height: 48.h,
                  backgroundColor: appColors.primaryText.withOpacity(0.05),
                  controller: controller.textEditController,
                  placeholder: "粘贴或输入邀请码",
                  autoFocus: false,
                  onTextChanged: controller.onInputChanged,
                  onSubmitted: (_) => controller.onMainButtonTap(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 粘贴按钮
          GestureDetector(
            onTap: () => controller.readClipboard(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                  color: appColors.mainButtonBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: appColors.primaryText.withOpacity(0.1))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.content_paste_rounded,
                      size: 20, color: appColors.mainButtonIcon),
                  SizedBox(width: 8.w),
                  Text("从剪贴板读取",
                      style: TextStyle(
                          color: appColors.mainButtonIcon,
                          fontWeight: FontWeight.w500))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // 2. 结果卡片
  Widget _buildResultCard(BuildContext context, AppThemeColors appColors) {
    final activity = controller.activity.value;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        // 选中状态的边框：使用主色
        border: Border.all(color: appColors.primaryText, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // 图标容器
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
                color: appColors.primaryText, // 黑底/白底
                shape: BoxShape.circle),
            child: Icon(Icons.account_balance_wallet_rounded,
                size: 32, color: appColors.cardBackground), // 反色图标
          ),
          SizedBox(height: 16.h),
          Text(activity.activityName,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryText)),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
                color: appColors.primaryText.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6)),
            child: Text("由 ${activity.creatorName} 创建",
                style:
                    TextStyle(fontSize: 12.sp, color: appColors.secondaryText)),
          ),
        ],
      ),
    );
  }

  // 3. 空状态
  Widget _buildEmptyHint(AppThemeColors appColors) {
    return Padding(
      padding: EdgeInsets.only(top: 40.h),
      child: Column(
        children: [
          Icon(Icons.search_rounded,
              size: 48, color: appColors.secondaryText.withOpacity(0.3)),
          SizedBox(height: 8.h),
          Text("输入邀请码以查找账本",
              style: TextStyle(
                  color: appColors.secondaryText.withOpacity(0.5),
                  fontSize: 14.sp)),
        ],
      ),
    );
  }

  // 4. 底部按钮区
  Widget _buildBottomAction(BuildContext context, AppThemeColors appColors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 34.w), // 适配底部安全区
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 底部栏背景
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        final bool hasData = controller.activity.value.activityId.isNotEmpty;
        final String btnText = hasData ? "确认加入" : "查找账本";

        // 按钮颜色逻辑：有数据用主色，无数据用禁用色
        final bgColor = hasData
            ? appColors.mainButtonBg
            : appColors.secondaryText.withOpacity(0.2);
        final textColor = hasData
            ? appColors.mainButtonIcon
            : appColors.secondaryText.withOpacity(0.5);

        return GestureDetector(
          onTap: () => controller.joinActivity(),
          child: Container(
            width: double.infinity,
            height: 50.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(25.r), // 圆角胶囊
            ),
            child: Text(
              btnText,
              style: TextStyle(
                  color: textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }
}
