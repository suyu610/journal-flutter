import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/trip_item.dart';
import 'package:journal/request/request.dart';
import 'package:journal/models/trip.dart'; // 引入你的新模型
import 'package:journal/models/item_library_model.dart';

class TripListController extends GetxController {
  final RxString searchQuery = "".obs;
  final TextEditingController searchController = TextEditingController();

  void clearSearch() {
    searchController.clear();
    searchQuery.value = "";
  }

  final RxList<Trip> allTrips = <Trip>[].obs;
  final RxBool isLoading = false.obs;

  EasyRefreshController easyRefreshController = EasyRefreshController();

  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

  // --- 1. 获取行程列表 ---
  Future<void> fetchTrips() async {
    isLoading.value = true;
    try {
      var data = await HttpRequest.request(Method.get, "/checklist/trip/list");
      if (data != null) {
        List rawList = data is List ? data : (data['data'] ?? []);

        allTrips.value = rawList.map((item) => Trip.fromJson(item)).toList();
        print(allTrips);
      }
    } catch (e) {
      Log().d("获取行程失败: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<Trip> get displayTrips {
    var list = allTrips.toList();
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((item) => (item.name)
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }
    // 默认把当前行程排在最前面
    list.sort(
        (a, b) => a.isCurrent == b.isCurrent ? 0 : (a.isCurrent ? -1 : 1));
    return list;
  }

  // --- 2. 行程的 CRUD 操作 ---
  Future<void> addTrip(String name, BuildContext context) async {
    if (name.isEmpty) return;
    try {
      JournalToast.showLoading(context, text: "创建中...");
      await HttpRequest.request(
        Method.post,
        "/checklist/trip/create", // 假设的新建接口
        params: {"name": name},
        success: (_) {
          JournalToast.dismiss();
          Get.back();
          fetchTrips();
        },
      );
    } catch (e) {
      JournalToast.dismiss();
    }
  }

  Future<void> updateTrip(Trip trip, BuildContext context,
      {bool showToast = true}) async {
    try {
      if (showToast) JournalToast.showLoading(context, text: "保存中...");

      // 构造保存参数
      final params = {
        "id": trip.id,
        "name": trip.name,
        "itemList": trip.itemList
            ?.map((e) => {
                  "id": e.id,
                  "tripId": e.tripId,
                  "itemName": e.itemName,
                  "isPacked": e.isPacked,
                  "quantity": e.quantity
                })
            .toList()
      };

      await HttpRequest.request(
        Method.post,
        "/checklist/trip/update", // 假设的更新接口
        params: params,
        success: (_) {
          JournalToast.dismiss();
          int index = allTrips.indexWhere((e) => e.id == trip.id);
          if (index != -1) {
            allTrips[index] = trip;
            allTrips.refresh(); // 刷新 UI
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

  Future<void> deleteTrip(int id, BuildContext context) async {
    try {
      JournalToast.showLoading(context, text: "删除中...");
      await HttpRequest.request(
        Method.post,
        "/checklist/trip/delete/$id",
        success: (_) {
          JournalToast.dismiss();
          allTrips.removeWhere((item) => item.id == id);
        },
      );
    } catch (e) {
      JournalToast.dismiss();
    }
  }

  // ==========================================
  // 👇 物品库操作逻辑（适配新 TripItem 模型）
  // ==========================================

  Future<List<ItemLibrary>> fetchAllLibraryItems() async {
    try {
      var data =
          await HttpRequest.request(Method.get, "/checklist/item/list/all");
      if (data != null && data['data'] != null) {
        return List<ItemLibrary>.from(
            (data['data'] as List).map((item) => ItemLibrary.fromJson(item)));
      }
    } catch (e) {
      Log().d("获取物品库失败: $e");
    }
    return [];
  }

  // 将选中的物品库商品，同步到行程中（因为新模型没有库ID，我们采用 itemName 进行比对去重）
  Future<void> syncItemsToTrip(Trip trip, List<ItemLibrary> selectedLibItems,
      BuildContext context) async {
    final currentList = trip.itemList ?? [];
    List<TripItem> updatedList = [];

    // 1. 保留原本就在行程里，且这次依然被勾选的物品（为了保留之前的数量 quantity 和 打包状态 isPacked）
    for (var item in currentList) {
      if (selectedLibItems.any((lib) => lib.name == item.itemName)) {
        updatedList.add(item);
      }
    }

    // 2. 找出哪些是全新勾选的，加进行程
    final existingNames = updatedList.map((e) => e.itemName).toSet();
    for (var libItem in selectedLibItems) {
      if (libItem.name != null && !existingNames.contains(libItem.name)) {
        updatedList.add(TripItem(
          id: 0, // 0 或 null，由后端自动生成主键
          tripId: trip.id,
          itemName: libItem.name!,
          isPacked: false,
          quantity: 1,
        ));
      }
    }

    trip.itemList = updatedList;
    await updateTrip(trip, context, showToast: false);
    Get.back(); // 关闭抽屉
  }

  // 更新行程内单个物品的数量，或删除物品
  Future<void> modifyTripItem(Trip trip, TripItem itemToModify, int newQuantity,
      BuildContext context) async {
    if (trip.itemList == null) return;

    if (newQuantity <= 0) {
      // 数量为 0 或以下，移除该物品 (通过 itemName 匹配)
      trip.itemList!
          .removeWhere((element) => element.itemName == itemToModify.itemName);
    } else {
      // 修改数量 (由于新模型 quantity 是 final，我们重新创建一个实例替换它)
      int idx = trip.itemList!
          .indexWhere((element) => element.itemName == itemToModify.itemName);
      if (idx != -1) {
        trip.itemList![idx] = TripItem(
          id: itemToModify.id,
          tripId: itemToModify.tripId,
          itemName: itemToModify.itemName,
          isPacked: itemToModify.isPacked, // 继承原本的打包状态
          quantity: newQuantity,
        );
      }
    }

    await updateTrip(trip, context, showToast: false);
    Get.back();
  }

  void toggleCurrent(int id, BuildContext context) {
    HttpRequest.request(Method.put, "/checklist/trip/toggle/$id");
    JournalToast.showSuccess(context, "已更新");
    fetchTrips();
  }
}
