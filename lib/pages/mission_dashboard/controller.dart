import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/trip.dart';
import 'package:journal/models/trip_card_model.dart';
import 'package:journal/models/trip_item.dart';
import 'package:journal/pages/mission_dashboard/widget/trip_edit_dialog.dart';
import 'package:journal/request/request.dart';
import 'package:journal/routers.dart';
import 'package:journal/services/voice_service.dart'; // ⚠️ 确保你已经创建了这个文件
import 'package:journal/util/dialog_util.dart';

class MissionController extends GetxController {
  // ========================================================================
  // 1. 核心变量与服务
  // ========================================================================

  // 语音服务
  final VoiceService voiceService = Get.put(VoiceService());
  Timer? _debounceTimer; // 语音防抖定时器

  // 响应式数据
  var tasks = <TripItem>[].obs; // 当前物品列表
  var trips = <TripModel>[].obs; // 行程卡片列表
  var isPackingMode = false.obs; // 是否处于整理模式

  var currentTrip = Rxn<Trip>(); // 当前选中的清单大对象
  var checklistTrips = <Trip>[].obs; // 可切换的清单列表（用于下拉）

  // 页面状态
  EasyRefreshController? refreshController = EasyRefreshController();
  var isLoading = true.obs;

  // 遗留变量 (可能后续会优化掉)
  var weatherTemp = "24°".obs;
  var flightStatus = "值机中".obs;
  final ImagePicker _picker = ImagePicker();

  // ========================================================================
  // 2. 初始化与生命周期
  // ========================================================================

  @override
  void onInit() {
    super.onInit();
    // 初始化语音服务
    voiceService.init();
    // 加载数据
    loadInitialData();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    refreshController?.dispose();
    super.onClose();
  }

  // 统一加载入口
  void loadInitialData() {
    tasks.clear();
    loadItems(); // 加载物品
    loadTrips(); // 加载行程卡片
    update(["mission"]);
  }

  // ========================================================================
  // 3. 语音交互逻辑 (新增)
  // ========================================================================

  /// 处理语音识别到的原始文本
  void processVoiceCommand(String text) {
    if (text.isEmpty) return;

    // 防抖处理：避免用户说话停顿导致频繁触发
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _executeVoiceCommand(text);
    });
  }

  /// 执行语音指令
  void _executeVoiceCommand(String text) {
    developer.log("正在分析语音指令: $text");

    // 1. 简单的意图判断
    // 如果包含“拿出来”、“取消”等词，视为取消装箱；否则默认为装箱
    bool isNegative =
        text.contains("取消") || text.contains("拿出") || text.contains("没带");
    bool targetStatus = !isNegative;

    // 2. 模糊匹配物品
    List<TripItem> matchedItems = [];

    // 预处理文本：去掉标点符号，只留中文、英文、数字
    String cleanText =
        text.replaceAll(RegExp(r'[^\u4e00-\u9fa5a-zA-Z0-9]'), '');

    for (var item in tasks) {
      // 策略：如果语音文本包含了物品名称，或者物品名称包含了语音里的关键部分
      if (cleanText.contains(item.itemName)) {
        matchedItems.add(item);
      }
    }

    if (matchedItems.isEmpty) {
      if (Get.context != null) {
        // JournalToast.showError(Get.context!, "没听清，或者清单里没有这个物品哦");
      }
      return;
    }

    // 3. 执行操作
    for (var item in matchedItems) {
      // 只有状态不一致时才切换
      if (item.isPacked != targetStatus) {
        toggleChecklistItem(item);
        if (Get.context != null) {
          // JournalToast.show(
          //     Get.context!, "已${targetStatus ? '装箱' : '拿出'}: ${item.itemName}");
        }
      } else {
        // 如果状态已经一样了，提示一下
        // JournalToast.show(Get.context!, "${item.itemName} 已经在那里啦");
      }
    }

    // 清空显示的文字结果
    voiceService.textResult.value = "";
    voiceService.reset();
    update(["mission"]);
  }

  // ========================================================================
  // 4. 物品清单逻辑 (Packing Logic)
  // ========================================================================

  // 获取当前清单详情
  Future<void> loadItems() async {
    try {
      final data = await HttpRequest.request(
          Method.get, "/checklist/trip/detail/current");
      if (data != null) {
        currentTrip.value = Trip.fromJson(data['data']);
        tasks.assignAll((currentTrip.value?.itemList) ?? []);
      }
    } catch (e) {
      print("获取当前清单失败: $e");
    }
  }

  // 切换物品装箱状态 (支持乐观更新)
  Future<void> toggleChecklistItem(TripItem item) async {
    HapticFeedback.lightImpact();

    // 乐观更新 UI：先变状态，再请求接口
    final originalState = item.isPacked;
    item.isPacked = !originalState;
    tasks.refresh(); // 刷新箱子区域 (SuitcaseView 监听了 tasks)
    currentTrip.refresh(); // 刷新未装箱区域 (UnpackGridView 监听了 currentTrip)
    update(["mission"]);

    try {
      await HttpRequest.request(
        Method.post,
        "/checklist/trip/toggle?tripItemId=${item.id}&isPacked=${item.isPacked}",
      );
    } catch (e) {
      // 失败回滚
      item.isPacked = originalState;
      tasks.refresh(); // 刷新箱子区域 (SuitcaseView 监听了 tasks)
      currentTrip.refresh(); // 刷新未装箱区域 (UnpackGridView 监听了 currentTrip)
      update(["mission"]);
      if (Get.context != null) {
        JournalToast.showError(Get.context!, "状态同步失败，请重试");
      }
    }
  }

  // 切换清单行程 (预留功能)
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

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);
  }

  void toggleAllTasks() {
    for (var element in tasks) {
      element.isPacked = false;
    }
    update(["mission"]);
  }

  // ========================================================================
  // 5. 行程卡片逻辑 (Trip Card Logic)
  // ========================================================================

  void loadTrips() async {
    try {
      var response = await HttpRequest.request(Method.get, "/travel/list");
      trips.clear();
      response['data']?.forEach((element) {
        trips.add(TripModel.fromJson(element));
      });
      update(["mission"]);
    } catch (e) {
      print("加载行程失败: $e");
    }
  }

  // 拖拽排序行程
  void reorderTrips(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final TripModel item = trips.removeAt(oldIndex);
    trips.insert(newIndex, item);
    HttpRequest.request(Method.post, "/travel/reorder", params: trips);
  }

  // 删除行程
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

  // 显示编辑/新增确认框
  void showConfirmDialog(TripModel trip, BuildContext context,
      {TripModel? existingTrip}) {
    Get.bottomSheet(
      TripEditDialog(
        initialTrip: trip,
        onConfirm: (newTrip) {
          if (existingTrip != null) {
            // 更新
            int index = trips.indexOf(existingTrip);
            newTrip.id = existingTrip.id;
            if (index != -1) {
              trips[index] = newTrip;
              developer.log("更新行程: $newTrip");
              HttpRequest.request(Method.put, "/travel/edit", params: newTrip);
              JournalToast.showSuccess(context, "行程已更新");
            }
          } else {
            // 新增
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

  // ========================================================================
  // 6. 弹窗与上传逻辑 (UI Helpers)
  // ========================================================================

  // 显示添加行程的底部弹窗
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

  // 构建选项 Cell
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

  // 手动添加弹窗
  void _showManualAddDialog(BuildContext context) {
    final emptyTrip = TripModel.fromJson({
      'type': 'Train',
      'status': 'Pending',
      'transport': {'number': '', 'duration': ''},
      'departure': {
        'city': '',
        'station_airport': '',
        'time': '00:00',
        'date': DateTime.now().toString().substring(0, 10),
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

  // 选图并上传 OCR
  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1920,
      );
      if (image != null) {
        if (context.mounted) {
          await _uploadAndParseImage(File(image.path), context);
        }
      }
    } catch (e) {
      if (context.mounted) JournalToast.showError(context, '选择图片失败: $e');
    }
  }

  // 上传图片进行 AI 解析
  Future<void> _uploadAndParseImage(
      File imageFile, BuildContext context) async {
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
          Get.back(); // 关闭 loading
          if (data != null) {
            try {
              Map<String, dynamic> mapData;
              if (data is String) {
                mapData = jsonDecode(data);
              } else {
                mapData = Map<String, dynamic>.from(data as Map);
              }
              TripModel trip = TripModel.fromJson(mapData);
              showConfirmDialog(trip, context);
            } catch (e) {
              print("解析错误: $e");
              JournalToast.showError(context, '解析数据失败');
            }
          }
        },
        fail: (code, msg) {
          Get.back();
          JournalToast.showError(context, '上传失败: $msg');
        },
      );
    } catch (e) {
      Get.back();
      JournalToast.showError(context, '网络错误: $e');
    }
  }

  // 跳转
  nav2ToTripList(BuildContext context) {
    Get.toNamed(Routers.TripChecklistPageUrl);
  }
}
