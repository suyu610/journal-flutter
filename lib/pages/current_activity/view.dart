import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/activity_card.dart';
import 'package:journal/components/custom_floating_action_button_location.dart';
import 'package:journal/components/empty_item.dart';
import 'package:journal/components/expense_item.dart';
// 1. 引入主题扩展
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/date_util.dart';
import 'package:journal/util/toast_util.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class CurrentActivityPage extends GetView<CurrentActivityController> {
  const CurrentActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CurrentActivityController>(
      init: CurrentActivityController(),
      id: "current_activity",
      autoRemove: false,
      builder: (_) {
        return Obx(() => Scaffold(
              // 背景色跟随主题
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: _navibar(context),
              body: _buildView(context),
              floatingActionButtonAnimator:
                  FloatingActionButtonAnimator.scaling,
              floatingActionButton: _buildFloatingActionButton(context),
              floatingActionButtonLocation: CustomFloatingActionButtonLocation(
                  FloatingActionButtonLocation.endContained,
                  0,
                  controller.shouldShowAddButton.value ? -24.h : 999.h),
            ));
      },
    );
  }

  // 主视图
  Widget _buildView(BuildContext context) {
    Activity activity = controller.currentActivity.value;
    // 移除硬编码背景色，直接透明，由 Scaffold 控制背景
    return Container(
      color: Colors.transparent,
      child: activity.activityId == ""
          ? _buildEmptyCard()
          : _buildCurrentActivityCard(activity, context),
    );
  }

  _buildEmptyCard() {
    return buildEmptyItem(
        title: "暂无默认账本",
        operateText: "添加",
        action: () {
          Get.toNamed(Routers.CreateActivityUrl);
        });
  }

  // NavBar
  PreferredSizeWidget _navibar(BuildContext context) {
    // 获取主题色用于标题
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return TDNavBar(
        useBorderStyle: false, // 去掉默认边框，更洁净
        height: 48,
        useDefaultBack: false,
        backgroundColor: Colors.transparent, // 沉浸式
        titleWidget: Obx(() => Text(
              controller.shouldShowAddButton.value &&
                      controller.currentActivity.value.activityName.isNotEmpty
                  ? controller.currentActivity.value.activityName
                  : "当前活动",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: "SmileySans",
                  color: appColors.primaryText // 适配深色
                  ),
            )));
  }

  // 当前账本卡片
  Widget _buildCurrentActivityCard(Activity activity, BuildContext context) {
    return SizedBox(
      width: 385.w,
      child: EasyRefresh(
        onRefresh: () async {
          ToastUtil.heavyImpact();
          await controller.initData();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16), // 统一边距
          controller: controller.scrollController,
          children: [
            SizedBox(height: 12.h),

            // 顶部的大卡片 (建议你也检查一下 activityCard 内部是否使用了 appColors)
            activityCard(
              activity,
              context,
              controller.updateView,
            ),

            _buildActivityDetail(activity, context),

            // 加载更多指示器
            if (controller.hasNextPage.value)
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 16),
                child: CupertinoActivityIndicator(),
              )
            else
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                child: Center(
                  child: Text(
                    "没有更多了",
                    style: TextStyle(
                        // 适配深色
                        color: Theme.of(context)
                            .extension<AppThemeColors>()!
                            .secondaryText,
                        fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 当前账本详情 (切换按钮区域)
  Widget _buildActivityDetail(Activity activity, BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    // 选中状态：深色字
    TextStyle activeTextStyle = TextStyle(
      color: appColors.primaryText,
      fontSize: 12,
      fontFamily: 'SourceCodePro',
      fontWeight: FontWeight.w700,
    );

    // 未选中状态：浅色字
    TextStyle inactiveTextStyle = TextStyle(
      color: appColors.secondaryText,
      fontSize: 12,
      fontFamily: 'SourceCodePro',
      fontWeight: FontWeight.w400,
    );

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.fromLTRB(6, 16, 6, 8), // 增加一点顶部间距
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("账单列表", style: inactiveTextStyle),
                GestureDetector(
                  onTap: () {
                    controller.switchExpenseListShowMode();
                  },
                  child: Container(
                    // 增加点击区域，体验更好
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Obx(() => Text(
                              "详细",
                              style: controller.isExpenseListShowMode.value
                                  ? activeTextStyle
                                  : inactiveTextStyle,
                            )),
                        Text(" / ", style: inactiveTextStyle),
                        Obx(() => Text(
                              "概括",
                              style: !controller.isExpenseListShowMode.value
                                  ? activeTextStyle
                                  : inactiveTextStyle,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            )),
        Obx(() {
          return Column(
            children: controller.expenseDateGroupList
                .map((e) => _buildSingleDateCard(e, context, appColors))
                .toList(),
          );
        }),
      ],
    );
  }

  // 单日卡片 / 概览卡片
  Widget _buildSingleDateCard(ExpenseDateGroup expenseDateGroup,
      BuildContext context, AppThemeColors appColors) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      margin: const EdgeInsets.only(bottom: 16), // 卡片间距加大，更有呼吸感
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 适配深色背景
        borderRadius: BorderRadius.circular(24), // 统一 24px 大圆角
        boxShadow: [
          // 高端弥散阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片头部：日期 + 总额
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateUtil.getFriendlyDate(expenseDateGroup.date),
                style: TextStyle(
                  color: appColors.primaryText,
                  fontSize: 15,
                  fontFamily: 'SourceCodePro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("支出",
                      style: TextStyle(
                          color: appColors.secondaryText,
                          fontSize: 12,
                          fontFamily: 'SourceCodePro')),
                  const SizedBox(width: 6),
                  Text(expenseDateGroup.totalExpense.toStringAsFixed(2),
                      style: TextStyle(
                          color: appColors.primaryText,
                          fontSize: 16,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 2),
                  Text("元",
                      style: TextStyle(
                          color: appColors.secondaryText,
                          fontSize: 12,
                          fontFamily: 'SourceCodePro'))
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 分割线：使用极淡的主题色
          Divider(
              height: 1,
              thickness: 0.5,
              color: appColors.primaryText.withOpacity(0.05)),

          // ------------------------------------------------------
          // 2. 核心内容区域
          // ------------------------------------------------------
          Obx(() {
            // [模式 A]: 详细模式
            if (controller.isExpenseListShowMode.value) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  // 这里假设 ActivityExpenseItem 内部也处理了文字颜色
                  // 如果没有，你需要进去改一下 Text style color 为 appColors.primaryText
                  ...expenseDateGroup.expenses
                      .map((e) => ActivityExpenseItem(e, context)),
                  const SizedBox(height: 8),
                ],
              );
            } else {
              // [模式 B]: 概括模式 (分类统计)
              var typeMap = expenseDateGroup.expensesByType;
              var sortedList = typeMap.entries.map((entry) {
                double subTotal = entry.value.fold(0.0, (prev, curr) {
                  return curr.positive == 0 ? prev + curr.price : prev;
                });
                return {
                  "typeName": entry.key,
                  "list": entry.value,
                  "subTotal": subTotal,
                };
              }).toList();

              sortedList.sort((a, b) =>
                  (b["subTotal"] as double).compareTo(a["subTotal"] as double));

              double totalExpense = expenseDateGroup.totalExpense;
              if (totalExpense == 0) totalExpense = 1;

              return Column(
                children: [
                  const SizedBox(height: 16),
                  ...sortedList.map((data) {
                    String typeName = data["typeName"] as String;
                    List<Expense> typeList = data["list"] as List<Expense>;
                    double subTotal = data["subTotal"] as double;
                    double maxBarWidth = screenWidth - 160.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // 统计条
                              Container(
                                width: (subTotal / totalExpense * screenWidth)
                                    .clamp(65.0, maxBarWidth),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  // 核心修改：使用 primaryText 的极低透明度
                                  // 这样在黑/白模式下，都能显示出淡淡的条纹，非常高级
                                  color:
                                      appColors.primaryText.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  typeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    // 条纹内的文字颜色
                                    color:
                                        appColors.primaryText.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${typeList.length}笔",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appColors.secondaryText,
                                ),
                              ),
                            ],
                          ),

                          // 右侧金额
                          Text(
                            "¥${subTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: appColors.primaryText, // 适配深色
                              fontFamily: 'SourceCodePro',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  // 回到顶部按钮
  Widget _buildFloatingActionButton(BuildContext context) {
    // 按钮颜色跟随主题 (mainButtonBg)
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return FloatingActionButton(
      mini: true,
      elevation: 4, // 稍微加一点阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      onPressed: () {
        controller.scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      },
      // 使用配置好的按钮色
      backgroundColor: appColors.mainButtonBg,
      child: Icon(
        Icons.arrow_upward_rounded,
        color: appColors.mainButtonIcon, // 图标颜色
        size: 20,
      ),
    );
  }
}
