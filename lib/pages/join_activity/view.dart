import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/components/navbar/brn_appbar.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class JoinActivityPage extends GetView<JoinActivityController> {
  const JoinActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JoinActivityController>(
      init: JoinActivityController(),
      id: "join_activity",
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: BrnAppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: true,
            showDefaultBottom: false,
            title: Text(
              "加入账本",
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: "SmileySans",
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      _buildSearchSection(context),
                      SizedBox(height: 16.h),
                      // 结果展示区域
                      Obx(() => controller.activity.value.activityId.isNotEmpty
                          ? _buildResultCard()
                          : _buildEmptyHint()),
                    ],
                  ),
                ),
              ),
              _buildBottomAction(context),
            ],
          ),
        );
      },
    );
  }

  // 1. 搜索区：修改了 onTextChanged
  Widget _buildSearchSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("邀请码 / 口令",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TDSearchBar(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFF2F3F5),
                  controller: controller.textEditController,
                  placeHolder: "粘贴或输入邀请码",
                  autoFocus: false,
                  // 绑定新的输入监听逻辑
                  onTextChanged: controller.onInputChanged,
                  // 键盘回车也可以触发逻辑
                  onSubmitted: (_) => controller.onMainButtonTap(context),
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => controller.readClipboard(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.content_paste_rounded,
                  size: 24, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  // 2. 结果卡片 (保持不变，省略部分样式代码以节省空间)
  Widget _buildResultCard() {
    final activity = controller.activity.value;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: TDTheme.of(Get.context!).brandFocusColor, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: TDTheme.of(Get.context!).brandFocusColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
                color: TDTheme.of(Get.context!).brandColor1,
                shape: BoxShape.circle),
            child: Icon(Icons.account_balance_wallet_rounded,
                size: 32, color: TDTheme.of(Get.context!).brandNormalColor),
          ),
          SizedBox(height: 16.h),
          Text(activity.activityName,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4)),
            child: Text("由 ${activity.creatorName} 创建",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  // 3. 空状态 (保持不变)
  Widget _buildEmptyHint() {
    return Padding(
      padding: EdgeInsets.only(top: 40.h),
      child: Column(
        children: [
          Icon(Icons.search_rounded, size: 48, color: Colors.grey[300]),
          SizedBox(height: 8.h),
          Text("输入邀请码以查找账本",
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp)),
        ],
      ),
    );
  }

  // 4. 底部按钮区 (核心改动：单按钮逻辑)
  Widget _buildBottomAction(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        // 根据是否有数据，决定按钮文案
        final bool hasData = controller.activity.value.activityId.isNotEmpty;
        final String btnText = hasData ? "确认加入" : "查找账本";

        return GestureDetector(
          onTap: () => controller.joinActivity(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: hasData ? Colors.blueGrey[900] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              btnText,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }),
    );
  }
}
