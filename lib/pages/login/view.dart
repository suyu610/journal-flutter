import 'dart:io';

import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/sp_util.dart';
import 'package:journal/util/toast_util.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'logic.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用 Get.find 放在这里，避免在每个子组件里重复查找
    final logic = Get.find<LoginLogic>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: Get.height,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 100.h),
              _buildWelcomeText(),
              SizedBox(height: 6.h),
              _buildRegTipText(logic),
              SizedBox(height: 35.h),
              _buildInput(logic),
              SizedBox(height: 25.h),
              _buildAgreeLicense(context, logic),
              _buildNextStepButton(context, logic),
              const Spacer(), // 使用 Spacer 自动撑开空间
              _buildAnotherLoginType(context, logic),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- 顶部文字区域 ---

  Widget _buildWelcomeText() {
    return Text(
      "欢迎登陆 好享记账",
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 28.sp,
        color: Colors.black,
      ),
    );
  }

  Widget _buildRegTipText(LoginLogic logic) {
    return Obx(() => Text(
          "未注册的${logic.isEmailMode.value ? "邮箱" : "手机号"}登陆成功后将自动注册",
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xff848484),
          ),
        ));
  }

  // --- 输入框区域 ---

  Widget _buildInput(LoginLogic logic) {
    return Obx(() {
      final isEmail = logic.isEmailMode.value;
      return TDInput(
        controller: logic.controller,
        inputAction: TextInputAction.done,
        inputType: isEmail ? TextInputType.emailAddress : TextInputType.number,
        leftInfoWidth: 30.w,
        leftLabelSpace: 0,
        leftLabel: isEmail ? "邮箱" : "+86",
        maxLength: isEmail ? 50 : 11,
        hintText: isEmail ? "请输入邮箱" : "请输入手机号",
        autofocus: false,
        hintTextStyle: const TextStyle(
          color: Color(0xFFAEADAD),
        ),
        inputFormatters: [
          isEmail
              ? FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]'))
              : FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onChanged: (value) {
          logic.state.phoneNum.value = value;
        },
      );
    });
  }

  // --- 协议区域 ---

  Widget _buildAgreeLicense(BuildContext context, LoginLogic logic) {
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
              size: 18.r,
              color: isAgree ? Colors.blueGrey[900] : Colors.grey,
            );
          }),
          SizedBox(width: 5.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '我已阅读并同意 ',
                style:
                    TextStyle(color: const Color(0xff848484), fontSize: 12.sp),
                children: [
                  TextSpan(
                    text: '《隐私协议》',
                    style: const TextStyle(color: Color(0xff22384e)),
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

  // --- 主操作按钮 ---

  Widget _buildNextStepButton(BuildContext context, LoginLogic logic) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30.w),
      child: Obx(() {
        final isEmail = logic.isEmailMode.value;
        final input = logic.state.phoneNum.value;

        // 简化判断逻辑
        final isValid = isEmail ? input.isEmail : input.isPhoneNumber;

        return TDButton(
          isBlock: true,
          height: 44.h, // 稍微加高一点点，更符合现代手感
          theme: isValid ? TDButtonTheme.primary : TDButtonTheme.defaultTheme,
          onTap: () => logic.next(context),
          child: Text(
            "下一步",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }

  // --- 底部第三方登录区域 (重构重点) ---

  Widget _buildAnotherLoginType(BuildContext context, LoginLogic logic) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "或通过以下方式登录",
          style: TextStyle(fontSize: 12.sp, color: const Color(0xff848484)),
        ),
        SizedBox(height: 30.h),

        // 按钮行
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSwitchModeButton(logic),

                // iOS 且安装了微信才显示间距
                if (Platform.isIOS) SizedBox(width: 60.w),

                if (Platform.isIOS) _buildAppleButton(context, logic),

                if (Platform.isIOS && SpUtil.getWeChatInstalled())
                  SizedBox(width: 60.w),

                if (SpUtil.getWeChatInstalled())
                  _buildWechatButton(context, logic),
              ],
            )),

        SizedBox(height: 50.h),
        TextButton(
          onPressed: () => logic.contact(),
          child: Text(
            "联系我们",
            style: TextStyle(color: const Color(0xff848484), fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  // 1. 切换 手机/邮箱 按钮
  Widget _buildSwitchModeButton(LoginLogic logic) {
    bool isEmailMode = logic.isEmailMode.value;

    // 如果当前是邮箱模式，显示“切换到手机”按钮；反之显示“切换到邮箱”
    // 统一风格：白底 + 彩色图标 + 阴影
    return CustomAuthButton(
      onPressed: () => logic.toggleEmailMode(),
      style: _getCircleButtonStyle(
        // 手机图标用黑色，邮箱图标用蓝色，区分度更高更美观
        iconColor: isEmailMode ? Colors.black87 : Colors.blueAccent,
      ),
      authIcon: AuthIcon(
        iconSize: 22.r,
        iconPath: isEmailMode
            ? "assets/icons/phone.png" // 这是一个切换回手机的按钮
            : "assets/icons/email.png", // 这是一个切换回邮箱的按钮 (你需要确保有这个资源，或者使用 Icons.email)
        // 如果没有 email 图片资源，可以使用 Icon 组件：
        // icon: Icon(isEmailMode ? Icons.phone_android : Icons.email, color: ...),
      ),
    );
  }

  // 2. Apple 登录按钮
  Widget _buildAppleButton(BuildContext context, LoginLogic logic) {
    return CustomAuthButton(
      onPressed: () {
        try {
          logic.loginWithApple(context);
        } catch (e) {
          print(e);
          TDToast.dismissLoading();
        }
      },
      style: _getCircleButtonStyle(
        // 手机图标用黑色，邮箱图标用蓝色，区分度更高更美观
        iconColor: Colors.black87,
      ),
      authIcon: AuthIcon(
          iconSize: 22.r, iconPath: "assets/icons/apple.png" // 这是一个切换回手机的按钮

          // 如果没有 email 图片资源，可以使用 Icon 组件：
          // icon: Icon(isEmailMode ? Icons.phone_android : Icons.email, color: ...),
          ),
    );
  }

  // 3. 微信登录按钮
  Widget _buildWechatButton(BuildContext context, LoginLogic logic) {
    return CustomAuthButton(
      onPressed: () => logic.loginWithWechat(context),
      style: _getCircleButtonStyle(
        bgColor: const Color(0xff5dce87), // 微信绿
      ),
      authIcon: AuthIcon(
        iconSize: 22.r,
        iconPath: "assets/icons/wechat.png",
      ),
    );
  }

  /// 提取公共样式配置：圆形按钮
  /// [bgColor] 背景色，默认为白色
  /// [iconColor] 图标颜色，默认为黑色
  AuthButtonStyle _getCircleButtonStyle({
    Color bgColor = Colors.black,
    Color iconColor = Colors.white,
  }) {
    return AuthButtonStyle(
      width: 48.r, // 使用 .r 确保正圆
      height: 48.r,
      borderRadius: 999, // 足够大的圆角
      padding: EdgeInsets.zero,
      buttonType: AuthButtonType.icon,
      iconType: AuthIconType.secondary,

      // 颜色配置
      buttonColor: bgColor,
      iconColor: iconColor,
      iconBackground: Colors.transparent,

      // 阴影配置 (仅白底时显示淡淡的阴影，有色背景通常不需要太重阴影)
      shadowColor: bgColor == Colors.white
          ? const Color.fromARGB(40, 0, 0, 0)
          : Colors.transparent,
      elevation: bgColor == Colors.white ? 3 : 0,

      // 进度条配置
      progressIndicatorColor: iconColor,
      progressIndicatorStrokeWidth: 2.0,
      progressIndicatorType: AuthIndicatorType.circular,

      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
