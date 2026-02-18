import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/empty_item.dart';
import 'package:journal/components/journal_switch.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/trip_item.dart';
import 'package:journal/pages/mission_dashboard/util/task_icon_mapper.dart';
import 'package:journal/pages/mission_dashboard/widget/task_item_cell.dart';
import 'package:journal/pages/mission_dashboard/widget/trip_card_item.dart';
import 'package:journal/util/toast_util.dart';
import 'controller.dart';

// ... import 保持不变 ...
class MissionPage extends GetView<MissionController> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    return GetBuilder<MissionController>(
      init: MissionController(),
      id: "mission",
      autoRemove: false,
      builder: (_) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: appColors.backgroundColor,
            body: _buildView(context, appColors),
          ),
        );
      },
    );
  }

  Widget _buildView(BuildContext context, AppThemeColors appColors) {
    return EasyRefresh(
      triggerAxis: Axis.vertical,
      controller: controller.refreshController,
      onRefresh: () async {
        ToastUtil.heavyImpact();
        controller.loadInitialData();
      },
      // 最外层包裹 DragTarget，用于接收从箱子拖出来的物品
      child: DragTarget<TripItem>(
        onWillAccept: (item) {
          if (!controller.isPackingMode.value) return false;
          return item?.isPacked ?? false;
        },
        onAccept: (item) {
          controller.toggleChecklistItem(item); // 取消完成，回到列表
        },
        builder: (context, candidateData, rejectedData) {
          return CustomScrollView(
            slivers: [
              _buildTripSection(context),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center, // 确保垂直居中
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("物品清单",
                                style: TextStyle(
                                    fontSize: 16, // 字号稍微加大，突出层级
                                    fontWeight: FontWeight.bold,
                                    color: appColors.primaryText)),
                            const SizedBox(width: 8),
                            Obx(() => JournalSwitch(
                                  value: controller.isPackingMode.value,
                                  activeIcon: Icons.lock_open_outlined,
                                  inactiveIcon: Icons.lock_outlined,
                                  onChanged: (v) =>
                                      controller.isPackingMode.value = v,
                                  width: 44, // 稍微加宽一点，让圆角更舒展
                                  height: 26,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          controller.nav2ToTripList(context);
                        },
                        child: Row(
                          children: [
                            Text("其他行程",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: appColors.secondaryText
                                        .withOpacity(0.5))),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: appColors.secondaryText.withOpacity(0.5),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. 箱子区域 ---
              _buildSuitcaseSection(context, appColors),

              // --- 3. 未装箱物品 标题 ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text("未装箱物品",
                      style: TextStyle(
                          fontSize: 14,
                          color: appColors.secondaryText)), // 截图里这里的字色偏淡一点
                ),
              ),

              // --- 4. 未装箱物品 网格 (逻辑修复) ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: Obx(() {
                  final isPackingMode = controller.isPackingMode.value;

                  // ⚠️ 修复：修正数据过滤逻辑的括号位置
                  final allItems = controller.currentTrip.value?.itemList ?? [];
                  final unPackedTasks =
                      allItems.where((t) => !t.isPacked).toList();

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
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 100,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                      childAspectRatio: 1, // 调整比例，让高度比宽度稍微大一点点
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = unPackedTasks[index];
                        return TaskItemCell(
                            task: task, isPackingMode: isPackingMode);
                      },
                      childCount: unPackedTasks.length,
                    ),
                  );
                }),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  // --- 构建箱子区域 ---
  Widget _buildSuitcaseSection(BuildContext context, AppThemeColors appColors) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final isPackingMode = controller.isPackingMode.value;
        final packedTasks = controller.tasks.where((t) => t.isPacked).toList();
        final totalCount = controller.tasks.length;
        final packedCount = packedTasks.length;
        if (totalCount == 0) return const SizedBox();
        return DragTarget<TripItem>(
          // 箱子作为拖入目标
          onWillAccept: (item) {
            if (!isPackingMode) return false;
            return !(item?.isPacked ?? true);
          },
          onAccept: (item) {
            controller.toggleChecklistItem(item); // 标记完成，进入箱子
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Obx(() => Text(
                              "背包: ${controller.currentTrip.value?.name ?? ""}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: appColors.primaryText),
                            )),
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
                                child: GestureDetector(
                                  onTap: isPackingMode
                                      ? () {
                                          controller.toggleChecklistItem(task);
                                        }
                                      : null,
                                  child: Container(
                                    width: 53,
                                    height: 44,
                                    decoration: BoxDecoration(
                                        color: appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4))
                                        ]),
                                    child: Icon(icon,
                                        color: appColors.primaryText, size: 20),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _buildSuitcaseIcon(
                                    icon, appColors, task, isPackingMode),
                              ),
                              child: Tooltip(
                                message: task.itemName,
                                child: _buildSuitcaseIcon(
                                    icon, appColors, task, isPackingMode),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 16),
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

  Widget _buildSuitcaseIcon(IconData icon, AppThemeColors appColors,
      TripItem task, bool isPackingMode) {
    return GestureDetector(
      onTap: isPackingMode
          ? () {
              print("点击了物品 $task");
              controller.toggleChecklistItem(task);
            }
          : null,
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

  // --- 抽取行程卡片构建逻辑 ---
  Widget _buildTripSection(BuildContext context) {
    var appColors = Theme.of(context).extension<AppThemeColors>()!;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          _buildTripTitle(appColors, context),
          const SizedBox(height: 6),
          // 内容区域
          Obx(() {
            if (controller.trips.isEmpty) {
              return JournalEmptyItem(
                title: "暂无行程",
                operateText: "添加",
                action: () => controller.showUploadDialog(context),
              );
            }

            return SizedBox(
              height: 300, // 固定高度以容纳卡片
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal, // 水平滚动
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.trips.length,

                // 排序回调
                onReorder: (oldIndex, newIndex) {
                  controller.reorderTrips(oldIndex, newIndex);
                },

                // 拖拽时的样式代理
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.05)
                          .animate(animation),
                      child: Opacity(opacity: 0.8, child: child),
                    ),
                  );
                },

                itemBuilder: (context, index) {
                  final trip = controller.trips[index];
                  return Container(
                    key: ValueKey(trip.id), // 必须有 Key
                    width: 340, // 卡片宽度
                    margin: const EdgeInsets.only(right: 12),
                    child: ExquisiteTripCard(
                      tripModel: trip,
                      // 连接 Controller 的方法
                      onEdit: () => controller.showConfirmDialog(trip, context,
                          existingTrip: trip),
                      onDelete: () => controller.deleteTrip(trip, context),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

_buildTripTitle(AppThemeColors appColors, BuildContext context) {
  MissionController controller = Get.find<MissionController>();
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("当前行程",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: appColors.primaryText)),
        TextButton(
          onPressed: () => controller.showUploadDialog(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Icon(Icons.add, size: 24, color: appColors.primaryText),
        ),
      ],
    ),
  );
}
