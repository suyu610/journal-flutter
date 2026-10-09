import 'package:journal/models/expense.dart';
import 'package:journal/models/paging.dart';
import 'package:journal/request/request.dart';

class ExpensePage {
  final List<Expense> entries;
  final bool hasNextPage;

  const ExpensePage(this.entries, this.hasNextPage);
}

abstract class ExpensePageSource {
  Future<ExpensePage> fetch(String activityId, int page, String keyword);
}

class HttpExpensePageSource implements ExpensePageSource {
  static String pathFor(String activityId, int page, String keyword) {
    return Uri(
      path: '/expense/list/$activityId',
      queryParameters: {
        'pageNum': '$page',
        if (keyword.isNotEmpty) 'keyword': keyword,
      },
    ).toString();
  }

  @override
  Future<ExpensePage> fetch(String activityId, int page, String keyword) async {
    final response = await HttpRequest.request<dynamic>(
      Method.get,
      pathFor(activityId, page, keyword),
    );
    if (response is! Map || response['code'] != 0) {
      throw StateError(response is Map
          ? response['errorMsg']?.toString() ?? '读取账单失败'
          : '网络请求失败');
    }
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('账单列表格式错误');
    }
    final paging = Paging.fromJson(data);
    return ExpensePage(
      paging.list
          .map((entry) => Expense.fromJson(entry as Map<String, dynamic>))
          .toList(),
      paging.hasNextPage,
    );
  }
}
