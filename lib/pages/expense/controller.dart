import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/components/toast/brn_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/cos.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:journal/util/media_util.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ExpensePageController extends GetxController {
  var expensePriceFocusNode = FocusNode();
  var expensePriceTextEditController = TextEditingController();
  var expenseLabelTextEditController = TextEditingController();
  var expenseOriginalPriceTextEditController = TextEditingController();

  ExpensePageController();
  Rx<Expense> expense = Expense.empty().obs;

  _initData() {
    if (Get.arguments != null) {
      // 判断type
      if (Get.arguments.runtimeType != Expense) {
        expense.value = Expense.empty();
        expense.value.activityId = Get.arguments["activityId"];
        // 日期 yyyy-mm-dd hh:mm:ss
        expense.value.expenseTime = DateTime.now().toString().substring(0, 19);
      } else {
        expense.value = Get.arguments;
        expensePriceTextEditController.text = expense.value.price.toString();
        expenseLabelTextEditController.text = expense.value.label.toString();
        expenseOriginalPriceTextEditController.text =
            expense.value.originalPrice.toString();
      }
    } else {
      expense.value = Expense.empty();
    }

    expensePriceFocusNode.requestFocus();

    update(["expense_item"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

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
    TDToast.showLoading(context: context, text: "修改中");
    await HttpRequest.request(
      Method.patch,
      "/expense",
      params: expense.value,
      success: (data) {
        TDToast.dismissLoading();
        TDToast.showSuccess("修改成功",
            context: context, duration: const Duration(seconds: 1));
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
        TDToast.dismissLoading();
        TDToast.showFail(msg,
            context: context, duration: const Duration(seconds: 1));
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
      BrnToast.show("上传失败", Get.context!);
    } finally {
      TDToast.dismissLoading();
    }
  }

  void showDeleteDialog(BuildContext context) {
    PremiumGlassDialog.show(context, title: "确认删除", content: "删除后无法恢复，确定要继续吗？",
        onConfirm: () {
      Navigator.pop(context); // 关弹窗
      deleteExpenseItem(); // 执行删除
    });
  }

  void showDatePicker(BuildContext context) {
    DateTime initial;
    try {
      initial = DateTime.parse(expense.value.expenseTime);
    } catch (e) {
      initial = DateTime.now();
    }
    TDPicker.showDatePicker(context, title: '选择时间', onConfirm: (selected) {
      var str =
          "${selected['year']}-${selected['month']}-${selected['day']} ${selected['hour']}:${selected['minute']}:${selected['second']}";
      modifyExpenseTime(str);
      Navigator.of(context).pop();
    },
        useYear: true,
        useMonth: true,
        useDay: true,
        useHour: true,
        useMinute: true,
        useSecond: true,
        initialDate: [
          initial.year,
          initial.month,
          initial.day,
          initial.hour,
          initial.minute,
          initial.second
        ]);
  }

  RxBool isRec = false.obs;
  void autoCategorizeByLabel(context) {
    if (isRec.value) return;
    // 防抖
    if (expense.value.label.isEmpty) {
      // TDToast.showFail("请输入标签", context: context);
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
        TDToast.showFail(msg, context: context);
      }
    });
  }
}
