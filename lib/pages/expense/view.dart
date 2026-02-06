import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart'; // 1. 引入主题文件
import 'package:journal/pages/image_preview_page.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/icons.dart';

import 'index.dart';

class ExpenseItemPage extends GetView<ExpensePageController> {
  const ExpenseItemPage({super.key});

  // 定义统一的圆角
  final double _cardRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    // 2. 获取当前主题颜色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<ExpensePageController>(
      init: ExpensePageController(),
      id: "expense_item",
      builder: (_) {
        return Scaffold(
          // 背景色跟随主题 (亮色:冷灰 / 暗色:深蓝灰)
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context, appColors),
          body: GestureDetector(
            // 点击空白处收起键盘
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              child: Column(
                children: [
                  _buildTypeAndAmountCard(context, appColors),
                  SizedBox(height: 16.h),
                  _buildDetailsCard(context, appColors),
                  SizedBox(height: 32.h),
                  _buildSaveButton(context, appColors)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppThemeColors appColors) {
    return JournalNavBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: "记一笔",
      rightBarItems: [
        NavBarItem(
          onTap: () => controller.showDeleteDialog(context),
          icon: Icons.delete_outline_rounded,
          color: Colors.redAccent,
        )
      ],
    );
  }

  // =======================================================
  // 1. 顶部核心卡片：类型 -> 金额 -> 商品名(强) -> 分类
  // =======================================================
  Widget _buildTypeAndAmountCard(
      BuildContext context, AppThemeColors appColors) {
    var expense = controller.expense.value;
    bool isExpense = expense.positive == 0;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w),
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 适配卡片背景
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), // 细腻的阴影
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 收支切换
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              // 背景色：主色调的极低透明度
              color: appColors.primaryText.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildSegmentBtn("支出", isExpense, appColors, () {
                  expense.positive = 0;
                  controller.update(['expense_item']);
                }),
                _buildSegmentBtn("收入", !isExpense, appColors, () {
                  expense.positive = 1;
                  controller.update(['expense_item']);
                }),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // 2. 金额输入
          Text("金额",
              style: TextStyle(color: appColors.secondaryText, fontSize: 12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "¥",
                style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryText),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  cursorColor: appColors.primaryText,
                  focusNode: controller.expensePriceFocusNode,
                  controller: controller.expensePriceTextEditController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: appColors.primaryText),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(
                        color: appColors.secondaryText.withOpacity(0.3)),
                    isDense: true,
                  ),
                  onChanged: (v) => controller.modifyExpensePrice(v),
                ),
              ),
            ],
          ),

          Divider(height: 1, color: appColors.primaryText.withOpacity(0.05)),
          SizedBox(height: 16.h),

          // 3. 商品名称输入 & AI 按钮
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("商品/事项",
                        style: TextStyle(
                            color: appColors.secondaryText, fontSize: 12)),
                    TextField(
                      cursorColor: appColors.primaryText,
                      controller: controller.expenseLabelTextEditController,
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: appColors.primaryText),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "例如：好享记账会员",
                        hintStyle: TextStyle(
                            color: appColors.secondaryText.withOpacity(0.5),
                            fontSize: 16.sp),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      onChanged: (v) => controller.modifyExpenseLabel(v),
                    ),
                  ],
                ),
              ),
              // AI 智能分类按钮
              Obx(() {
                bool isLoading = controller.isRec.value;

                return GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                          controller.autoCategorizeByLabel(context);
                        },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      // AI 按钮颜色适配
                      color: isLoading
                          ? appColors.primaryText.withOpacity(0.05)
                          : appColors.primaryText.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isLoading
                            ? Colors.transparent
                            : appColors.primaryText.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: appColors.primaryText,
                            ),
                          )
                        else
                          Icon(Icons.auto_awesome,
                              size: 14, color: appColors.primaryText),
                        SizedBox(width: 6.w),
                        Text(
                          isLoading ? "分析中..." : "智能分类",
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: appColors.primaryText,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              })
            ],
          ),

          SizedBox(height: 12.h),

          // 4. 分类选择
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Get.toNamed(Routers.ExpenseCategoryPageUrl)?.then((result) {
                if (result != null) {
                  expense.type = result['type'];
                  expense.positive = result['positive'];
                  controller.update(['expense_item']);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: appColors.primaryText.withOpacity(0.05),
                        width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: appColors.primaryText.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CategoryIconMap.getIcon(expense.type),
                        color: appColors.primaryText, size: 18),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    expense.type.isEmpty ? "选择分类" : expense.type,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: appColors.primaryText),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: appColors.secondaryText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 收支切换按钮子组件
  Widget _buildSegmentBtn(String text, bool isSelected,
      AppThemeColors appColors, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // 选中时使用卡片色，未选中透明
            color: isSelected ? appColors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              // 选中跟随主色，未选中跟随次要色
              color:
                  isSelected ? appColors.primaryText : appColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // 2. 详情卡片：日期、备注、图片
  // =======================================================
  Widget _buildDetailsCard(BuildContext context, AppThemeColors appColors) {
    var expense = controller.expense.value;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 日期选择
          GestureDetector(
            onTap: () => controller.showDatePicker(context),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: appColors.secondaryText),
                SizedBox(width: 10.w),
                Text("日期",
                    style: TextStyle(
                        fontSize: 15.sp, color: appColors.primaryText)),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: appColors.primaryText.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    expense.expenseTime,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appColors.primaryText),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(
                height: 1, color: appColors.primaryText.withOpacity(0.05)),
          ),

          // 2. 原价
          Row(
            children: [
              Icon(Icons.price_change_outlined,
                  size: 18, color: appColors.secondaryText),
              SizedBox(width: 10.w),
              Text("原价",
                  style:
                      TextStyle(fontSize: 15.sp, color: appColors.primaryText)),
              SizedBox(width: 8.w),
              Text("(可选)",
                  style: TextStyle(
                      fontSize: 12.sp, color: appColors.secondaryText)),
              const Spacer(),
              SizedBox(
                width: 100.w,
                child: TextField(
                  cursorColor: appColors.primaryText,
                  controller: controller.expenseOriginalPriceTextEditController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appColors.secondaryText,
                    decoration: TextDecoration.lineThrough, // 保持划线
                    decorationColor: appColors.secondaryText,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "无优惠",
                    hintStyle: TextStyle(
                        color: appColors.secondaryText.withOpacity(0.5),
                        fontSize: 14,
                        decoration: TextDecoration.none),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => controller.modifyExpenseOriginalPrice(v),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(
                height: 1, color: appColors.primaryText.withOpacity(0.05)),
          ),

          // 3. 图片附件
          Text("附件图片",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryText)),
          SizedBox(height: 12.h),
          _buildImageGrid(context, appColors),
        ],
      ),
    );
  }

  // 图片网格
  Widget _buildImageGrid(BuildContext context, AppThemeColors appColors) {
    var expense = controller.expense.value;
    var fileList = expense.fileList ?? [];
    double totalPadding = 18.w * 2 + 18.w * 2;
    double itemWidth =
        (MediaQuery.of(context).size.width - totalPadding - 50) / 3;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // 1. 已有图片
        ...List.generate(fileList.length, (index) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) =>
                        ImagePreviewPage(urls: fileList, initialIndex: index),
                  );
                },
                child: Container(
                  width: itemWidth,
                  height: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(fileList[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () {
                    expense.fileList?.removeAt(index);
                    controller.update(['expense_item']);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5)),
                    child:
                        const Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
              )
            ],
          );
        }),

        // 2. 添加按钮
        if (fileList.length < 9)
          GestureDetector(
            onTap: () => controller.pickAndUploadImage(context),
            child: Container(
              width: itemWidth,
              height: itemWidth,
              decoration: BoxDecoration(
                color: appColors.primaryText.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, color: appColors.secondaryText, size: 28),
            ),
          ),
      ],
    );
  }

  // =======================================================
  // 3. 底部按钮区
  // =======================================================
  Widget _buildSaveButton(BuildContext context, AppThemeColors appColors) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () => controller.updateExpense(context),
        style: ElevatedButton.styleFrom(
          // 使用主题定义的主按钮色
          backgroundColor: appColors.mainButtonBg,
          elevation: 5,
          shadowColor: appColors.mainButtonBg.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Text(
          "保存",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: appColors.mainButtonIcon),
        ),
      ),
    );
  }
}
