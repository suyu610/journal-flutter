import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/activity_card.dart';
import 'package:journal/components/empty_item.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/toast_util.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class ActivityListPage extends GetView<ActivityListController> {
  const ActivityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActivityListController>(
      init: ActivityListController(),
      id: "activity_list",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          // 背景色跟随主题
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppbar(context),
          body: _buildView(context),
          // floatingActionButton: _buildFloatingActionButton(),
          // floatingActionButtonLocation: CustomFloatingActionButtonLocation(
          // FloatingActionButtonLocation.endContained, 0, -24.h),
        );
      },
    );
  }

// 尾巴
  Widget _buildFooter(Activity activity, BuildContext context) {
    // 获取主题颜色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              var a =
                  Get.toNamed(Routers.ExpenseListPageUrl, arguments: activity);
              Log().d(a.toString());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
              decoration: BoxDecoration(
                  // 边框色适配：使用主要文字色
                  border: Border.all(color: appColors.primaryText, width: 1),
                  borderRadius: BorderRadius.circular(20.r)),
              child: Text(
                "账单详情",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: appColors.primaryText, // 文字色适配
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          // 我记一笔
          GestureDetector(
            onTap: () {
              Get.toNamed(Routers.ChatDetailPageUrl, arguments: activity);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
              decoration: BoxDecoration(
                  // 背景色适配：使用定义好的主按钮背景
                  color: appColors.mainButtonBg,
                  borderRadius: BorderRadius.circular(20.r)),
              child: Text(
                "我记一笔",
                style: TextStyle(
                    // 文字色适配：使用定义好的主按钮图标/文字色
                    color: appColors.mainButtonIcon,
                    fontSize: 12.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 主视图
  Widget _buildView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h),
      child: EasyRefresh(
        controller: controller.refreshController,
        onRefresh: () async {
          // 震动
          ToastUtil.heavyImpact();
          controller.initData();
        },
        child: SingleChildScrollView(
          controller: controller.scrollController,
          child: controller.activityList.isEmpty &&
                  controller.joinedActivityList.isEmpty
              ? Container(
                  // 移除硬编码的 Colors.white，设为透明，让 EmptyItem 自己的卡片样式展示出来
                  color: Colors.transparent,
                  height: 600.h,
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: buildEmptyItem(
                      title: "未找到账本",
                      operateText: "点击添加",
                      action: () {
                        Get.toNamed(Routers.CreateActivityUrl);
                      }))
              : ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 800.h),
                  child: Column(
                    children: [
                      Column(
                          children: controller.activityList
                              .map((e) => activityCard(
                                  e, context, controller.update,
                                  footerWidget: _buildFooter(e, context)))
                              .toList()),
                      Column(
                          children: controller.joinedActivityList
                              .map((e) => activityCard(
                                  e, context, controller.update,
                                  footerWidget: _buildFooter(e, context)))
                              .toList())
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return TDNavBar(
        useBorderStyle: true,
        height: 48,
        useDefaultBack: false,
        backgroundColor: Colors.transparent, // 沉浸式透明背景
        titleWidget: Text(
          "账本列表",
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: "SmileySans",
            color: appColors.primaryText, // 标题颜色适配
          ),
        ),
        border: TDNavBarItemBorder(width: 0, color: Colors.transparent),
        leftBarItems: [
          TDNavBarItem(
              iconWidget: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text("加入多人账本",
                    style: TextStyle(
                      // 按钮文字适配
                      color: appColors.primaryText,
                      fontFamily: "SmileySans",
                      fontWeight: FontWeight.w500,
                    )),
              ),
              action: () {
                Get.toNamed(Routers.JoinActivityPageUrl);
                return;
              }),
        ],
        rightBarItems: [
          TDNavBarItem(
              iconWidget: Text("新建",
                  style: TextStyle(
                    fontFamily: "SmileySans",
                    color: appColors.primaryText,
                    fontWeight: FontWeight.w500,
                  )),
              action: () {
                Get.toNamed(Routers.CreateActivityUrl);
                return;
              }),
        ]);
  }
}
