import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaHelper {
  /// 检查权限并选择图片
  static Future<File?> pickImageWithPermission(BuildContext context) async {
    bool hasPermission = await _checkPermission();

    if (!hasPermission) {
      if (!context.mounted) return null;
      _showPermissionDialog(context);
      return null;
    }

    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    return result != null ? File(result.path) : null;
  }

// 建议改名为 requestPermission，因为它包含请求动作
  static Future<bool> _checkPermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+: 同时请求图片和视频权限
        // 只要图片或视频任意一个被授权/部分授权，通常就可以视为通过
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();

        // 判断逻辑：图片 OR 视频 只要有一个是 granted 或 limited 即可
        // 注意：Android 14 的 limited 状态在这里很重要
        bool photoGranted = statuses[Permission.photos]!.isGranted ||
            statuses[Permission.photos]!.isLimited;
        bool videoGranted = statuses[Permission.videos]!.isGranted ||
            statuses[Permission.videos]!.isLimited;

        return photoGranted || videoGranted;
      } else {
        // Android < 13: 使用旧的存储权限
        status = await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      // iOS: 通常只需要 photos 权限即可访问相册（含视频）
      status = await Permission.photos.request();
    } else {
      return false;
    }

    // 处理结果
    if (status.isGranted || status.isLimited) {
      return true;
    }

    // 处理“永久拒绝”的情况：引导用户去设置
    if (status.isPermanentlyDenied) {
      // 这里可以弹出一个对话框，询问用户是否去设置开启
      // bool openSetting = await showDialog...
      // if (openSetting) await openAppSettings();
      print("权限被永久拒绝，请去设置开启");
    }

    return false;
  }

  static void _showPermissionDialog(BuildContext context) {
    PremiumGlassDialog.show(
      context,
      title: "权限提示",
      content: "希望读取你的相册，用于上传图片",
      onConfirm: () => openAppSettings(),
    );
  }
}
