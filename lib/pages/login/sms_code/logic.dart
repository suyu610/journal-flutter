import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/request/request.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/sp_util.dart';
import 'package:journal/util/toast_util.dart';

import '../logic.dart';
import 'state.dart';

class CodeLogic extends GetxController {
  final CodeState state = CodeState();
  final int time = 60;
  Timer? _timer;

  ///手机号后四位
  String get phoneNum {
    final loginLogic = Get.find<LoginLogic>();
    var phone = loginLogic.state.phoneNum.value;
    if (phone.isNotEmpty && phone.length == 11) {
      return phone.substring(phone.length - 4);
    }
    return "";
  }

  /// 验证码输入完成
  void codeInputCompleted({required String code}) {
    state.code.value = code;
  }

  /// 验证码是否输入完毕
  bool get codeIsCompleted {
    return state.code.value.length == 4;
  }

  // 获取验证码
  void _sendCode() {
    final loginLogic = Get.find<LoginLogic>();
    HttpRequest.request(
      Method.post,
      "/user/login/smsCode?telephone=${loginLogic.state.phoneNum.value}",
    ).then((e) {
      Log().d(e.toString());
      _startTimer();
    });
  }

  @override
  void onReady() {
    super.onReady();
    _sendCode();
  }

  ///打开计时器
  void _startTimer() {
    _stopTimer();
    state.countDownNum.value = time;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (state.countDownNum.value <= 0) {
        state.countDownNum.value = -1;
        return;
      }
      state.countDownNum.value--;
    });
  }

  ///停止计时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  // 调用发送接口

  ///重新发送
  ///
  void reSendCode() {
    // 判断能否重新发送

    if (state.countDownNum.value > 0) {
      return;
    }
    // 重新发送验证码

    // 这里需要调用接口发送验证码
    //发送代码
    _sendCode();
    // _startTimer();
  }

  ///下一步
  void next(BuildContext context) {
    if (!codeIsCompleted) {
      return;
    }
    final loginLogic = Get.find<LoginLogic>();

    // 登录！
    HttpRequest.request(Method.post,
        "/user/login?telephone=${loginLogic.state.phoneNum.value}&code=${state.code.value}",
        success: handleLoginSuccess, fail: handleLoginFail);
  }

  void handleLoginSuccess(e) {
    Log().d("登陆返回${e.toString()}");

    // var response = LoginResponse.fromJson(e);
    // var token = response.token;

    // UserLogic.setToken(token: token);
    SpUtil.setToken(e);
    Get.offAllNamed(Routers.LayoutPageUrl);
    // final userLogic = Get.find<UserLogic>();

    // 保存用户信息
  }

  void handleLoginFail(int code, String msg) {
    if (code == 10007) {
      ToastUtil.showSnackBar("错误", "验证码错误");
      return;
    }

    if (code == 415) {
      ToastUtil.showSnackBar("错误", "验证码错误");
    }
    ToastUtil.showSnackBar("错误", msg);
  }
}
