import 'package:get/get.dart';

class LoginState {
  // 手机号
  RxString phoneNum = "".obs;

  // 是否同意协议
  RxBool isAgree = false.obs;

  RxBool verify = false.obs;
}
