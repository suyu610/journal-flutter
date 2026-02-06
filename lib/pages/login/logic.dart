import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/core/log.dart';
import 'package:journal/request/request.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/regex_util.dart';
import 'package:journal/util/sp_util.dart';
import 'package:journal/util/toast_util.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:slider_captcha/slider_captcha.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'state.dart';

/// 登录页面逻辑层
class LoginLogic extends GetxController {
  final LoginState state = LoginState();
  final TextEditingController controller = TextEditingController();
  SliderController sliderController = SliderController();
  Fluwx fluwx = Fluwx();
  RxBool isEmailMode = false.obs;

  @override
  void dispose() {
    super.dispose();
    fluwx.clearSubscribers();
  }

  @override
  onReady() async {
    super.onReady();
    fluwx.registerApi(
        doOnIOS: true,
        doOnAndroid: true,
        appId: "wx30e85737940da4af",
        universalLink: "https://journal.uuorb.com/app/");
    fluwx.addSubscriber((response) {
      if (response is WeChatAuthResponse && response.isSuccessful) {
        Log().d(response.toString());
        Future.delayed(const Duration(milliseconds: 100), () {});
        Log().d("微信登录中${response.code}");
        handlerWechatLoginWithCode(response.code);
      }
    });
  }

  // --- 改造 1: 滑动验证码弹窗 (适配主题色) ---
  buildSliderCaptcha(BuildContext context) {
    // 获取主题颜色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: appColors.cardBackground, // 适配背景
            borderRadius: BorderRadius.circular(16.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SliderCaptcha(
          captchaSize: 50,
          title: "安全验证",
          titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              color: appColors.primaryText), // 适配标题色
          imageToBarPadding: 16,
          controller: sliderController,
          onConfirm: (value) async {
            if (value) {
              TDToast.showSuccess("验证通过", context: context);
              Get.back();
              state.verify.value = true;
              next(context);
            } else {
              sliderController.create();
              TDToast.showFail("请重试", context: context);
            }
          },
          image: Image.asset(
            'assets/images/captcha.png',
            fit: BoxFit.fitWidth,
          ),
          borderImager: 1,
          colorBar: appColors.cardBackground, // 适配滑块条颜色
          colorCaptChar: appColors.cardBackground, // 适配缺口背景
        ),
      ),
    );
  }

  /// 下一步
  void next(BuildContext context) {
    //为空不能执行下一步
    if (state.phoneNum.value.isEmpty) {
      return;
    }
    if (isEmailMode.value) {
      if (!RegexUtil.isEmail(state.phoneNum.value)) {
        TDToast.showFail('请检查邮箱', context: context);
        return;
      }
    } else {
      //手机号不符合要求
      if (!RegexUtil.isMobileSimple(state.phoneNum.value)) {
        TDToast.showFail('请检查手机号', context: context);
        return;
      }
    }

    if (!state.isAgree.value) {
      // 使用统一提取的隐私弹窗
      _showPrivacyPopup(context, () {
        // 同意后的回调
        FocusScope.of(context).unfocus();
        next(context);
      });
      return;
    }

    if (!state.verify.value) {
      Get.dialog(
        buildSliderCaptcha(context),
        barrierDismissible: true,
      );
      return;
    }
    //跳转到验证码界面
    Get.toNamed(Routers.CodePageUrl);
  }

  void loginWithWechat(BuildContext context) {
    if (!state.isAgree.value) {
      // 使用统一提取的隐私弹窗
      _showPrivacyPopup(context, () {
        // 同意后的回调 (稍微延迟，等待弹窗关闭动画)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            loginWithWechat(context);
          }
        });
      });
      return;
    }

    fluwx.authBy(
        which: NormalAuth(
            scope: 'snsapi_userinfo', state: 'wechat_sdk_demo_test'));
  }

  // --- 改造 2: 提取统一的隐私协议弹窗 (适配主题色) ---
  void _showPrivacyPopup(BuildContext context, VoidCallback onAgree) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    ToastUtil.showBottomPopup(
      false,
      Container(
        width: 375.w,
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
        decoration: BoxDecoration(
          color: appColors.cardBackground, // 适配背景
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 高度自适应
          children: [
            Text(
              "服务协议与隐私政策",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryText),
            ),
            SizedBox(height: 16.h),
            Text(
              "为了更好地保障您的权益，请阅读并同意以下条款：",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: appColors.secondaryText),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () {
                Get.toNamed(Routers.WebViewPageUrl, arguments: {
                  "url": "https://blog.uuorb.com/archives/journal-privacy",
                  "title": "隐私协议"
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: appColors.primaryText.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.article_outlined,
                        size: 20, color: appColors.primaryText),
                    SizedBox(width: 8.w),
                    Text(
                      "《隐私政策》",
                      style: TextStyle(
                          color: appColors.primaryText,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                  onPressed: () {
                    state.isAgree.value = true;
                    Navigator.of(context).pop();
                    onAgree();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.mainButtonBg, // 适配按钮背景
                    foregroundColor: appColors.mainButtonIcon, // 适配按钮文字
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                  child: const Text("同意并继续",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
            )
          ],
        ),
      ),
    );
  }

  // 用微信code换token
  void handlerWechatLoginWithCode(String? code) {
    if (code == null) {
      TDToast.dismissLoading();
      return;
    }
    String platform = "";
    if (Platform.isAndroid) {
      platform = "android";
    } else if (Platform.isIOS) {
      platform = "ios";
    } else {
      platform = "unsupport";
    }

    // 跳转微信
    HttpRequest.request(
      Method.post,
      "/user/login/wechat?code=$code&platform=$platform",
      success: (data) async {
        TDToast.dismissLoading();
        await SpUtil.setToken(data.toString());

        Future.delayed(const Duration(milliseconds: 300),
            () => Get.offAllNamed(Routers.LayoutPageUrl));
      },
      fail: (code, msg) {},
    );
  }

  void loginWithApple(BuildContext context) async {
    TDToast.showLoading(context: context, text: "登陆中", preventTap: false);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 苹果登录
      HttpRequest.request(
        Method.post,
        "/user/login/apple?code=${credential.authorizationCode}",
        success: (data) {
          TDToast.dismissLoading();
          Log().d("apple登录$data");
          SpUtil.setToken(data.toString());
          Get.offAllNamed(Routers.LayoutPageUrl);
        },
        fail: (code, msg) {},
      );
      print(credential);
    } catch (e) {
      TDToast.dismissLoading();
    }
  }

  // 联系我们
  void contact() {
    fluwx.open(
        target: CustomerServiceChat(
            corpId: 'ww9d9a8a9c7211e1f8',
            url: 'https://work.weixin.qq.com/kfid/kfc001bab61abbb134c'));
  }

  void toggleEmailMode() {
    isEmailMode.value = !isEmailMode.value;
  }
}
