import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/checklist_template_model.dart';
import 'package:journal/models/item_library_model.dart'; // 需要引入物品库模型
import 'package:journal/pages/mission_dashboard/util/task_icon_mapper.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'controller.dart';

class TemplateListPage extends GetView<TemplateListController> {
  const TemplateListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<TemplateListController>(
      init: TemplateListController(),
      id: "template_list",
      builder: (_) {
        return Scaffold(
          backgroundColor: appColors.backgroundColor,
          appBar: JournalNavBar(
            title: "模板清单",
            rightBarItems: [
              NavBarItem(
                onTap: () => _showTemplateDialog(context, isAdd: true),
                iconWidget: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appColors.brandColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 16, color: appColors.brandColor),
                      const SizedBox(width: 4),
                      Text("新建模版",
                          style: TextStyle(
                              color: appColors.brandColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              // 1. 顶部搜索框
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 12, bottom: 4),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: appColors.secondaryText.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.searchQuery.value = value,
                    style:
                        TextStyle(color: appColors.primaryText, fontSize: 14),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: "搜索模版名称...",
                      hintStyle: TextStyle(
                          color: appColors.secondaryText, fontSize: 13),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      prefixIcon: const Icon(RemixIcons.search_line,
                          color: Colors.grey, size: 18),
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      suffixIcon:
                          Obx(() => controller.searchQuery.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => controller.clearSearch(),
                                  child: const Icon(
                                      RemixIcons.close_circle_fill,
                                      color: Colors.grey,
                                      size: 18),
                                )
                              : const SizedBox(width: 40, height: 40)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // 2. 模版列表
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.displayTemplates.isEmpty) {
                    return Center(
                        child: Text("暂无模版数据",
                            style: TextStyle(color: appColors.secondaryText)));
                  }
                  return EasyRefresh(
                    controller: controller.easyRefreshController,
                    onRefresh: () async => await controller.fetchTemplates(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.displayTemplates.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildTemplateCard(
                            controller.displayTemplates[index],
                            appColors,
                            context);
                      },
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

  // ==========================================
  // 👉 核心 UI：支持外露物品的模版卡片
  // ==========================================
  Widget _buildTemplateCard(ChecklistTemplate template,
      AppThemeColors appColors, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
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
          // 第一部分：模版头部信息
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 12, top: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(template.name ?? "未命名",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: appColors.primaryText)),
                        ],
                      ),
                      if (template.description != null &&
                          template.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(template.description!,
                            style: TextStyle(
                                fontSize: 12, color: appColors.secondaryText)),
                      ]
                    ],
                  ),
                ),
                // 模版操作菜单 ⋯
                GestureDetector(
                  onTap: () =>
                      _showTemplateActionMenu(template, context, appColors),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(RemixIcons.more_2_fill,
                        size: 20, color: appColors.secondaryText),
                  ),
                )
              ],
            ),
          ),

          Divider(height: 1, color: appColors.backgroundColor),

          // 第二部分：具体物品区 (外露展示)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12, // 横向间距
              runSpacing: 12, // 纵向间距
              children: [
                // 遍历展示已有的物品
                ...?template.itemList?.map((item) =>
                    _buildItemChip(template, item, appColors, context)),

                // 【+ 添加物品】按钮，直接触发物品库勾选
                GestureDetector(
                  onTap: () =>
                      _showLibraryItemPicker(template, context, appColors),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(RemixIcons.add_line,
                            size: 14, color: appColors.brandColor),
                        const SizedBox(width: 4),
                        Text("添加物品",
                            style: TextStyle(
                                fontSize: 12,
                                color: appColors.brandColor,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 模版内单个物品的 UI
  Widget _buildItemChip(ChecklistTemplate template, TemplateItem item,
      AppThemeColors appColors, BuildContext context) {
    final iconData = TaskIconMapper.getIcon(item.category, item.itemName ?? "");

    return GestureDetector(
      onTap: () => _showEditItemDialog(template, item, context, appColors),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标或小图片
            Icon(iconData, size: 16, color: appColors.secondaryText),
            const SizedBox(width: 6),
            // 名称
            Text(item.itemName ?? "未知",
                style: TextStyle(fontSize: 13, color: appColors.primaryText)),
            const SizedBox(width: 6),
            // 数量角标
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4)),
              child: Text("x${item.quantity ?? 1}",
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 👉 交互弹窗区域
  // ==========================================

  // 1. 从物品库选择物品的抽屉

  void _showLibraryItemPicker(ChecklistTemplate template, BuildContext context,
      AppThemeColors appColors) {
    // 提前安全地提取模版中已有的物品 ID (过滤掉可能为 null 的脏数据)
    final existingItemIds = template.itemList
            ?.where((e) => e.itemId != null)
            .map((e) => e.itemId!)
            .toSet() ??
        {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

              // 👉 核心改变：初始化已选列表！遍历物品库，如果该物品的 ID 已经在模版里，就默认加入已选列表
              List<ItemLibrary> selectedItems = allLibItems
                  .where((item) => existingItemIds.contains(item.id))
                  .toList();

              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.75, // 抽屉高度75%
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("选择 /管理物品",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: appColors.primaryText)),
                            TextButton(
                              onPressed: () => controller.syncItemsToTemplate(
                                  template, selectedItems, context),
                              style: TextButton.styleFrom(
                                  backgroundColor: appColors.brandColor,
                                  foregroundColor: appColors.cardBackground,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16)),
                              child: Text("保存 (${selectedItems.length})"),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: allLibItems.length,
                          itemBuilder: (context, index) {
                            final libItem = allLibItems[index];
                            // 判断当前物品是否在勾选列表中
                            final isSelected =
                                selectedItems.any((e) => e.id == libItem.id);
                            final iconData = TaskIconMapper.getIcon(
                                libItem.category, libItem.name ?? "");

                            return ListTile(
                              leading: libItem.img != null &&
                                      libItem.img!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(libItem.img!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover))
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFF0F0F0),
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Icon(iconData,
                                          color: appColors.secondaryText)),
                              title: Text(libItem.name ?? "",
                                  style:
                                      TextStyle(color: appColors.primaryText)),
                              subtitle: Text(libItem.category ?? "其它",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              trailing: Checkbox(
                                value: isSelected, // 全部变成复选框
                                activeColor: appColors.brandColor,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedItems.add(libItem);
                                    } else {
                                      selectedItems.removeWhere(
                                          (e) => e.id == libItem.id);
                                    }
                                  });
                                },
                              ),
                              onTap: () {
                                // 点击整行也能触发勾选/取消勾选
                                setState(() {
                                  if (isSelected) {
                                    selectedItems
                                        .removeWhere((e) => e.id == libItem.id);
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
  void _showEditItemDialog(ChecklistTemplate template, TemplateItem item,
      BuildContext context, AppThemeColors appColors) {
    int currentQuantity = item.quantity ?? 1;

    Get.bottomSheet(
      StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: appColors.cardBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("修改物品",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: appColors.primaryText)),
              const SizedBox(height: 20),
              Text(item.itemName ?? "",
                  style: TextStyle(fontSize: 18, color: appColors.brandColor)),
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
                            fontSize: 24, fontWeight: FontWeight.bold)),
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
                      onPressed: () => controller.modifyTemplateItem(
                          template, item, 0, context),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: appColors.dangerColor,
                          side: BorderSide(color: appColors.dangerColor)),
                      child: const Text("从模板移除"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.modifyTemplateItem(
                          template, item, currentQuantity, context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: appColors.brandColor,
                          foregroundColor: appColors.cardBackground),
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

  // 3. 原有逻辑：模版本身的 操作菜单 (编辑基础信息、复制、删除)
  void _showTemplateActionMenu(ChecklistTemplate template, BuildContext context,
      AppThemeColors appColors) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 12, bottom: 30),
        decoration: BoxDecoration(
            color: appColors.cardBackground,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
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
            _buildActionItem(
                RemixIcons.plug_line, "使用该模板", appColors.primaryText, () {
              Get.back();
              JournalDialog.show(
                context,
                title: "给你的行程取个名吧",
                content: "【${template.name}】模板",
                onConfirmWithInput: (v) {
                  HttpRequest.request(
                      Method.post, "/checklist/trip/instantiate",
                      params: {
                        "sourceTemplateId": template.id,
                        "name": v,
                        "itemList": template.itemList,
                      }).then((res) {
                    Get.back();
                  });
                },
              );
            }),
            _buildActionItem(
                RemixIcons.edit_2_line, "编辑模版信息", appColors.primaryText, () {
              Get.back();
              _showTemplateDialog(context, isAdd: false, template: template);
            }),
            _buildActionItem(
                RemixIcons.file_copy_line, "复制创建副本", appColors.primaryText, () {
              Get.back();
              JournalDialog.show(
                context,
                title: "复制模版",
                content: "确定要以【${template.name}】为基础创建一个新模版吗？",
                onConfirm: () {
                  controller.copyTemplate(
                      template.id!, "${template.name} 的副本", context);
                  Get.back();
                },
              );
            }),
            _buildActionItem(
                RemixIcons.delete_bin_line, "删除模版", appColors.dangerColor, () {
              Get.back();
              JournalDialog.show(
                context,
                title: "删除警告",
                content: "删除后不可恢复，确定要删除【${template.name}】吗？",
                onConfirm: () {
                  controller.deleteTemplate(template.id!, context);
                  Get.back();
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
        title: Text(title, style: TextStyle(color: color, fontSize: 15)),
        onTap: onTap);
  }

  // 4. 原有逻辑：新增/编辑模版基础信息的弹窗
  void _showTemplateDialog(BuildContext context,
      {required bool isAdd, ChecklistTemplate? template}) {
    final TextEditingController nameController =
        TextEditingController(text: template?.name ?? "");
    final TextEditingController descController =
        TextEditingController(text: template?.description ?? "");
    final TextEditingController categoryController =
        TextEditingController(text: template?.category ?? "旅行");
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: appColors.backgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isAdd ? "新建模版" : "编辑模版信息",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      if (isAdd) {
                        controller.addTemplate(
                            nameController.text,
                            descController.text,
                            categoryController.text,
                            context);
                      } else {
                        template!.name = nameController.text;
                        template.description = descController.text;
                        template.category = categoryController.text;
                        controller.updateTemplate(template, context);
                        Get.back();
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: appColors.brandColor,
                        foregroundColor: appColors.cardBackground,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6)),
                    child: Text(isAdd ? "创建" : "保存"),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // ... 具体的输入框 UI（复用了之前的逻辑，此处精简代码体积不占篇幅，使用常规 TextField 即可）
              _buildInputArea(
                  "模版名称", nameController, "给模版起个名字", RemixIcons.text, appColors,
                  autoFocus: isAdd),
              const SizedBox(height: 16),
              _buildInputArea("使用场景描述", descController, "简单描述该清单适用的情况",
                  RemixIcons.file_list_3_line, appColors),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInputArea(String label, TextEditingController textController,
      String hint, IconData icon, AppThemeColors appColors,
      {bool autoFocus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: appColors.cardBackground,
              borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: textController,
            autofocus: autoFocus,
            style: TextStyle(color: appColors.primaryText, fontSize: 14),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: appColors.secondaryText),
                prefixIcon: Icon(icon, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        )
      ],
    );
  }
}
