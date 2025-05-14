import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:journal/core/log.dart';
import 'package:journal/util/device_util.dart';

class ErrorHelper {
  /// 异常捕获处理
  static void init() {
    //捕获异常
    FlutterError.onError = (errorDetails) {
      _logError(errorDetails.exception, errorDetails.stack);
    };
    //捕获异步异常
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
    // 自定义报错页面
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      Log().d(flutterErrorDetails.toString());
      return Center(
          child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "发生错误",
                style: TextStyle(
                    
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 16,
                ),
              ]),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(5)),
            height: 100,
            child: ListView(
              children: [Text(flutterErrorDetails.toString())],
            ),
          )
        ],
      ));
    };
  }

  /// 打印日志，存到日志文件中
  static Future<void> _logError(dynamic error, dynamic stackTrace) async {
    String logMessage = '''
    ---------------- APP Exception ----------------
    $error$stackTrace
    ---------------- APP Exception ----------------
    ''';
    Log().d(logMessage);

    // 发送到服务器
    await sendLogToServer(logMessage);
  }

  static sendLogToServer(String logMessage) async {
    String sysName = Platform.operatingSystem; // ? "iOS" : "Android";
    String appVersion = await DeviceUtil.appVersion();
    String appName = "journal";
    String model = await DeviceUtil.phoneModel();
    String osVersion = await DeviceUtil.systemVersion();

    logMessage += "============\n"
        "appVersion:$appVersion, appName:$appName, model:$model, osVersion:$osVersion, sysName:$sysName";

  }
}
