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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: Get.height,
          padding: EdgeInsets.fromLTRB(24.w, 100.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeText(),
              SizedBox(height: 6.h),
              _buildRegTipText(),
              SizedBox(height: 35.h),
              _buildPhoneInput(),
              SizedBox(height: 25.h),
              _buildAgreeLicense(context),
              _buildNextStepButton(context),
              SizedBox(height: 20.h),
              _buildAnotherLoginType(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgreeLicense(BuildContext context) {
    final logic = Get.find<LoginLogic>();

    return InkWell(
      onTap: () {
        logic.state.isAgree.value = !logic.state.isAgree.value;
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.h),
            child: Obx(() => Icon(
                  logic.state.isAgree.value
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 18.r,
                  color: logic.state.isAgree.value ? Colors.blue : Colors.grey,
                )),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '我已阅读并同意',
                style: TextStyle(
                  color: const Color(0xff848484),
                  fontSize: 12.sp,
                ),
                children: [
                  TextSpan(
                    text: ' ',
                    style: TextStyle(color: Colors.black, fontSize: 12.sp),
                  ),
                  TextSpan(
                    text: '《隐私协议》',
                    style: const TextStyle(color: Color(0xff22384e)),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        ToastUtil.lightImpact();
                        Get.toNamed(Routers.WebViewPageUrl, arguments: {
                          "url": "https://journal.aceword.xyz/privacy.html",
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

  Widget _buildNextStepButton(BuildContext context) {
    final logic = Get.find<LoginLogic>();

    return Obx(
      () => TDButton(
        isBlock: true,
        height: 40.h,
        theme: logic.state.phoneNum.value.isPhoneNumber
            ? TDButtonTheme.primary
            : TDButtonTheme.defaultTheme,
        margin: EdgeInsets.only(top: 30.w, bottom: 30.w),
        onTap: () {
          logic.next(context);
        },
        child: Text(
          "下一步",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    final logic = Get.find<LoginLogic>();
    return TDInput(
      controller: logic.controller,
      inputAction: TextInputAction.done,
      inputType: TextInputType.number,
      leftInfoWidth: 30.w,
      leftLabelSpace: 0,
      leftLabel: "+86",
      maxLength: 11,
      hintText: "请输入手机号",
      autofocus: false,
      hintTextStyle: const TextStyle(
        color: Color.fromARGB(255, 174, 173, 173),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      onChanged: (value) {
        logic.state.phoneNum.value = value;
      },
    );
  }

  Widget _buildRegTipText() {
    return Text(
      "未注册的手机号登陆成功后将自动注册",
      style: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xff848484),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      "欢迎登陆 好享记账",
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 28.sp,
      ),
    );
  }

  Widget _buildAnotherLoginType(BuildContext context) {
    final logic = Get.find<LoginLogic>();

    return // 其他登录方式
        Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "或通过以下方式登录",
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xff848484),
              ),
            ),
            SizedBox(height: 30.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Platform.isIOS
                    ? AppleAuthButton(
                        onPressed: () async {
                          try {
                            logic.loginWithApple(context);
                          } catch (e) {
                            print(e);
                            TDToast.dismissLoading();
                          }
                        },
                        text: "通过Apple登录",
                        style: AuthButtonStyle(
                          iconSize: 16,
                          height: 45.h,
                          width: 45.h,
                          borderRadius: 999,
                          buttonType: AuthButtonType.icon,
                          iconType: AuthIconType.secondary,
                          iconColor: Colors.white,
                          buttonColor: Colors.black,
                          iconBackground: Colors.black,
                          textStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          shadowColor: const Color.fromARGB(50, 223, 220, 220),
                          progressIndicatorColor: Colors.black,
                          progressIndicatorStrokeWidth: 2.0,
                          progressIndicatorValue: 1.0,
                          progressIndicatorType: AuthIndicatorType.circular,
                          visualDensity: VisualDensity.standard,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    : const SizedBox(),
                SizedBox(
                  width:
                      Platform.isIOS && SpUtil.getWeChatInstalled() ? 60.w : 0,
                ),
                // 微信登录
                Visibility(
                  visible: SpUtil.getWeChatInstalled(),
                  child: CustomAuthButton(
                    onPressed: () async {
                      logic.loginWithWechat(context);
                    },
                    style: AuthButtonStyle(
                      borderRadius: 999,
                      height: 45.h,
                      width: 45.h,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      buttonType: AuthButtonType.icon,
                      iconType: AuthIconType.secondary,
                      iconColor: Colors.black87,
                      buttonColor: const Color(0xff5dce87),
                      textStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      shadowColor: const Color.fromARGB(50, 223, 220, 220),
                      progressIndicatorColor: Colors.black,
                      progressIndicatorStrokeWidth: 2.0,
                      progressIndicatorValue: 1.0,
                      progressIndicatorType: AuthIndicatorType.circular,
                      visualDensity: VisualDensity.standard,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    authIcon: AuthIcon(
                      iconSize: 20,
                      iconPath: "assets/icons/wechat.png",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50.w),
            TextButton(
                onPressed: () async {
                  logic.contact();
                },
                child: Text(
                  "联系我们",
                  style: TextStyle(
                      color: const Color(0xff848484), fontSize: 12.sp),
                )),
            SizedBox(height: 20.w),
          ],
        ),
      ),
    );
  }
}
