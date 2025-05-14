import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/pages/profile/controller.dart';
import 'package:journal/request/request.dart';

class AiConfigController extends GetxController {
  AiConfigController();
  ProfileController profileController = Get.find<ProfileController>();

  late TextEditingController openingStatementController;
  late TextEditingController salutationController;
  late TextEditingController relationshipController;
  late TextEditingController personalityController;

  _initData() {
    update(["ai_config"]);
  }

  void onTap() {}

  @override
  void onInit() {
    super.onInit();
    openingStatementController = TextEditingController();
    salutationController = TextEditingController();

    relationshipController = TextEditingController();
    personalityController = TextEditingController();

    openingStatementController.text =
        profileController.user.value.openingStatement ?? "";
    salutationController.text = profileController.user.value.salutation ?? "";
    relationshipController.text =
        profileController.user.value.relationship ?? "";
    personalityController.text = profileController.user.value.personality ?? "";
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void modifyPersonality(List<BrnTagItemBean> items, BuildContext context) {
    var personality = items.map((e) => e.name).toList().join(",");
    // BrnToast.show(personality.toString(), context);
    // BrnLoadingDialog.show(context);

    HttpRequest.request(Method.patch, "/user",
        params: {"personality": personality}, success: (data) {
      profileController.user.value.personality = personality;
      // BrnLoadingDialog.dismiss(context);
      // BrnToast.show("修改成功", context);
      update(["ai_config"]);
    });
  }

  void modifyRelationship(String relationship, BuildContext context) {
    // BrnLoadingDialog.show(context);

    HttpRequest.request(Method.patch, "/user",
        params: {"relationship": relationship}, success: (data) {
      profileController.user.value.relationship = relationship;
      // BrnLoadingDialog.dismiss(context);
      // BrnToast.show("修改成功", context);
      update(["ai_config"]);
    });
  } 

  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  modifySalutation(String salutation, context) async {
    debouncer.call(() {
      // BrnLoadingDialog.show(context);

      HttpRequest.request(Method.patch, "/user",
          params: {"salutation": salutation}, success: (data) {
        profileController.user.value.salutation = salutation;
        // BrnLoadingDialog.dismiss(context);

        // BrnToast.show("修改成功", context);
        update(["ai_config"]);
      });
    });
  }

  @override
  void onClose() {
    super.onClose();
    openingStatementController.dispose();
    salutationController.dispose();
    relationshipController.dispose();
    personalityController.dispose();
  }
}
