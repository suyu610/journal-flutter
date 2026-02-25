// 文件路径: lib/pages/mission_dashboard/widget/suitcase_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/trip_item.dart';
import 'package:journal/pages/mission_dashboard/controller.dart';
import 'package:journal/pages/mission_dashboard/util/task_icon_mapper.dart';
import 'package:journal/util/toast_util.dart';

class SuitcaseView extends GetView<MissionController> {
  const SuitcaseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return SliverToBoxAdapter(
      child: Obx(() {
        final isPackingMode = controller.isPackingMode.value;
        final packedTasks = controller.tasks.where((t) => t.isPacked).toList();
        final totalCount = controller.tasks.length;
        final packedCount = packedTasks.length;

        if (totalCount == 0) return const SizedBox();

        return DragTarget<TripItem>(
          onWillAccept: (item) {
            if (!isPackingMode) return false;
            return !(item?.isPacked ?? true);
          },
          onAccept: (item) {
            controller.toggleChecklistItem(item);
            ToastUtil.heavyImpact();
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isHovering
                    ? appColors.primaryText.withOpacity(0.08)
                    : appColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: isHovering
                        ? appColors.primaryText
                        : Colors.black.withOpacity(0.05),
                    width: isHovering ? 2 : 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "背包: ${controller.currentTrip.value?.name ?? "默认清单"}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: appColors.primaryText),
                        ),
                      ),
                      Text("$packedCount / $totalCount",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: appColors.primaryText)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 物品列表
                  packedTasks.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text("把物品拖到这里装箱...",
                                style: TextStyle(
                                    color: appColors.secondaryText
                                        .withOpacity(0.5))),
                          ),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: 12,
                          children: packedTasks.map((task) {
                            final icon =
                                TaskIconMapper.getIcon("", task.itemName);
                            return Draggable<TripItem>(
                              data: task,
                              maxSimultaneousDrags: isPackingMode ? 1 : 0,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _SuitcaseIcon(
                                    icon: icon,
                                    task: task,
                                    isPackingMode: isPackingMode,
                                    appColors: appColors),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _SuitcaseIcon(
                                    icon: icon,
                                    task: task,
                                    isPackingMode: isPackingMode,
                                    appColors: appColors),
                              ),
                              child: Tooltip(
                                message: task.itemName,
                                child: _SuitcaseIcon(
                                    icon: icon,
                                    task: task,
                                    isPackingMode: isPackingMode,
                                    appColors: appColors),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 16),

                  // 进度条
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalCount == 0 ? 0 : packedCount / totalCount,
                      backgroundColor: Colors.black.withOpacity(0.05),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(appColors.primaryText),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

// 私有小组件：箱子里的图标
class _SuitcaseIcon extends StatelessWidget {
  final IconData icon;
  final TripItem task;
  final bool isPackingMode;
  final AppThemeColors appColors;

  const _SuitcaseIcon({
    Key? key,
    required this.icon,
    required this.task,
    required this.isPackingMode,
    required this.appColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MissionController controller = Get.find();
    return GestureDetector(
      onTap: isPackingMode ? () => controller.toggleChecklistItem(task) : null,
      child: Container(
        width: 59,
        height: 44,
        decoration: BoxDecoration(
            color: appColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: appColors.secondaryText.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                  color: appColors.cardBackground,
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (task.quantity > 1)
              Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: appColors.backgroundColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(task.quantity.toString(),
                          style: TextStyle(
                              color: appColors.primaryText,
                              fontSize: 7,
                              fontWeight: FontWeight.bold)),
                    ),
                  )),
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: appColors.primaryText, size: 20),
                const SizedBox(height: 2),
                Text(task.itemName,
                    style: TextStyle(
                      color: appColors.primaryText,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
