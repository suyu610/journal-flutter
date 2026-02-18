// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:journal/util/app_logger.dart';

// /// 推送服务
// /// 负责接收原生层的 deviceToken 并上传到后端
// class PushService {
//   static final PushService _instance = PushService._internal();
//   factory PushService() => _instance;
//   PushService._internal();

//   static const MethodChannel _channel = MethodChannel('journal/push');

//   /// 初始化推送服务
//   /// 监听原生层的 token 回调
//   Future<void> initialize() async {
//     try {
//       _channel.setMethodCallHandler(_handleMethodCall);
//       AppLogger.success(Module.notification, '推送服务初始化成功');
//     } catch (e) {
//       AppLogger.error(
//           Module.notification, '推送服务初始化失败', {'error': e.toString()});
//     }
//   }

//   /// 处理原生层的方法调用
//   Future<dynamic> _handleMethodCall(MethodCall call) async {
//     switch (call.method) {
//       case 'onDeviceToken':
//         final String token = call.arguments as String;
//         AppLogger.success(Module.notification, '收到 APNs Token', {
//           'tokenPrefix': '${token.substring(0, 10)}...',
//         });
//         // await _uploadDeviceToken(token, 'ios');
//         break;

//       case 'onTPNSToken':
//         final String token = call.arguments as String;
//         AppLogger.success(Module.notification, '收到 TPNS Token', {
//           'tokenPrefix': '${token.substring(0, 10)}...',
//         });
//         // TPNS token 也上传（可以同时支持两种 token）
//         // await _uploadDeviceToken(token, 'ios');
//         break;

//       case 'onDeviceTokenError':
//         final String error = call.arguments as String;
//         AppLogger.error(Module.notification, 'Token 获取失败', {'error': error});
//         break;

//       default:
//         AppLogger.warning(
//             Module.notification, '未知的方法调用', {'method': call.method});
//     }
//   }

//   /// 上传待处理的 token（登录后调用）
//   ///
//   /// 调用时机：用户登录成功后
//   // Future<void> uploadPendingToken() async {
//   //   if (_pendingToken != null && _pendingPlatform != null) {
//   //     AppLogger.info(Module.notification, '上传缓存的 deviceToken');
//   //     await _uploadDeviceToken(_pendingToken!, _pendingPlatform!);
//   //     // 上传后清除缓存
//   //     _pendingToken = null;
//   //     _pendingPlatform = null;
//   //   }
//   // }
// }
