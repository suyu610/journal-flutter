import 'package:flutter_test/flutter_test.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/lab/receipt/receipt_line.dart';

void main() {
  group('buildReceiptLines', () {
    test('keeps detail rows in their original order', () {
      final expenses = [
        _expense(id: '1', type: '餐饮', label: '早餐', price: 12),
        _expense(id: '2', type: '交通', label: '地铁', price: 4),
      ];

      final lines = buildReceiptLines(expenses, groupByCategory: false);

      expect(lines.map((line) => line.label), ['早餐', '地铁']);
      expect(lines.map((line) => line.price), [12, 4]);
    });

    test('groups by category while keeping income and expense separate', () {
      final expenses = [
        _expense(
          id: '1',
          type: '餐饮',
          label: '午餐',
          price: 20,
          originalPrice: 25,
        ),
        _expense(id: '2', type: '餐饮', label: '晚餐', price: 30),
        _expense(
          id: '3',
          type: '餐饮',
          label: '退款',
          price: 8,
          positive: 1,
        ),
      ];

      final lines = buildReceiptLines(expenses, groupByCategory: true);

      expect(lines, hasLength(2));
      expect(lines[0].label, '餐饮');
      expect(lines[0].positive, 0);
      expect(lines[0].price, 50);
      expect(lines[0].originalPrice, 55);
      expect(lines[1].label, '餐饮');
      expect(lines[1].positive, 1);
      expect(lines[1].price, 8);
    });

    test('uses a stable label for empty categories', () {
      final lines = buildReceiptLines(
        [_expense(id: '1', type: '  ', label: '其它', price: 6)],
        groupByCategory: true,
      );

      expect(lines.single.label, '未分类');
    });
  });
}

Expense _expense({
  required String id,
  required String type,
  required String label,
  required num price,
  num? originalPrice,
  int positive = 0,
}) {
  return Expense(
    expenseId: id,
    type: type,
    price: price,
    originalPrice: originalPrice,
    label: label,
    userId: 'user',
    expenseTime: '2026-10-08 12:00:00',
    createTime: '2026-10-08 12:00:00',
    activityId: 'activity',
    positive: positive,
  );
}
