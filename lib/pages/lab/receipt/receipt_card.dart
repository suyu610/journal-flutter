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
// 3. 小票卡片主体 (ReceiptCard)
// ==========================================
class ReceiptCard extends StatelessWidget {
  final List<Expense> items;
  final double totalAmount;
  final double budget;
  final String date;
  final String nickname; // 顾客昵称

  final int? randomSeed; // 用于固定随机歪斜 (可选)

  const ReceiptCard({
    Key? key,
    required this.nickname, // 顾客昵称
    required this.items,
    required this.totalAmount,
    required this.budget,
    required this.date,
    this.randomSeed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 基础字体样式 (模拟热敏打印机)
    final receiptStyle = TextStyle(
      fontFamily: 'Courier', // 务必使用等宽字体
      fontSize: 14,
      color: Colors.grey[850],
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    // --- 生成受控的随机变换 (歪歪扭扭) ---
    final random =
        math.Random(randomSeed ?? DateTime.now().millisecondsSinceEpoch);
    // 旋转 (-1.5 ~ 1.5度)
    double rotateAngle = (random.nextDouble() - 0.5) * 0.03;
    // 切变 (拉伸变形)
    double skewY = (random.nextDouble() - 0.5) * 0.02;

    Matrix4 transformMatrix = Matrix4.identity()
      ..rotateZ(rotateAngle)
      ..setEntry(1, 0, skewY);

    return Transform(
      transform: transformMatrix,
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 300.w, // 固定宽度，模仿小票规格
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          // 阴影
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
            clipper: ReceiptClipper(),

            // 2. 纸张颜色 (必须在这里设置，不要在 child Container 里设置)
            color: const Color(0xFFF8F5F2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              // 纸张微渐变背景
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(Icons.receipt_long, size: 32, color: Colors.grey[800]),
                  // Image.asset("assets/images/logo.png", height: 32),
                  const SizedBox(height: 8),
                  Text("今日小票",
                      style:
                          receiptStyle.copyWith(fontSize: 10, letterSpacing: 3),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),

                  // Header
                  _buildDashedLine(),
                  const SizedBox(height: 8),
                  _buildRow("日期", date,
                      receiptStyle.copyWith(fontWeight: FontWeight.normal)),
                  _buildRow("顾客", nickname,
                      receiptStyle.copyWith(fontWeight: FontWeight.normal)),
                  const SizedBox(height: 8),
                  _buildDashedLine(),

                  // List
                  const SizedBox(height: 12),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildRow(
                            item.label,
                            item.price.toStringAsFixed(2),
                            receiptStyle.copyWith(fontSize: 15)),
                      )),

                  // 占位
                  if (items.length < 3)
                    SizedBox(height: (3 - items.length) * 20.0),

                  const SizedBox(height: 12),
                  _buildDashedLine(),

                  // Total
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("总计",
                          style: receiptStyle.copyWith(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      Text("¥${totalAmount.toStringAsFixed(2)}",
                          style: receiptStyle.copyWith(
                              fontSize: 22, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  if (budget > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("目标",
                            style: receiptStyle.copyWith(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text("¥${budget.toStringAsFixed(2)}",
                            style: receiptStyle.copyWith(
                                fontSize: 22, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  // 超出或者未超出目标
                  if (totalAmount > budget && budget > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("超出",
                            style: receiptStyle.copyWith(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text("¥${(totalAmount - budget).toStringAsFixed(2)}",
                            style: receiptStyle.copyWith(
                                fontSize: 22, fontWeight: FontWeight.w500)),
                      ],
                    ),

                  if (totalAmount <= budget && budget > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("节省",
                            style: receiptStyle.copyWith(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text("¥${(budget - totalAmount).toStringAsFixed(2)}",
                            style: receiptStyle.copyWith(
                                fontSize: 22, fontWeight: FontWeight.w500)),
                      ],
                    ),

                  const SizedBox(height: 25),

                  // Footer Slogan
                  Text(
                    "记录，构筑生活秩序",
                    textAlign: TextAlign.center,
                    style: receiptStyle.copyWith(
                        fontSize: 10, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 15),

                  // 模拟条形码
                  // 模拟条形码 (优化视觉版)
                  SizedBox(
                    height: 40, //稍微高一点
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. 左侧起始符 (模拟真实条形码的 Guard Bar)
                        _buildBar(2, true),
                        _buildBar(1, false),
                        _buildBar(2, true),
                        _buildBar(1, false),

                        // 2. 中间随机数据区 (更密集的线条)
                        ...List.generate(45, (index) {
                          // 让线条粗细变化更丰富 (1, 2, 3 像素)
                          // 并且引入一点点间隙变化
                          double width = (random.nextInt(3) + 1).toDouble();
                          bool isSpace = random.nextInt(10) > 7; // 20% 的概率是宽间隙

                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: isSpace ? 1.5 : 0.5),
                            width: width,
                            color: Colors.black87, // 条形码通常是纯黑
                          );
                        }),

                        // 3. 右侧结束符
                        _buildBar(1, false),
                        _buildBar(2, true),
                        _buildBar(1, false),
                        _buildBar(2, true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // 底部留白给锯齿
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, TextStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end, // 底部对齐
      children: [
        Text(label, style: style),
        // 中间可以用点点填充 (可选优化)
        Expanded(
            child: Text(" . " * 20,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(color: Colors.grey[300]))),
        Text(value, style: style),
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
                  decoration: BoxDecoration(color: Colors.grey[400])),
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

Widget _buildBar(double width, bool isDark) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 0.5),
    width: width,
    color: isDark ? Colors.black87 : Colors.transparent,
  );
}
