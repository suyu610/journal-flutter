import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_date_picker.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/cos.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:journal/util/media_util.dart';

class ExpensePageController extends GetxController {
  var expensePriceFocusNode = FocusNode();
  var expensePriceTextEditController = TextEditingController();
  var expenseLabelTextEditController = TextEditingController();
  var expenseOriginalPriceTextEditController = TextEditingController();
  RxList<Activity> activityList = <Activity>[].obs;
  static List<Activity>? _cachedActivityList;
  ExpensePageController();
  Rx<Expense> expense = Expense.empty().obs;
  RxString activityName = "默认账本".obs;

  void showActivityPicker(BuildContext context, dynamic appColors) {
    // 拦截操作：如果数据还没回来，提示用户（解决问题 1）
    if (activityList.isEmpty) {
      JournalToast.showError(context, "账本数据加载中，请稍候",
          duration: const Duration(seconds: 1));
      return;
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
            top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: appColors.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("选择所属账本",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appColors.primaryText)),
            const SizedBox(height: 16),
            ...activityList.map((e) => _buildActivityListItem(
                e.activityName, e.activityId, appColors)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityListItem(String name, String id, dynamic appColors) {
    return ListTile(
      title: Text(name, style: TextStyle(color: appColors.primaryText)),
      trailing: expense.value.activityId == id
          ? Icon(Icons.check_circle, color: appColors.mainButtonBg)
          : null,
      onTap: () {
        expense.value.activityId = id;
        activityName.value = name;
        update(['expense_item']);
        Get.back(); // 关闭弹窗
      },
    );
  }

  _initData() {
    // 1. 优先解析传入的参数，确立基础的 expense 对象
    if (Get.arguments != null) {
      if (Get.arguments.runtimeType != Expense) {
        expense.value = Expense.empty();
        expense.value.activityId = Get.arguments["activityId"] ?? "";
        expense.value.expenseTime = DateTime.now().toString().substring(0, 19);
      } else {
        expense.value = Get.arguments;
        expensePriceTextEditController.text = expense.value.price.toString();
        expenseLabelTextEditController.text = expense.value.label.toString();
        // 兼容 originalPrice 为 null 的情况
        expenseOriginalPriceTextEditController.text =
            expense.value.originalPrice?.toString() ?? "";
      }
    } else {
      expense.value = Expense.empty();
    }

    expensePriceFocusNode.requestFocus();
    // 先更新一次，让输入框等基础 UI 渲染出来
    update(["expense_item"]);

    // 2. 加载账本数据并处理反显
    _loadActivitiesAndMatchName();
  }

  // 新增：专门处理账本列表获取和反显的方法
  void _loadActivitiesAndMatchName() {
    // 方案：优先使用缓存，实现秒开（解决问题 2）
    if (_cachedActivityList != null && _cachedActivityList!.isNotEmpty) {
      activityList.value = _cachedActivityList!;
      _matchCurrentActivityName();
    }

    // 无论有没有缓存，都在后台静默请求一次最新列表（防止其他页面新增了账本）
    HttpRequest.request(Method.get, "/activity/list/all", success: (data) {
      var list = (data as List).map((e) => Activity.fromJson(e)).toList();
      activityList.value = list;
      _cachedActivityList = list; // 更新静态缓存

      // 匹配当前选中的账本名称（解决问题 3）
      _matchCurrentActivityName();

      update(["activity_list"]);
    }, fail: (code, msg) {
      Log().d("获取账本列表失败: $msg");
    });
  }

  // 新增：根据 current activityId 匹配名称的方法
  void _matchCurrentActivityName() {
    String currentId = expense.value.activityId;
    if (currentId.isEmpty) {
      activityName.value = "请选择账本";
      update(["expense_item"]);
      return;
    }

    try {
      // 在列表中寻找对应的账本
      var matchedActivity = activityList.firstWhere(
        (element) => element.activityId == currentId,
      );
      activityName.value = matchedActivity.activityName;
    } catch (e) {
      // 说明没找到（可能被删了，或者数据异常）
      activityName.value = "未知账本";
    }

    // 更新 UI 以展示反显的名字
    update(["expense_item"]);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void deleteExpenseItem() {
    HttpRequest.request(Method.delete,
        "/expense/${expense.value.expenseId}/${expense.value.activityId}",
        success: (data) {
      eventBus.fire(const NeedRefreshData(
          refreshChartsList: true,
          refreshActivityList: true,
          refreshCurrentActivity: true));
      Get.back(result: true);
      Get.back(result: true);
    });
  }

  void modifyExpenseTime(String time) {
    expense.value.expenseTime = time;
    update(["expense_item"]);
  }

  void modifyExpenseColumn(String v) {
    expense.value.type = v;
    update(["expense_item"]);
    // HttpRequest.request(Method.patch, "/expense", params: expense.value,
    //     success: (data) {
    //   Get.back();
    //   update(["expense_item"]);
    //   eventBus.fire(const NeedRefreshData(
    //     refreshActivityList: true,
    //     refreshCurrentActivity: true,
    //     refreshChartsList: true,
    //   ));
    // });
  }

  void modifyExpensePrice(String v) {
    try {
      expense.value.price = num.parse(v);
    } catch (e) {
      Log().d(e.toString());
    }
  }

  void modifyExpenseLabel(String v) {
    expense.value.label = v;
  }

  void modifyExpenseOriginalPrice(String value) {
    if (value.isEmpty) {
      expense.value.originalPrice = null;
      return;
    }
    expense.value.originalPrice = num.parse(value);
  }

  Future<bool> updateExpense(context) async {
    JournalToast.showLoading(context, text: "修改中");

    await HttpRequest.request(
      Method.patch,
      "/expense",
      params: expense.value,
      success: (data) {
        JournalToast.dismiss();
        JournalToast.showSuccess(context, "修改成功",
            duration: const Duration(seconds: 1));
        eventBus.fire(const NeedRefreshData(
          refreshActivityList: true,
          refreshCurrentActivity: true,
          refreshChartsList: true,
        ));
        Future.delayed(const Duration(seconds: 1));
        Get.back(result: true);
        return true;
      },
      fail: (code, msg) {
        JournalToast.dismiss();
        JournalToast.showError(context, msg,
            duration: const Duration(seconds: 1));
      },
    );

    return true;
  }

  void modifyExpenseItem() {}

  Future<void> pickAndUploadImage(BuildContext context) async {
    try {
      File? file = await MediaHelper.pickImageWithPermission(context);
      if (file == null) return;
      String userId = "appendix";

      if (context.mounted) {
        String? url = await TencentCosService().uploadFile(
            filePath: file.path,
            userId: userId,
            prefix: "expense",
            context: context // 传入 context 自动展示 loading
            );
        if (url == null) return; // 上传失败内部已经处理了 Toast

        // 3. 更新业务数据
        if (context.mounted) {
          // 4. 将 URL 添加到 expense 的 fileList
          if (expense.value.fileList == null) {
            expense.value.fileList = [];
          }
          expense.value.fileList!.add(url);
        }
        // 5. 刷新界面
        update(['expense_item']);
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

  void showDeleteDialog(BuildContext context) {
    JournalDialog.show(context, title: "确认删除", content: "删除后无法恢复，确定要继续吗？",
        onConfirm: () {
      Navigator.pop(context); // 关弹窗
      deleteExpenseItem(); // 执行删除
    });
  }

  void showDatePicker(BuildContext context) {
    // 1. 解析初始时间 (保持你原有的逻辑)
    DateTime initial;
    try {
      initial = DateTime.parse(expense.value.expenseTime);
    } catch (e) {
      initial = DateTime.now();
    }

    // 2. 调用 JournalDatePicker
    JournalDatePicker.show(
      context,
      title: '选择时间',
      // 关键点：设置为 dateTime 模式，同时选择日期和时间
      mode: JournalDatePickerMode.dateTime,
      initialDate: initial,
      onConfirm: (DateTime selected) {
        // 3. 格式化时间 (yyyy-MM-dd HH:mm:ss)
        // 使用 padLeft(2, '0') 确保月份和分钟是两位数 (例如 5 -> 05)
        String twoDigits(int n) => n.toString().padLeft(2, '0');

        var str =
            "${selected.year}-${twoDigits(selected.month)}-${twoDigits(selected.day)} "
            "${twoDigits(selected.hour)}:${twoDigits(selected.minute)}:00"; // 秒数默认归零，体验更好

        modifyExpenseTime(str);

        // 注意：MyDatePicker 内部点击确定后会自动 pop，
        // 所以这里不需要再写 Navigator.of(context).pop();
      },
    );
  }

  RxBool isRec = false.obs;
  void autoCategorizeByLabel(context) {
    if (isRec.value) return;
    // 防抖
    if (expense.value.label.isEmpty) {
      // JournalToast.showError("请输入标签", context: context);
      return;
    }
    isRec.value = true;
    HttpRequest.request(Method.get, "/ai/type?sentence=${expense.value.label}",
        success: (data) {
      isRec.value = false;
      data as dynamic;
      print(data);
      expense.value.type = data as String;
      update(["expense_item"]);
    }, fail: (code, msg) {
      isRec.value = false;
      if (context.mounted) {
        JournalToast.showError(context, msg);
      }
    });
  }
}
