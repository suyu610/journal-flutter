import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/lab/receipt/receipt_card.dart'; // 确保引用了你的组件

class ReceiptData {
  final double budget;
  final String nickname;
  final String date;
  final List<Expense> items;

  ReceiptData({
    required this.nickname,
    required this.budget,
    required this.items,
    required this.date,
  });
}

class MedicalPrinterCard extends StatefulWidget {
  final ReceiptData data;

  const MedicalPrinterCard({super.key, required this.data});

  @override
  State<MedicalPrinterCard> createState() => _MedicalPrinterCardState();
}

class _MedicalPrinterCardState extends State<MedicalPrinterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _printAnimation;

  // 状态
  double _paperHeight = 0.0;
  final double _cardHeight = 180.0; // 打印机机身高度
  final double _cardWidth = 340.0; // 打印机/纸张宽度

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _printAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    // 页面打开 300ms 后自动开始打印
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(), // 点击空白处关闭
      child: Scaffold(
        backgroundColor: Colors.transparent, // 透明背景
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60), // 距离顶部的位置
            child: GestureDetector(
              onTap: () {}, // 拦截点击，防止误触关闭
              child: SizedBox(
                width: _cardWidth,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none, // 允许纸张超出 Stack 边界
                  children: [
                    Positioned(
                      top: _cardHeight - 14, // 初始位置在出纸口附近
                      child: ClipRect(
                        // 裁剪：防止纸张向上移动时从打印机顶部冒出来
                        child: AnimatedBuilder(
                          animation: _printAnimation,
                          builder: (context, child) {
                            // 计算位移：从 "完全缩进(-height)" 移动到 "完全展示(0)"
                            double initialY = -_paperHeight;
                            double currentY = initialY +
                                (0 - initialY) * _printAnimation.value;
                            return Transform.translate(
                              offset: Offset(0, currentY),
                              child: child,
                            );
                          },
                          child: MeasureSize(
                            onChange: (size) {
                              if (_paperHeight != size.height) {
                                setState(() => _paperHeight = size.height);
                              }
                            },
                            // 这里放置真正的小票内容
                            child: SizedBox(
                              width: _cardWidth - 24, // 稍微比打印机窄一点
                              child: ReceiptCard(
                                width: _cardWidth - 24,
                                nickname: widget.data.nickname,
                                budget: widget.data.budget,
                                items: widget.data.items,
                                date: widget.data.date,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ================= 2. 打印机主体层 (在顶层) =================
                    Positioned(
                      top: 0,
                      child: Hero(
                        tag: 'printer_hero_tag', // 必须与 ChartNavBar 中的 tag 一致
                        child: Material(
                          color: Colors.transparent,
                          type: MaterialType.transparency,
                          child: Container(
                            height: _cardHeight,
                            width: _cardWidth,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2962FF), // 机器蓝色
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF0D47A1).withOpacity(0.5),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  // 机器面板内容 (文字、状态灯)
                                  _buildCardContent(),

                                  // 出纸口阴影效果
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 24,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black38,
                                            Colors.transparent
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 机器面板 UI
  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.print_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("好享记账打印机",
                      style: TextStyle(
                          // fontFamily: "SmileySans",
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => Text(
                        _controller.isAnimating ? "Printing..." : "Ready",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 辅助组件：测量高度 ---
class MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  ValueChanged<Size> onChange;
  Size? _oldSize;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    if (size != _oldSize) {
      _oldSize = size;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(size);
      });
    }
  }
}
