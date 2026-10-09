import 'package:flutter_test/flutter_test.dart';
import 'package:journal/pages/expense_category/category_order.dart';

void main() {
  final defaults = <Map<String, dynamic>>[
    {'labelName': '美食'},
    {'labelName': '交通'},
  ];
  final customs = <Map<String, dynamic>>[
    {'id': 3, 'labelName': '宠物'},
    {'id': 8, 'labelName': '咖啡'},
  ];

  test('new custom categories appear first without a saved order', () {
    final ordered = orderCategoryItems(defaults, customs, null);
    expect(ordered.map((item) => item['labelName']), ['咖啡', '宠物', '美食', '交通']);
  });

  test('new categories precede the existing manual order', () {
    final ordered = orderCategoryItems(
      defaults,
      customs,
      ['交通', '宠物', '美食'],
    );
    expect(ordered.map((item) => item['labelName']), ['咖啡', '交通', '宠物', '美食']);
  });
}
