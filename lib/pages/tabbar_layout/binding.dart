import 'package:get/get.dart';
import 'package:journal/pages/login/logic.dart';

import 'controller.dart';

class LayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>LoginLogic());

    Get.lazyPut(() => LayoutController());
  }
}
