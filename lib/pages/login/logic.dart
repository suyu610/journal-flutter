import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
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

///登录页面
class LoginLogic extends GetxController {
  final LoginState state = LoginState();
  final TextEditingController controller = TextEditingController();
  SliderController sliderController = SliderController();
  Fluwx fluwx = Fluwx();

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
        appId: "wx30e85737940da4af",
        universalLink: "https://journal.uuorb.com/app/");
    fluwx.addSubscriber((response) {
      if (response is WeChatAuthResponse && response.isSuccessful) {
        Log().d(response.toString());
        // delay一下
        Future.delayed(const Duration(milliseconds: 100), () {});
        Log().d("微信登录中${response.code}");
        handlerWechatLoginWithCode(response.code);
      }
    });
  }

  buildSliderCaptcha(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        child: SliderCaptcha(
          captchaSize: 50,
          title: "滑动验证",
          titleStyle: const TextStyle(
              fontSize: 12,
              decoration: TextDecoration.none,
              
              color: Colors.white),
          imageToBarPadding: 10,
          controller: sliderController,
          onConfirm: (value) async {
            if (value) {
              TDToast.showSuccess("验证通过",
                  context: context); // ToastUtil.showToast("验证通过");
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
          colorBar: const Color(0xff000000),
          colorCaptChar: Colors.white, //,
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

    //手机号不符合要求
    if (!RegexUtil.isMobileSimple(state.phoneNum.value)) {
      TDToast.showFail('请检查手机号', context: context);
      return;
    }

    if (!state.isAgree.value) {
      ToastUtil.showBottomPopup(
        false,
        SizedBox(
          width: 375.w,
          height: 200.h,
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              Text(
                "请阅读并同意以下条款",
                style: TextStyle( fontSize: 16.sp),
              ),
              SizedBox(
                height: 20.h,
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routers.WebViewPageUrl, arguments: {
                    "url": "https://journal.aceword.xyz/privacy.html",
                    "title": "隐私协议"
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "《隐私政策》",
                      style: TextStyle(
                           color: Color(0xff22384e)),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextButton(
                    onPressed: () {
                      state.isAgree.value = true;
                      Navigator.of(context).pop();
                      FocusScope.of(Get.context!).requestFocus(FocusNode());

                      next(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0xff0052D9)),
                      // white
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      // 设置按钮的大小
                      minimumSize: WidgetStateProperty.all(Size(375.w, 45.h)),
                      // 设置按钮的边框
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                      ),
                    ),
                    child: const Text("同意并继续")),
              )
            ],
          ),
        ),
      );
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
      ToastUtil.showBottomPopup(
        false,
        SizedBox(
          width: 375.w,
          height: 200.h,
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              Text(
                "请阅读并同意以下条款",
                style: TextStyle( fontSize: 16.sp),
              ),
              SizedBox(
                height: 20.h,
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routers.WebViewPageUrl, arguments: {
                    "url": "https://journal.aceword.xyz/privacy.html",
                    "title": "隐私协议"
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "《隐私政策》",
                      style: TextStyle(
                           color: Color(0xff22384e)),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: TextButton(
                    onPressed: () {
                      state.isAgree.value = true;
                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        loginWithWechat(context);
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0xff0052D9)),
                      // white
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      // 设置按钮的大小
                      minimumSize: WidgetStateProperty.all(Size(375.w, 45.h)),
                      // 设置按钮的边框
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                      ),
                    ),
                    child: const Text("同意并继续")),
              )
            ],
          ),
        ),
      );
      return;
    }

    fluwx.authBy(
        which: NormalAuth(
            scope: 'snsapi_userinfo', state: 'wechat_sdk_demo_test'));
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

}
