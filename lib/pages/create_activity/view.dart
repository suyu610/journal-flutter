import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_nav_bar.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/util/dialog_util.dart';

import 'index.dart';

class CreateActivityPage extends GetView<CreateActivityController> {
  const CreateActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<CreateActivityController>(
      init: CreateActivityController(),
      id: "createactivitypage",
      autoRemove: true,
      builder: (_) {
        return Scaffold(
          // 背景色跟随主题
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppbar(context, appColors),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: _buildView(context, appColors),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppbar(
      BuildContext context, AppThemeColors appColors) {
    return JournalNavBar(
        backgroundColor: Colors.transparent, // 沉浸式
        elevation: 0,
        centerTitle: true,
        title: controller.activity.value.activityId == "" ? "创建账本" : "更新账本");
  }

  // 主视图
  Widget _buildView(BuildContext context, AppThemeColors appColors) {
    return Column(
      children: [
        // 1. 表单卡片区域
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: appColors.cardBackground, // 适配深色
            borderRadius: BorderRadius.circular(24.r), // 统一圆角
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // 创建人 (仅在编辑且非空时显示，或者逻辑你自己定，这里照搬原逻辑)
              if (controller.activity.value.activityId != "")
                _buildInputRow(
                  title: "创建人",
                  controller: controller.creatorController,
                  appColors: appColors,
                  isEdit: false,
                ),

              if (controller.activity.value.activityId != "")
                _buildDivider(appColors),

              // 设为默认账本
              _buildSwitchRow(
                title: "设为默认账本",
                value: controller.activity.value.activated,
                onChanged: (val) => controller.updateActivated(val),
                appColors: appColors,
              ),

              _buildDivider(appColors),

              // 账本名称
              _buildInputRow(
                title: "账本名称",
                controller: controller.activityNameController,
                appColors: appColors,
                isEdit: controller.isOwner.value ||
                    controller.activity.value.activityId == "",
                hint: "请输入名称",
                focusNode: controller.activityNameFocusNode,
              ),

              _buildDivider(appColors),

              // 预算金额
              _buildInputRow(
                title: "预算金额",
                controller: controller.budgetController,
                appColors: appColors,
                isEdit: controller.isOwner.value ||
                    controller.activity.value.activityId == "",
                inputType: const TextInputType.numberWithOptions(decimal: true),
                hint: "请输入预算",
              ),

              _buildDivider(appColors),

              // 预算模式
              _buildBudgetModeSelector(appColors),
            ],
          ),
        ),

        SizedBox(height: 32.h),

        // 2. 底部按钮区域
        // 创建/保存按钮
        if (controller.isOwner.value ||
            controller.activity.value.activityId == "")
          _buildMainButton(
            text: controller.activity.value.activityId == "" ? "创建" : "保存",
            onTap: () => controller.createActivity(context),
            appColors: appColors,
          ),

        SizedBox(height: 16.h),

        // 删除按钮 (Owner)
        if (controller.activity.value.activityId != "" &&
            controller.isOwner.value)
          _buildDestructiveButton(
            text: "删除账本",
            onTap: () {
              PremiumGlassDialog.show(context,
                  title: "确认删除此账本？",
                  content:
                      "请输入账本名【${controller.activity.value.activityName}】，以继续删除",
                  textInputAction: TextInputAction.done,
                  isDestructive: true, // 开启红色警示风格
                  confirmText: "删除", onConfirmWithInput: (v) {
                if (v != controller.activity.value.activityName) {
                  // 简单Toast，或者你可以换成 Get.snackbar
                  Get.snackbar("错误", "账本名不匹配",
                      backgroundColor: appColors.cardBackground,
                      colorText: appColors.primaryText);
                  return;
                } else {
                  controller.deleteActivity(context);
                }
              });
            },
            appColors: appColors,
          ),

        // 退出按钮 (Non-Owner)
        if (controller.activity.value.activityId != "" &&
            !controller.isOwner.value)
          _buildDestructiveButton(
            text: "退出账本",
            onTap: () => controller.exitActivity(context),
            appColors: appColors,
          ),
      ],
    );
  }

  // --- 组件封装 ---

  // 1. 通用输入行
  Widget _buildInputRow({
    required String title,
    required TextEditingController controller,
    required AppThemeColors appColors,
    bool isEdit = true,
    TextInputType inputType = TextInputType.text,
    String? hint,
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              color: appColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              enabled: isEdit,
              keyboardType: inputType,
              textAlign: TextAlign.end, // 靠右对齐，符合移动端习惯
              style: TextStyle(
                fontSize: 15.sp,
                color: isEdit ? appColors.primaryText : appColors.secondaryText,
                fontWeight: isEdit ? FontWeight.w500 : FontWeight.normal,
              ),
              cursorColor: appColors.primaryText,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: TextStyle(
                  color: appColors.secondaryText.withOpacity(0.5),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. 开关行
  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppThemeColors appColors,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              color: appColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: value,
              activeColor: appColors.cardBackground,
              activeTrackColor: appColors.primaryText, // 黑白反转
              inactiveTrackColor: appColors.secondaryText.withOpacity(0.2),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // 3. 预算模式选择器 (Segmented Control 风格)
  Widget _buildBudgetModeSelector(AppThemeColors appColors) {
    bool isMonth = controller.activity.value.budgetType == "month";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "预算模式",
            style: TextStyle(
              fontSize: 15.sp,
              color: appColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: appColors.primaryText.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildSegmentOption("月预算", isMonth, appColors, () {
                  controller.updateBudgetType("month");
                }),
                _buildSegmentOption("总预算", !isMonth, appColors, () {
                  controller.updateBudgetType("total");
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSegmentOption(String text, bool isSelected,
      AppThemeColors appColors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? appColors.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: isSelected ? appColors.primaryText : appColors.secondaryText,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 4. 分割线
  Widget _buildDivider(AppThemeColors appColors) {
    return Divider(
        height: 1,
        thickness: 0.5,
        color: appColors.primaryText.withOpacity(0.05));
  }

  // 5. 主按钮
  Widget _buildMainButton({
    required String text,
    required VoidCallback onTap,
    required AppThemeColors appColors,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.mainButtonBg,
          elevation: 5,
          shadowColor: appColors.mainButtonBg.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: appColors.mainButtonIcon,
          ),
        ),
      ),
    );
  }

  // 6. 危险/次要按钮 (空心/文字)
  Widget _buildDestructiveButton({
    required String text,
    required VoidCallback onTap,
    required AppThemeColors appColors,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
