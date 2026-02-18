import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
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

  runApp(_myApp());
}

Widget _myApp() {
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
              extensions: const [_darkAppColors],
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
                    fontWeight: FontWeight.w500),
              ),
              cardTheme: CardThemeData(
                color: _lightAppColors.cardBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              extensions: const [_lightAppColors],
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

// 1. 亮色模式配置
const _lightAppColors = AppThemeColors(
  // 新增
  backgroundColor: Color(0xFFF5F7FA),
  // 原有
  primaryText: Color(0xFF2D3436),
  secondaryText: Color(0xFF9EAAB7),
  cardBackground: Color(0xFFFFFFFF),
  chartLine: Color(0xFF2D3436),
  chartPalette: [
    Color(0xFF1677FF), // 1. 核心蓝 (最深)
    Color(0xFF3388FF), // 2.
    Color(0xFF519AFF), // 3.
    Color(0xFF6FACFF), // 4.
    Color(0xFF8CBEFF), // 5.
    Color(0xFFAAD0FF), // 6.
    Color(0xFFC8E2FF), // 7.
    Color(0xFFE6F4FF), // 8. 冰川蓝 (最浅)
  ],
  navActive: Color(0xFF2D3436),
  navInactive: Color(0xFFB2B2B2),
  mainButtonBg: Color(0xFF2D3436),
  mainButtonIcon: Color(0xFFFFFFFF),
  brandColor: Color(0xFF2D3436),
  onBrandColor: Color(0xFFFFFFFF),
  dangerColor: Color(0xFFFF4757),
  outlineBorder: Color(0xFFDFE6E9),
);

// 2. 暗色模式配置
const _darkAppColors = AppThemeColors(
  backgroundColor: Color(0xFF2D3436),
  primaryText: Color(0xFFECF0F1),
  secondaryText: Color(0xFF95A5A6),
  cardBackground: Color.fromARGB(255, 44, 57, 63), // 你的深青灰背景
  chartLine: Color(0xFFECF0F1),
  chartPalette: [
    Color(0xFF1677FF), // 1. 核心蓝 (最深)
    Color(0xFF3388FF), // 2.
    Color(0xFF519AFF), // 3.
    Color(0xFF6FACFF), // 4.
    Color(0xFF8CBEFF), // 5.
    Color(0xFFAAD0FF), // 6.
    Color(0xFFC8E2FF), // 7.
    Color(0xFFE6F4FF), // 8. 冰川蓝 (最浅)
  ],
  navActive: Color(0xFFECF0F1),
  navInactive: Color(0xFF636E72),
  mainButtonBg: Color(0xFFECF0F1),
  mainButtonIcon: Color(0xFF2D3436),

  // === 新增语义化配置 ===
  // 品牌色：复用你的亮色文字 (ECF0F1)，在深色背景下最醒目
  brandColor: Color(0xFFECF0F1),
  // 品牌文字色：复用你的深色背景色 (2D3436)，形成黑字白底
  onBrandColor: Color(0xFF2D3436),
  // 危险色：深色模式下红稍微亮一点，或者偏粉一点，这里选用了稍柔和的红
  dangerColor: Color(0xFFFF6B81),
  // 边框色：复用 navInactive 或稍深一点
  outlineBorder: Color(0xFF636E72),
);
