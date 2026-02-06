import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_avatar_group.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/routers.dart';

import '../models/activity.dart';

Widget activityCard(
    Activity activity, BuildContext context, Function refreshFunc,
    {Widget? footerWidget, Widget? topRightWidget}) {
  // 1. 初始化计算逻辑
  final stats = _BudgetStats(activity);

  // 2. 获取主题颜色
  final appColors = Theme.of(context).extension<AppThemeColors>()!;

  return Container(
    padding: const EdgeInsets.all(24), // 增加内边距，更有呼吸感
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: appColors.cardBackground, // 适配深色背景
      borderRadius: BorderRadius.circular(24), // 统一大圆角
      boxShadow: [
        // 统一的高级弥散阴影
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头部信息
        _Header(
            activity: activity,
            topRightWidget: topRightWidget,
            context: context,
            appColors: appColors), // 传入颜色配置

        const SizedBox(height: 20),
        // 分割线：使用极淡的主题色
        Divider(height: 1, color: appColors.primaryText.withOpacity(0.05)),
        const SizedBox(height: 20),

        // 核心财务数据
        _FinanceOverview(
            activity: activity, onRefresh: refreshFunc, appColors: appColors),

        // 预算分析模块
        if (stats.hasBudget) ...[
          const SizedBox(height: 24),
          _BudgetAnalysis(
              stats: stats, activity: activity, appColors: appColors),
        ],

        // 底部扩展区域
        if (footerWidget != null) ...[
          const SizedBox(height: 14),
          footerWidget,
        ]
      ],
    ),
  );
}

// ... _BudgetStats 类保持不变 ...
class _BudgetStats {
  final bool hasBudget;
  final bool isMonthType;
  final double progress;
  final double budgetAmount;
  final double remaining;
  final double dayLimit;
  final double weekLimit;
  final double dayRemaining;
  final double weekRemaining;

  _BudgetStats(Activity activity)
      : hasBudget = (activity.budget != null && activity.budget! > 0),
        isMonthType = (activity.budgetType ?? 'TOTAL').toUpperCase() == 'MONTH',
        budgetAmount = _toDouble(activity.budget),
        progress = _calculateProgress(activity),
        remaining = _toDouble(activity.remainingBudget),
        dayLimit = _toDouble(activity.budget) / 30,
        weekLimit = _toDouble(activity.budget) / 4.2,
        dayRemaining = (_toDouble(activity.budget) / 30) -
            _toDouble(activity.todayExpense),
        weekRemaining = (_toDouble(activity.budget) / 4.2) -
            _toDouble(activity.weekExpense);

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static double _calculateProgress(Activity a) {
    double budget = _toDouble(a.budget);
    if (budget == 0) return 0.0;

    double used = (a.budgetType ?? 'TOTAL').toUpperCase() == 'MONTH'
        ? _toDouble(a.monthExpense)
        : _toDouble(a.totalExpense);

    return (used / budget).clamp(0.0, 1.0);
  }
}

// =============================================================================
//  Sub Widgets: UI 组件 (已深度改造)
// =============================================================================

class _Header extends StatelessWidget {
  final Activity activity;
  final Widget? topRightWidget;
  final BuildContext context;
  final AppThemeColors appColors;

  const _Header({
    required this.activity,
    required this.topRightWidget,
    required this.context,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Get.toNamed(Routers.CreateActivityUrl, arguments: activity),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 图标背景
              Container(
                width: 44, // 稍微加大
                height: 44,
                decoration: BoxDecoration(
                  // color: appColors.primaryText, // 使用主题文字色作为背景（黑/白反转）
                  border: Border.all(
                    color: appColors.primaryText.withOpacity(0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16), // 圆角方形更现代
                ),
                alignment: Alignment.center,
                child: Text(
                  activity.activityName.length > 1
                      ? activity.activityName.substring(0, 1)
                      : (activity.activityName.isNotEmpty
                          ? activity.activityName
                          : ""),
                  style: TextStyle(
                      color: appColors.primaryText, // 反色文字
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    activity.activityName,
                    style: TextStyle(
                        color: appColors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTag("编辑", appColors),
                      if (activity.activated) ...[
                        const SizedBox(width: 6),
                        _buildTag("当前账本", appColors),
                      ]
                    ],
                  ),
                ],
              ),
            ],
          ),
          topRightWidget ?? buildOperationAvatar(activity, context),
        ],
      ),
    );
  }

  Widget _buildTag(String text, AppThemeColors appColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          // 使用极淡的背景色
          color: appColors.secondaryText.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(
            color: appColors.secondaryText, // 次要文字色
            fontSize: 10,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _FinanceOverview extends StatelessWidget {
  final Activity activity;
  final Function onRefresh;
  final AppThemeColors appColors;

  const _FinanceOverview(
      {required this.activity,
      required this.onRefresh,
      required this.appColors});

  @override
  Widget build(BuildContext context) {
    final double income = _BudgetStats._toDouble(activity.totalIncome);
    final double expense = _BudgetStats._toDouble(activity.totalExpense);
    final double balance = _BudgetStats._toDouble(activity.remainingBudget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onRefresh(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("总支出",
                      style: TextStyle(
                          color: appColors.primaryText, fontSize: 13)),
                  const SizedBox(width: 4),
                  if (activity.budget != 0)
                    Text("/ 限额",
                        style: TextStyle(
                            color: appColors.secondaryText.withOpacity(0.7),
                            fontSize: 11)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("¥",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: appColors.primaryText, // 适配颜色
                          fontFamily: 'SourceCodePro')),
                  const SizedBox(width: 4),
                  Text(
                    expense.toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 32, // 字体加大
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w500,
                        color: appColors.primaryText),
                  ),
                  const SizedBox(width: 6),
                  if (activity.budget != 0)
                    Text(
                      "/ ${activity.budget?.toStringAsFixed(2) ?? "0.00"}",
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w400,
                          color: appColors.secondaryText),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _miniStatItem("收入", income, const Color(0xFF00A870), appColors),
            // 分割线
            Container(
              width: 1,
              height: 24,
              color: appColors.chartLine.withOpacity(0.1),
            ),
            const SizedBox(width: 4),
            _miniStatItem(
                "结余",
                balance,
                balance < 0 ? const Color(0xFFE34D59) : appColors.primaryText,
                appColors),
          ],
        )
      ],
    );
  }

  Widget _miniStatItem(
      String label, double value, Color valueColor, AppThemeColors appColors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(label,
                style: TextStyle(color: appColors.secondaryText, fontSize: 12)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'SourceCodePro',
                  fontWeight: FontWeight.w500,
                  color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetAnalysis extends StatelessWidget {
  final _BudgetStats stats;
  final Activity activity;
  final AppThemeColors appColors;

  const _BudgetAnalysis(
      {required this.stats, required this.activity, required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 总进度条
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(stats.isMonthType ? "本月花销进度" : "总花销进度",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: appColors.primaryText)),
            Text("${(stats.progress * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'SourceCodePro',
                    fontWeight: FontWeight.w500,
                    color: appColors.primaryText))
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: stats.progress,
            backgroundColor: appColors.primaryText.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(stats.progress >= 1.0
                ? const Color(0xFFE34D59)
                : appColors.primaryText),
            minHeight: 8,
          ),
        ),

        if (stats.isMonthType) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _highlightCard(
                      title: "今日",
                      remainingLabel:
                          "今日${stats.dayRemaining < 0 ? "超出" : "剩余"}",
                      remaining: stats.dayRemaining,
                      spent: (activity.todayExpense ?? 0).toDouble(),
                      limit: stats.dayLimit)),
              const SizedBox(width: 12),
              Expanded(
                  child: _highlightCard(
                      title: "本周",
                      remainingLabel: stats.weekRemaining < 0 ? "本周超出" : "本周剩余",
                      remaining: stats.weekRemaining,
                      spent: (activity.weekExpense ?? 0).toDouble(),
                      limit: stats.weekLimit)),
            ],
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            "总预算 ¥${stats.budgetAmount.toStringAsFixed(2)}",
            style: TextStyle(color: appColors.secondaryText, fontSize: 11),
          ),
        ]
      ],
    );
  }

  // 高亮展示卡片 (重构为卡片中的卡片)
  Widget _highlightCard({
    required String title,
    required String remainingLabel,
    required double remaining,
    required double spent,
    required double limit,
  }) {
    final remainColor =
        remaining < 0 ? const Color(0xFFE34D59) : appColors.primaryText;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // 使用非常淡的背景色，制造层次
        color: appColors.primaryText.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 3,
                  height: 12,
                  // 装饰条颜色
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: appColors.primaryText,
                  ),
                  margin: const EdgeInsets.only(right: 6)),
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: appColors.primaryText)),
            ],
          ),
          const SizedBox(height: 12),

          Text(remainingLabel,
              style: TextStyle(fontSize: 10, color: appColors.secondaryText)),
          const SizedBox(height: 2),
          Text(
            "¥${remaining.abs().toStringAsFixed(1)}",
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'SourceCodePro',
                fontWeight: FontWeight.w500,
                color: remainColor),
          ),

          const SizedBox(height: 12),
          // 分割线
          Container(height: 1, color: appColors.primaryText.withOpacity(0.05)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("已支",
                  style:
                      TextStyle(fontSize: 10, color: appColors.secondaryText)),
              Text("¥${spent.toStringAsFixed(0)}",
                  style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'SourceCodePro',
                      color: appColors.secondaryText)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("限额",
                  style:
                      TextStyle(fontSize: 10, color: appColors.secondaryText)),
              Text("¥${limit.toStringAsFixed(0)}",
                  style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'SourceCodePro',
                      color: appColors.secondaryText)),
            ],
          ),
        ],
      ),
    );
  }
}

// 头像部分保持逻辑，样式稍作调整
Widget buildOperationAvatar(Activity activity, BuildContext context) {
  List<String> avatarList =
      activity.userList.take(3).map((e) => e.avatarUrl).toList();

  return GestureDetector(
    onTap: () => Get.toNamed(Routers.InvitePageUrl, arguments: activity),
    child: Container(
        alignment: Alignment.centerRight,
        child: JournalAvatarGroup(
          avatarUrls: avatarList,
          totalCount: activity.userList.length,
          onTap: () {
            Get.toNamed(Routers.InvitePageUrl, arguments: activity);
          },
        )),
  );
}
