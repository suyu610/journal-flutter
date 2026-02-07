import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/constants/bill_column.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:journal/util/sp_util.dart';

class ExpenseTypePickerController extends GetxController {
  late RxList<Map<String, dynamic>> expenseList;
  late RxList<Map<String, dynamic>> incomeList;
  static const String keyExpenseSort = "key_expense_sort_order";
  static const String keyIncomeSort = "key_income_sort_order";
  final RxBool isEditMode = false.obs;
  ExpenseTypePickerController();

  @override
  void onInit() {
    super.onInit();
    expenseList = List<Map<String, dynamic>>.from(billColumnList).obs;
    incomeList = List<Map<String, dynamic>>.from(incomeColumnList).obs;
    _fetchData();
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    update(["expense_type_picker"]);
  }

  void _fetchData() {
    HttpRequest.request(Method.get, "/expense/custom/type/list").then((value) {
      List<dynamic> data = value['data'] as List<dynamic>;

      // 临时列表，用于存放新获取的数据
      List<Map<String, dynamic>> newExpenses = [];
      List<Map<String, dynamic>> newIncomes = [];

      if (data.isNotEmpty) {
        data.forEach((element) {
          // 2. 解析 ID (关键：用于删除)
          Map<String, dynamic> item = {
            "labelName": element["typeName"],
            "id": element["id"], // 只有自定义的有 ID
            "isCustom": true, // 标记为自定义
          };

          if (element["type"] == "expense") {
            newExpenses.add(item);
          } else {
            newIncomes.add(item);
          }
        });
      }

      // 3. 合并数据：本地默认 + 接口数据
      // 注意：这里需要去重，或者清空 expenseList 后重新添加本地+网络
      // 简单起见，假设 billColumnList 不包含网络数据
      expenseList.addAll(newExpenses);
      incomeList.addAll(newIncomes);

      // 4. 恢复排序 (根据 SP)
      _restoreSortOrder(true);
      _restoreSortOrder(false);
    });
  }

  // --- 核心功能 1: 删除 ---
  void deleteCategory(
      bool isExpense, int id, String name, BuildContext context) {
    // 调用接口
    HttpRequest.request(Method.delete, "/expense/custom/type",
        params: {"id": id}).then((_) {
      // 成功后更新 UI
      if (isExpense) {
        expenseList.removeWhere((item) => item['id'] == id);
        _saveSortOrder(true); // 删除后更新排序记录
      } else {
        incomeList.removeWhere((item) => item['id'] == id);
        _saveSortOrder(false);
      }
      if (context.mounted) {
        JournalToast.showSuccess(context, "删除成功");
      }
    });
  }

  // --- 核心功能 2: 拖拽排序 ---
  void onReorder(int oldIndex, int newIndex, bool isExpense) {
    RxList<Map<String, dynamic>> targetList =
        isExpense ? expenseList : incomeList;

    // 也就是 "添加按钮" 的位置，不允许拖拽到它后面
    if (oldIndex >= targetList.length || newIndex >= targetList.length) return;

    final item = targetList.removeAt(oldIndex);
    targetList.insert(newIndex, item);

    // 持久化保存
    _saveSortOrder(isExpense);
  }

  // 保存排序到 SP (存 labelName 的 List)
  void _saveSortOrder(bool isExpense) {
    List<String> names = (isExpense ? expenseList : incomeList)
        .map((e) => e['labelName'].toString())
        .toList();

    SpUtil.putStringList(isExpense ? keyExpenseSort : keyIncomeSort, names);
  }

  // 从 SP 恢复排序
  void _restoreSortOrder(bool isExpense) {
    List<String>? savedOrder =
        SpUtil.getStringList(isExpense ? keyExpenseSort : keyIncomeSort);

    if (savedOrder == null || savedOrder.isEmpty) return;

    RxList<Map<String, dynamic>> targetList =
        isExpense ? expenseList : incomeList;

    // 排序逻辑：
    // 1. 在 savedOrder 里的，按 savedOrder 顺序排
    // 2. 不在 savedOrder 里的 (比如新增的)，放到最后

    targetList.sort((a, b) {
      int indexA = savedOrder.indexOf(a['labelName']);
      int indexB = savedOrder.indexOf(b['labelName']);

      // 如果两个都在列表里，按索引比
      if (indexA != -1 && indexB != -1) {
        return indexA.compareTo(indexB);
      }
      // 如果 a 在列表里，b 不在，a 排前面
      if (indexA != -1) return -1;
      // 如果 b 在列表里，a 不在，b 排前面
      if (indexB != -1) return 1;

      // 都不在列表里，保持原样 (或者按创建时间)
      return 0;
    });

    targetList.refresh(); // 强制刷新 UI
  }

// 添加分类 (原有逻辑微调)
  void addCategory(bool isExpense, String name) {
    HttpRequest.request(Method.post, "/expense/custom/type", params: {
      "typeName": name,
      "type": isExpense ? "expense" : "income",
    }).then((res) {
      // 假设接口返回了新创建的对象 data: {id: "xxx", typeName: "xxx"}
      // 如果没返回 ID，还得重新拉一遍列表，否则刚创建的没法删除
      _fetchData();
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
