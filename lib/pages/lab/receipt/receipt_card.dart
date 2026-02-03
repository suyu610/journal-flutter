import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:journal/models/expense.dart'; // 假设你用了 screenutil，如果没有请手动换成固定数值

// ==========================================
// 1. 打印机动画容器 (PrintingReceiptAnim)
// ==========================================
class PrintingReceiptAnim extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPrintFinished;

  const PrintingReceiptAnim({
    Key? key,
    required this.child,
    this.onPrintFinished,
  }) : super(key: key);

  @override
  State<PrintingReceiptAnim> createState() => _PrintingReceiptAnimState();
}

class _PrintingReceiptAnimState extends State<PrintingReceiptAnim>
    with TickerProviderStateMixin {
  // 主打印动画
  late AnimationController _printController;
  late Animation<double> _printAnimation;

  // 纸屑掉落动画
  late AnimationController _chadsController;
  late Animation<double> _chadsDropAnimation;
  late Animation<double> _chadsOpacityAnimation;

  bool _showChads = false; // 开关：打印完才显示纸屑

  @override
  void initState() {
    super.initState();

    // --- 1. 打印过程配置 (2秒匀速) ---
    _printController = AnimationController(
      duration: const Duration(seconds: 2), // 打印时长
      vsync: this,
    );
    // 使用线性曲线模拟机械运动
    _printAnimation =
        CurvedAnimation(parent: _printController, curve: Curves.linear);

    // --- 2. 碎纸屑动画配置 (400毫秒) ---
    _chadsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 下落位移：向下掉 30 像素
    _chadsDropAnimation = Tween<double>(begin: 0, end: 30.0).animate(
        CurvedAnimation(parent: _chadsController, curve: Curves.easeOutQuad));

    // 透明度：迅速消失
    _chadsOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 80),
    ]).animate(_chadsController);

    // --- 3. 启动逻辑 ---
    _printController.forward().then((_) {
      // 打印结束
      widget.onPrintFinished?.call(); // 这里可以播放 "咔嚓" 音效

      if (mounted) {
        setState(() {
          _showChads = true;
        });
        _chadsController.forward(); // 触发掉纸屑
      }
    });
  }

  @override
  void dispose() {
    _printController.dispose();
    _chadsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A. 打印机出口 (拟物黑条)
        Container(
          width: 310.w, // 比小票稍宽
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              )
            ],
          ),
          // 绿灯指示器
          child: Center(
            child: Container(
                width: 40,
                height: 2,
                color: Colors.greenAccent.withOpacity(0.8)),
          ),
        ),

        // B. 小票吐出动画 (Mask)
        SizeTransition(
          sizeFactor: _printAnimation,
          axis: Axis.vertical,
          axisAlignment: -1.0, // -1.0 表示内容固定在顶部，向下展开
          child: widget.child,
        ),

        // C. 碎纸屑层 (打印完瞬间出现)
        if (_showChads)
          AnimatedBuilder(
            animation: _chadsController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _chadsDropAnimation.value),
                child: Opacity(
                  opacity: _chadsOpacityAnimation.value,
                  child: child,
                ),
              );
            },
            child: const PaperChads(),
          ),
      ],
    );
  }
}

// ==========================================
// 2. 碎纸屑组件 (PaperChads)
// ==========================================
class PaperChads extends StatelessWidget {
  final Color color;
  const PaperChads({Key? key, this.color = const Color(0xFFF8F5F2)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    // 随机生成 15-25 个纸屑
    final count = 15 + random.nextInt(10);

    return SizedBox(
      height: 20,
      width: 300.w, // 与小票宽度对齐
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(count, (index) {
          final size = 3.0 + random.nextDouble() * 4.0; // 随机大小
          final rotation = random.nextDouble() * math.pi; // 随机旋转
          final offsetY = random.nextDouble() * 6.0; // 随机上下错落

          return Transform.translate(
            offset: Offset(0, offsetY),
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1), // 微圆角
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ==========================================
// 3. 小票卡片主体 (ReceiptCard) - 已修改
// ==========================================
// ... 前面的 Imports 和 PrintingReceiptAnim 保持不变 ...

class ReceiptCard extends StatelessWidget {
  final List<Expense> items;
  final double budget;
  final String date;
  final String nickname;
  final int? randomSeed;

  const ReceiptCard({
    Key? key,
    required this.nickname,
    required this.items,
    required this.budget,
    required this.date,
    this.randomSeed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ================== 1. 逻辑计算优化 ==================
    // 纯支出
    double totalExpense = items
        .where((item) => item.positive != 1)
        .fold(0.0, (sum, item) => sum + item.price);

    // 纯收入
    double totalIncome = items
        .where((item) => item.positive == 1)
        .fold(0.0, (sum, item) => sum + item.price);

    // 总节省
    double totalSavings = items.fold(0.0, (sum, item) {
      if (item.originalPrice != null && item.originalPrice! > item.price) {
        return sum + (item.originalPrice! - item.price);
      }
      return sum;
    });

    // 是否超支 (仅当设置了预算且支出大于预算时)
    bool hasBudget = budget > 0;
    bool isOverBudget = hasBudget && (totalExpense > budget);
    double budgetLeft = hasBudget ? (budget - totalExpense) : 0;

    // 样式定义
    final baseStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 14,
      color: Colors.grey[850],
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    // 随机变换矩阵 (保持不变)
    final random =
        math.Random(randomSeed ?? DateTime.now().millisecondsSinceEpoch);
    double rotateAngle = (random.nextDouble() - 0.5) * 0.03;
    double skewY = (random.nextDouble() - 0.5) * 0.02;
    Matrix4 transformMatrix = Matrix4.identity()
      ..rotateZ(rotateAngle)
      ..setEntry(1, 0, skewY);

    return Transform(
      transform: transformMatrix,
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 300.w,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: -2,
              ),
            ],
          ),
          child: PhysicalShape(
            clipper: ReceiptClipper(), // 你的 Clipper
            color: const Color(0xFFF8F5F2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header ---
                  Icon(Icons.receipt_long, size: 32, color: Colors.grey[800]),
                  const SizedBox(height: 8),
                  Text("今日小票",
                      style: baseStyle.copyWith(fontSize: 10, letterSpacing: 3),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  _buildDashedLine(),
                  const SizedBox(height: 8),
                  _buildRow("日期", date,
                      baseStyle.copyWith(fontWeight: FontWeight.normal)),
                  _buildRow("顾客", nickname,
                      baseStyle.copyWith(fontWeight: FontWeight.normal)),
                  const SizedBox(height: 8),
                  _buildDashedLine(),

                  // --- List (区域 A) ---
                  const SizedBox(height: 12),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildRow(
                          item.label,
                          item.price.toStringAsFixed(2),
                          baseStyle.copyWith(fontSize: 15),
                          positive: item.positive,
                          // 只有当有划线价且大于现价时才显示
                          deleteValue: (item.originalPrice != null &&
                                  item.originalPrice! > item.price)
                              ? item.originalPrice?.toStringAsFixed(2)
                              : null,
                        ),
                      )),

                  // 最小高度占位
                  if (items.length < 3)
                    SizedBox(height: (3 - items.length) * 24.0),

                  const SizedBox(height: 12),
                  _buildDashedLine(),

                  // --- Summary (区域 B：结算区) ---
                  // 这里只负责“算钱”，不要放预算逻辑，保持干净
                  const SizedBox(height: 12),

                  // 1. 如果有优惠，先展示“节省” (这也是一般小票的逻辑)
                  if (totalSavings > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("今日节省: ",
                              style: baseStyle.copyWith(
                                  fontSize: 12, color: Colors.grey[600])),
                          Text("¥${totalSavings.toStringAsFixed(2)}",
                              style: baseStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent)),
                        ],
                      ),
                    ),

                  // 2. 总支出 (大号字体)
                  if (totalExpense > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("总支出",
                            style: baseStyle.copyWith(
                                fontWeight: FontWeight.bold)),
                        Text("-¥${totalExpense.toStringAsFixed(2)}",
                            style: baseStyle.copyWith(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),

                  // 3. 总收入 (如果有)
                  if (totalIncome > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("总收入",
                            style: baseStyle.copyWith(
                                fontWeight: FontWeight.normal)),
                        Text("+¥${totalIncome.toStringAsFixed(2)}",
                            style: baseStyle.copyWith(
                                fontSize: 16, color: Colors.green[700])),
                      ],
                    ),

                  const SizedBox(height: 25),

                  // --- Footer (区域 C：状态/预算区) ---
                  // 这里才展示“预算”相关的判断，用颜色块区分情绪
                  if (hasBudget)
                    _buildBudgetCard(
                        isOverBudget: isOverBudget,
                        budgetLeft: budgetLeft,
                        overAmount: totalExpense - budget,
                        savings: totalSavings)
                  else
                    // 如果没有预算，展示一个通用的“记录”语录或者净收支
                    Center(
                      child: Text("记录，构筑生活秩序",
                          style: baseStyle.copyWith(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                    Text("¥${savings.toStringAsFixed(0)}",
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

  Widget _buildRow(String label, String value, TextStyle style,
      {String? deleteValue, int positive = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline, // 基线对齐，防止字体大小不同导致的抖动
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 左侧：名称 + 虚线
        Expanded(
          child: Row(
            children: [
              Text(label, style: style),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 4, right: 8),
                  height: 1,
                  // 虚线颜色淡一点，不要抢戏
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
        ),

        // 右侧：价格逻辑
        if (deleteValue != null && deleteValue != "0.00")
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // 划线价：灰色，小字体
              Text(deleteValue,
                  style: style.copyWith(
                      color: Colors.grey[400],
                      fontSize: 12,
                      decorationThickness: .8,
                      decorationColor: Colors.grey[400],
                      decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 6),
              // 实付价：原样式
              Text(value,
                  style: style.copyWith(
                      color: positive == 1 ? Colors.green[700] : Colors.black)),
            ],
          )
        else
          Text(positive == 1 ? "+$value" : value,
              style: style.copyWith(
                  color: positive == 1 ? Colors.green[700] : Colors.black)),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.grey[100])), // 颜色调淡
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

// ==========================================
// 4. 锯齿边缘剪裁器 (ReceiptClipper)
// ==========================================
class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);

    // 锯齿配置
    const double toothWidth = 10.0; // 每个锯齿的宽度
    const double toothHeight = 6.0; // 锯齿凹进去的深度

    double x = 0;

    // 循环画三角形
    while (x < size.width) {
      // 1. 往上走 (形成缺口)
      path.lineTo(x + toothWidth / 2, size.height - toothHeight);
      // 2. 往下走 (回到底部)
      path.lineTo(x + toothWidth, size.height);
      x += toothWidth;
    }

    path.lineTo(size.width, 0); // 连到右上角
    path.close(); // 闭合

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
