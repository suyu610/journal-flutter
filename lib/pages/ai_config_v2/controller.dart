import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/ai_presets.dart';
import 'package:journal/services/local_server.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:journal/request/request.dart';
import 'package:journal/models/ai_config_model.dart';

class AiConfigV2Controller extends GetxController {
  // =========================================================
  // 1. 状态定义
  // =========================================================

  // 引用静态数据，方便调用
  final List<AICharacter> characters = CharacterPresets.list;

  // 当前选中的角色索引
  var currentIndex = 0.obs;
  RxBool isWebViewReady = false.obs;

  // 两个输入框控制器
  late final TextEditingController nameController;
  late final TextEditingController openingController;

  // WebView 控制器
  late final WebViewController webViewController;

  // 获取当前选中的角色对象（Getter）
  AICharacter get currentCharacter => characters[currentIndex.value];

  // =========================================================
  // 2. 生命周期
  // =========================================================

  @override
  void onInit() {
    super.onInit();
    // 初始化输入框
    nameController = TextEditingController();
    openingController = TextEditingController();

    // 初始化数据
    _fillInputs(characters[0]); // 先填默认值防止空白
    _initWebView();
    _fetchCurrentConfig(); // 异步拉取服务器配置
  }

  @override
  void onClose() {
    // 记得销毁控制器，防止内存泄漏
    nameController.dispose();
    openingController.dispose();
    super.onClose();
  }

  // =========================================================
  // 3. UI 交互逻辑
  // =========================================================

  /// 切换角色（点击左右箭头时调用）
  void switchCharacter(int offset) {
    int newIndex = currentIndex.value + offset;

    // 循环切换逻辑
    if (newIndex >= characters.length) newIndex = 0;
    if (newIndex < 0) newIndex = characters.length - 1;

    // 更新索引
    currentIndex.value = newIndex;
    final char = characters[newIndex];

    // 更新输入框为该角色的默认值
    _fillInputs(char);

    // 通知 WebView 切换模型
    _switchRoleInWebView(char.id);
  }

  /// 填充输入框
  void _fillInputs(AICharacter char) {
    nameController.text = char.defaultSalutation;
    openingController.text = char.defaultOpening;
  }

  /// 直接选中某个角色
  void selectCharacter(int index) {
    if (index < 0 || index >= characters.length) return;
    if (index == currentIndex.value) return;

    currentIndex.value = index;
    final char = characters[index];

    // 更新输入框
    _fillInputs(char);

    // 通知 WebView
    _switchRoleInWebView(char.id);
  }
  // =========================================================
  // 4. WebView 相关逻辑
  // =========================================================

  void _initWebView() async {
    // 默认先加载列表里的第一个，防止白屏
    String defaultId = characters[0].id;
    LocalServer.start();
    String baseUrl = "${LocalServer.baseUrl}/index.html?roleName=$defaultId";

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            isWebViewReady.value = true;
            String targetId = characters[currentIndex.value].id;
            if (targetId != defaultId) {
              Future.delayed(const Duration(milliseconds: 300), () {
                _switchRoleInWebView(targetId);
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(baseUrl + defaultId));
  }

  void _switchRoleInWebView(String roleId) {
    print("roleId: $roleId");
    if (!(isWebViewReady.value)) return;
    webViewController.runJavaScript("window.loadModelByName('$roleId')");
  }

  // =========================================================
  // 5. 网络请求 / 业务逻辑
  // =========================================================

  /// 获取当前配置并回显
  void _fetchCurrentConfig() async {
    var result =
        await HttpRequest.request(Method.get, "/api/ai-config/current");

    if (result != null) {
      try {
        UserAIConfig config = UserAIConfig.fromJson(result['data']);

        int index = characters.indexWhere((p) => p.id == config.characterCode);
        if (index == -1) index = 0;
        // 更新本地数据状态
        currentIndex.value = index;
        nameController.text = config.userAppellation;
        openingController.text = config.openingStatement;

        if (isWebViewReady.value) {
          _switchRoleInWebView(characters[index].id);
        }
      } catch (e) {
        debugPrint("解析配置失败: $e");
      }
    }
  }

  /// 保存配置
  Future<void> saveConfig() async {
    var selectedPreset = currentCharacter;

    UserAIConfig newConfig = UserAIConfig(
      customName: selectedPreset.name,
      characterCode: selectedPreset.id,
      userAppellation: nameController.text,
      openingStatement: openingController.text,
      themeColorHex: selectedPreset.bgColors[0].value.toRadixString(16),
    );

    await HttpRequest.request(Method.post, "/api/ai-config/update",
        params: newConfig.toJson(), success: (data) {
      Get.snackbar("保存成功", "现在的管家是 ${selectedPreset.name}",
          backgroundColor: selectedPreset.themeColor,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1000));
      // 后退
      // 延迟 1 秒，确保 snackbar 显示出来
      // Future.delayed(const Duration(milliseconds: 2000), () {
      //   Get.back();
      // });
    }, fail: (code, msg) {
      Get.snackbar("保存失败", msg,
          backgroundColor: Colors.red, colorText: Colors.white);
    });
  }
}
