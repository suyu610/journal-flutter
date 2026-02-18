import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/request/request.dart';
import 'package:journal/models/checklist_template_model.dart';
// 👇 确保导入了你物品库的模型，用于选择物品
import 'package:journal/models/item_library_model.dart';

class TemplateListController extends GetxController {
  final RxString searchQuery = "".obs;
  final TextEditingController searchController = TextEditingController();

  void clearSearch() {
    searchController.clear();
    searchQuery.value = "";
  }

  final RxList<ChecklistTemplate> allTemplates = <ChecklistTemplate>[].obs;
  final RxString selectedCategory = "全部".obs;
  final RxBool isLoading = false.obs;

  final RxList<String> categories = ["旅行", "出差", "户外", "日常", "其它"].obs;

  EasyRefreshController easyRefreshController = EasyRefreshController();
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchTemplates();
  }

  // --- 1. 获取模版列表 (包含模版内的 itemList) ---
  Future<void> fetchTemplates() async {
    isLoading.value = true;
    try {
      var data =
          await HttpRequest.request(Method.get, "/checklist/template/list");
      if (data['data'] != null) {
        final list = List<ChecklistTemplate>.from((data['data'] as List)
            .map((item) => ChecklistTemplate.fromJson(item)));
        allTemplates.value = list;

        final Set<String> mergedCategories = {"旅行", "出差", "户外", "日常", "其它"};
        for (var item in list) {
          if (item.category != null && item.category!.isNotEmpty) {
            mergedCategories.add(item.category!);
          }
        }
        categories.assignAll(mergedCategories.toList());
      }
    } catch (e) {
      Log().d("获取模版失败: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<ChecklistTemplate> get displayTemplates {
    var list = allTemplates.toList();
    if (selectedCategory.value != "全部") {
      list = list
          .where((item) => item.category == selectedCategory.value)
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((item) => (item.name ?? "")
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }
    return list;
  }

  // --- 2. 模版的 CRUD 基础操作 ---
  Future<void> addTemplate(String name, String description, String category,
      BuildContext context) async {
    if (name.isEmpty) return;
    try {
      JournalToast.showLoading(context, text: "创建中...");
      await HttpRequest.request(
        Method.post,
        params: {
          "name": name,
          "description": description,
          "category": category
        },
        "/checklist/template/create",
        success: (_) {
          JournalToast.dismiss();
          Get.back();
          fetchTemplates();
        },
      );
    } catch (e) {
      JournalToast.dismiss();
    }
  }

  Future<void> updateTemplate(ChecklistTemplate template, BuildContext context,
      {bool showToast = true}) async {
    try {
      if (showToast) JournalToast.showLoading(context, text: "保存中...");

      template.itemCount = template.itemList?.length ?? 0;

      await HttpRequest.request(
        Method.post,
        "/checklist/template/update",
        params: template.toJson(),
        success: (_) {
          JournalToast.dismiss();
          int index = allTemplates.indexWhere((e) => e.id == template.id);
          if (index != -1) {
            allTemplates[index] = template;
            allTemplates.refresh(); // 刷新 UI，展示最新的物品列表
          }
          if (showToast) JournalToast.showSuccess(context, "已更新");
        },
      );
    } catch (e) {
      JournalToast.dismiss();
      if (context.mounted) {
        JournalToast.showError(context, "更新失败");
      }
    }
  }

  Future<void> deleteTemplate(int id, BuildContext context) async {
    try {
      JournalToast.showLoading(context, text: "删除中...");
      await HttpRequest.request(
        Method.post,
        "/checklist/template/delete/$id",
        success: (_) {
          JournalToast.dismiss();
          allTemplates.removeWhere((item) => item.id == id);
        },
      );
    } catch (e) {
      JournalToast.dismiss();
    }
  }

  Future<void> copyTemplate(
      int id, String newName, BuildContext context) async {
    try {
      JournalToast.showLoading(context, text: "复制中...");
      await HttpRequest.request(
        Method.post,
        "/checklist/template/copy/$id",
        params: {"newTemplateName": newName},
        success: (_) {
          JournalToast.dismiss();
          fetchTemplates();
        },
      );
    } catch (e) {
      JournalToast.dismiss();
    }
  }

  // ==========================================
  // 👇 核心新增：模版内“物品”的操作逻辑
  // ==========================================

  // 获取用户完整的物品库 (用于弹窗勾选)
  Future<List<ItemLibrary>> fetchAllLibraryItems() async {
    try {
      var data =
          await HttpRequest.request(Method.get, "/checklist/item/list/all");
      if (data['data'] != null) {
        return List<ItemLibrary>.from(
            (data['data'] as List).map((item) => ItemLibrary.fromJson(item)));
      }
    } catch (e) {
      Log().d("获取物品库失败: $e");
    }
    return [];
  }

  // 将选中的物品库商品，追加到模版中
// 将选中的物品库商品，追加到模版中
  Future<void> addItemsToTemplate(ChecklistTemplate template,
      List<ItemLibrary> selectedItems, BuildContext context) async {
    if (selectedItems.isEmpty) return;

    // 1. 安全初始化：使用局部变量接管，避免 Dart 编译器对类属性(template.itemList)强解包的误判
    final currentList = template.itemList ?? [];

    // 2. 安全提取已有 ID：加了 .where((e) => e.itemId != null) 过滤掉由于历史脏数据导致 itemId 为空的情况
    List<int> existingItemIds =
        currentList.where((e) => e.id != null).map((e) => e.id!).toList();

    for (var libItem in selectedItems) {
      if (libItem.id == null) continue;

      if (!existingItemIds.contains(libItem.id)) {
        currentList.add(TemplateItem(
          templateId: template.id,
          itemId: libItem.id,
          id: libItem.id, // 新增：将 libItem.id 赋值给 id 字段
          quantity: 1, // 默认添加数量为 1
          category: libItem.category,
          itemName: libItem.name ?? "未知物品",
          img: libItem.img,
        ));
      }
    }

    // 4. 将更新后的安全列表赋值回 template
    template.itemList = currentList;

    // 调用更新模版接口，将新的物品列表整体覆盖保存
    await updateTemplate(template, context, showToast: false);
    Get.back(); // 关闭物品选择抽屉
  }

  // 将选中的物品库商品，同步到模版中（支持新增和取消勾选移除）
  Future<void> syncItemsToTemplate(ChecklistTemplate template,
      List<ItemLibrary> selectedLibItems, BuildContext context) async {
    // 1. 获取模版现有的物品列表
    final currentList = template.itemList ?? [];

    // 2. 获取用户最新勾选的所有物品 ID
    final selectedIds =
        selectedLibItems.where((e) => e.id != null).map((e) => e.id!).toSet();

    List<TemplateItem> updatedList = [];

    // 3. 第一步：保留原本就在模版里，且这次依然被勾选的物品（这样做是为了保留你之前设置的数量 quantity）
    for (var item in currentList) {
      if (item.id != null && selectedIds.contains(item.id!)) {
        updatedList.add(item);
      }
    }

    // 4. 第二步：找出哪些是这次全新勾选的，把它们加进模版（默认数量为 1）
    final existingIds = updatedList.map((e) => e.id!).toSet();
    for (var libItem in selectedLibItems) {
      if (libItem.id != null && !existingIds.contains(libItem.id)) {
        updatedList.add(TemplateItem(
          templateId: template.id,
          itemId: libItem.id,
          id: libItem.id, // 新增：将 libItem.id 赋值给 id 字段
          quantity: 1,
          category: libItem.category,
          itemName: libItem.name ?? "未知物品",
          img: libItem.img,
        ));
      }
    }

    // 5. 将更新后的列表赋值回 template 并保存
    template.itemList = updatedList;
    await updateTemplate(template, context, showToast: false);
    Get.back(); // 关闭抽屉
  }

  // 更新模版内单个物品的数量，或删除物品
  Future<void> modifyTemplateItem(ChecklistTemplate template,
      TemplateItem itemToModify, int newQuantity, BuildContext context) async {
    print("modifyTemplateItem: $itemToModify, $newQuantity");
    print("modifyTemplateItem: ${template.itemList}");
    if (template.itemList == null) return;

    if (newQuantity <= 0) {
      // 数量为 0 或以下，表示移除该物品
      template.itemList!
          .removeWhere((element) => element.id == itemToModify.id);
    } else {
      // 修改数量
      int idx = template.itemList!
          .indexWhere((element) => element.id == itemToModify.id);
      if (idx != -1) {
        template.itemList![idx].quantity = newQuantity;
      }
    }

    await updateTemplate(template, context, showToast: false);
    Get.back(); // 关闭数量修改小弹窗
  }
}
