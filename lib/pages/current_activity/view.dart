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
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/date_util.dart';
import 'package:journal/util/keyboard_util.dart';
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
        return Scaffold(
          appBar: _navibar(context),
          body: _buildView(context),
          floatingActionButton: _buildFloatingActionButton(),
          floatingActionButtonLocation: CustomFloatingActionButtonLocation(
              FloatingActionButtonLocation.endContained, 0, -24.h),
        );
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
        operateText: "刷新",
        action: () {
          KeyboardUtils.hide();
          controller.initData();
        });
  }

  // NavBar
  PreferredSizeWidget _navibar(BuildContext context) {
    return const TDNavBar(
      useBorderStyle: true,
      height: 48,
      useDefaultBack: false,
      titleWidget: TDImage(
        assetUrl: 'assets/images/logo_navi_bar.png',
        width: 70,
        height: 24,
      ),
      // rightBarItems: [
      //   TDNavBarItem(
      //       icon: TDIcons.usergroup_add,
      //       iconSize: 24,
      //       action: () {
      //         Get.toNamed(Routers.CreateActivityUrl);
      //       }),
      // ],
    );
  }

  // 浮动按钮
  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        if (controller.currentActivity.value.activityId == "") {
          Get.toNamed(Routers.CreateActivityUrl);
        } else {
          Get.toNamed(Routers.ChatDetailPageUrl,
              arguments: controller.currentActivity.value);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 5,
              offset: Offset(0, 5),
              spreadRadius: -3,
            ),
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 8),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 14,
              offset: Offset(0, 3),
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 24,
                height: 24,
                child: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                )),
          ],
        ),
      ),
    );
  }

  // 当前账本卡片
  Widget _buildCurrentActivityCard(Activity activity, context) {
    return Container(
      width: 385.w,
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: EasyRefresh(
        onRefresh: () async {
          // 在这里调用刷新数据的方法
          ToastUtil.heavyImpact();

          await controller.initData();
        },
        child: ListView(
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
      fontSize: 14,
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
            padding: const EdgeInsets.fromLTRB(6, 16, 16, 0),
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("账单列表", style: activeTextStyle),
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
          // 2. 渲染列表
          // 注意：这里需要再次包裹一个 Column，因为 Obx 必须返回一个 Widget
          // 如果不想多一层 Column，你的父级布局需要调整，但通常这样写最安全
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
          // ------------------------------------------------------
          // 1. 顶部日期栏 (保持不变)
          // ------------------------------------------------------
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
          BrnBarBottomDivider(),

          // ------------------------------------------------------
          // 2. 核心内容区域
          // ------------------------------------------------------
          Obx(() {
            // [模式 A]: 详细模式 -> 展示每一笔 ActivityExpenseItem
            if (controller.isExpenseListShowMode.value) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  ...expenseDateGroup.expenses
                      .map((e) => ActivityExpenseItem(e, context)),
                ],
              );
            }

            // [模式 B]: 概括模式 -> 只展示分类统计，不展示具体 Item
            else {
              // 获取分组 Map
              var typeMap = expenseDateGroup.expensesByType;

              return Column(
                children: [
                  const SizedBox(height: 8), // 稍微调整间距
                  ...typeMap.entries.map((entry) {
                    String typeName = entry.key;
                    List<Expense> typeList = entry.value;

                    // 计算该类型的子总计
                    double subTotal = typeList.fold(0.0, (prev, curr) {
                      return curr.positive == 0 ? prev + curr.price : prev;
                    });

                    // 构建简洁的统计行
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12), // 行间距
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 左侧：类型名称
                          Row(
                            children: [
                              // 可选：如果每个类型有图标，可以在这里加 Icon
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5), // 浅灰背景
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  typeName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${typeList.length}笔", // 可选：显示笔数
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
                  }),
                  const SizedBox(height: 4),
                ],
              );
            }
          }),
        ],
      ),
    );
  }
  // 用户头像

  // 账本卡片头部
}
