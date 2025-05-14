import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';

import 'index.dart';

class CreateActivityPage extends GetView<CreateActivityController> {
  const CreateActivityPage({super.key});

  // 主视图
  Widget _buildView(context) {
    return Column(
      children: [
        Visibility(
          visible: controller.activity.value.activityId != "",
          child: BrnTextInputFormItem(
            title: "创建人",
            hint: "",
            isEdit: false,
            controller: controller.creatorController,
          ),
        ),
        BrnSwitchFormItem(
          isRequire: false,
          value: controller.activity.value.activated,
          title: "当前账本",
          onChanged: (oldValue, newValue) {
            controller.updateActivated(newValue);
          },
        ),
        BrnBarBottomDivider(),
        BrnTextInputFormItem(
          title: "账本名称",
          isRequire: true,
          isEdit: controller.isOwner.value ||
              controller.activity.value.activityId == "",
          controller: controller.activityNameController,
        ),
        BrnBarBottomDivider(),
        BrnTextInputFormItem(
          title: "预算金额",
          isEdit: controller.isOwner.value ||
              controller.activity.value.activityId == "",
          hint: "请输入预算",
          subTitle: "为空则不限制预算",
          controller: controller.budgetController,
          inputType: BrnInputType.decimal,
        ),
        BrnBarBottomDivider(),
        Visibility(
          visible: controller.isOwner.value ||
              controller.activity.value.activityId == "",
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 8.w),
            child: BrnBigMainButton(
              title:
                  controller.activity.value.activityId == "" ? "创建" : "保存",
              onTap: () {
                controller.createActivity(context);
              },
            ),
          ),
        ),
        Visibility(
          visible: controller.activity.value.activityId != "" &&
              controller.isOwner.value,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0.h, horizontal: 8.w),
            child: BrnBigOutlineButton(
              title: "删除账本",
              lineColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                BrnMiddleInputDialog(
                    title: "确认删除此账本？",
                    message:
                        "请输入账本名【${controller.activity.value.activityName}】，以继续删除",
                    textInputAction: TextInputAction.done,
                    confirmText: "删除",
                    onCancel: () {
                      Get.back();
                    },
                    onConfirm: (v) {
                      if (v != controller.activity.value.activityName) {
                        BrnToast.showInCenter(text: "账本名不匹配", context: context);
                        return;
                      } else {
                        controller.deleteActivity(context);
                      }
                    }).show(context);
              },
            ),
          ),
        ),
        Visibility(
          visible: controller.activity.value.activityId != "" &&
              !controller.isOwner.value,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 8.w),
            child: BrnBigOutlineButton(
              onTap: () {
                controller.exitActivity(context);
              },
              lineColor: Colors.red,
              textColor: Colors.red,
              title: "退出账本",
            ),
          ),
        )
      ],
    );
  }

  PreferredSizeWidget _buildappbar() => BrnAppBar(
        themeData: BrnAppBarConfig.light(),
        automaticallyImplyLeading: true,
        showDefaultBottom: true,
        showLeadingDivider: true,
        title: Text(
          controller.activity.value.activityId == "" ? "创建账本" : "更新账本",
          style: const TextStyle(fontSize: 16),
        ),
        //多icon
        actions: const <Widget>[],
      );
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateActivityController>(
      init: CreateActivityController(),
      id: "createactivitypage",
      autoRemove: true,
      builder: (_) {
        return Scaffold(
          appBar: _buildappbar(),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }
}
