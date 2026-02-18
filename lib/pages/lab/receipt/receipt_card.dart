import 'package:flutter/material.dart';

import 'package:journal/models/expense.dart';
// 保持你原有的 import
// import 'package:journal/models/expense.dart';

// ----------------------------------------------------------------

class ReceiptCard extends StatelessWidget {
  final List<Expense> items;
  final double budget;
  final String date;
  final String nickname;
  final double width;

  const ReceiptCard({
    Key? key,
    required this.nickname,
    required this.items,
    required this.budget,
    required this.date,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 逻辑计算
    double totalExpense = items
        .where((item) => item.positive != 1)
        .fold(0.0, (sum, item) => sum + item.price);

    double totalIncome = items
        .where((item) => item.positive == 1)
        .fold(0.0, (sum, item) => sum + item.price);

    double totalSavings = items.fold(0.0, (sum, item) {
      if (item.originalPrice != null && item.originalPrice! > item.price) {
        return sum + (item.originalPrice! - item.price);
      }
      return sum;
    });

    bool isOverBudget = budget > 0 && totalExpense > budget;

    // --- 样式常量 ---
    const Color paperColor = Color(0xFFFDFBF7); // 米白纸张色
    const Color inkColor = Color(0xFF2D2D2D); // 接近黑色的深灰，比纯黑柔和
    bool hasBudget = budget > 0;

    double budgetLeft = hasBudget ? (budget - totalExpense) : 0;

    const TextStyle monoStyle = TextStyle(
      fontFamily: 'Courier', // 关键：等宽字体
      fontSize: 14,
      color: inkColor,
      fontWeight: FontWeight.w600,
      package: null, // 如果你有 GoogleFonts，推荐用 'VT323' 或 'Space Mono'
    );

    return Center(
      child: Container(
        width: width,
        // 模拟纸张微微翘起的阴影
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipPath(
          clipper: ReceiptClipper(), // 优化后的锯齿
          child: Container(
            color: paperColor,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 40), // 底部留出锯齿空间
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 18),
                Text(
                  "LIFE JOURNAL",
                  style: monoStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. 信息栏 (日期/顾客)
                _buildInfoRow("DATE", date, monoStyle),
                _buildInfoRow(
                    "TIME",
                    "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                    monoStyle),
                _buildInfoRow("USER", nickname.toUpperCase(), monoStyle),
                const SizedBox(height: 16),

                // 分割线
                _buildDashedDivider(),
                const SizedBox(height: 16),

                // 3. 商品列表
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildItemRow(item, monoStyle),
                    )),

                // 最小高度撑开，防止小票太短不好看
                if (items.length < 3)
                  SizedBox(height: (3 - items.length) * 24.0),

                const SizedBox(height: 16),
                _buildDashedDivider(),
                const SizedBox(height: 16),

                // 4. 结算区 (重点展示)
                if (totalSavings > 0)
                  _buildSummaryRow(
                      "TOTAL SAVINGS",
                      "-${totalSavings.toStringAsFixed(2)}",
                      monoStyle.copyWith(
                          color: Colors.red[800], fontWeight: FontWeight.bold)),

                if (totalIncome > 0)
                  _buildSummaryRow(
                      "INCOME",
                      "+${totalIncome.toStringAsFixed(2)}",
                      monoStyle.copyWith(color: Colors.green[800])),

                const SizedBox(height: 8),

                // 总支出 (特大号)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TOTAL",
                        style: monoStyle.copyWith(
                            fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(
                      "¥${totalExpense.toStringAsFixed(2)}",
                      style: monoStyle.copyWith(
                          fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 5. 预算状态 (用方框围起来)
                if (hasBudget)
                  _buildBudgetCard(
                      isOverBudget: isOverBudget,
                      budgetLeft: budgetLeft,
                      overAmount: totalExpense - budget,
                      savings: totalSavings),

                const SizedBox(height: 30),

                const SizedBox(height: 8),
                Text(
                  "THANK YOU FOR VISITING",
                  style: monoStyle.copyWith(fontSize: 10, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: style.copyWith(color: Colors.grey[600], fontSize: 12)),
          Text(value, style: style.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  // 构建商品行 (带密集虚线)
  Widget _buildItemRow(Expense item, TextStyle style) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 商品名
        Text(item.label, style: style),
        const SizedBox(width: 8),
        // 自动填充的虚线
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 2.0;
              final dashCount =
                  (constraints.constrainWidth() / (2 * dashWidth)).floor();
              return Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (_) {
                  return const SizedBox(
                    width: dashWidth,
                    height: 1,
                    child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black26)),
                  );
                }),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        // 价格区域
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 原价 (划线)
            if (item.originalPrice != null && item.originalPrice! > item.price)
              Text(
                item.originalPrice!.toStringAsFixed(2),
                style: style.copyWith(
                    fontSize: 10,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough),
              ),
            // 现价
            Text(
              "${item.positive == 1 ? '+' : ''}${item.price.toStringAsFixed(2)}",
              style: style.copyWith(
                  color: item.positive == 1 ? Colors.green[700] : Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  // 新增：提取出来的底部状态卡片，逻辑更清晰
  Widget _buildBudgetCard({
    required bool isOverBudget,
    required double budgetLeft,
    required double overAmount,
    required double savings,
  }) {
    // 样式 A: 预算充足 (黑色高级感)
    if (!isOverBudget) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), // 近乎全黑
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          children: [
            // 左侧：预算剩余
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("预算剩余",
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text("¥${budgetLeft.toStringAsFixed(2)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
            // 右侧装饰：显示节省 (如果有)
            if (savings > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    const Text("额外节省",
                        style: TextStyle(color: Colors.white54, fontSize: 8)),
                    Text("¥${savings.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    // 样式 B: 超支警报 (红色)
    else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE), // 浅红背景
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red[200]!), // 红色边框
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("预算超支警告",
                    style: TextStyle(
                        color: Colors.red[900],
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text("- ¥${overAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace')),
              ],
            ),
            Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 28),
          ],
        ),
      );
    }
  }

  // 总结行
  Widget _buildSummaryRow(String label, String value, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(fontSize: 12)),
          Text(value, style: style),
        ],
      ),
    );
  }

  // 简单的虚线分隔符
  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        150 ~/ 2, // 密度
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.black26,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------
// 优化的锯齿剪裁器 (更尖锐)
// ----------------------------------------------------------------
class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 10); // 留出10px画锯齿

    const double toothWidth = 8.0; // 锯齿宽度
    final int toothCount = (size.width / toothWidth).ceil();
    final double actualToothWidth = size.width / toothCount; // 动态调整确保填满

    for (int i = 0; i < toothCount; i++) {
      double x = i * actualToothWidth;
      // 锯齿形状：下、上
      path.lineTo(x + actualToothWidth / 2, size.height);
      path.lineTo(x + actualToothWidth, size.height - 10);
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
