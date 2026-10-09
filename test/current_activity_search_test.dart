import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/current_activity/controller.dart';
import 'package:journal/pages/current_activity/expense_page_source.dart';

void main() {
  test('search path sends amount or fuzzy name to the backend', () {
    final path = HttpExpensePageSource.pathFor('book', 2, '午 餐');
    final uri = Uri.parse(path);
    expect(uri.path, '/expense/list/book');
    expect(uri.queryParameters, {'pageNum': '2', 'keyword': '午 餐'});
    expect(
      Uri.parse(HttpExpensePageSource.pathFor('book', 1, '12.5'))
          .queryParameters['keyword'],
      '12.5',
    );
  });

  test('category mode groups every page and keeps income separate', () async {
    final source = _FakeSource((_, page, __) async => page == 1
        ? ExpensePage([
            _expense('1', '餐饮', 20),
            _expense('2', '交通', 7),
          ], true)
        : ExpensePage([
            _expense('3', '餐饮', 12),
            _expense('4', '餐饮', 5, positive: 1),
          ], false));
    final controller = CurrentActivityController(pageSource: source);
    controller.currentActivity.value = Activity.empty()..activityId = 'book';

    await controller.setDisplayMode(ExpenseDisplayMode.category);

    expect(source.pages, [1, 2]);
    expect(controller.categoryGroups.map((group) => group.name), ['餐饮', '交通']);
    final food = controller.categoryGroups.first;
    expect(food.expenseTotal, 32);
    expect(food.incomeTotal, 5);
    expect(food.entries.map((entry) => entry.expenseId), ['1', '3', '4']);
    controller.onClose();
  });

  test('paged details merge duplicate records and their attachments', () async {
    final source = _FakeSource((_, page, keyword) async {
      expect(keyword, '12');
      return page == 1
          ? ExpensePage([
              _expense('same', '餐饮', 12)..fileList = ['first.jpg'],
            ], true)
          : ExpensePage([
              _expense('same', '餐饮', 12)..fileList = ['second.jpg'],
              _expense('next', '交通', 12),
            ], false);
    });
    final controller = CurrentActivityController(pageSource: source);
    controller.currentActivity.value = Activity.empty()..activityId = 'book';
    controller.searchKeyword = '12';

    await controller.getExpenseList();
    await controller.getExpenseList(targetPage: 2);

    final entries = controller.expenseDateGroupList.single.expenses;
    expect(entries.map((entry) => entry.expenseId), ['same', 'next']);
    expect(entries.first.fileList, ['first.jpg', 'second.jpg']);
    expect(source.pages, [1, 2]);
    controller.onClose();
  });

  test('stale page cannot replace a new search', () async {
    final oldResult = Completer<ExpensePage>();
    final source = _FakeSource((_, __, keyword) => keyword.isEmpty
        ? oldResult.future
        : Future.value(ExpensePage([_expense('new', '餐饮', 8)], false)));
    final controller = CurrentActivityController(pageSource: source);
    controller.currentActivity.value = Activity.empty()..activityId = 'book';

    final oldLoad = controller.getExpenseList();
    controller.onSearchChanged('午餐');
    oldResult.complete(ExpensePage([_expense('old', '餐饮', 50)], false));
    await oldLoad;
    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(source.keywords, ['', '午餐']);
    expect(controller.expenseDateGroupList.single.expenses.single.expenseId,
        'new');
    controller.onClose();
  });
}

class _FakeSource implements ExpensePageSource {
  final Future<ExpensePage> Function(String, int, String) respond;
  final List<int> pages = [];
  final List<String> keywords = [];

  _FakeSource(this.respond);

  @override
  Future<ExpensePage> fetch(String activityId, int page, String keyword) {
    pages.add(page);
    keywords.add(keyword);
    return respond(activityId, page, keyword);
  }
}

Expense _expense(String id, String type, num price, {int positive = 0}) {
  return Expense(
    expenseId: id,
    type: type,
    price: price,
    label: '午餐',
    userId: 'user',
    expenseTime: '2026-10-08 12:00:00',
    createTime: '2026-10-08 12:00:00',
    activityId: 'book',
    positive: positive,
  );
}
