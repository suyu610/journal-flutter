// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dio/dio.dart';

/// 错误信息处理
class HttpException {
  static const int unknownError = 9999;
  static const int socketError = 10000;
  static const int httpError = 10001;
  static const int parseError = 10002;
  static const int timeoutError = 10003;
  static const int cancelError = 10004;
  static const int netError = 10005;

  static const String netWorkError =
      "Network error. Please check your connection and try again.";
  static const String errorOccur = "Error Occurred";
  static const String requestTimeout = "Request Timeout";

  /// 错误信息处理
  /// [error] 错误信息类型
  static NetError handleException(DioError error) {
    switch (error.type) {
      case DioErrorType.response:
        dynamic e = error.error;
        if (e is SocketException) {
          return NetError(socketError, netWorkError);
        } else if (e is HttpException) {
          return NetError(httpError, errorOccur);
        } else if (e is FormatException) {
          return NetError(parseError, errorOccur);
        } else {
          return NetError(netError, netWorkError);
        }
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
        return NetError(timeoutError, requestTimeout);
      case DioErrorType.cancel:
        return NetError(cancelError, errorOccur);
      default:
        return NetError(unknownError, errorOccur);
    }
  }
}

class NetError {
  int code;
  String errorMsg;

  NetError(this.code, this.errorMsg);
}
