import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef JMap = Map<String, dynamic>;
typedef LJMap = List<JMap>;

class DeviceUtil {
  /// 获取应用版本号
  static Future<String> appVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// 获取应用的bundle-id
  static Future<String> packageName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }

  /// 获取应用的build号
  static Future<String> buildNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  /// 获取应用名
  static Future<String> appName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.appName;
  }

  /// 获取当前设备品牌
  static Future<String> phoneBrand() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      return "Apple";
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.brand;
    }
  }

  /// 获取设备名称
  static Future<String> phoneName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isMacOS) {
      return "MacOS";
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.display;
    }
  }

  /// 获取设备型号
  static Future<String> phoneModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isMacOS) {
      return "MacOS";
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.model;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    }
  }

  /// 获取设备型号
  static Future<String> iosSystemVersion() async {
    return (await iosDeviceInfo()).systemVersion;
  }

  /// 获取统一设备型号
  static Future<String> systemVersion() async {
    if (Platform.isIOS) {
      return (await iosDeviceInfo()).systemVersion;
    } else if (Platform.isAndroid) {
      return (await androidDeviceInfo()).version.release;
    }
    return '';
  }

  ///获取android设备信息
  static Future<AndroidDeviceInfo> androidDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    return await deviceInfo.androidInfo;
  }

  ///获取ios设备信息
  static Future<IosDeviceInfo> iosDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    return await deviceInfo.iosInfo;
  }

  /// newVersion 新版本号 old 老版本号
  static bool isUpdateVersion(String? newVersion, String? old) {
    if (newVersion == null ||
        newVersion.isEmpty ||
        old == null ||
        old.isEmpty) {
      return false;
    }
    int newVersionInt, oldVersion;
    var newList = newVersion.split('.');
    var oldList = old.split('.');
    if (newList.isEmpty || oldList.isEmpty) {
      return false;
    }
    for (int i = 0; i < newList.length; i++) {
      newVersionInt = int.parse(newList[i]);
      oldVersion = int.parse(oldList[i]);
      if (newVersionInt > oldVersion) {
        return true;
      } else if (newVersionInt < oldVersion) {
        return false;
      }
    }
    return false;
  }
}
