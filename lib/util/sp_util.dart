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
}
