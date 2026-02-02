import 'package:journal/models/expense.dart';

class ExpenseDateGroup {
  final String date;
  final List<Expense> expenses;
  double totalExpense = 0.0;

  ExpenseDateGroup(this.date, this.expenses);
  // ==========================================
  // 核心修改：增加一个 getter 自动按 type 分组
  // ==========================================
  Map<String, List<Expense>> get expensesByType {
    Map<String, List<Expense>> map = {};
    for (var e in expenses) {
      // 这里的 type 是你的 Expense 类里的字段，比如 "餐饮", "交通"
      if (map[e.type] == null) {
        map[e.type] = [];
      }
      map[e.type]!.add(e);
    }
    return map;
  }

  // 如果你需要获取该日期下，某个类型的总金额
  double getTypeTotal(String type) {
    var list = expensesByType[type];
    if (list == null) return 0.0;

    double total = 0.0;
    for (var e in list) {
      if (e.positive == 0) {
        // 假设 0 是支出
        total += e.price;
      }
    }
    return total;
  }
}
