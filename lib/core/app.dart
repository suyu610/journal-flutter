import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/core/injection.dart';
import 'package:journal/core/log.dart';
import 'package:journal/i10n/translations.dart';
import 'package:journal/pages/login/logic.dart';
import 'package:journal/routers.dart';
import 'package:journal/services/notification_service.dart';
import 'package:journal/util/keyboard_util.dart';
import 'package:journal/util/sp_util.dart';
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

Widget _myApp(_themeData) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "好享记账",
      onDispose: () {
        Log().d("parent view onDispose");
      },
      translations: AppTranslations(),
      supportedLocales: AppTranslations.supportedLocales,
      locale: Get.deviceLocale,
      fallbackLocale: AppTranslations.fallbackLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      getPages: Routers.routePages,
      themeMode: ThemeMode.light,
      darkTheme: ThemeData(
          scaffoldBackgroundColor: const Color(0xff35353b),
          cardColor: const Color(0xff35353b),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xff35353b)),
          extensions: [_themeData]),
      theme: ThemeData(
          useMaterial3: true,
          cardColor: Colors.white,
          scaffoldBackgroundColor: const Color(0xfff1f1f1),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          extensions: [_themeData]),
      initialRoute: SpUtil.getToken() == ""
          ? Routers.LoginPageUrl
          : Routers.LayoutPageUrl,
      initialBinding: InitialBinding(),
      onInit: () {
        SpUtil.setFirstOpenApp(true);
        Get.put(NotificationService());
      },
      builder: (context, child) {
        return Scaffold(
          body: GestureDetector(
              onTap: () {
                KeyboardUtils.hide();
              },
              child: child),
        );
      },
    ),
  );
}

// ignore: non_constant_identifier_names
InitialBinding() {
  Get.lazyPut(() => LoginLogic());
}
