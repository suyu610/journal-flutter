import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/login/sms_code/widget/verification_code.dart';

import 'logic.dart';

class CodePage extends StatelessWidget {
  const CodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<CodeLogic>();
    // 2. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      // 背景色适配
      backgroundColor: appColors.backgroundColor,
      // 使用 SafeArea 保证不被刘海遮挡
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // 关闭按钮
              InkWell(
                onTap: () {
                  Get.back();
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close,
                    size: 28.r,
                    color: appColors.primaryText, // 适配图标色
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // 大标题
              Text(
                "请输入验证码",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                  color: appColors.primaryText, // 适配标题色
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 12.h),

              // 副标题
              Obx(() => Text(
                    "已向您的${logic.phoneNum.isEmail ? "邮箱" : "手机号"} ${logic.phoneNum} 发送验证码",
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.5,
                      color: appColors.secondaryText, // 适配次要文本色
                    ),
                  )),

              SizedBox(height: 48.h),

              // 验证码输入框 (需要 VerificationCode 组件支持颜色参数)
              Center(
                child: VerificationCode(
                  autoFocused: true,
                  height: 50,
                  style: CodeStyle.rectangle,
                  maxLength: 4,
                  itemWidth: 50,
                  itemSpace: 30, // 稍微减小间距以适应小屏
                  borderWidth: 1.5,
                  contentSize: 24.sp,
                  // 适配颜色：
                  contentColor: appColors.primaryText, // 输入数字颜色
                  borderSelectColor: appColors.primaryText, // 选中框颜色
                  borderColor:
                      appColors.secondaryText.withOpacity(0.2), // 未选中框颜色
                  onCompleted: (String value) {
                    logic.codeInputCompleted(code: value);
                  },
                  onChanged: (value) {
                    logic.state.code.value = value;
                  },
                ),
              ),

              SizedBox(height: 32.h),

              // 重新发送按钮
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        logic.reSendCode();
                      },
                      child: Text(
                        logic.state.countDownNum.value == -1
                            ? "重新发送"
                            : "重新发送 (${logic.state.countDownNum.value}s)",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          // 倒计时中灰色，可点击时蓝色(或其他强调色)
                          color: logic.state.countDownNum.value == -1
                              ? Colors.blueAccent
                              : appColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 48.h),

              // 下一步按钮
              Obx(() {
                // 按钮是否可用
                bool isEnabled = logic.codeIsCompleted;

                return GestureDetector(
                  onTap: () {
                    if (isEnabled) logic.next(context);
                  },
                  child: Container(
                    height: 50.h,
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.r), // 圆角胶囊
                      // 适配按钮背景色
                      color: isEnabled
                          ? appColors.mainButtonBg
                          : appColors.secondaryText.withOpacity(0.1),
                      // 增加阴影
                      boxShadow: isEnabled
                          ? [
                              BoxShadow(
                                  color:
                                      appColors.mainButtonBg.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                    ),
                    child: Text(
                      "下一步",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        // 适配按钮文字色
                        color: isEnabled
                            ? appColors.mainButtonIcon
                            : appColors.secondaryText.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
