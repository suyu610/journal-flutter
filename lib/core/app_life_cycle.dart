import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 用于监听系统暗黑模式改变
class AppLifeCycleDelegate with WidgetsBindingObserver {
  static final AppLifeCycleDelegate _appLifeCycleDelegate =
      AppLifeCycleDelegate._init();

  AppLifeCycleDelegate._init() {
    WidgetsBinding.instance.addObserver(this);
  }

  factory AppLifeCycleDelegate() {
    return _appLifeCycleDelegate;
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    Get.forceAppUpdate();
  }
}
