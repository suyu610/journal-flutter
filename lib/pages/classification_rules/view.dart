// pages/classification_rules/view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/config/theme_config.dart';
import 'package:journal/pages/classification_rules/controller.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ClassificationRulesPage extends GetView<ClassificationRulesController> {
  const ClassificationRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassificationRulesController>(
      init: ClassificationRulesController(),
      id: "classification_rules",
      builder: (_) {
        return Scaffold(
          // 点击背景收起键盘
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: backgroundColor, // 保持你的背景色
              appBar: _buildAppbar(context),
              body: Column(
                children: [
                  // 上方输入区域，使用 Expanded 占满剩余空间
                  Expanded(child: _buildInputArea(context)),
                  // 底部按钮区域
                  _buildBottomButtons(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return TDNavBar(
      useBorderStyle: true,
      height: 48,
      useDefaultBack: true,
      titleWidget: Text(
        "分类规则配置",
        style: TextStyle(
            fontSize: 18.sp,
            fontFamily: "SmileySans",
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          // 增加一点阴影，让输入区不那么“平”
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: TDInput(
          controller: controller.ruleInputController,
          inputType: TextInputType.multiline,
          needClear: false,
          maxLines: 15, // 自适应高度
          hintText:
              "在此输入分类规则，AI 将优先依据此规则进行记账分类。\n\n示例：\n1. 餐饮：包含“饭”、“面”、“肯德基”\n2. 交通：包含“打车”、“滴滴”、“地铁”",
          hintTextStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          backgroundColor: Colors.transparent,
          leftLabel: null, // 去掉左侧标签
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 34.h), // 适配底部安全区
      decoration: BoxDecoration(
        color: Colors.white,
        // 顶部加一条微弱的边框或阴影，区分内容区
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // --- 左侧：清空按钮 (弱样式) ---
          Expanded(
            flex: 1, // 占比 1
            child: TDButton(
              text: "清空",
              size: TDButtonSize.large,
              type: TDButtonType.outline, // 描边样式
              theme: TDButtonTheme.defaultTheme, // 默认灰色主题
              onTap: () => controller.clearRules(context),
            ),
          ),

          SizedBox(width: 16.w), // 按钮间距

          // --- 右侧：保存按钮 (强样式) ---
          Expanded(
            flex: 2, // 占比 2，让保存按钮稍微宽一点（可选，也可以设为1等宽）
            child: Obx(() {
              final isLoading = controller.isSaving.value;
              return TDButton(
                text: isLoading ? "保存中..." : "保存配置",
                size: TDButtonSize.large,
                type: TDButtonType.fill, // 实心样式
                theme: TDButtonTheme.primary, // 主色调
                // 如果正在保存，显示 Loading 图标
                iconWidget: isLoading
                    ? Container(
                        padding: const EdgeInsets.only(right: 8),
                        child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white)))
                    : null,
                onTap: isLoading ? null : () => controller.saveRules(context),
              );
            }),
          ),
        ],
      ),
    );
  }
}
