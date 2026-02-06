import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/constants/bill_column.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/dialog_util.dart';

class ExpenseTypePickerController extends GetxController {
  // 1. 将数据转为 RxList 以便监听变化
  // 假设 billColumnList 和 incomeColumnList 是 List<Map<String, dynamic>>
  late RxList<Map<String, dynamic>> expenseList;
  late RxList<Map<String, dynamic>> incomeList;

  ExpenseTypePickerController();

  @override
  void onInit() {
    super.onInit();
    // 初始化数据，深拷贝一份以防修改原常量
    expenseList = List<Map<String, dynamic>>.from(billColumnList).obs;
    incomeList = List<Map<String, dynamic>>.from(incomeColumnList).obs;
    HttpRequest.request(Method.get, "/expense/custom/type/list").then((value) {
      print("value: $value");
      List<dynamic> data = value['data'] as List<dynamic>;
      // {id: 1, userId: us745b5117fa584096, typeName: 哈哈哈, type: expense}
      print("data: $data");
      // "labelName": "工资"
      if (data.isNotEmpty) {
        data.forEach((element) {
          if (element["type"] == "expense") {
            expenseList.add({
              "labelName": element["typeName"],
            });
          } else {
            incomeList.add(
              {
                "labelName": element["typeName"],
              },
            );
          }
        });
      }
    });
  }

  // 2. 添加新类别的方法
  void addCategory(bool isExpense, String name) {
    Map<String, dynamic> newCategory = {
      'labelName': name,
    };

    if (isExpense) {
      expenseList.add(newCategory);
    } else {
      incomeList.add(newCategory);
    }

    // 接口
    HttpRequest.request(Method.post, "/expense/custom/type", params: {
      "typeName": name,
      "type": isExpense ? "expense" : "income",
    });
  }

  void onAddTapCategory(bool isExpense, BuildContext context) {
    PremiumGlassDialog.show(context,
        title: "新建类别",
        content: "请输入类别名称",
        textInputAction: TextInputAction.done,
        confirmText: "确认", onConfirmWithInput: (v) {
      addCategory(isExpense, v);
      Get.back();
    });
  }
}
