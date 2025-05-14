import 'package:get/get.dart';

import 'logic.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>LoginLogic());
  }
}
