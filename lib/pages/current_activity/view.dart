import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/activity_card.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/components/custom_floating_action_button_location.dart';
import 'package:journal/components/empty_item.dart';
import 'package:journal/components/expense_item.dart';
import 'package:journal/config/theme_config.dart';
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
              backgroundColor: backgroundColor,
              appBar: _navibar(context),
              body: _buildView(context),
              floatingActionButtonAnimator:
                  FloatingActionButtonAnimator.scaling,
              floatingActionButton: _buildFloatingActionButton(),
              floatingActionButtonLocation: CustomFloatingActionButtonLocation(
                  FloatingActionButtonLocation.endContained,
                  0,
                  controller.shouldShowAddButton.value ? -24.h : 999.h),
            ));
      },
    );
  }

  // 主视图
  Widget _buildView(context) {
    Activity activity = controller.currentActivity.value;
    return Container(
      color: activity.activityId == "" ? Colors.white : const Color(0xfff3f3f3),
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
          // KeyboardUtils.hide();
          // controller.initData();
        });
  }

  // NavBar
  PreferredSizeWidget _navibar(BuildContext context) {
    return TDNavBar(
        useBorderStyle: true,
        height: 48,
        useDefaultBack: false,
        titleWidget: Obx(() => Text(
              controller.shouldShowAddButton.value &&
                      controller.currentActivity.value.activityName.isNotEmpty
                  ? controller.currentActivity.value.activityName
                  : "当前活动",
              style: TextStyle(fontSize: 18.sp, fontFamily: "SmileySans"),
            )));
  }

  // 当前账本卡片
  Widget _buildCurrentActivityCard(Activity activity, context) {
    return Container(
      width: 385.w,
      child: EasyRefresh(
        onRefresh: () async {
          // 在这里调用刷新数据的方法
          ToastUtil.heavyImpact();
          await controller.initData();
        },
        child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12),
          controller: controller.scrollController,
          children: [
            SizedBox(
              height: 12.h,
            ),
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
                    style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 当前账本详情
  _buildActivityDetail(Activity activity, context) {
    TextStyle activeTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontFamily: 'SourceCodePro',
      fontWeight: FontWeight.w600,
      height: 0,
    );
    TextStyle inactiveTextStyle = const TextStyle(
      color: Colors.black54,
      fontSize: 12,
      fontFamily: 'SourceCodePro',
      fontWeight: FontWeight.w400,
      height: 0,
    );
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("账单列表", style: inactiveTextStyle),
                GestureDetector(
                  onTap: () {
                    controller.switchExpenseListShowMode();
                  },
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
                      const Text(" / "),
                      Obx(() => Text(
                            "概括",
                            style: !controller.isExpenseListShowMode.value
                                ? activeTextStyle
                                : inactiveTextStyle,
                          )),
                    ],
                  ),
                ),
              ],
            )),
        Obx(() {
          return Column(
            children: controller.expenseDateGroupList
                .map((e) => _buildSingleDateCard(e, context))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSingleDateCard(ExpenseDateGroup expenseDateGroup, context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateUtil.getFriendlyDate(expenseDateGroup.date),
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                  fontFamily: 'SourceCodePro',
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
              Row(
                children: [
                  const Text("支出",
                      style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontFamily: 'SourceCodePro')),
                  const SizedBox(width: 6),
                  Text(expenseDateGroup.totalExpense.toStringAsFixed(2),
                      style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Text("元",
                      style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontFamily: 'SourceCodePro'))
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          BrnBarBottomDivider(), // 修正：加上 const

          // ------------------------------------------------------
          // 2. 核心内容区域
          // ------------------------------------------------------
          Obx(() {
            // [模式 A]: 详细模式
            if (controller.isExpenseListShowMode.value) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  ...expenseDateGroup.expenses
                      .map((e) => ActivityExpenseItem(e, context)),
                ],
              );
            } else {
              // [模式 B]: 概括模式 (分类统计)

              // 1. 预处理数据：计算每个分类的总额，存入 List 以便排序
              var typeMap = expenseDateGroup.expensesByType;

              // 将 Map 转换为 List<{name, list, total}> 的结构方便排序
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

              // 2. 排序：按金额从大到小排序
              sortedList.sort((a, b) =>
                  (b["subTotal"] as double).compareTo(a["subTotal"] as double));

              double totalExpense = expenseDateGroup.totalExpense;
              // 防止总金额为0导致除法错误
              if (totalExpense == 0) totalExpense = 1;

              return Column(
                children: [
                  const SizedBox(height: 12),
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
                              Container(
                                // 核心逻辑：计算宽度
                                width: (subTotal / totalExpense * screenWidth)
                                    .clamp(65.0, maxBarWidth),
                                padding: const EdgeInsets.only(
                                    top: 4, bottom: 4, left: 6, right: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.centerLeft, // 确保文字靠左
                                child: Text(
                                  typeName,
                                  maxLines: 1, // 防止换行破坏高度
                                  overflow: TextOverflow.ellipsis, // 宽度不够时显示省略号
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 笔数显示
                              Text(
                                "${typeList.length}笔",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),

                          // 右侧：该类型金额
                          Text(
                            "¥${subTotal.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontFamily: 'SourceCodePro',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }), // 记得转回 List
                  const SizedBox(height: 4),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  // 回到顶部
  Widget? _buildFloatingActionButton() {
    return FloatingActionButton(
      mini: true,
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
      backgroundColor: Colors.blueGrey[900],
      child: const Icon(
        Icons.arrow_upward,
        color: Colors.white,
      ),
    );
  }
}
