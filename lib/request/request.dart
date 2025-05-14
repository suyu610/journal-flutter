import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:journal/core/log.dart';
import 'package:journal/request/http_exception.dart';
import 'package:journal/request/http_response.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/device_util.dart';
import 'package:journal/util/sp_util.dart';

import 'url.dart';

/// 连接超时时间
const int _connectTimeout = 1500000;

/// 发送超时时间
const int _sendTimeout = 1500000;

/// 成功回调
typedef Success<T> = Function(T data);

/// 失败回调
typedef Fail = Function(int code, String msg);

/// 完成回调
typedef Complete = VoidCallback;

class HttpRequest {
  static Dio? _dio;

  static Dio get dio => createInstance();

  /// 创建 dio 实例对象
  static Dio createInstance({int receiveTimeout = 1000000}) {
    if (_dio == null) {
      var options = BaseOptions(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => true,
        sendTimeout: _sendTimeout,
        connectTimeout: _connectTimeout,
        receiveTimeout: receiveTimeout,
        baseUrl: HttpUrl.baseUrl,
      );
      _dio = Dio(options);
    }
    return _dio!;
  }

  /// 请求，返回参数为 T
  static Future<T?> request<T>(Method method, String path,
      {dynamic params,
      Map<String, dynamic>? header,
      Success<T>? success,
      Fail? fail,
      Complete? complete,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      bool isStream = false}) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        fail?.call(HttpException.netError, HttpException.netWorkError);
        return Future.value(null);
      }
      Dio dio = createInstance();
      Log().d("request url -> $path request param:$params");

      Response response = await dio.request(
        path,
        data: params,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          method: _methodValues[method],
          headers: await _headerToken(header, url: path),
          responseType: isStream ? ResponseType.stream : ResponseType.json,
        ),
      );
      // 流式
      if (isStream) {
        success?.call(response.data.stream);
        return Future.value(response.data.stream);
        // processStreamResponse(response.data.stream);
      } else {
        var result = Result.fromJson(response.data);
        Log().d("$path result -> ${response.data}");
        if (result.code == -1) {
          Log().d("token失效");
          SpUtil.removeToken();
          getx.Get.offAllNamed(Routers.LoginPageUrl);
        }

        if (response.statusCode == 200 && result.code == Result.SUCCESS_CODE) {
          success?.call(result.data as T);
        } else {
          Log().d("result fail -> code: ${result.code} msg:${result.errorMsg}");
          fail?.call(result.code ?? -1, result.errorMsg ?? "未知错误");
        }
      }
      return Future.value(response.data as T);
    } on DioError catch (e) {
      final NetError netError = HttpException.handleException(e);
      fail?.call(netError.code, netError.errorMsg);

      Log().d(
          "error =====> message: ${e.message},\ntype:${e.type},\nresponse:${e.response}, \nerror:${e.error}");
      return Future.value(null);
    } finally {
      complete?.call();
    }
  }
}



/// 处理流式响应
Future<void> processStreamResponse(Stream stream) async {

  // 用于每个阶段的对话结果
  final StringBuffer buffer = StringBuffer();

  // 处理流式响应
  await for (var data in stream) {

    // 将字节数据解码为字符串
    final bytes = data as List<int>;
    final decodedData = utf8.decode(bytes);
    // 移除 JSON 数据前的额外字符
    // 这里因为qwen模型的响应数据每次都以data:开头，后面跟着一个json字符串，所以需要先移除data:
    List<String> jsonData = decodedData.split('data: ');

    // 移除空字符串
    jsonData = jsonData.where((element) => element.isNotEmpty).toList();

    // 遍历每个阶段
    for (var element in jsonData) {

      // 判断是否结束，如果结束则直接返回
      if (element == '[DONE]') {
        break;
      }

      try {
        // 解析 JSON 数据
        final json = jsonDecode(element);

        // 获取当前阶段的对话结果，根据qwen模型的对接文档，这里的content就是当前阶段的对话结果，finish_reason表示当前阶段是否结束
        final content = json['choices'][0]['delta']['content'] as String;
        final finishReason = json['choices'][0]['finish_reason'] ?? '';

        if (content.isNotEmpty) {
          // 将每次的 content 添加到缓冲区中
          buffer.write(content);
          // 输出对话结果
          print(buffer.toString());
        }
        if (finishReason == 'stop') {
          // 如果 finish_reason 为 stop，则输出完整的对话完成结果
          print(buffer.toString());
          break;
        }

      } catch (e) {
        print('Error parsing JSON: $e');
        // 如果解析失败，可以尝试其他方式处理数据
        // 例如，检查是否有其他非标准前缀，并进行相应的处理
      }
    }
  }
}


enum Method { get, post, delete, put, patch, head }

const _methodValues = {
  Method.get: "get",
  Method.post: "post",
  Method.delete: "delete",
  Method.put: "put",
  Method.patch: "patch",
  Method.head: "head",
};

Future<Map<String, dynamic>?> _headerToken(Map<String, dynamic>? optionalHeader,
    {String? url}) async {
  String sysName = Platform.isIOS ? "iOS" : "Android";
  String appVersion = await DeviceUtil.appVersion();
  String appName = "vigolive_app";
  String model = await DeviceUtil.phoneModel();
  String osVersion = await DeviceUtil.systemVersion();
  String? token = SpUtil.getToken();
  Map<String, dynamic> httpHeaders = {
    "x-wx-from-appid": "wx2f6af8ec967dde40",
    "x-model-type": "PHONE",
    "x-os-type": sysName,
    "x-os-version": osVersion,
    "x-phone-model": model,
    "x-app-version": appVersion,
    "x-app-name": appName,
    "Authorization": token,
    "x-app": "app"
  };
  if (optionalHeader != null) {
    httpHeaders.addAll(optionalHeader);
  }
  // Log().d("$url request header -> ${httpHeaders.toString()}");
  return httpHeaders;
}
