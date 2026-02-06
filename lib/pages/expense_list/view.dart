import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/activity_card.dart';
import 'package:journal/components/expense_item.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/routers.dart';

import 'index.dart';

class ExpenseListPage extends GetView<ExpenseListController> {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<ExpenseListController>(
      init: ExpenseListController(),
      id: "expense_list",
      builder: (_) {
        return Scaffold(
          // 背景色跟随主题
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context, appColors),
          body: _buildView(context, appColors),
        );
      },
    );
  }

  // appbar
  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppThemeColors appColors) {
    return AppBar(
      leadingWidth: 80.w,
      backgroundColor: Colors.transparent, // 沉浸式
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new,
            color: appColors.primaryText, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        controller.activity.value.activityName,
        style: TextStyle(
            fontSize: 18.sp,
            color: appColors.primaryText, // 适配标题色
            fontFamily: "SmileySans"),
      ),
    );
  }

  // 主视图
  Widget _buildView(BuildContext context, AppThemeColors appColors) {
    Activity activity = controller.activity.value;

    return Stack(
      children: [
        Container(
            // 移除硬编码背景色，设为透明
            color: Colors.transparent,
            padding: const EdgeInsets.only(left: 18.0, right: 18, bottom: 0),
            child: buildMainView(activity, context, appColors)),
      ],
    );
  }

  Widget buildMainView(
      Activity activity, BuildContext context, AppThemeColors appColors) {
    return Container(
      width: 385.w,
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 顶部的大卡片 (已在之前适配过，会自动跟随主题)
            activityCard(activity, context, controller.update,
                topRightWidget: const SizedBox()),
            SizedBox(
              height: 16.h,
            ),
            _buildActivityDetail(activity, context, appColors),
            SizedBox(
              height: 20.h,
            ),
            // Loading 状态
            controller.hasNextPage.value
                ? const CupertinoActivityIndicator()
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 40),
                      child: Text(
                        "没有更多了",
                        style: TextStyle(
                            color: appColors.secondaryText, // 适配文字
                            fontSize: 12.sp),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _buildActivityDetail(
      Activity activity, BuildContext context, AppThemeColors appColors) {
    List<ExpenseDateGroup> groupList = controller.expenseDateGroupList;
    return Column(
        children: groupList
            .map((e) => _buildSingleDateCard(e, context, appColors))
            .toList());
  }

  Widget _buildSingleDateCard(ExpenseDateGroup expenseDateGroup,
      BuildContext context, AppThemeColors appColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 适配卡片背景
        borderRadius: BorderRadius.circular(24), // 统一 24px 大圆角
        boxShadow: [
          // 统一的高级弥散阴影
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
          // 日期标题
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              expenseDateGroup.date,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryText, // 适配文字
                  fontFamily: 'SourceCodePro'),
            ),
          ),
          // 分割线
          Divider(
              height: 1,
              thickness: 0.5,
              color: appColors.primaryText.withOpacity(0.05)),
          SizedBox(height: 12.h),

          // 列表项 (ActivityExpenseItem 内部已适配)
          ...expenseDateGroup.expenses
              .map((e) => ActivityExpenseItem(e, context))
        ],
      ),
    );
  }

  // 消费详情 (虽然被忽略了，但也顺手改一下颜色，以防万一)
  // ignore: unused_element
  Widget _buildActivityConsumptionItem(
      Expense e, BuildContext context, AppThemeColors appColors) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routers.ExpenseItemPageUrl, arguments: e);
      },
      child: Container(
        color: appColors.cardBackground,
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.ideographic,
                  children: [
                    Text(
                      e.type,
                      style: TextStyle(
                          color: appColors.primaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 6.w,
                    ),
                    Text(
                      "¥${e.price}",
                      style: TextStyle(
                          color: appColors.primaryText,
                          fontFamily: "SourceCodePro",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  e.expenseTime,
                  style: TextStyle(
                      color: appColors.secondaryText,
                      fontSize: 12.sp,
                      fontFamily: "SourceCodePro"),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  e.label,
                  style: TextStyle(
                    color: appColors.secondaryText,
                    fontSize: 12.sp,
                  ),
                )
              ],
            ),
            // ... 右侧头像部分保持原样或根据需要适配 ...
          ],
        ),
      ),
    );
  }
}
