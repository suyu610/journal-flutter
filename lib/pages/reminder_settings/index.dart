import 'package:get/get.dart';
import 'controller.dart';

class ReminderSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReminderSettingsController());
  }
}
