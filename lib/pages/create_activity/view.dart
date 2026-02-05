import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/util/dialog_util.dart';

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
          title: "设为默认账本",
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
        BrnRadioInputFormItem(
          title: "预算模式",
          isRequire: false,
          options: const ["月预算", "总预算"],
          value:
              controller.activity.value.budgetType == "month" ? "月预算" : "总预算",
          onChanged: (oldValue, newValue) {
            print(newValue);
            controller.updateBudgetType(newValue == "月预算" ? "month" : "total");
          },
        ),
        BrnBarBottomDivider(),
        Visibility(
            visible: controller.isOwner.value ||
                controller.activity.value.activityId == "",
            child: GestureDetector(
              onTap: () {
                controller.createActivity(context);
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                margin: EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 8.w),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                      controller.activity.value.activityId == "" ? "创建" : "保存",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            )),
        Visibility(
          visible: controller.activity.value.activityId != "" &&
              controller.isOwner.value,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0.h, horizontal: 8.w),
            child: BrnBigOutlineButton(
              title: "删除账本",
              lineColor: Colors.black,
              textColor: Colors.black,
              onTap: () {
                PremiumGlassDialog.show(context,
                    title: "确认删除此账本？",
                    content:
                        "请输入账本名【${controller.activity.value.activityName}】，以继续删除",
                    textInputAction: TextInputAction.done,
                    confirmText: "删除", onConfirmWithInput: (v) {
                  if (v != controller.activity.value.activityName) {
                    BrnToast.showInCenter(text: "账本名不匹配", context: context);
                    return;
                  } else {
                    controller.deleteActivity(context);
                  }
                });
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

  PreferredSizeWidget _buildAppbar() => BrnAppBar(
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
          appBar: _buildAppbar(),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }
}
