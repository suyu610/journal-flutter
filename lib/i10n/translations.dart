
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/i10n/translations/zh_cn.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zhCN,
      };

  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
  ];

  static const fallbackLocale = Locale('CN');
}
