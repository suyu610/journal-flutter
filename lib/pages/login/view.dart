import 'dart:io';

import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/sp_util.dart';
import 'package:journal/util/toast_util.dart';

import 'logic.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<LoginLogic>();
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          height: Get.height,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 100.h),
              _buildWelcomeText(appColors),
              SizedBox(height: 6.h),
              _buildRegTipText(logic, appColors),
              SizedBox(height: 40.h),
              _buildInput(logic, appColors),
              SizedBox(height: 25.h),
              _buildAgreeLicense(context, logic, appColors),
              _buildNextStepButton(context, logic, appColors),
              const Spacer(),
              _buildAnotherLoginType(context, logic, appColors),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- 顶部文字 ---
  Widget _buildWelcomeText(AppThemeColors appColors) {
    return Text(
      "欢迎登陆 好享记账",
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 28.sp,
        color: appColors.primaryText,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildRegTipText(LoginLogic logic, AppThemeColors appColors) {
    return Obx(() => Text(
          "未注册的${logic.isEmailMode.value ? "邮箱" : "手机号"}登陆成功后将自动注册",
          style: TextStyle(
            fontSize: 14.sp,
            color: appColors.secondaryText,
          ),
        ));
  }

  // --- 输入框 ---
  Widget _buildInput(LoginLogic logic, AppThemeColors appColors) {
    return Obx(() {
      final isEmail = logic.isEmailMode.value;
      return Container(
        decoration: BoxDecoration(
            color: appColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ]),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          children: [
            SizedBox(
              width: 50.w,
              child: Text(
                isEmail ? "邮箱" : "+86",
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryText),
              ),
            ),
            Expanded(
              child: TextField(
                controller: logic.controller,
                textInputAction: TextInputAction.done,
                keyboardType:
                    isEmail ? TextInputType.emailAddress : TextInputType.number,
                maxLength: isEmail ? 50 : 11,
                autofocus: false,
                cursorColor: appColors.primaryText,
                style: TextStyle(
                    fontSize: 16.sp,
                    color: appColors.primaryText,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: "",
                  hintText: isEmail ? "请输入邮箱" : "请输入手机号",
                  hintStyle: TextStyle(
                      color: appColors.secondaryText.withOpacity(0.5),
                      fontSize: 15.sp),
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                inputFormatters: [
                  isEmail
                      ? FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9@.]'))
                      : FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onChanged: (value) {
                  logic.state.phoneNum.value = value;
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- 协议 ---
  Widget _buildAgreeLicense(
      BuildContext context, LoginLogic logic, AppThemeColors appColors) {
    return InkWell(
      onTap: () => logic.state.isAgree.toggle(),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() {
            final isAgree = logic.state.isAgree.value;
            return Icon(
              isAgree ? Icons.check_circle : Icons.circle_outlined,
              size: 20.r,
              color: isAgree ? appColors.primaryText : appColors.secondaryText,
            );
          }),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '我已阅读并同意 ',
                style:
                    TextStyle(color: appColors.secondaryText, fontSize: 12.sp),
                children: [
                  TextSpan(
                    text: '《隐私协议》',
                    style: TextStyle(
                        color: appColors.primaryText,
                        fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        ToastUtil.lightImpact();
                        Get.toNamed(Routers.WebViewPageUrl, arguments: {
                          "url":
                              "https://blog.uuorb.com/archives/journal-privacy",
                          "title": "隐私协议"
                        });
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 按钮 ---
  Widget _buildNextStepButton(
      BuildContext context, LoginLogic logic, AppThemeColors appColors) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30.w),
      child: Obx(() {
        final isEmail = logic.isEmailMode.value;
        final input = logic.state.phoneNum.value;
        final isValid = isEmail ? input.isEmail : input.isPhoneNumber;

        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () => logic.next(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid
                  ? appColors.mainButtonBg
                  : appColors.secondaryText.withOpacity(0.1),
              elevation: isValid ? 5 : 0,
              shadowColor: isValid
                  ? appColors.mainButtonBg.withOpacity(0.3)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: Text(
              "下一步",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isValid
                    ? appColors.mainButtonIcon
                    : appColors.secondaryText.withOpacity(0.5),
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- 第三方登录 (恢复图片资源) ---
  Widget _buildAnotherLoginType(
      BuildContext context, LoginLogic logic, AppThemeColors appColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "或通过以下方式登录",
          style: TextStyle(fontSize: 12.sp, color: appColors.secondaryText),
        ),
        SizedBox(height: 30.h),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSwitchModeButton(logic, appColors),
                if (Platform.isIOS) SizedBox(width: 60.w),
                if (Platform.isIOS)
                  _buildAppleButton(context, logic, appColors),
                if (Platform.isIOS && SpUtil.getWeChatInstalled())
                  SizedBox(width: 60.w),
                if (SpUtil.getWeChatInstalled())
                  _buildWechatButton(context, logic, appColors),
              ],
            )),
        SizedBox(height: 40.h),
        TextButton(
          onPressed: () => logic.contact(),
          child: Text(
            "联系我们",
            style: TextStyle(color: appColors.secondaryText, fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  // 1. 切换 手机/邮箱 按钮 (恢复图片资源 + 适配颜色)
  Widget _buildSwitchModeButton(LoginLogic logic, AppThemeColors appColors) {
    bool isEmailMode = logic.isEmailMode.value;
    return CustomAuthButton(
      onPressed: () => logic.toggleEmailMode(),
      style: _getCircleButtonStyle(
        bgColor: appColors.cardBackground,
        iconColor: appColors.primaryText, // 传入主色，用于 Tint 图片
        appColors: appColors,
      ),
      authIcon: AuthIcon(
        iconSize: 22.r,
        // 恢复原来的图片路径
        iconPath:
            isEmailMode ? "assets/icons/phone.png" : "assets/icons/email.png",
        // 关键点：给图片着色，适配深浅模式
        color: appColors.primaryText,
      ),
    );
  }

  // 2. Apple 登录按钮 (恢复图片资源 + 适配颜色)
  Widget _buildAppleButton(
      BuildContext context, LoginLogic logic, AppThemeColors appColors) {
    return CustomAuthButton(
      onPressed: () {
        try {
          logic.loginWithApple(context);
        } catch (e) {
          print(e);
          JournalToast.dismiss();
        }
      },
      style: _getCircleButtonStyle(
        bgColor: appColors.cardBackground,
        iconColor: appColors.primaryText,
        appColors: appColors,
      ),
      authIcon: AuthIcon(
        iconSize: 22.r,
        iconPath: "assets/icons/apple.png",
        // Apple 图标也要着色，亮色黑，深色白
        color: appColors.primaryText,
      ),
    );
  }

  // 3. 微信登录按钮 (恢复图片资源 + 保持白色)
  Widget _buildWechatButton(
      BuildContext context, LoginLogic logic, AppThemeColors appColors) {
    return CustomAuthButton(
      onPressed: () => logic.loginWithWechat(context),
      style: _getCircleButtonStyle(
        bgColor: const Color(0xff5dce87), // 微信绿不变
        iconColor: Colors.white, // 图标始终白色
        appColors: appColors,
      ),
      authIcon: AuthIcon(
        iconSize: 22.r,
        iconPath: "assets/icons/wechat.png",
        color: Colors.white, // 微信图标始终白色
      ),
    );
  }

  AuthButtonStyle _getCircleButtonStyle({
    required Color bgColor,
    required Color iconColor,
    required AppThemeColors appColors,
  }) {
    // 只有在背景是卡片色（通常是白/深灰）时才显示阴影，彩色背景（如微信绿）不显阴影
    bool isCardBg = bgColor == appColors.cardBackground;

    return AuthButtonStyle(
      width: 48.r,
      height: 48.r,
      borderRadius: 999,
      padding: EdgeInsets.zero,
      buttonType: AuthButtonType.icon,
      iconType: AuthIconType.secondary,

      // 颜色配置
      buttonColor: bgColor,
      iconColor: iconColor,
      iconBackground: Colors.transparent,

      // 阴影配置
      shadowColor:
          isCardBg ? Colors.black.withOpacity(0.08) : Colors.transparent,
      elevation: isCardBg ? 4 : 0,

      progressIndicatorColor: iconColor,
      progressIndicatorStrokeWidth: 2.0,
      progressIndicatorType: AuthIndicatorType.circular,

      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
