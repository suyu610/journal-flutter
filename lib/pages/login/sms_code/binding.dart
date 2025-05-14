

import 'package:get/get.dart';
import 'package:journal/pages/login/logic.dart';

import 'logic.dart';

class CodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CodeLogic());
    Get.lazyPut(() => LoginLogic());
  }
}
