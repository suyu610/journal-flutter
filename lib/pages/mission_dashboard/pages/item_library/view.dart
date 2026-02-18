import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/item_library_model.dart';
import 'package:journal/pages/mission_dashboard/util/task_icon_mapper.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart';

import 'package:journal/pages/mission_dashboard/pages/item_library/controller.dart';

class ItemLibraryPage extends GetView<ItemLibraryController> {
  const ItemLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 获取主题扩展颜色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<ItemLibraryController>(
      init: ItemLibraryController(),
      id: "item_library",
      builder: (_) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F9), // 浅灰背景，仿截图
          appBar: JournalNavBar(
            title: "我的物品", // 截图标题
            rightBarItems: [
              NavBarItem(
                onTap: () => _showAddDialog(context),
                iconWidget: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 16, color: appColors.primaryText),
                      const SizedBox(width: 4),
                      Text("物品",
                          style: TextStyle(
                              color: appColors.primaryText,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              // 1. 新增：搜索框 UI
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 12, bottom: 4),
                child: Container(
                  height: 40, // 搜索框高度
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.searchQuery.value = value,
                    style:
                        TextStyle(color: appColors.primaryText, fontSize: 14),

                    // 👇 1. 明确告诉 TextField 内容需要垂直居中
                    textAlignVertical: TextAlignVertical.center,

                    decoration: InputDecoration(
                      // 👇 2. 开启紧凑模式，消除 Flutter 默认自带的冗余内边距
                      isDense: true,

                      // 👇 3. 清空手动指定的垂直 padding，完全交给 textAlignVertical 自动计算
                      contentPadding: EdgeInsets.zero,

                      hintText: "搜索物品名称",
                      hintStyle: TextStyle(
                          color: appColors.secondaryText, fontSize: 13),

                      // 限制 prefixIcon 的约束大小，防止图标默认的约束挤压文字空间
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      prefixIcon: const Icon(RemixIcons.search_line,
                          color: Colors.grey, size: 18),

                      // 同样限制 suffixIcon 的约束大小
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      suffixIcon:
                          Obx(() => controller.searchQuery.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => controller.clearSearch(),
                                  child: const Icon(
                                      RemixIcons.close_circle_fill,
                                      color: Colors.grey,
                                      size: 18),
                                )
                              // 保持占位组件大小与 Icon 约束一致，防止 UI 抖动
                              : const SizedBox(width: 40, height: 40)),

                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              // 2. 分类 Tab 栏 (仿截图 IMG_2993)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Obx(() => ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildCategoryChip(
                            "全部", controller, appColors.primaryText),
                        ...controller.categories.map((cat) =>
                            _buildCategoryChip(
                                cat, controller, appColors.primaryText)),
                      ],
                    )),
              ),

              // 4. 物品网格列表
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.displayItems.isEmpty) {
                    return Center(
                        child: Text("暂无物品",
                            style: TextStyle(color: appColors.secondaryText)));
                  }
                  return EasyRefresh(
                    controller: controller.easyRefreshController,
                    onRefresh: () async => await controller.fetchItems(),
                    child: Scrollbar(
                      controller: controller.scrollController,
                      // 👇 直接使用 GridView.builder，删掉 SingleChildScrollView
                      child: GridView.builder(
                        controller: controller
                            .scrollController, // 把 controller 移给 GridView
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: controller.displayItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.displayItems[index];
                          return _buildItemCard(
                              item,
                              appColors.cardBackground,
                              appColors.primaryText,
                              appColors.secondaryText,
                              context);
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
      String category, ItemLibraryController controller, Color primaryColor) {
    bool isSelected = controller.selectedCategory.value == category;
    int count = controller.getCountByCategory(category);

    return GestureDetector(
      onTap: () => controller.selectedCategory.value = category,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            category == "全部" ? "全部" : "$category ($count)",
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(ItemLibrary item, BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    nameController.text = item.name ?? "";
    categoryController.text = item.category ?? "其它";
    controller.tempImgUrl.value = item.img;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("编辑物品", // 标题改为编辑
                      style: TextStyle(fontSize: 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          JournalDialog.show(
                            context,
                            title: "删除物品",
                            content: "确定要删除 ${item.name} 吗？",
                            onConfirm: () {
                              controller.deleteItem(item.id!, context);
                              Get.back();
                            },
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: appColors.dangerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                        ),
                        child: const Text("删除"), // 按钮改为保存
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          final updatedItem = ItemLibrary(
                            id: item.id,
                            name: nameController.text,
                            category: categoryController.text,
                            img: controller.tempImgUrl.value, // 使用当前(可能已修改)的图片
                            createTime: item.createTime,

                            icon: item.icon,
                          );

                          controller.updateItem(updatedItem, context);
                        },

                        style: TextButton.styleFrom(
                          backgroundColor: appColors.brandColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                        ),
                        child: const Text("保存"), // 按钮改为保存
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text("基本信息",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),

              // --- 图片 + 名称 (完全复用新增逻辑) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => controller.pickAndUploadImage(context),
                    child: Obx(() {
                      bool hasImage = controller.tempImgUrl.value != null &&
                          controller.tempImgUrl.value!.isNotEmpty;
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                          image: hasImage
                              ? DecorationImage(
                                  image: NetworkImage(
                                      controller.tempImgUrl.value!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: hasImage
                            ? null
                            : const Icon(Icons.camera_alt,
                                color: Colors.grey, size: 24),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        style: TextStyle(
                            color: appColors.primaryText, fontSize: 14),
                        controller: nameController,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: appColors.secondaryText),
                          hintText: "请输入物品名称",
                          prefixIcon: const Icon(RemixIcons.archive_line,
                              color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- 物品分类 ---
              const Text("物品分类",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  style: TextStyle(color: appColors.primaryText, fontSize: 14),
                  controller: categoryController,
                  decoration: InputDecoration(
                    hintText: "输入或选择下方分类",
                    hintStyle: TextStyle(color: appColors.secondaryText),
                    prefixIcon: const Icon(RemixIcons.price_tag_3_line,
                        color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- 快捷标签 ---
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.categories.map((cat) {
                  return GestureDetector(
                    onTap: () {
                      categoryController.text = cat;
                      categoryController.selection = TextSelection.fromPosition(
                          TextPosition(offset: categoryController.text.length));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Text(cat,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87)),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildItemCard(ItemLibrary item, Color cardColor, Color textColor,
      Color subTextColor, BuildContext context) {
    // 使用你提供的 Mapper 获取图标
    final iconData = TaskIconMapper.getIcon(item.category, item.name ?? "");

    return GestureDetector(
      onTap: () {
        // 点击物品，编辑物品
        _showEditDialog(item, context);
      },
      onLongPress: () {
        // 长按删除
        JournalDialog.show(
          context,
          title: "删除物品",
          content: "确定要删除 ${item.name} 吗？",
          onConfirm: () {
            controller.deleteItem(item.id!, context);
            Get.back();
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.category ?? "其它",
              style: TextStyle(fontSize: 10, color: subTextColor),
            ),
            const SizedBox(height: 8),
            Icon(iconData, size: 24, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              item.name ?? "",
              style: TextStyle(fontSize: 12, color: textColor),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    // 每次打开弹窗前，清空之前的图片缓存
    controller.tempImgUrl.value = null;
    categoryController.text = "其它";

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 顶部操作栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("新增物品",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      // 提交时带上 controller.tempImgUrl.value
                      controller.addItem(
                          nameController.text,
                          categoryController.text,
                          controller.tempImgUrl.value,
                          context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                    ),
                    child: const Text("完成"),
                  )
                ],
              ),
              const SizedBox(height: 20),

              const Text("基本信息",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),

              // 2. 图片 + 名称 组合布局
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 图片上传组件 ---
                  GestureDetector(
                    onTap: () => controller.pickAndUploadImage(context),
                    child: Obx(() {
                      bool hasImage = controller.tempImgUrl.value != null;
                      // 添加图片
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                          image: hasImage
                              ? DecorationImage(
                                  image: NetworkImage(
                                      controller.tempImgUrl.value!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: hasImage
                            ? null // 有图片时不显示图标
                            : const Icon(Icons.camera_alt,
                                color: Colors.grey, size: 24),
                      );
                    }),
                  ),

                  const SizedBox(width: 12),

                  // --- 名称输入框 (占据剩余空间) ---
                  Expanded(
                    child: Container(
                      height: 60, // 与图片高度一致，或者自适应
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        style: TextStyle(
                            color: appColors.primaryText, fontSize: 14),
                        controller: nameController,
                        autofocus: true,
                        // hint 文字颜色

                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: appColors.secondaryText),
                          hintText: "请输入物品名称",
                          prefixIcon: const Icon(RemixIcons.archive_line,
                              color: Colors.grey),
                          border: InputBorder.none,

                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20), // 调整垂直居中
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. 物品分类输入
              const Text("物品分类",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: categoryController,
                  style: TextStyle(color: appColors.primaryText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "输入或选择下方分类",
                    hintStyle: TextStyle(color: appColors.secondaryText),
                    prefixIcon: const Icon(RemixIcons.price_tag_3_line,
                        color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. 快捷标签
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.categories.map((cat) {
                  return GestureDetector(
                    onTap: () {
                      categoryController.text = cat;
                      categoryController.selection = TextSelection.fromPosition(
                          TextPosition(offset: categoryController.text.length));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Text(cat,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87)),
                    ),
                  );
                }).toList(),
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
