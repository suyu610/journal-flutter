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
import 'package:journal/util/media_util.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ExpensePageController extends GetxController {
  var expensePriceTextEditController = TextEditingController();
  var expenseLabelTextEditController = TextEditingController();
  var expenseOriginalPriceTextEditController = TextEditingController();

  ExpensePageController();
  Rx<Expense> expense = Expense.empty().obs;

  _initData() {
    if (Get.arguments != null) {
      expense.value = Get.arguments;
      Log().d(expense.value.type.toString());
      expensePriceTextEditController.text = expense.value.price.toString();
      expenseLabelTextEditController.text = expense.value.label.toString();
      expenseOriginalPriceTextEditController.text =
          expense.value.originalPrice.toString();
    } else {
      expense.value = Expense.empty();
    }

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

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
