import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 屏幕适配工具类
class ScreenUtils {
  ///去除状态栏半透明
  static setSystemTransparent() {
    if (Platform.isAndroid) {
      SystemUiOverlayStyle style = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      );
      SystemChrome.setSystemUIOverlayStyle(style);
    }
  }

  static setSystemStatusBarColor({
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
    Brightness? statusBarBrightness,
  }) {
    if (Platform.isAndroid) {
      SystemUiOverlayStyle style = SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness ?? Brightness.dark,
        statusBarBrightness: statusBarBrightness ?? Brightness.light,
      );
      SystemChrome.setSystemUIOverlayStyle(style);
    }
  }

  /// 强制竖屏
  static setPreferredOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
