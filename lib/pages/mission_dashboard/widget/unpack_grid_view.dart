// 文件路径: lib/pages/mission_dashboard/widget/unpack_grid_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/mission_dashboard/controller.dart';
import 'package:journal/pages/mission_dashboard/widget/task_item_cell.dart';

class UnpackGridView extends GetView<MissionController> {
  const UnpackGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: Obx(() {
        final isPackingMode = controller.isPackingMode.value;

        final allItems = controller.currentTrip.value?.itemList ?? [];
        final unPackedTasks = allItems.where((t) => !t.isPacked).toList();

        if (unPackedTasks.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text("所有物品都已装箱 ~",
                    style: TextStyle(color: appColors.secondaryText)),
              ),
            ),
          );
        }
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            childAspectRatio: 1,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final task = unPackedTasks[index];
              return TaskItemCell(task: task, isPackingMode: isPackingMode);
            },
            childCount: unPackedTasks.length,
          ),
        );
      }),
    );
  }
}
