import 'package:flutter/material.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/config/cos_config.dart';
import 'package:journal/core/log.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/toast_util.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/fetch_credentials.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class TencentCosService {
  // 单例模式 (可选，为了保持全局只初始化一次)
  static final TencentCosService _instance = TencentCosService._internal();
  factory TencentCosService() => _instance;
  TencentCosService._internal();

  /// 初始化 SDK
  static Future<void> init() async {
    Log().d("TencentCosService: init");
    await Cos().initWithSessionCredential(_CredentialFetcher());

    CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
      region: CosConfig.region,
      isDebuggable: false, // 生产环境建议改为 false
      isHttps: true,
    );

    TransferConfig transferConfig = TransferConfig(
      forceSimpleUpload: false,
      enableVerification: true,
      divisionForUpload: 2097152,
      sliceSizeForUpload: 1048576,
    );

    Cos().registerDefaultTransferManger(serviceConfig, transferConfig);
  }

  /// 通用上传方法
  /// 返回: 成功返回完整 CDN URL，失败返回 null
  Future<String?> uploadFile({
    required String filePath,
    required String userId,
    String prefix = "common",
    BuildContext? context, // 传入 Context 用于显示 Loading，可空
  }) async {
    final Completer<String?> completer = Completer();

    // 1. 显示 Loading (如果传入了 Context)
    if (context != null && context.mounted) {
      BrnLoadingDialog.show(context, content: "上传中", useRootNavigator: true);
    }

    // try {
    String uuid = const Uuid().v4().toString();
    String cosPath = "/journal/$prefix/$userId/$uuid.png";

    // 2. 获取 TransferManager
    CosTransferManger transferManager = Cos().getDefaultTransferManger();

    // 3. 定义回调监听
    ResultListener listener = ResultListener((header, result) {
      // --- 成功 ---
      if (context != null) ToastUtil.hideLoading();

      if (result != null && result.accessUrl != null) {
        // 替换域名为 CDN
        String finalUrl =
            result.accessUrl!.replaceAll(CosConfig.cosHost, CosConfig.cdnHost);
        // 这里为了保险，也可以直接拼：String finalUrl = "${CosConfig.cdnHost}$cosPath";
        completer.complete(finalUrl);
      } else {
        completer.complete(null);
      }
    }, (clientException, serviceException) {
      // --- 失败 ---
      if (context != null) {
        ToastUtil.hideLoading();
        BrnToast.show("上传失败", context);
      }
      Log().d("ClientErr: $clientException, ServiceErr: $serviceException");
      completer.complete(null);
    });

    // 4. 执行上传
    await transferManager.upload(CosConfig.bucket, cosPath,
        filePath: filePath, resultListener: listener);
    // } catch (e) {
    //   if (context != null) ToastUtil.hideLoading();
    //   e.printInfo();
    //   Log().d("Upload Exception: ${e..toString()}");
    //   completer.complete(null);
    // }

    return completer.future;
  }
}

/// 内部私有类：专门负责获取凭证
class _CredentialFetcher implements IFetchCredentials {
  @override
  Future<SessionQCloudCredentials> fetchSessionCredentials() async {
    try {
      var response =
          await HttpRequest.request(Method.get, "/tencent/cos/credential");
      var data = response['data'];
      Log().d("Credentials fetched");
      return SessionQCloudCredentials(
          secretId: data['secretId'],
          secretKey: data['secretKey'],
          token: data['sessionToken'],
          startTime: data['startTime'] ?? "",
          expiredTime: data['expiredTime'] ?? "");
    } catch (e) {
      Log().d("Credential Error: $e");
      throw ArgumentError("Failed to fetch credentials");
    }
  }
}
