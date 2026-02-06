import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_date_picker.dart';
import 'package:journal/components/journal_toast.dart';
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
            JournalToast.show(context, '请开启通知权限');
          }
          return;
        }
      }
    }
    service.toggleEnabled(value);
    if (value) {
      if (context.mounted) {
        JournalToast.show(context, '提醒已开启');
      }
    } else {
      if (context.mounted) {
        JournalToast.show(context, '提醒已关闭');
      }
    }
  }

  void showTimePicker(BuildContext context) {
    JournalDatePicker.show(
      context,
      mode: JournalDatePickerMode.time,
      onConfirm: (DateTime dateTime) {
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final timeStr = '$hour:$minute';
        service.addReminderTime(timeStr);
        JournalToast.show(context, '已添加提醒时间 $timeStr');
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
        JournalToast.show(context, '已删除提醒');
        Get.back();
      },
    );
  }
}
