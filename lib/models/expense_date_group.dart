import 'package:journal/models/expense.dart';

class ExpenseDateGroup{
  final String date;
  final List<Expense> expenses;

  ExpenseDateGroup(this.date, this.expenses);
}