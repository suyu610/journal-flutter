import 'package:get/get.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/lab/sankey/view.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/sp_util.dart';
import 'package:journal/util/toast_util.dart';

class LabController extends GetxController {
  void resetGuide() {
    SpUtil.clearAllGuides();
    ToastUtil.showSnackBar("重置成功", "请重新打开APP");
  }

  void nav2SankeyChart() async {
    // 获取自己的所有花销
    List<Expense> expenses = await ExpenseService().getAllExpenses();
    Get.to(
      SankeyChartView(
        expenses: expenses,
      ),
    );
  }
}

class ExpenseService {
  Future<List<Expense>> getAllExpenses() async {
    dynamic data = await HttpRequest.request(Method.get, "/expense/all");
    var result = data['data'] as List<dynamic>;
    List<Expense> expenses = result.map((e) => Expense.fromJson(e)).toList();
    print(expenses);
    return expenses;
  }
}
