import 'dart:io';

import 'package:home_widget/home_widget.dart';

// 假设你的 Activity 模型或传入参数包含这些字段
class WidgetSyncService {
  static const String appGroupId = 'group.com.uuorb.journal_v2';
  static const String androidAppGroupId = "com.uuorb.journal";
  static const String iOSWidgetName = 'ExpenseWidget';
  static Future<void> setAppGroupId() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidget({
    required String budgetType, // 'total' 或 'month'
    required double todayExpense,
    required double weekExpense,
    required double monthExpense,
    required double totalExpense,
    required double budgetAmount,
  }) async {
    try {
      if (Platform.isAndroid) {
        await HomeWidget.setAppGroupId(androidAppGroupId);
      } else {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      print("todayExpense: $todayExpense, target: ${budgetAmount / 30}");
      // 1. 写入数据到 UserDefaults
      await Future.wait([
        HomeWidget.saveWidgetData<String>('budget_type', budgetType),
        HomeWidget.saveWidgetData<double>('today_expense', todayExpense),
        HomeWidget.saveWidgetData<double>('week_expense', weekExpense),
        HomeWidget.saveWidgetData<double>('month_expense', monthExpense),
        HomeWidget.saveWidgetData<double>('total_expense', totalExpense),
        HomeWidget.saveWidgetData<double>('budget_amount', budgetAmount),
      ]);

      // 2. 通知系统刷新
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: 'ExpenseWidgetProvider',
      );

      print("Widget 同步成功: $budgetType 模式");
    } catch (e) {
      print("同步 Widget 失败: $e");
    }
  }
}
