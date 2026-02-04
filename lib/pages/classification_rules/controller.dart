// pages/classification_rules/controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/ai_config_model.dart';
import 'package:journal/request/request.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ClassificationRulesController extends GetxController {
  // 1. 定义文本控制器
  final TextEditingController ruleInputController = TextEditingController();
// 新增：用于控制保存按钮的 Loading 状态
  final RxBool isSaving = false.obs;
  @override
  void onInit() async {
    super.onInit();
    var result =
        await HttpRequest.request(Method.get, "/api/ai-config/current");

    UserAIConfig config = UserAIConfig.fromJson(result['data']);
    ruleInputController.text = config.specialConfig;
  }

  @override
  void onClose() {
    // 记得销毁，防止内存泄漏
    ruleInputController.dispose();
    super.onClose();
  }

// 新增：清空逻辑
  void clearRules(context) {
    if (ruleInputController.text.isEmpty) return;

    // 可选：如果内容较多，防止误触，可以加个弹窗确认，这里先直接清空
    ruleInputController.clear();
    // 强制更新一下UI（虽然TextEditingController通常会自动更，但有时配合Obx需要注意）
    update(["classification_rules"]);
    TDToast.showSuccess("已清空内容", context: context);
  }

  // 2. 保存逻辑
  void saveRules(BuildContext context) async {
    // 1. 开启 Loading 状态
    isSaving.value = true;

    final content = ruleInputController.text;
    Log().d("saveRules content: $content");
    UserAIConfig newConfig = UserAIConfig(specialConfig: content);

    await HttpRequest.request(
        Method.post, "/api/ai-config/update/special-config",
        params: newConfig.toJson(), success: (data) {
      // 2. 关闭 Loading
      isSaving.value = false;
      if (context.mounted) {
        TDToast.showSuccess("配置已更新", context: context);
        // 可选：保存成功后收起键盘
        FocusScope.of(context).unfocus();
      }
    }, fail: (code, msg) {
      // 2. 关闭 Loading (即使失败也要关)
      isSaving.value = false;
      TDToast.showWarning("保存失败: $msg", context: context);
    });
  }
}
