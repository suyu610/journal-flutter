import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/trip.dart';
import 'package:journal/models/item_library_model.dart';
import 'package:journal/models/trip_item.dart';
import 'package:journal/pages/mission_dashboard/util/task_icon_mapper.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'controller.dart'; // 引用你的 controller 路径

class TripChecklistPage extends GetView<TripListController> {
  const TripChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    // 截图风格的浅灰色背景
    const Color bgColor = Color(0xFFF5F6F9);

    return GetBuilder<TripListController>(
      init: TripListController(),
      id: "trip_list",
      builder: (_) {
        return Scaffold(
          backgroundColor: bgColor,
          appBar: JournalNavBar(
            title: "行程列表",
            rightBarItems: [
              NavBarItem(
                onTap: () {
                  Get.toNamed(Routers.TemplateListPageUrl);
                },
                iconWidget: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2E33), // 截图中的深色风格
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text("新建",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ),
              )
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.displayTrips.isEmpty) {
              return Center(
                  child: Text("暂无行程数据",
                      style: TextStyle(color: appColors.secondaryText)));
            }
            return EasyRefresh(
              controller: controller.easyRefreshController,
              onRefresh: () async => await controller.fetchTrips(),
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: controller.displayTrips.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildTripCard(
                      controller.displayTrips[index], appColors, context);
                },
              ),
            );
          }),
        );
      },
    );
  }

  // ==========================================
  // 👉 核心 UI：极简大圆角行程卡片
  // ==========================================
  Widget _buildTripCard(
      Trip trip, AppThemeColors appColors, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // 大圆角
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一部分：行程头部信息
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(trip.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: appColors.primaryText)),
                      ),
                      if (trip.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FF), // 浅蓝色背景
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("当前行程",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6B8AFF),
                                  fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                ),
                // 菜单
                GestureDetector(
                  onTap: () => _showTripActionMenu(trip, context, appColors),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(RemixIcons.more_2_fill,
                        size: 24,
                        color: appColors.secondaryText.withOpacity(0.5)),
                  ),
                )
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Color(0xFFF5F6F9)),
          ),

          // 第二部分：具体物品区
          Padding(
            padding: const EdgeInsets.all(20),
            child: (trip.itemList == null || trip.itemList!.isEmpty)
                ? GestureDetector(
                    // 没有物品时的大面积引导点击区域
                    onTap: () =>
                        _showLibraryItemPicker(trip, context, appColors),
                    child: Row(
                      children: [
                        Icon(RemixIcons.add_circle_line,
                            size: 18,
                            color: appColors.secondaryText.withOpacity(0.5)),
                        const SizedBox(width: 6),
                        Text("点击添加需要携带的物品",
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                    appColors.secondaryText.withOpacity(0.7))),
                      ],
                    ),
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // 遍历展示已有的物品
                      ...trip.itemList!.map((item) =>
                          _buildItemChip(trip, item, appColors, context)),

                      // 【+】小按钮
                      GestureDetector(
                        onTap: () =>
                            _showLibraryItemPicker(trip, context, appColors),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F9),
                            borderRadius: BorderRadius.circular(12), // 更圆润
                          ),
                          child: Icon(RemixIcons.add_line,
                              size: 16, color: appColors.secondaryText),
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // 单个物品的 UI
  Widget _buildItemChip(Trip trip, TripItem item, AppThemeColors appColors,
      BuildContext context) {
    final iconData = TaskIconMapper.getIcon("默认", item.itemName); // 兼容没有分类的模型
    final bool isPacked = item.isPacked;

    return GestureDetector(
      onTap: () => _showEditItemDialog(trip, item, context, appColors),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isPacked
              ? const Color(0xFFF9F9F9)
              : const Color(0xFFF5F6F9), // 已打包的颜色变浅
          borderRadius: BorderRadius.circular(12),
          border: isPacked
              ? null
              : Border.all(color: Colors.black.withOpacity(0.02)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData,
                size: 14,
                color: isPacked
                    ? Colors.grey.withOpacity(0.5)
                    : appColors.primaryText),
            const SizedBox(width: 6),
            Text(item.itemName,
                style: TextStyle(
                    fontSize: 13,
                    color: isPacked ? Colors.grey : appColors.primaryText,
                    decoration:
                        isPacked ? TextDecoration.lineThrough : null, // 增加删除线
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            Text("x${item.quantity}",
                style: TextStyle(
                    fontSize: 11,
                    color: isPacked ? Colors.grey : appColors.secondaryText,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 👉 交互弹窗区域
  // ==========================================

  // 1. 从物品库选择物品的抽屉 (原汁原味保留并适配 itemName 去重)
  void _showLibraryItemPicker(
      Trip trip, BuildContext context, AppThemeColors appColors) {
    final existingItemNames =
        trip.itemList?.map((e) => e.itemName).toSet() ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext sheetContext) {
        return FutureBuilder<List<ItemLibrary>>(
            future: controller.fetchAllLibraryItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                    height: 300,
                    child: Center(
                        child: Text("物品库暂无物品",
                            style: TextStyle(color: appColors.secondaryText))));
              }

              final allLibItems = snapshot.data!;
              // 初始化已选列表 (基于名称匹配)
              List<ItemLibrary> selectedItems = allLibItems
                  .where((item) => existingItemNames.contains(item.name))
                  .toList();

              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("向行程添加物品",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: appColors.primaryText)),
                            TextButton(
                              onPressed: () => controller.syncItemsToTrip(
                                  trip, selectedItems, context),
                              style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF2B2E33),
                                  foregroundColor: Colors.white),
                              child: Text("保存 (${selectedItems.length})"),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: allLibItems.length,
                          itemBuilder: (context, index) {
                            final libItem = allLibItems[index];
                            final isSelected = selectedItems
                                .any((e) => e.name == libItem.name);
                            final iconData = TaskIconMapper.getIcon(
                                libItem.category, libItem.name ?? "");

                            return ListTile(
                              leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF5F6F9),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(iconData,
                                      color: appColors.primaryText, size: 20)),
                              title: Text(libItem.name ?? "",
                                  style: TextStyle(
                                      color: appColors.primaryText,
                                      fontWeight: FontWeight.w500)),
                              subtitle: Text(libItem.category ?? "其它",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              trailing: Checkbox(
                                value: isSelected,
                                activeColor: const Color(0xFF2B2E33),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedItems.add(libItem);
                                    } else {
                                      selectedItems.removeWhere(
                                          (e) => e.name == libItem.name);
                                    }
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedItems.removeWhere(
                                        (e) => e.name == libItem.name);
                                  } else {
                                    selectedItems.add(libItem);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              });
            });
      },
    );
  }

  // 2. 修改模版内单个物品数量/删除的弹窗
  void _showEditItemDialog(Trip trip, TripItem item, BuildContext context,
      AppThemeColors appColors) {
    int currentQuantity = item.quantity;

    Get.bottomSheet(
      StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("修改数量",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: appColors.primaryText)),
              const SizedBox(height: 20),
              Text(item.itemName,
                  style: TextStyle(
                      fontSize: 20,
                      color: appColors.primaryText,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),

              // 数量步进器
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(RemixIcons.subtract_line),
                    color: currentQuantity <= 1
                        ? Colors.grey
                        : appColors.primaryText,
                    onPressed: () {
                      if (currentQuantity > 1) {
                        setState(() => currentQuantity--);
                      }
                    },
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text("$currentQuantity",
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(RemixIcons.add_line),
                    color: appColors.primaryText,
                    onPressed: () => setState(() => currentQuantity++),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          controller.modifyTripItem(trip, item, 0, context),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: appColors.dangerColor,
                          side: BorderSide(color: appColors.dangerColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text("从行程移除"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.modifyTripItem(
                          trip, item, currentQuantity, context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B2E33),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text("保存修改"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      }),
    );
  }

  // 3. 行程操作菜单
  void _showTripActionMenu(
      Trip trip, BuildContext context, AppThemeColors appColors) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 12, bottom: 30),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            if (!trip.isCurrent)
              _buildActionItem(
                  RemixIcons.star_line, "设为当前行程", appColors.primaryText, () {
                controller.toggleCurrent(trip.id, context);
                Get.back();
              }),
            _buildActionItem(
                RemixIcons.edit_2_line, "重命名", appColors.primaryText, () {
              Get.back();
              _showTripDialog(context, isAdd: false, trip: trip);
            }),
            _buildActionItem(
                RemixIcons.delete_bin_line, "删除行程", appColors.dangerColor, () {
              Get.back();
              JournalDialog.show(
                context,
                title: "删除警告",
                content: "删除后不可恢复，确定要删除【${trip.name}】吗？",
                onConfirm: () {
                  controller.deleteTrip(trip.id, context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
      IconData icon, String title, Color? color, VoidCallback onTap) {
    return ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(title,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w500)),
        onTap: onTap);
  }

  // 4. 新增/重命名 行程信息的弹窗
  void _showTripDialog(BuildContext context,
      {required bool isAdd, Trip? trip}) {
    final TextEditingController nameController =
        TextEditingController(text: trip?.name ?? "");
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Color(0xFFF5F6F9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isAdd ? "新建行程" : "重命名",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      if (isAdd) {
                        controller.addTrip(nameController.text, context);
                      } else {
                        trip!.name = nameController.text;
                        controller.updateTrip(trip, context);
                        Get.back();
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2E33),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6)),
                    child: Text(isAdd ? "创建" : "保存"),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Text("行程名称",
                  style:
                      TextStyle(color: appColors.secondaryText, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: nameController,
                  autofocus: isAdd,
                  style: TextStyle(color: appColors.primaryText, fontSize: 16),
                  decoration: const InputDecoration(
                      hintText: "给这趟行程起个名...",
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
