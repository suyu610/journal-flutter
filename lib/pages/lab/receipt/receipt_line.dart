import 'package:journal/models/expense.dart';

class ReceiptLine {
  final String label;
  final num price;
  final num? originalPrice;
  final int positive;

  const ReceiptLine({
    required this.label,
    required this.price,
    required this.positive,
    this.originalPrice,
  });

  factory ReceiptLine.fromExpense(Expense expense) {
    return ReceiptLine(
      label: expense.label,
      price: expense.price,
      originalPrice: expense.originalPrice,
      positive: expense.positive,
    );
  }
}

List<ReceiptLine> buildReceiptLines(
  List<Expense> expenses, {
  required bool groupByCategory,
}) {
  if (!groupByCategory) {
    return expenses.map(ReceiptLine.fromExpense).toList();
  }

  final grouped = <(String, int), List<Expense>>{};
  for (final expense in expenses) {
    final category = expense.type.trim().isEmpty ? '未分类' : expense.type.trim();
    grouped.putIfAbsent((category, expense.positive), () => []).add(expense);
  }

  final lines = grouped.entries.map((entry) {
    final items = entry.value;
    final price = items.fold<num>(0, (sum, item) => sum + item.price);
    final originalPrice = items.fold<num>(
      0,
      (sum, item) => sum + (item.originalPrice ?? item.price),
    );

    return ReceiptLine(
      label: entry.key.$1,
      positive: entry.key.$2,
      price: price,
      originalPrice: originalPrice > price ? originalPrice : null,
    );
  }).toList();

  lines.sort((a, b) {
    final direction = a.positive.compareTo(b.positive);
    if (direction != 0) return direction;
    return b.price.compareTo(a.price);
  });
  return lines;
}
