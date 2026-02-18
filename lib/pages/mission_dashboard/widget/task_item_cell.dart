import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';

import 'package:journal/models/trip_item.dart';
import 'package:journal/pages/mission_dashboard/controller.dart';
import 'package:journal/pages/mission_dashboard/util/task_icon_mapper.dart';

class TaskItemCell extends StatelessWidget {
  final TripItem task;
  final bool isPackingMode;
  const TaskItemCell(
      {super.key, required this.task, required this.isPackingMode});
  @override
  Widget build(BuildContext context) {
    final MissionController controller = Get.find<MissionController>();
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final iconData = TaskIconMapper.getIcon("", task.itemName);
    // 构建紧凑卡片 UI
    Widget buildCardContent(bool isDragging) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isDragging
              ? appColors.cardBackground.withOpacity(0.8)
              : appColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDragging
                  ? appColors.primaryText.withOpacity(0.5)
                  : Colors.black.withOpacity(0.05),
              width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
          crossAxisAlignment: CrossAxisAlignment.center, // 水平居中（也可以改成 start）
          children: [
            Icon(iconData, color: appColors.primaryText, size: 22),
            const SizedBox(height: 6),
            Text(
              task.itemName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: appColors.primaryText,
              ),
            ),
            if (task.quantity > 1)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: appColors.primaryText,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "x${task.quantity}",
                  style: const TextStyle(
                      fontSize: 10,
                      height: 1,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      );
    }

    return Draggable<TripItem>(
      data: task,
      maxSimultaneousDrags: isPackingMode ? 1 : 0,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          // 反馈组件的大小，可以稍微大一点
          width: 80,
          height: 90,
          child: buildCardContent(true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: buildCardContent(false),
      ),
      child: GestureDetector(
        onTap:
            isPackingMode ? () => controller.toggleChecklistItem(task) : null,
        child: buildCardContent(false),
      ),
    );
  }
}
