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

  static Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      // Android 13 (API 33) 及以上使用 photos 权限
      if (androidInfo.version.sdkInt >= 33) {
        return await Permission.photos.request().isGranted;
      } else {
        return await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
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
