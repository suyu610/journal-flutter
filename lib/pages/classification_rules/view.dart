import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_nav_bar.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/classification_rules/controller.dart';

class ClassificationRulesPage extends GetView<ClassificationRulesController> {
  const ClassificationRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<ClassificationRulesController>(
      init: ClassificationRulesController(),
      id: "classification_rules",
      builder: (_) {
        return Scaffold(
          // 点击背景收起键盘
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              // 跟随主题背景
              backgroundColor: appColors.backgroundColor,
              appBar: _buildAppbar(context, appColors),
              body: Column(
                children: [
                  // 上方输入区域
                  Expanded(child: _buildInputArea(context, appColors)),
                  // 底部按钮区域
                  _buildBottomButtons(context, appColors),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppbar(
      BuildContext context, AppThemeColors appColors) {
    return JournalNavBar(
      // useBorderStyle: false, // 去掉边框
      backgroundColor: Colors.transparent, // 沉浸式
      height: 48,
      useDefaultBack: false, // 自定义返回，适配颜色
      leftBarItems: [
        NavBarItem(
          icon: Icons.arrow_back_ios_new,
          iconSize: 20,
          onTap: () => Get.back(),
        )
      ],
      titleWidget: Text(
        "分类规则配置",
        style: TextStyle(
            fontSize: 18.sp,
            fontFamily: "SmileySans",
            fontWeight: FontWeight.w500,
            color: appColors.primaryText), // 适配标题色
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AppThemeColors appColors) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: appColors.cardBackground, // 适配卡片背景
          borderRadius: BorderRadius.circular(24.r), // 统一 24px 圆角
          // 统一的高端弥散阴影
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        // 这里改用原生 TextField 以获得更好的颜色控制权
        child: TextField(
          controller: controller.ruleInputController,
          maxLines: 15, // 自适应高度
          cursorColor: appColors.primaryText, // 光标颜色适配
          style: TextStyle(
            fontSize: 16.sp,
            height: 1.5, // 增加行高，提升阅读体验
            color: appColors.primaryText, // 输入文字颜色适配
          ),
          decoration: InputDecoration(
            border: InputBorder.none, // 去掉下划线
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            hintText:
                "在此输入分类规则，AI 将优先依据此规则进行记账分类。\n\n示例：\n1. 餐饮：包含“饭”、“面”、“肯德基”\n2. 交通：包含“打车”、“滴滴”、“地铁”",
            hintStyle: TextStyle(
                color: appColors.secondaryText.withOpacity(0.5), // 提示文字颜色适配
                fontSize: 14.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, AppThemeColors appColors) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 34.h), // 适配底部安全区
      decoration: BoxDecoration(
          color:
              appColors.cardBackground, // 底部栏也用卡片色，或者 scaffoldBackgroundColor
          // 顶部加一条极淡的分割线
          border: Border(
              top: BorderSide(color: appColors.primaryText.withOpacity(0.05))),
          boxShadow: [
            // 底部栏稍微加一点向上阴影，增加层次
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                offset: const Offset(0, -5),
                blurRadius: 10)
          ]),
      child: Row(
        children: [
          // --- 左侧：清空按钮 (弱样式) ---
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => controller.clearRules(context),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: appColors.secondaryText.withOpacity(0.3),
                      width: 1),
                ),
                child: Text(
                  "清空",
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: appColors.secondaryText,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // --- 右侧：保存按钮 (强样式) ---
          Expanded(
            flex: 2,
            child: Obx(() {
              final isLoading = controller.isSaving.value;
              return GestureDetector(
                onTap: isLoading ? null : () => controller.saveRules(context),
                child: Container(
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      // 使用定义好的主按钮色
                      color: appColors.mainButtonBg,
                      borderRadius: BorderRadius.circular(12.r),
                      // 按钮阴影
                      boxShadow: [
                        BoxShadow(
                            color: appColors.mainButtonBg.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoading) ...[
                        SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                // Loading 颜色跟随图标色
                                color: appColors.mainButtonIcon)),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        isLoading ? "保存中..." : "保存配置",
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: appColors.mainButtonIcon, // 文字颜色适配
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
