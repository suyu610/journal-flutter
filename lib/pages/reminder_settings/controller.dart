import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/services/notification_service.dart';
import 'package:journal/util/dialog_util.dart';

class ReminderSettingsController extends GetxController {
  final NotificationService service = NotificationService.to;

  void toggleReminder(bool value, BuildContext context) async {
    if (value) {
      final hasPermission = await service.checkPermissions();
      if (!hasPermission) {
        await service.requestPermissions();
        if (!service.isEnabled.value) {
          if (context.mounted) {
            BrnToast.show('请开启通知权限', context);
          }
          return;
        }
      }
    }
    service.toggleEnabled(value);
    if (value) {
      if (context.mounted) {
        BrnToast.show('提醒已开启', context);
      }
    } else {
      if (context.mounted) {
        BrnToast.show('提醒已关闭', context);
      }
    }
  }

  void showTimePicker(BuildContext context) {
    BrnDatePicker.showDatePicker(
      context,
      pickerMode: BrnDateTimePickerMode.time,
      dateFormat: 'HH:mm',
      onConfirm: (DateTime dateTime, List<int> selectedIndex) {
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final timeStr = '$hour:$minute';
        service.addReminderTime(timeStr);
        BrnToast.show('已添加提醒时间 $timeStr', context);
      },
    );
  }

  void removeTime(String time, BuildContext context) {
    PremiumGlassDialog.show(
      context,
      title: "确认删除",
      content: "确定要删除 $time 的提醒吗？",
      onConfirm: () {
        service.removeReminderTime(time);
        BrnToast.show('已删除提醒', context);
        Get.back();
      },
    );
  }
}
