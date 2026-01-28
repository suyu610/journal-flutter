import 'package:get/get.dart';
import 'controller.dart';
import 'view.dart';

class ReminderSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReminderSettingsController());
  }
}
