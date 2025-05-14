import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/models/user.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class InvitePage extends GetView<InviteController> {
  const InvitePage({super.key});

  // 主视图
  Widget _buildView(context) {
    return Stack(
      children: [
        TDCellGroup(
            scrollable: true,
            title: "账本成员",
            cells: controller.activity.value.userList
                .map((user) => _buildUserItem(user, context))
                .toList()),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TDCell(
              //   title: "账本ID",
              //   note: controller.activity.value.activityId,
              // ),
              TDButton(
                size: TDButtonSize.large,
                theme: TDButtonTheme.primary,
                text: "复制账本邀请码",
                onTap: () {
                  controller.copyInviteCode();
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  TDCell _buildUserItem(User user, BuildContext context) {
    return TDCell(
      bordered: true,
      leftIconWidget: ClipOval(
          child: Image.network(
        user.avatarUrl,
        fit: BoxFit.cover,
        width: 50.r,
        height: 50.r,
      )),
      title: user.nickname,
      description: "记了[todo]笔账，最近记录于[todo]",
      onClick: (v) {
        TDToast.showText("开发中：\n查看该用户的记账记录", context: context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InviteController>(
      init: InviteController(),
      id: "invite",
      builder: (_) {
        return Scaffold(
          appBar: BrnAppBar(
              showDefaultBottom: true,
              showLeadingDivider: true,
              title: Text(
                controller.activity.value.activityName,
                style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[800],
                    fontFamily: "SmileySans"),
              )),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }
}
