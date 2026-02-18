import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/item_library_model.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/cos.dart';
import 'package:journal/util/media_util.dart';

class ItemLibraryController extends GetxController {
  final RxString searchQuery = "".obs;
  final TextEditingController searchController = TextEditingController();
  // 4. 新增：清空搜索框逻辑
  void clearSearch() {
    searchController.clear();
    searchQuery.value = "";
  }

  // 状态：所有物品列表
  final RxList<ItemLibrary> allItems = <ItemLibrary>[].obs;

  // 状态：当前选中的分类，默认“全部”
  final RxString selectedCategory = "全部".obs;

  // 状态：加载中
  final RxBool isLoading = false.obs;

  // 预设分类（参考截图 IMG_2994）
  final RxList<String> categories = ["衣物", "数码产品", "洗漱", "证件", "医药", "其它"].obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    try {
      var data = await HttpRequest.request(
        Method.get,
        "/checklist/item/list/all",
      );

      if (data['data'] != null) {
        final list = List<ItemLibrary>.from(
            (data['data'] as List).map((item) => ItemLibrary.fromJson(item)));
        allItems.value = list;
        final Set<String> mergedCategories = {};

        // A. 先加入预设分类 (保证这些基础选项一直都在，方便新增时选择)
        mergedCategories.addAll(["衣物", "数码产品", "洗漱", "证件", "医药", "其它"]);

        // B. 遍历后端返回的数据，把用户自定义的分类也加进去
        for (var item in list) {
          if (item.category != null && item.category!.isNotEmpty) {
            mergedCategories.add(item.category!);
          }
        }

        // C. 更新到 RxList，界面会自动刷新
        categories.assignAll(mergedCategories.toList());
      }
    } catch (e) {
      print(e);
      Get.snackbar("获取物品失败", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 计算属性：根据选中的分类过滤列表
// 2. 修改：displayItems 逻辑（支持分类 + 搜索双重过滤）
  List<ItemLibrary> get displayItems {
    var list = allItems.toList();

    // A. 先根据分类过滤
    if (selectedCategory.value != "全部") {
      list = list
          .where((item) => item.category == selectedCategory.value)
          .toList();
    }

    // B. 再根据搜索词过滤 (忽略大小写)
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((item) => (item.name ?? "")
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return list;
  }

  // 获取某分类下的数量
// 3. 修改：获取某分类下的数量（让数量也跟随搜索词动态变化）
  int getCountByCategory(String cat) {
    var list = allItems.toList();
    // 如果有搜索词，先算出符合搜索词的总池子
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((item) => (item.name ?? "")
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    if (cat == "全部") return list.length;
    return list.where((item) => item.category == cat).length;
  }

  // 新增物品
  Future<void> addItem(
      String name, String category, String? img, BuildContext context) async {
    if (name.isEmpty) return;
    try {
      JournalToast.showLoading(context, text: "添加中...");
      await HttpRequest.request(
        Method.post,
        params: {"name": name, "category": category, "img": img},
        "/checklist/item/add",
        success: (data) {
          // 本地乐观更新
          allItems.add(ItemLibrary(
              id: DateTime.now().millisecondsSinceEpoch,
              name: name,
              category: category,
              img: img, // 保存图片
              createTime: DateTime.now().toIso8601String()));

          JournalToast.dismiss();
          JournalToast.showSuccess(context, "已添加 $name");
        },
        fail: (code, msg) {
          JournalToast.dismiss();
          JournalToast.showError(context, "添加失败: $msg");
        },
      );
    } catch (e) {
      // handle error
      JournalToast.dismiss();
      if (context.mounted) {
        JournalToast.showError(context, "添加失败: $e");
      }
    }
  }

  // --- 新增：弹窗中暂存的图片 URL ---
  final RxnString tempImgUrl = RxnString(null);

  EasyRefreshController easyRefreshController = EasyRefreshController();

  // --- 新增：图片选择与上传逻辑 (基于你提供的示例) ---
  Future<void> pickAndUploadImage(BuildContext context) async {
    try {
      // 1. 选择图片
      File? file = await MediaHelper.pickImageWithPermission(context);
      if (file == null) return;

      String userId = "item_library"; // 或者是当前用户的真实ID

      if (context.mounted) {
        // 2. 上传到腾讯云 COS
        String? url = await TencentCosService().uploadFile(
            filePath: file.path,
            userId: userId,
            prefix: "item_img", // 修改前缀为物品图片
            context: context // 自动展示 loading
            );

        if (url == null) return; // 内部已处理 Toast

        // 3. 更新暂存的 URL，UI 会自动刷新显示图片
        tempImgUrl.value = url;
      }
    } catch (e) {
      Log().d("上传失败: $e");
      if (context.mounted) {
        JournalToast.showError(context, "上传失败");
      }
    } finally {
      JournalToast.dismiss();
    }
  }

  // 删除物品
  Future<void> deleteItem(int id, BuildContext context) async {
    try {
      JournalToast.showLoading(context, text: "删除中...");
      await HttpRequest.request(
        Method.post,
        "/checklist/item/delete/$id",
      );
      allItems.removeWhere((item) => item.id == id);
    } catch (e) {
      if (context.mounted) {
        JournalToast.dismiss();
        JournalToast.showError(context, "删除失败");
      }
    }
  }

  RxBool showTip = true.obs;

  ScrollController? scrollController = ScrollController();
  void dismissTip() {
    showTip.value = false;
    update(["item_library"]);
  }

  // 更新物品
  Future<void> updateItem(ItemLibrary item, BuildContext context) async {
    try {
      JournalToast.showLoading(context, text: "更新中...");
      await HttpRequest.request(
        Method.post,
        "/checklist/item/update",
        params: {
          "id": item.id,
          "name": item.name,
          "category": item.category,
          "img": item.img, // 图片 URL
          "createTime": item.createTime, //以此保持对象完整性
          // "userId": userId // 通常后端 @UserId 注解会自动从 Token 获取，前端无需传
        },
        success: (data) {
          JournalToast.dismiss();
          // 本地更新列表，避免重新请求网络
          int index = allItems.indexWhere((e) => e.id == item.id);
          if (index != -1) {
            allItems[index] = item;
            allItems.refresh(); // 通知 Obx 更新
          }
          Get.back(); // 关闭弹窗
          JournalToast.showSuccess(context, "更新成功");
        },
        fail: (code, msg) {
          JournalToast.dismiss();
          JournalToast.showError(context, "更新失败: $msg");
        },
      );
    } catch (e) {
      Log().d("更新物品异常:  $e");
    }
  }
}
