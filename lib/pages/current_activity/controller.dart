import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/pages/current_activity/expense_category_group.dart';
import 'package:journal/pages/current_activity/expense_page_source.dart';
import 'package:journal/request/request.dart';
import 'package:journal/services/widget_service.dart';

enum ExpenseDisplayMode { detailed, summary, category }

class CurrentActivityController extends GetxController {
  final ExpensePageSource _pageSource;
  CurrentActivityController({ExpensePageSource? pageSource})
      : _pageSource = pageSource ?? HttpExpensePageSource();

  ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;
  StreamSubscription<NeedRefreshData>? _refreshSubscription;
  int _queryGeneration = 0;
  String searchKeyword = '';
  bool searchPending = false;
  String? listError;
  String? categoryError;
  bool categoryLoading = false;
  int categoryLoadedCount = 0;
  List<ExpenseCategoryGroup> categoryGroups = [];
  final Rx<ExpenseDisplayMode> displayMode = ExpenseDisplayMode.detailed.obs;
  Rx<Activity> currentActivity = Activity.empty().obs;
  RxList<ExpenseDateGroup> expenseDateGroupList = <ExpenseDateGroup>[].obs;
  RxInt pageNum = 0.obs;
  RxBool hasNextPage = true.obs;
  RxBool isLoading = false.obs;
  final Map<String, Expense> _loadedExpenses = {};

  void updateView() {
    update(["current_activity"]);
  }

  RxList<Activity> activityList = <Activity>[].obs;

  void fetchAllActivityList() {
    Log().d("fetchAllActivityList");
    HttpRequest.request(
      Method.get,
      "/activity/list/all",
      success: (data) {
        Log().d("activityList data: ${activityList.toString()}");
        activityList.value =
            (data as List).map((e) => Activity.fromJson(e)).toList();

        update(["activity_list"]);
      },
      fail: (code, msg) {},
    );
  }

  Future<void> getExpenseList({int targetPage = 1}) async {
    if (isLoading.value || currentActivity.value.activityId.isEmpty) return;
    final generation = _queryGeneration;
    final activityId = currentActivity.value.activityId;
    final keyword = searchKeyword;
    isLoading.value = true;
    listError = null;
    update(["current_activity"]);

    try {
      final page = await _pageSource.fetch(activityId, targetPage, keyword);
      if (generation != _queryGeneration ||
          activityId != currentActivity.value.activityId) {
        return;
      }
      hasNextPage.value = page.hasNextPage;
      pageNum.value = targetPage;
      if (targetPage == 1) {
        expenseDateGroupList.clear();
        _loadedExpenses.clear();
      }
      _appendDateGroups(page.entries);
    } catch (error) {
      if (generation != _queryGeneration) return;
      Log().d('加载账单失败: $error');
      listError = '加载失败，点击重试';
    } finally {
      if (generation == _queryGeneration) {
        isLoading.value = false;
        update(["current_activity"]);
      }
    }
  }

  void _appendDateGroups(List<Expense> entries) {
    final byDate = <String, List<Expense>>{};
    for (final entry in entries) {
      if (entry.expenseTime.length < 10) continue;
      final existing = _loadedExpenses[entry.expenseId];
      if (existing != null) {
        _mergeFiles(existing, entry);
        continue;
      }
      _loadedExpenses[entry.expenseId] = entry;
      final date = entry.expenseTime.substring(0, 10);
      byDate.putIfAbsent(date, () => []).add(entry);
    }
    for (final group in expenseDateGroupList) {
      final additions = byDate.remove(group.date);
      if (additions != null) group.expenses.addAll(additions);
    }
    byDate.forEach((date, entries) {
      expenseDateGroupList.add(ExpenseDateGroup(date, entries));
    });
    expenseDateGroupList.sort((a, b) => b.date.compareTo(a.date));
    for (final group in expenseDateGroupList) {
      group.totalExpense = group.expenses
          .where((entry) => entry.positive == 0)
          .fold(0.0, (total, entry) => total + entry.price.toDouble());
    }
  }

  Future<void> _loadCategoryGroups() async {
    final generation = _queryGeneration;
    final activityId = currentActivity.value.activityId;
    final keyword = searchKeyword;
    categoryLoading = true;
    categoryError = null;
    categoryLoadedCount = 0;
    categoryGroups = [];
    update(["current_activity"]);

    final entries = <Expense>[];
    final seenEntries = <String, Expense>{};
    var nextPage = 1;
    try {
      while (true) {
        final page = await _pageSource.fetch(activityId, nextPage, keyword);
        if (generation != _queryGeneration ||
            displayMode.value != ExpenseDisplayMode.category ||
            activityId != currentActivity.value.activityId) {
          return;
        }
        for (final entry in page.entries) {
          final existing = seenEntries[entry.expenseId];
          if (existing == null) {
            seenEntries[entry.expenseId] = entry;
            entries.add(entry);
          } else {
            _mergeFiles(existing, entry);
          }
        }
        categoryLoadedCount = entries.length;
        update(["current_activity"]);
        if (!page.hasNextPage) break;
        if (page.entries.isEmpty) {
          throw const FormatException('账单分页未继续更新');
        }
        nextPage++;
      }
      categoryGroups = groupExpensesByCategory(entries);
    } catch (error) {
      if (generation != _queryGeneration) return;
      Log().d('加载分类账单失败: $error');
      categoryError = '加载失败，点击重试';
    } finally {
      if (generation == _queryGeneration) {
        categoryLoading = false;
        update(["current_activity"]);
      }
    }
  }

  void _mergeFiles(Expense target, Expense duplicate) {
    final files = duplicate.fileList;
    if (files == null || files.isEmpty) return;
    target.fileList ??= [];
    for (final file in files) {
      if (!target.fileList!.contains(file)) target.fileList!.add(file);
    }
  }

  Future<void> _loadForMode() {
    if (currentActivity.value.activityId.isEmpty) return Future.value();
    return displayMode.value == ExpenseDisplayMode.category
        ? _loadCategoryGroups()
        : getExpenseList(targetPage: 1);
  }

  Future<void> initData() async {
    _searchDebounce?.cancel();
    searchPending = false;
    _clearResults();
    currentActivity.value = Activity.empty();
    update(["current_activity"]);
    fetchAllActivityList();
    final generation = _queryGeneration;

    try {
      final response = await HttpRequest.request<dynamic>(
        Method.get,
        '/activity/current',
      );
      if (generation != _queryGeneration) return;
      if (response is! Map || response['code'] != 0) {
        throw StateError('获取当前账本失败');
      }
      final data = response['data'];
      currentActivity.value = data is Map<String, dynamic>
          ? Activity.fromJson(data)
          : Activity.empty();
      update(["current_activity"]);
      if (currentActivity.value.activityId.isEmpty) return;

      await _loadForMode();
      await WidgetSyncService.updateWidget(
        budgetType: currentActivity.value.budgetType ?? 'total',
        todayExpense: (currentActivity.value.todayExpense ?? 0).toDouble(),
        weekExpense: (currentActivity.value.weekExpense ?? 0).toDouble(),
        monthExpense: (currentActivity.value.monthExpense ?? 0).toDouble(),
        totalExpense: (currentActivity.value.totalExpense ?? 0).toDouble(),
        budgetAmount: (currentActivity.value.budget ?? 0).toDouble(),
      );
    } catch (error) {
      Log().d('获取当前账本失败: $error');
    }
  }

  void onTap() {}

  void reset() {
    _clearResults();
    update(["current_activity"]);
  }

  void _clearResults() {
    _queryGeneration++;
    pageNum.value = 0;
    hasNextPage.value = true;
    isLoading.value = false;
    expenseDateGroupList.clear();
    _loadedExpenses.clear();
    listError = null;
    categoryGroups = [];
    categoryError = null;
    categoryLoading = false;
    categoryLoadedCount = 0;
  }

  RxBool shouldShowAddButton = false.obs;

  void _loadMore() {
    if (displayMode.value == ExpenseDisplayMode.category ||
        searchPending ||
        isLoading.value ||
        !hasNextPage.value ||
        listError != null) {
      return;
    }
    getExpenseList(targetPage: pageNum.value + 1);
  }

  @override
  void onReady() {
    super.onReady();
    initData();
    // 触底加载更多
    scrollController.addListener(() {
      shouldShowAddButton.value = scrollController.position.pixels > 200;

      // 触底加载更多
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50) {
        // 提示：留出 50 像素的缓冲区域，体验更好
        _loadMore();
      }
    });
    _refreshSubscription = eventBus.on<NeedRefreshData>().listen((data) {
      Log().d("need refresh data: $data");
      if (data.refreshCurrentActivity) {
        initData();
      }
    });
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    searchKeyword = value.trim();
    _clearResults();
    searchPending = true;
    update(["current_activity"]);
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchPending = false;
      update(["current_activity"]);
      _loadForMode();
    });
  }

  void clearSearch() {
    searchController.clear();
    onSearchChanged('');
  }

  Future<void> setDisplayMode(ExpenseDisplayMode mode) async {
    if (displayMode.value == mode) return;
    displayMode.value = mode;
    _searchDebounce?.cancel();
    searchPending = false;
    _clearResults();
    update(["current_activity"]);
    await _loadForMode();
  }

  void retryList() {
    listError = null;
    getExpenseList(targetPage: pageNum.value + 1);
  }

  void retryCategories() {
    _loadCategoryGroups();
  }

  void switchActivity(Activity activity) async {
    searchController.clear();
    searchKeyword = '';
    _clearResults();
    update(["current_activity"]);
    activity.activated = true;
    await HttpRequest.request(Method.patch, "/activity", params: activity);
    initData();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _refreshSubscription?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
