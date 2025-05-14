import 'package:get/get.dart';

class ExpenseTypePickerController extends GetxController {
  ExpenseTypePickerController();

  _initData() {
    update(["expense_category"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
