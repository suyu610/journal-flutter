import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/activity_card.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/components/custom_floating_action_button_location.dart';
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
          backgroundColor: const Color(0xfff3f3f3),
          appBar: _buildappbar(context),
          body: _buildView(context),
          floatingActionButton: _buildFloatingActionButton(),
          floatingActionButtonLocation: CustomFloatingActionButtonLocation(
              FloatingActionButtonLocation.endContained, 0, -24.h),
        );
      },
    );
  }

// 浮动按钮
  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routers.CreateActivityUrl);
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
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                )),
            const SizedBox(width: 4),
            const Text(
              "新建账本",
              textAlign: TextAlign.center,
              style: TextStyle(
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

  // 浮动按钮

// 尾巴
  Widget _buildFooter(Activity activity, context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () =>
              Get.toNamed(Routers.CreateActivityUrl, arguments: activity),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
            decoration: BoxDecoration(
                color: const Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(20.r)),
            child: Text(
              "更多",
              style: TextStyle(color: const Color(0xff181818), fontSize: 12.sp),
            ),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                var a = Get.toNamed(Routers.ExpenseListPageUrl,
                    arguments: activity);
                Log().d(a.toString());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
                decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xff3C3C43), width: 1),
                    borderRadius: BorderRadius.circular(20.r)),
                child: Text(
                  "账单详情",
                  style: TextStyle(fontSize: 12.sp),
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
                    color: const Color(0xff3C3C43),
                    borderRadius: BorderRadius.circular(20.r)),
                child: Text(
                  "我记一笔",
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // 主视图
  Widget _buildView(context) {
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
                  color: Colors.white,
                  height: 600.h,
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: BrnAbnormalStateWidget(
                    img: Image.asset(
                      'assets/images/no_data.png',
                      scale: 3.0,
                    ),
                    isCenterVertical: true,
                    title: "未找到账本",
                    operateTexts: const <String>["点击重试", "创建账本"],
                    operateAreaType: OperateAreaType.doubleButton,
                    action: (index) {
                      if (index == 0) {
                        controller.fetchSelfActivityList();
                      } else {
                        Get.toNamed(Routers.CreateActivityUrl);
                      }
                    },
                  ),
                )
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

  PreferredSizeWidget _buildappbar(context) => TDNavBar(
          useBorderStyle: true,
          height: 48,
          useDefaultBack: false,
          titleWidget: Text(
            "账本列表",
            style: TextStyle(fontSize: 18.sp, fontFamily: "SmileySans"),
          ),
          border: TDNavBarItemBorder(width: 0, color: Colors.transparent),
          // 创建账本
          rightBarItems: [
            TDNavBarItem(
                iconWidget: const Text("加入账本", style: TextStyle()),
                action: () {
                  Get.toNamed(Routers.JoinActivityPageUrl);
                  return;
                }),
          ]);
}
