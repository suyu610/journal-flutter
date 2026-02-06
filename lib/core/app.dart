import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart'; // 确保这个文件存在
import 'package:journal/core/injection.dart';
import 'package:journal/core/log.dart';
import 'package:journal/core/theme_controller.dart';
import 'package:journal/i10n/translations.dart';
import 'package:journal/pages/login/logic.dart';
import 'package:journal/routers.dart';
import 'package:journal/services/notification_service.dart';
import 'package:journal/util/keyboard_util.dart';
import 'package:journal/util/sp_util.dart';

// 【关键修改】隐藏冲突的类，使用 Flutter 原生的 ThemeData 和 CardTheme
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 环境类型
enum Env { qa, beta, mp }

/// 当前环境类型
Env appEnv = Env.beta;

/// 是否需要调试工具
bool get isNeedUme {
  return appEnv == Env.qa || appEnv == Env.beta;
}

/// 初始化
Future<void> initApp(Env env) async {
  appEnv = env;
  await Injection.init();
  TDTheme.needMultiTheme();

  EasyRefresh.defaultHeaderBuilder = () => ClassicHeader(
        dragText: 'Pull to refresh'.tr,
        armedText: 'Release ready'.tr,
        readyText: 'Refreshing...'.tr,
        processingText: 'Refreshing...'.tr,
        processedText: 'Succeeded'.tr,
        noMoreText: 'No more'.tr,
        failedText: 'Failed'.tr,
        messageText: 'Last updated at %T'.tr,
      );
  EasyRefresh.defaultFooterBuilder = () => ClassicFooter(
        dragText: 'Pull to load'.tr,
        armedText: 'Release ready'.tr,
        readyText: 'Loading...'.tr,
        processingText: 'Loading...'.tr,
        processedText: 'Succeeded'.tr,
        noMoreText: 'No more'.tr,
        failedText: 'Failed'.tr,
        messageText: 'Last updated at %T'.tr,
      );
  var jsonString = await rootBundle.loadString('assets/tdtheme.json');
  var _themeData = TDThemeData.fromJson('black', jsonString);

  runApp(_myApp(_themeData));
}

Widget _myApp(TDThemeData? tDesignTheme) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) {
      return GetX<ThemeController>(
        init: ThemeController(),
        builder: (themeController) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "好享记账",

            // --- 国际化配置 ---
            translations: AppTranslations(),
            supportedLocales: AppTranslations.supportedLocales,
            locale: Get.deviceLocale,
            fallbackLocale: AppTranslations.fallbackLocale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // --- 路由与绑定 ---
            getPages: Routers.routePages,
            initialRoute: SpUtil.getToken() == ""
                ? Routers.LoginPageUrl
                : Routers.LayoutPageUrl,
            initialBinding: InitialBinding(),

            // --- 生命周期 ---
            onDispose: () => Log().d("parent view onDispose"),
            onInit: () {
              SpUtil.setFirstOpenApp(true);
              Get.put(NotificationService());
            },

            // --- 主题配置 ---
            themeMode: themeController.themeMode.value,

            // 1. 暗色主题 (Dark Theme)
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.blueGrey[900], // 保持深色背景
              cardColor: _darkAppColors.cardBackground,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blueGrey[900],
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              // 全局卡片样式
              cardTheme: CardThemeData(
                color: _darkAppColors.cardBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              extensions: [
                if (tDesignTheme != null) tDesignTheme,
                _darkAppColors
              ],
            ),

            // 2. 亮色主题 (Light Theme)
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              // 高级冷灰背景
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
              cardColor: _lightAppColors.cardBackground,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF5F7FA),
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF2D3436)),
                titleTextStyle: TextStyle(
                    color: Color(0xFF2D3436),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              cardTheme: CardThemeData(
                color: _lightAppColors.cardBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              extensions: [
                if (tDesignTheme != null) tDesignTheme,
                _lightAppColors
              ],
            ),

            builder: (context, child) {
              return Scaffold(
                body: GestureDetector(
                  onTap: () => KeyboardUtils.hide(),
                  child: child,
                ),
              );
            },
          );
        },
      );
    },
  );
}

// ignore: non_constant_identifier_names
InitialBinding() {
  Get.lazyPut(() => LoginLogic());
}

// ------------ 底部配置变量 (直接在这里实例化) ------------
// 1. 亮色模式配置
const _lightAppColors = AppThemeColors(
  primaryText: Color(0xFF2D3436),
  secondaryText: Color(0xFF9EAAB7),
  cardBackground: Color(0xFFFFFFFF),
  chartLine: Color(0xFF2D3436),
  chartPalette: [
    Color(0xFF34495E),
    Color(0xFF576D7E),
    Color(0xFF95A5A6),
    Color(0xFFBDC3C7),
    Color(0xFFE8ECEF)
  ],
  navActive: Color(0xFF2D3436),
  // --- 新增 ---
  navInactive: Color(0xFFB2B2B2), // 浅灰
  mainButtonBg: Color(0xFF2D3436), // 深色按钮
  mainButtonIcon: Color(0xFFFFFFFF), // 白色图标
);

// 2. 暗色模式配置
const _darkAppColors = AppThemeColors(
  primaryText: Color(0xFFECF0F1),
  secondaryText: Color(0xFF95A5A6),
  cardBackground: Color.fromARGB(255, 44, 57, 63),
  // cardBackground: Color(0xFF2C3E50),
  //Color(0xFF2C3E50),
  chartLine: Color(0xFFECF0F1),
  chartPalette: [
    Color(0xFFECF0F1),
    Color(0xFFBDC3C7),
    Color(0xFF95A5A6),
    Color(0xFF7F8C8D),
    Color(0xFF34495E)
  ],
  navActive: Color(0xFFECF0F1),

  // --- 新增 ---
  navInactive: Color(0xFF636E72), // 深灰
  mainButtonBg: Color(0xFFECF0F1), // 亮色按钮 (在深色背景下醒目)
  mainButtonIcon: Color(0xFF2D3436), // 深色图标
);
