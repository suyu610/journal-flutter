import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/activity_card.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/components/custom_floating_action_button_location.dart';
import 'package:journal/components/expense_item.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/routers.dart';
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
    return BrnAbnormalStateWidget(
      img: Image.asset(
        'assets/images/no_data.png',
        scale: 3.0,
      ),
      isCenterVertical: true,
      title: "无默认账本",
      operateTexts: const <String>["刷新"],
      operateAreaType: OperateAreaType.textButton,
      action: (index) {
        KeyboardUtils.hide();
        controller.initData();
      },
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF3C3C43),
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
              child: controller.currentActivity.value.activityId == ""
                  ? const Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 4),
            Text(
              controller.currentActivity.value.activityId == ""
                  ? "创建账本"
                  : "记一笔",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w600,
              ),
            ),
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
    List<ExpenseDateGroup> groupList = controller.expenseDateGroupList;

    return Column(
      children: groupList.map((e) => _buildSingleDateCard(e, context)).toList(),
    );
  }

  // 单个日期卡片
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
          Text(
            expenseDateGroup.date,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              fontFamily: 'SourceCodePro',
              fontWeight: FontWeight.w600,
              height: 0,
            ),
          ),
          const SizedBox(height: 16),
          ...expenseDateGroup.expenses
              .map((e) => ActivityExpenseItem(e, context)),
        ],
      ),
    );
  }

  // 用户头像

  // 账本卡片头部
}
