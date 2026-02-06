import 'package:flutter/material.dart';
import 'package:journal/core/app_theme_colors.dart';

class JournalPopMenu {
  static void show(
    BuildContext context, {
    required List<String> items,
    required Function(int index, String value) onSelected,
    String? currentSelect, // 当前选中的项（用于高亮）
    double width = 160, // 菜单宽度
  }) {
    // 1. 获取点击控件的位置和尺寸
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 2. 计算菜单显示位置 (在控件正下方，稍微偏移一点)
    final double left = offset.dx + 4;
    final double top = offset.dy + size.height; // 8是间距

    Navigator.of(context).push(
      _JournalPopRoute(
        child: _PopMenuWidget(
          items: items,
          onSelected: onSelected,
          currentSelect: currentSelect,
          width: width,
          anchorRect: Rect.fromLTWH(left, top, size.width, size.height),
        ),
      ),
    );
  }
}

// 路由层：处理透明背景和动画
class _JournalPopRoute extends PopupRoute {
  final Widget child;

  _JournalPopRoute({required this.child});

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.05); // 点击外部关闭，背景微暗

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Close';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // 缩放+淡入动画，锚点在左上角 (Alignment.topLeft)
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        alignment: Alignment.topLeft, // 从左上角（即点击位置）展开
        child: child,
      ),
    );
  }
}

// UI层：菜单的具体样式
class _PopMenuWidget extends StatelessWidget {
  final List<String> items;
  final Function(int index, String value) onSelected;
  final String? currentSelect;
  final double width;
  final Rect anchorRect;

  const _PopMenuWidget({
    required this.items,
    required this.onSelected,
    this.currentSelect,
    required this.width,
    required this.anchorRect,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Stack(
      children: [
        Positioned(
          left: anchorRect.left,
          top: anchorRect.top,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              constraints: const BoxConstraints(maxHeight: 300), // 限制最大高度
              decoration: BoxDecoration(
                color: appColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: appColors.outlineBorder, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true, // 根据内容高度自适应
                  itemCount: items.length,
                  separatorBuilder: (ctx, i) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: appColors.outlineBorder.withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == currentSelect;

                    return InkWell(
                      onTap: () {
                        onSelected(index, item);
                        Navigator.of(context).pop(); // 关闭菜单
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        // 选中态背景微调
                        color: isSelected
                            ? appColors.brandColor.withOpacity(0.05)
                            : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? appColors.brandColor
                                      : appColors.primaryText,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: appColors.brandColor,
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
