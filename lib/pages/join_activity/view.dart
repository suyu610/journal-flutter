import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/components/bruno/src/components/navbar/brn_appbar.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class JoinActivityPage extends GetView<JoinActivityController> {
  const JoinActivityPage({super.key});

  // 主视图
  Widget _buildView(context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            width: 385.w,
            height: 50.h,
            child: BrnAppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: true,
              showDefaultBottom: true,
              showLeadingDivider: true,
              title: Text(
                "加入账本",
                style: TextStyle(fontSize: 18.sp, fontFamily: "SmileySans"),
              ),
            ),
          ),
          TDSearchBar(
            controller: controller.textEditController,
            // hintText: "请输入账本邀请码",
            placeHolder: "请输入带有邀请码的文本",
            autoFocus: false,
            onTextChanged: (v) {
              controller.id.value = v;
            },
          ),
          Visibility(
            visible: true, // controller.activity.value.activityId.isNotEmpty,
            child: TDCell(
              title: "账本名称",
              note: controller.activity.value.activityName,
            ),
          ),
          Visibility(
            visible: true, //controller.activity.value.activityId.isNotEmpty,
            child: TDCell(
              title: "创建人",
              note: controller.activity.value.creatorName,
            ),
          ),
          Visibility(
            visible: true, // controller.activity.value.activityId.isNotEmpty,
            child: TDCell(
              title: "最近更新时间",
              note: controller.activity.value.updateTime,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => TDButton(
                      width: ((385 - 60) / 2).w,
                      theme: controller.id.value.isEmpty
                          ? TDButtonTheme.defaultTheme
                          : TDButtonTheme.primary,
                      size: TDButtonSize.large,
                      text: "查找账本",
                      onTap: () {
                        controller.searchActivity(context);
                      },
                    )),
                const SizedBox(
                  width: 20,
                ),
                Obx(() => TDButton(
                      width: ((385 - 60) / 2).w,
                      theme: controller.activity.value.activityId.isEmpty
                          ? TDButtonTheme.defaultTheme
                          : TDButtonTheme.primary,
                      // type: TDButtonType.outline,
                      size: TDButtonSize.large,
                      text: "加入账本",
                      onTap: () {
                        controller.joinActivity();
                      },
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TDButton(
            theme: TDButtonTheme.primary,
            // type: TDButtonType.ghost,
            size: TDButtonSize.large,
            text: "读取剪贴板",
            isBlock: true,
            onTap: () {
              controller.readClipboard();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JoinActivityController>(
      init: JoinActivityController(),
      id: "join_activity",
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }
}
