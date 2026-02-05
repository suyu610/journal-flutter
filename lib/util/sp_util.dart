import 'package:get/get.dart';
import 'package:journal/constants/spkey.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 键值对存储
class SpUtil {
  /// 刚打开app
  static bool isFirstOpenApp() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.getBool(SPKey.isFirstOpenApp) ?? true;
  }

  static Future<bool> setFirstOpenApp(bool v) {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.setBool(SPKey.isFirstOpenApp, v);
  }

  ///是否第一次打开
  static bool isFirstOpen() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.getBool(SPKey.isFirstOpen) ?? true;
  }

  /// 已打开APP
  static Future<bool> appIsOpen() {
    return Get.find<SharedPreferences>().setBool(SPKey.isFirstOpen, false);
  }

  /// 聊天背景图
  static String? getChatBg() {
    return Get.find<SharedPreferences>().getString(SPKey.chatBg);
  }

  static Future<bool> setChatBg(String bg) {
    return Get.find<SharedPreferences>().setString(SPKey.chatBg, bg);
  }

  ///Token
  static String getToken() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.getString(SPKey.token) ?? "";
  }

  /// Token
  static Future<bool> setToken(String token) {
    return Get.find<SharedPreferences>().setString(SPKey.token, token);
  }

  /// Token
  static Future<bool> removeToken() {
    return Get.find<SharedPreferences>().remove(SPKey.token);
  }

  // 从API中获取用户信息
  // 是否安装了微信
  static void setWeChatInstalled(bool weChatInstalled) {
    SharedPreferences sp = Get.find<SharedPreferences>();
    sp.setBool(SPKey.wechatInstall, weChatInstalled);
  }

  static bool getWeChatInstalled() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.getBool(SPKey.wechatInstall) ?? true;
  }

  static void setKeyboardMode(bool value) {
    SharedPreferences sp = Get.find<SharedPreferences>();
    sp.setBool(SPKey.keyboardMode, value);
  }

  static bool getKeyboardMode() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.getBool(SPKey.keyboardMode) ?? true;
  }

  static String getZipVersion() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.getString(SPKey.live2dZipVersion) ?? "";
  }

  static Future<bool> setZipVersion(String version) {
    return Get.find<SharedPreferences>()
        .setString(SPKey.live2dZipVersion, version);
  }

  void saveTabOrder(List<String> list) {
    SharedPreferences sp = Get.find<SharedPreferences>();
    sp.setStringList(SPKey.tabOrder, list);
  }

  /// 获取tabbar顺序
  List<String> getTabOrder() {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.getStringList(SPKey.tabOrder) ?? [];
  }

  static const String keyDisabledTabs = 'key_disabled_tabs';

  // 保存被禁用的 Tab ID
  Future<bool> saveDisabledTabs(List<String> ids) {
    SharedPreferences sp = Get.find<SharedPreferences>();

    return sp.setStringList(keyDisabledTabs, ids);
  }

  // 获取被禁用的 Tab ID
  List<String> getDisabledTabs() {
    SharedPreferences sp = Get.find<SharedPreferences>();

    return sp.getStringList(keyDisabledTabs) ?? [];
  }

  static String? getString(String key) {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.getString(key);
  }

  static Future<bool> putString(String key, String value) {
    SharedPreferences sp = Get.find<SharedPreferences>();
    return sp.setString(key, value);
  }

  // 给所有引导相关的 Key 加一个统一前缀，避免冲突
  static const String _guidePrefix = 'guide_shown_';

  /// 通用检查：某个引导是否显示过
  /// [featureId] 是你自己定义的唯一标识，比如 'home_add_btn', 'profile_avatar'
  static bool hasShownGuide(String featureId) {
    String key = '$_guidePrefix$featureId';
    return Get.find<SharedPreferences>().getBool(key) ?? false;
  }

  /// 通用标记：标记某个引导已显示
  static Future<bool> setGuideShown(String featureId) {
    String key = '$_guidePrefix$featureId';
    return Get.find<SharedPreferences>().setBool(key, true);
  }

  /// 开发调试用：重置所有引导（方便你测试）
  static Future<void> clearAllGuides() async {
    final sp = Get.find<SharedPreferences>();
    final keys = sp.getKeys();
    for (String key in keys) {
      if (key.startsWith(_guidePrefix)) {
        await sp.remove(key);
      }
    }
  }
}
