import 'package:journal/models/expense.dart';

class ExpenseCategoryGroup {
  final String name;
  final List<Expense> entries = [];
  double expenseTotal = 0;
  double incomeTotal = 0;

  ExpenseCategoryGroup(this.name);
}

List<ExpenseCategoryGroup> groupExpensesByCategory(List<Expense> expenses) {
  final groups = <String, ExpenseCategoryGroup>{};
  for (final expense in expenses) {
    final name = expense.type.trim().isEmpty ? '未分类' : expense.type.trim();
    final group = groups.putIfAbsent(name, () => ExpenseCategoryGroup(name));
    group.entries.add(expense);
    if (expense.positive == 1) {
      group.incomeTotal += expense.price.toDouble();
    } else {
      group.expenseTotal += expense.price.toDouble();
    }
  }
  return groups.values.toList()
    ..sort((a, b) {
      final byExpense = b.expenseTotal.compareTo(a.expenseTotal);
      if (byExpense != 0) return byExpense;
      final byIncome = b.incomeTotal.compareTo(a.incomeTotal);
      if (byIncome != 0) return byIncome;
      return a.name.compareTo(b.name);
    });
}
