import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/log.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/toast_util.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/fetch_credentials.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';
import 'package:uuid/uuid.dart';

typedef ResultSuccessCallBack = Function(
    Map<String?, String?>? header, CosXmlResult? result);

class FetchCredentials implements IFetchCredentials {
  var kDebugMode = true;
  Future<String> upload(
    String filePath,
    String userId,
    String prifix,
    BuildContext context,
    ResultSuccessCallBack successCallBack,
  ) async {
    //上传失败回调
    failCallBack(clientException, serviceException) {
      ToastUtil.hideLoading();
      BrnToast.show("上传失败", Get.context!);
      if (clientException != null) {
        Log().d(clientException);
      }
      if (serviceException != null) {
        Log().d(serviceException);
      }
    }

    try {
      BrnLoadingDialog.show(context, content: "上传中", useRootNavigator: true);
      String uuid = const Uuid().v4().toString();
      // uuid

      CosTransferManger transferManager = Cos().getDefaultTransferManger();
      String bucket = "uuorb-1254798469";
      // // 对象key

      String cosPath = "/journal/$prifix/$userId/$uuid.png";
      // // 本地文件的绝对路径
      String srcPath = filePath;
      String? uploadId;

      // 开始上传
      TransferTask transferTask = await transferManager.upload(bucket, cosPath,
          filePath: srcPath,
          uploadId: uploadId,
          resultListener: ResultListener(successCallBack, failCallBack));

      Log().d(transferTask.toString());
      return "https://cdn.uuorb.com/$cosPath";
    } catch (e) {
      // BrnToast.show(e.toString(), context);
      Log().d(e.toString());
      e.printError();
      return "";
    }
  }

  @override
  Future<SessionQCloudCredentials> fetchSessionCredentials() async {
    Log().d("fetchSessionCredentials");
    // 首先从您的临时密钥服务器获取包含了密钥信息的响应，例如：
    try {
      var response =
          await HttpRequest.request(Method.get, "/tencent/cos/credential");

      var data = response['data'];
      // 然后解析响应，获取临时密钥信息
      Log().d("Credentials: $data");
      // 最后返回临时密钥信息对象
      return SessionQCloudCredentials(
          secretId: data['secretId'], // 临时密钥 SecretId
          secretKey: data['secretKey'], // 临时密钥 SecretKey
          token: data['sessionToken'], // 临时密钥 Token
          startTime: data['startTime'] ?? "", //临时密钥有效起始时间，单位是秒
          expiredTime: data['expiredTime'] ?? "" //临时密钥有效截止时间戳，单位是秒
          );
    } catch (exception) {
      throw ArgumentError();
    }
  }
}

void initTencentCos() async {
  Log().d("initTencentCos");
  String region = "ap-beijing";
  await Cos().initWithSessionCredential(FetchCredentials());
  // 创建 CosXmlServiceConfig 对象，根据需要修改默认的配置参数
  CosXmlServiceConfig serviceConfig = CosXmlServiceConfig(
    region: region,
    isDebuggable: true,
    isHttps: true,
  );

  TransferConfig transferConfig = TransferConfig(
    forceSimpleUpload: false,
    enableVerification: true,
    divisionForUpload: 2097152, // 设置大于等于 2M 的文件进行分块上传
    sliceSizeForUpload: 1048576, //设置默认分块大小为 1M
  );

  // 注册默认 COS TransferManger
  Cos().registerDefaultTransferManger(serviceConfig, transferConfig);
}
