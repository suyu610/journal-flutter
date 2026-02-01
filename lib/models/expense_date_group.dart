import 'package:journal/models/expense.dart';

class ExpenseDateGroup {
  final String date;
  final List<Expense> expenses;
  double totalExpense = 0.0;

  ExpenseDateGroup(this.date, this.expenses);
}
