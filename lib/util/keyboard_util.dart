import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// 软键盘相关工具类
class KeyboardUtils {
  ///隐藏软键盘
  ///[context] 上下文
  static hideKeyboard(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 隐藏键盘
  static void hide({Function? func}) {
    SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(() {
      Future.delayed(const Duration(milliseconds: 10)).whenComplete(() {
        if (func != null) func();
      });
    });
  }

  /// 显示键盘
  static void show({Function? func}) {
    SystemChannels.textInput.invokeMethod('TextInput.show').whenComplete(() {
      Future.delayed(const Duration(milliseconds: 10)).whenComplete(() {
        if (func != null) func();
      });
    });
  }
}
