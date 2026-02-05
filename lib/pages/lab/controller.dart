import 'package:get/get.dart';
import 'package:journal/util/sp_util.dart';
import 'package:journal/util/toast_util.dart';

class LabController extends GetxController {
  void resetGuide() {
    SpUtil.clearAllGuides();
    ToastUtil.showSnackBar("重置成功", "请重新打开APP");
  }
}
