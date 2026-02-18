import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:journal/models/trip.dart';
import 'package:journal/models/trip_item.dart';
import 'package:journal/request/request.dart';
import 'package:journal/models/trip_card_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:journal/pages/mission_dashboard/widget/trip_edit_dialog.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/dialog_util.dart';

class MissionController extends GetxController {
  // 响应式列表
  var tasks = <TripItem>[].obs;

  var weatherTemp = "24°".obs; // 稍微改暖一点，配合浅色
  var flightStatus = "值机中".obs;
// --- 新增：整理模式开关 ---
  var isPackingMode = false.obs;
  // 新增：行程列表
  var trips = <TripModel>[].obs;

  final ImagePicker _picker = ImagePicker();

  EasyRefreshController? refreshController = EasyRefreshController();
  var isLoading = true.obs;
  var currentTrip = Rxn<Trip>(); // 当前选中的清单行程
  var checklistTrips = <Trip>[].obs; // 清单行程列表（用于下拉切换）
// --- 新增：处理行程排序 ---
  void reorderTrips(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final TripModel item = trips.removeAt(oldIndex);
    trips.insert(newIndex, item);

    HttpRequest.request(Method.post, "/travel/reorder", params: trips);
  }

  // --- 新增：删除行程 ---
  void deleteTrip(TripModel trip, BuildContext context) {
    JournalDialog.show(
      context,
      title: "确认删除",
      content: "确定要删除 ${trip.depCity}-${trip.arrCity} 的行程吗？",
      confirmText: "删除",
      onConfirm: () {
        trips.remove(trip);
        HttpRequest.request(Method.delete, "/travel/delete/${trip.id}");
        Get.back();
      },
    );
  }

  void showConfirmDialog(TripModel trip, BuildContext context,
      {TripModel? existingTrip}) {
    Get.bottomSheet(
      TripEditDialog(
        initialTrip: trip,
        onConfirm: (newTrip) {
          if (existingTrip != null) {
            int index = trips.indexOf(existingTrip);
            newTrip.id = existingTrip.id;
            if (index != -1) {
              trips[index] = newTrip;
              HttpRequest.request(Method.put, "/travel/edit", params: newTrip);
              JournalToast.showSuccess(context, "行程已更新");
            }
          } else {
            trips.add(newTrip);
            HttpRequest.request(Method.post, "/travel/save", params: newTrip);
            JournalToast.showSuccess(context, "行程已添加");
          }
          Get.back();
        },
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void showUploadDialog(BuildContext context) {
    var appColors = Theme.of(context).extension<AppThemeColors>()!;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "添加行程",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryText,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: appColors.secondaryText),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 选项
            _buildUploadOption(
              context,
              icon: Icons.photo_library_outlined,
              label: "从相册选择",
              desc: "识别截图或照片",
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery, context);
              },
            ),
            const SizedBox(height: 16),
            _buildUploadOption(
              context,
              icon: Icons.camera_alt_outlined,
              label: "拍照识别",
              desc: "拍摄车票或行程单",
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera, context);
              },
            ),
            const SizedBox(height: 16),
            _buildUploadOption(
              context,
              icon: Icons.edit_note_outlined,
              label: "手动添加",
              desc: "手动输入行程信息",
              onTap: () {
                Get.back();
                _showManualAddDialog(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showManualAddDialog(BuildContext context) {
    final emptyTrip = TripModel.fromJson({
      'type': 'Train', // 默认类型
      'status': 'Pending',
      'transport': {'number': '', 'duration': ''},
      'departure': {
        'city': '',
        'station_airport': '',
        'time': '00:00',
        'date': DateTime.now().toString().substring(0, 10), // 默认今天
        'gate_platform': ''
      },
      'arrival': {
        'city': '',
        'station_airport': '',
        'time': '00:00',
        'day_diff': 0
      },
      'finance': {'seat_class': '', 'seat_detail': ''},
      'meta': {'remark': ''}
    });

    showConfirmDialog(emptyTrip, context);
  }

  Widget _buildUploadOption(BuildContext context,
      {required IconData icon,
      required String label,
      required String desc,
      required VoidCallback onTap}) {
    var appColors = Theme.of(context).extension<AppThemeColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColors.backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appColors.secondaryText.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColors.primaryText.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: appColors.primaryText, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: appColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: appColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: appColors.secondaryText),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      // 增加图片压缩参数，避免上传过大文件
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70, // 压缩质量 70%
        maxWidth: 1920, // 限制最大宽度
      );
      if (image != null) {
        if (context.mounted) {
          await _uploadAndParseImage(File(image.path), context);
        }
      }
    } catch (e) {
      Get.snackbar('错误', '选择图片失败: $e');
    }
  }

  Future<void> _uploadAndParseImage(
      File imageFile, BuildContext context) async {
    // 打印文件大小
    int fileSize = await imageFile.length();
    print(
        "Upload file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB");

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      String fileName = imageFile.path.split('/').last;
      var formData = dio.FormData.fromMap({
        "file": await dio.MultipartFile.fromFile(imageFile.path,
            filename: fileName),
      });

      await HttpRequest.request(
        Method.post,
        "/ai/parse",
        params: formData,
        success: (data) {
          Get.back();
          if (data != null) {
            try {
              Map<String, dynamic> mapData;
              if (data is String) {
                try {
                  mapData = jsonDecode(data);
                } catch (e) {
                  throw Exception("无法解析返回数据: $data");
                }
              } else if (data is Map<String, dynamic>) {
                mapData = data;
              } else {
                // 其他类型，尝试强转或者报错
                try {
                  mapData = Map<String, dynamic>.from(data as Map);
                } catch (e) {
                  throw Exception("Unexpected data type: ${data.runtimeType}");
                }
              }

              TripModel trip = TripModel.fromJson(mapData);
              // 弹出确认框
              showConfirmDialog(trip, context);
            } catch (e) {
              print("解析错误: $e");
              Get.snackbar('错误', '解析数据失败: $e');
            }
          }
        },
        fail: (code, msg) {
          Get.back(); // 关闭 loading
          Get.snackbar('错误', '上传失败: $msg');
        },
      );
    } catch (e) {
      Get.back(); // 关闭 loading
      Get.snackbar('错误', '上传失败: $e');
    }
  }

  // 计算进度
  double get progress {
    if (tasks.isEmpty) return 0.0;
    int completed = tasks.where((t) => t.isPacked).length;
    return completed / tasks.length;
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  void loadInitialData() {
    tasks.clear();

    loadItems();
    loadTrips();
    update(["mission"]);
  }

  void loadTrips() async {
    var date = await HttpRequest.request(Method.get, "/travel/list");
    trips.clear();

    date['data']?.forEach((element) {
      trips.add(TripModel.fromJson(element));
    });
    update(["mission"]);
    // trips.assignAll();
  }

  // 列表重新排序
  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);
  }

  void toggleAllTasks() {
    tasks.forEach((element) {
      element.isPacked = false;
    });
  }

  // --- 接入新 API：获取实例列表 ---
  Future<void> fetchChecklistTrips() async {
    try {
      final data =
          await HttpRequest.request(Method.get, "/checklist/trip/list");
      if (data != null && data is List) {
        checklistTrips.assignAll(data.map((e) => Trip.fromJson(e)).toList());
      }
    } catch (e) {
      print("获取行程列表失败: $e");
    }
  }

  // --- 接入新 API：获取当前实例 ---
  Future<void> loadItems() async {
    try {
      final data = await HttpRequest.request(
          Method.get, "/checklist/trip/detail/current");
      if (data != null) {
        print("data:$data");
        currentTrip.value = Trip.fromJson(data['data']);
        print("currentTrip:${currentTrip.value?.itemList}");
        tasks.assignAll((currentTrip.value?.itemList) ?? []);
      }
    } catch (e) {
      print("获取当前清单失败: $e");
    }
  }

  // --- 接入新 API：切换具体行程 ---
  Future<void> switchTripDetail(int tripId) async {
    isLoading.value = true;
    update(["mission"]);
    try {
      final data = await HttpRequest.request(
          Method.get, "/checklist/trip/detail/$tripId");
      if (data != null) {
        currentTrip.value = Trip.fromJson(data);
      }
    } catch (e) {
      print("切换清单失败: $e");
    } finally {
      isLoading.value = false;
      update(["mission"]);
    }
  }

  // --- 接入新 API：切换装箱状态 (乐观更新) ---
  Future<void> toggleChecklistItem(TripItem item) async {
    HapticFeedback.lightImpact();

    // 乐观更新 UI
    final originalState = item.isPacked;
    item.isPacked = !originalState;
    update(["mission"]);

    try {
      await HttpRequest.request(
        Method.post,
        "/checklist/trip/toggle?tripItemId=${item.id}&isPacked=${item.isPacked}",
      );
      // 如果您的 request 封装拦截了错误，这里可以判断 code
    } catch (e) {
      // 失败回滚
      item.isPacked = originalState;
      update(["mission"]);
      Get.snackbar('错误', '状态同步失败，请重试');
    }
  }

  nav2ToTripList(BuildContext context) {
    Get.toNamed(Routers.TripChecklistPageUrl);
  }
}
