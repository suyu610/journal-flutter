import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/constants/bill_column.dart';
import 'package:journal/pages/expense_category/category_order.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:journal/util/sp_util.dart';

class ExpenseTypePickerController extends GetxController {
  late RxList<Map<String, dynamic>> expenseList;
  late RxList<Map<String, dynamic>> incomeList;
  static const String keyExpenseSort = "key_expense_sort_order";
  static const String keyIncomeSort = "key_income_sort_order";
  final RxBool isEditMode = false.obs;
  int _fetchGeneration = 0;
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

  Future<void> _fetchData(
      {String? promotedName, bool? promotedIsExpense}) async {
    final generation = ++_fetchGeneration;
    final response = await HttpRequest.request<dynamic>(
      Method.get,
      "/expense/custom/type/list",
    );
    if (generation != _fetchGeneration ||
        response is! Map ||
        response['code'] != 0 ||
        response['data'] is! List) {
      return;
    }

    final newExpenses = <Map<String, dynamic>>[];
    final newIncomes = <Map<String, dynamic>>[];
    for (final element in response['data'] as List) {
      final item = <String, dynamic>{
        'labelName': element['typeName'],
        'id': element['id'],
        'isCustom': true,
      };
      if (element['type'] == 'expense') {
        newExpenses.add(item);
      } else {
        newIncomes.add(item);
      }
    }

    expenseList.assignAll(orderCategoryItems(
      billColumnList.map((item) => Map<String, dynamic>.from(item)).toList(),
      newExpenses,
      SpUtil.getStringList(keyExpenseSort),
    ));
    incomeList.assignAll(orderCategoryItems(
      incomeColumnList.map((item) => Map<String, dynamic>.from(item)).toList(),
      newIncomes,
      SpUtil.getStringList(keyIncomeSort),
    ));

    if (promotedName != null && promotedIsExpense != null) {
      final target = promotedIsExpense ? expenseList : incomeList;
      final index = target.indexWhere(
          (item) => item['id'] != null && item['labelName'] == promotedName);
      if (index != -1) {
        target.insert(0, target.removeAt(index));
        _saveSortOrder(promotedIsExpense);
      }
    }
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

  Future<void> addCategory(bool isExpense, String name) async {
    final response = await HttpRequest.request<dynamic>(
        Method.post, "/expense/custom/type",
        params: {
          "typeName": name,
          "type": isExpense ? "expense" : "income",
        });
    if (response is Map && response['code'] == 0) {
      await _fetchData(promotedName: name, promotedIsExpense: isExpense);
    }
  }

  void onAddTapCategory(bool isExpense, BuildContext context) {
    JournalDialog.show(context,
        title: "新建类别",
        content: "请输入类别名称",
        textInputAction: TextInputAction.done,
        confirmText: "确认", onConfirmWithInput: (v) {
      addCategory(isExpense, v);
      Get.back();
    });
  }
}
