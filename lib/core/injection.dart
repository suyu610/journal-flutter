import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_life_cycle.dart';
import 'package:journal/core/flutter_error.dart';
import 'package:journal/core/log.dart';
import 'package:journal/core/page_state.dart';
import 'package:journal/services/local_server.dart';
import 'package:journal/util/cos.dart';
import 'package:journal/util/screen_util.dart';
import 'package:journal/util/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 初始化时进行依赖注入-全局
class Injection {
  ///初始化
  static Future<void> init() async {
    await Get.putAsync(() => SharedPreferences.getInstance());
    //异常处理
    ErrorHelper.init();
    //路由记录监听器
    RouteHistoryObserver.init();
    //强制竖屏
    ScreenUtils.setPreferredOrientation();
    //暗黑变化监听, （主题变化监听，强制页面UI更新）
    AppLifeCycleDelegate();
    //透明状态栏
    // ScreenUtils.setSystemTransparent();
    //整理日志文件
    ConsoleOutput().clearUpLogFile();
    // 判断是否安装了微信
    await Fluwx().registerApi(
        doOnIOS: true,
        doOnAndroid: true,
        appId: "wx30e85737940da4af",
        universalLink: "https://journal.uuorb.com/app/");
    SpUtil.setWeChatInstalled(await Fluwx().isWeChatInstalled);
    await TencentCosService.init();

    await LocalServer.start();
  }
}
