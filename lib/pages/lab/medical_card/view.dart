import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/lab/receipt/receipt_card.dart';
import 'package:journal/pages/lab/receipt/receipt_share_service.dart';

class ReceiptData {
  final double budget;
  final String nickname;
  final String date;
  final List<Expense> items;
  final bool groupByCategory;

  ReceiptData({
    required this.nickname,
    required this.budget,
    required this.items,
    required this.date,
    this.groupByCategory = false,
  });
}

class MedicalPrinterCard extends StatefulWidget {
  final ReceiptData data;
  final ReceiptShareService? shareService;

  const MedicalPrinterCard({super.key, required this.data, this.shareService});

  @override
  State<MedicalPrinterCard> createState() => _MedicalPrinterCardState();
}

class _MedicalPrinterCardState extends State<MedicalPrinterCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _printAnimation;
  late AnimationController _foldController;
  final ScrollController _paperScrollController = ScrollController();
  double _lastPaperOffset = 0;
  bool _sharing = false;

  final double _cardHeight = 140.0; // 打印机机身高度
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
    _foldController = AnimationController.unbounded(vsync: this);
    _paperScrollController.addListener(_onPaperScroll);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) setState(() {});
    });

    // 页面打开 300ms 后自动开始打印
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _paperScrollController.dispose();
    _foldController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onPaperScroll() {
    final offset = _paperScrollController.offset;
    if (_controller.isCompleted) {
      final delta = offset - _lastPaperOffset;
      _foldController.value = (delta / 22).clamp(-1.0, 1.0);
    }
    _lastPaperOffset = offset;
  }

  bool _onPaperScrollEnd(ScrollEndNotification notification) {
    _foldController.animateWith(SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 220, damping: 18),
      _foldController.value,
      0,
      0,
    ));
    return false;
  }

  Future<void> _shareReceipt(
      BuildContext buttonContext, double paperWidth) async {
    if (_sharing) return;
    final button = buttonContext.findRenderObject() as RenderBox?;
    if (button == null) return;
    final origin = button.localToGlobal(Offset.zero) & button.size;
    setState(() => _sharing = true);

    try {
      await (widget.shareService ?? ReceiptShareService()).shareReceipt(
        ReceiptCard(
          width: paperWidth,
          nickname: widget.data.nickname,
          budget: widget.data.budget,
          items: widget.data.items,
          date: widget.data.date,
          groupByCategory: widget.data.groupByCategory,
        ),
        context,
        origin,
      );
    } catch (error) {
      Log().d('分享小票失败: $error');
      if (mounted) JournalToast.showError(context, '分享小票失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(), // 点击空白处关闭
      child: Scaffold(
        backgroundColor: Colors.transparent, // 透明背景
        body: LayoutBuilder(
          builder: (context, constraints) {
            final printerWidth =
                math.min(_cardWidth, constraints.maxWidth - 32);
            final paperWidth = printerWidth - 24;
            final printerTop = MediaQuery.paddingOf(context).top + 36;
            final feedTop = printerTop + _cardHeight - 14;

            return Stack(
              children: [
                Positioned(
                  top: feedTop,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: paperWidth,
                      height: constraints.maxHeight - feedTop,
                      child: GestureDetector(
                        onTap: () {},
                        child: NotificationListener<ScrollEndNotification>(
                          onNotification: _onPaperScrollEnd,
                          child: SingleChildScrollView(
                            key: const Key('receipt-paper-scroll'),
                            controller: _paperScrollController,
                            physics: _controller.isCompleted
                                ? const BouncingScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              bottom: math.max(24,
                                  MediaQuery.paddingOf(context).bottom + 16),
                            ),
                            child: SizeTransition(
                              sizeFactor: _printAnimation,
                              axisAlignment: -1,
                              child: ReceiptCard(
                                key: const Key('receipt-paper'),
                                width: paperWidth,
                                nickname: widget.data.nickname,
                                budget: widget.data.budget,
                                items: widget.data.items,
                                date: widget.data.date,
                                groupByCategory: widget.data.groupByCategory,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: feedTop,
                  left: (constraints.maxWidth - paperWidth) / 2,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation:
                          Listenable.merge([_printAnimation, _foldController]),
                      builder: (context, _) => Opacity(
                        opacity: _printAnimation.value,
                        child: CustomPaint(
                          key: const Key('receipt-paper-fold'),
                          size: Size(paperWidth, 38),
                          painter: _PaperFeedPainter(_foldController.value),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: printerTop,
                  left: (constraints.maxWidth - printerWidth) / 2,
                  child: GestureDetector(
                    onTap: () {},
                    child: Hero(
                      tag: 'printer_hero_tag',
                      child: Material(
                        color: Colors.transparent,
                        type: MaterialType.transparency,
                        child: Container(
                          key: const Key('receipt-printer'),
                          height: _cardHeight,
                          width: printerWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2962FF),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D47A1).withOpacity(0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                _buildCardContent(paperWidth),
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
                                          Colors.transparent,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 机器面板 UI
  Widget _buildCardContent(double paperWidth) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                              fontFamily: "SmileySans",
                              color: Colors.white,
                              fontSize: 15)),
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
              Builder(
                builder: (buttonContext) => IconButton(
                  tooltip: '分享小票',
                  onPressed: _sharing
                      ? null
                      : () => _shareReceipt(buttonContext, paperWidth),
                  icon: _sharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share_outlined, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaperFeedPainter extends CustomPainter {
  final double bend;

  const _PaperFeedPainter(this.bend);

  @override
  void paint(Canvas canvas, Size size) {
    final twist = bend * 10;
    final path = Path()
      ..moveTo(0, 2 + twist)
      ..cubicTo(
          size.width * .25, -2, size.width * .75, 8, size.width, 2 - twist)
      ..lineTo(size.width, 28 - twist * .3)
      ..cubicTo(size.width * .72, 37 + twist * .35, size.width * .28,
          23 - twist * .35, 0, 29 + twist * .3)
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(.3), 7, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFBDB5AA),
            Color(0xFFFDFBF7),
            Color(0xFFE6DED2),
            Color(0xFFFDFBF7),
          ],
          stops: [0, .25, .7, 1],
        ).createShader(Offset.zero & size),
    );
    final crease = Path()
      ..moveTo(0, 29 + twist * .3)
      ..cubicTo(size.width * .28, 23 - twist * .35, size.width * .72,
          37 + twist * .35, size.width, 28 - twist * .3);
    canvas.drawPath(
      crease,
      Paint()
        ..color = Colors.black.withOpacity(.12 + bend.abs() * .1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _PaperFeedPainter oldDelegate) =>
      oldDelegate.bend != bend;
}
