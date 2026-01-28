import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:journal/services/notification_service.dart';

class ReminderSettingsController extends GetxController {
  final NotificationService service = NotificationService.to;

  void toggleReminder(bool value, BuildContext context) async {
    if (value) {
      final hasPermission = await service.checkPermissions();
      if (!hasPermission) {
        await service.requestPermissions();
        if (!service.isEnabled.value) {
          TDToast.showSuccess('请开启通知权限', context: context);
          return;
        }
      }
    }
    service.toggleEnabled(value);
    if (value) {
      TDToast.showSuccess('提醒已开启', context: context);
    } else {
      TDToast.showSuccess('提醒已关闭', context: context);
    }
  }

  void showTimePicker(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return TDTimePicker(
          title: '选择提醒时间',
          onConfirm: (time) {
            final hour = time.hour.toString().padLeft(2, '0');
            final minute = time.minute.toString().padLeft(2, '0');
            final timeStr = '$hour:$minute';
            service.addReminderTime(timeStr);
            TDToast.showSuccess('已添加提醒时间 $timeStr', context: context);
            Get.back();
          },
        );
      },
    );
  }

  void removeTime(String time, BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return TDAlertDialog(
          title: '确认删除',
          content: '确定要删除 $time 的提醒吗？',
          rightBtnAction: () {
            service.removeReminderTime(time);
            TDToast.showSuccess('已删除提醒', context: context);
            Get.back();
          },
        );
      },
    );
  }
}
