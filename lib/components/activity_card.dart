import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/routers.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../models/activity.dart';

/// 核心入口：账本卡片
Widget activityCard(
    Activity activity, BuildContext context, Function refreshFunc,
    {Widget? footerWidget, Widget? topRightWidget}) {
  // 1. 初始化计算逻辑
  final stats = _BudgetStats(activity);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. 头部信息
        _Header(
            activity: activity,
            topRightWidget: topRightWidget,
            context: context),

        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
        const SizedBox(height: 16),

        // 3. 核心财务数据 (结余已改为 remainingBudget)
        _FinanceOverview(activity: activity, onRefresh: refreshFunc),

        // 4. 预算分析模块 (日周重点展示)
        if (stats.hasBudget) ...[
          const SizedBox(height: 20),
          _BudgetAnalysis(stats: stats, activity: activity),
        ],

        // 5. 底部扩展区域
        if (footerWidget != null) ...[
          const SizedBox(height: 14),
          footerWidget,
        ]
      ],
    ),
  );
}

// =============================================================================
//  Logic Model: 数据清洗与计算
// =============================================================================
class _BudgetStats {
  final bool hasBudget;
  final bool isMonthType;
  final double progress;
  final double budgetAmount;
  final double remaining; // 总剩余/月剩余

  // 限额 (仅用于月模式)
  final double dayLimit;
  final double weekLimit;

  // 剩余 (仅用于月模式)
  final double dayRemaining;
  final double weekRemaining;

  _BudgetStats(Activity activity)
      : hasBudget = (activity.budget != null && activity.budget! > 0),
        isMonthType = (activity.budgetType ?? 'TOTAL').toUpperCase() == 'MONTH',
        budgetAmount = _toDouble(activity.budget),
        progress = _calculateProgress(activity),
        // 这里虽然叫 remaining，但逻辑上被 activity.remainingBudget 替代显示了
        // 不过进度条计算里可能还需要用到计算值
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
//  Sub Widgets: UI 组件
// =============================================================================

class _Header extends StatelessWidget {
  final Activity activity;
  final Widget? topRightWidget;
  final BuildContext context;

  const _Header({
    required this.activity,
    required this.topRightWidget,
    required this.context,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(99),
                ),
                alignment: Alignment.center,
                child: Text(
                  activity.activityName.length > 1
                      ? activity.activityName.substring(0, 1)
                      : (activity.activityName.isNotEmpty
                          ? activity.activityName
                          : ""),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    activity.activityName,
                    style: const TextStyle(
                        color: Color(0xFF1D1D1D),
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF2F3F5),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text(
                          "编辑",
                          style:
                              TextStyle(color: Color(0xFF666666), fontSize: 10),
                        ),
                      ),
                      if (activity.activated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF2F3F5),
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text(
                            "当前账本",
                            style: TextStyle(
                                color: Color(0xFF666666), fontSize: 10),
                          ),
                        ),
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
}

class _FinanceOverview extends StatelessWidget {
  final Activity activity;
  final Function onRefresh;

  const _FinanceOverview({required this.activity, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final double income = _BudgetStats._toDouble(activity.totalIncome);
    final double expense = _BudgetStats._toDouble(activity.totalExpense);
    // 修改点：直接使用 activity.remainingBudget，如果为 null 则显示 0
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
                  const Text("总支出",
                      style: TextStyle(color: Color(0xFF999999), fontSize: 12)),
                  const SizedBox(width: 4),
                  if (activity.budget != 0)
                    const Text("/ 限额",
                        style:
                            TextStyle(color: Color(0xFF999999), fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text("¥",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SourceCodePro')),
                  const SizedBox(width: 4),
                  Text(
                    expense.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 32,
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D1D1D)),
                  ),
                  const SizedBox(width: 4),
                  if (activity.budget != 0)
                    Text(
                      "/ ${activity.budget?.toStringAsFixed(2) ?? "0.00"}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF999999)),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _miniStatItem("收入", income, const Color(0xFF00A870)),
            Container(
              width: 1,
              height: 24,
              color: const Color(0xFFE7E7E7),
            ),
            const SizedBox(
              width: 4,
            ),
            // 这里的结余现在显示的是 remainingBudget
            _miniStatItem(
                "结余",
                balance,
                balance < 0
                    ? const Color(0xFFE34D59)
                    : const Color(0xFF1D1D1D)),
          ],
        )
      ],
    );
  }

  Widget _miniStatItem(String label, double value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4), // 稍微缩进一点
            child: Text(label,
                style: const TextStyle(color: Color(0xFF999999), fontSize: 12)),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 4),
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

  const _BudgetAnalysis({required this.stats, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 总进度条 (始终显示)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stats.isMonthType ? "本月花销进度" : "总花销进度",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333))),
              Text("${(stats.progress * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'SourceCodePro',
                      fontWeight: FontWeight.w500,
                      color: Color(0xff000000)))
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.progress,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(stats.progress >= 1.0
                  ? const Color(0xFFE34D59)
                  : const Color(0xFF000000)),
              minHeight: 8,
            ),
          ),

          if (stats.isMonthType) ...[
            const SizedBox(height: 20), // 加大间距
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
                        remainingLabel:
                            stats.weekRemaining < 0 ? "本周超出" : "本周剩余",
                        remaining: stats.weekRemaining,
                        spent: (activity.weekExpense ?? 0).toDouble(),
                        limit: stats.weekLimit)),
              ],
            ),
          ] else ...[
            // 总预算模式下的简单文本
            const SizedBox(height: 8),
            Text(
              "总预算 ¥${stats.budgetAmount.toStringAsFixed(2)}",
              style: const TextStyle(color: Color(0xFF999999), fontSize: 11),
            ),
          ]
        ],
      ),
    );
  }

  // 高亮展示卡片
  Widget _highlightCard({
    required String title,
    required String remainingLabel,
    required double remaining,
    required double spent,
    required double limit,
  }) {
    // 剩余颜色：不够了变红，够用则是深色
    final remainColor =
        remaining < 0 ? const Color(0xFFE34D59) : const Color(0xFF1D1D1D);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 3,
                  height: 12,
                  color: const Color(0xff000000),
                  margin: const EdgeInsets.only(right: 6)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333))),
            ],
          ),
          const SizedBox(height: 8),

          // 重点：剩余金额
          Text(remainingLabel,
              style: const TextStyle(fontSize: 10, color: Color(0xFF999999))),
          Text(
            "¥${remaining.abs().toStringAsFixed(1)}",
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'SourceCodePro',
                fontWeight: FontWeight.w500,
                color: remainColor),
          ),

          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFF0F0F0)),
          const SizedBox(height: 6),

          // 辅点：支出与限额
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("已支",
                  style: TextStyle(fontSize: 10, color: Color(0xFF999999))),
              Text("¥${spent.toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'SourceCodePro',
                      color: Color(0xFF666666))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("限额",
                  style: TextStyle(fontSize: 10, color: Color(0xFF999999))),
              Text("¥${limit.toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'SourceCodePro',
                      color: Color(0xFF999999))),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildOperationAvatar(Activity activity, BuildContext context) {
  List<String> avatarList =
      activity.userList.take(3).map((e) => e.avatarUrl).toList();

  return GestureDetector(
    onTap: () => Get.toNamed(Routers.InvitePageUrl, arguments: activity),
    child: Container(
      alignment: Alignment.centerRight,
      child: TDAvatar(
          avatarSize: 32,
          size: TDAvatarSize.small,
          type: TDAvatarType.display,
          displayText: activity.userList.length > 3
              ? '${activity.userList.length}+'
              : "+",
          avatarDisplayList: avatarList,
          onTap: () {
            TDToast.showText('点击了操作', context: context);
          }),
    ),
  );
}
