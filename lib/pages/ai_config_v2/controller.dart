import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/pages/ai_config_v2/view.dart';

class AiConfigV2Controller extends GetxController {
  AiConfigV2Controller();

  _initData() {
    update(["ai_config_v2"]);
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

  Rx<AICharacter?> selectedCharacter = Rx<AICharacter?>(null);

  void selectCharacter(AICharacter character) {
    Log().d("controller.selectedCharacter");
    selectedCharacter.value = character;
    update(["ai_config_v2"]);
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
