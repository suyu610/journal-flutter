import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:journal/pages/reminder_settings/index.dart';

class ReminderSettingsPage extends GetView<ReminderSettingsController> {
  ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReminderSettingsController>(
      init: ReminderSettingsController(),
      builder: (_) {
        return Scaffold(
          appBar: _navibar(context),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _navibar(BuildContext context) {
    return const TDNavBar(
      useBorderStyle: true,
      height: 48,
      useDefaultBack: true,
      title: '记账提醒',
    );
  }

  Widget _buildView(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          TDCellGroup(
            theme: TDCellGroupTheme.cardTheme,
            cells: [
              TDCell(
                title: '开启提醒',
                note: '每天在设定时间提醒您记账',
                widget: TDSwitch(
                  value: controller.service.isEnabled.value,
                  onChanged: (value) {
                    controller.toggleReminder(value, context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TDCellGroup(
            theme: TDCellGroupTheme.cardTheme,
            cells: [
              TDCell(
                title: '提醒时间',
                note: controller.service.reminderTimes.isEmpty
                    ? '未设置'
                    : controller.service.reminderTimes.join(', '),
                arrow: true,
                onClick: (_) {
                  controller.showTimePicker(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.service.reminderTimes.isNotEmpty)
            Expanded(
              child: TDCellGroup(
                theme: TDCellGroupTheme.cardTheme,
                cells: controller.service.reminderTimes.map((time) {
                  return TDCell(
                    title: time,
                    rightIcon: TDIcons.delete,
                    onClick: (_) {
                      controller.removeTime(time, context);
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      );
    });
  }
}
