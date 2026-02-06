import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // 用于更美观的 Loading

class JournalToast {
  static OverlayEntry? _overlayEntry;
  static Timer? _dismissTimer;
  static bool _isVisible = false;

  /// 显示纯文本
  static void show(
    BuildContext context,
    String text, {
    Duration duration = const Duration(milliseconds: 2000),
    bool preventTap = false,
  }) {
    _showOverlay(
      context,
      _ToastWidget(
        text: text,
        type: _ToastType.text,
      ),
      duration: duration,
      preventTap: preventTap,
    );
  }

  /// 显示成功
  static void showSuccess(
    BuildContext context,
    String text, {
    Duration duration = const Duration(milliseconds: 2000),
    bool preventTap = false,
  }) {
    _showOverlay(
      context,
      _ToastWidget(
        text: text,
        icon: Icons.check_circle_rounded,
        iconColor: Colors.white,
        type: _ToastType.success,
      ),
      duration: duration,
      preventTap: preventTap,
    );
  }

  /// 显示警告/错误
  static void showError(
    BuildContext context,
    String text, {
    Duration duration = const Duration(milliseconds: 1500),
    bool preventTap = false,
  }) {
    _showOverlay(
      context,
      _ToastWidget(
        text: text,
        icon: Icons.error_rounded,
        iconColor: Colors.white, // 或者用淡红色
        type: _ToastType.warning,
      ),
      duration: duration,
      preventTap: preventTap,
    );
  }

  /// 显示加载中 (需要手动 dismiss)
  static void showLoading(
    BuildContext context, {
    String? text,
    bool preventTap = true, // Loading 默认阻断操作
  }) {
    _showOverlay(
      context,
      _ToastWidget(
        text: text,
        type: _ToastType.loading,
      ),
      duration: const Duration(hours: 1), // 极长时间，直到手动关闭
      preventTap: preventTap,
    );
  }

  /// 关闭 Toast
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_overlayEntry != null && _isVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
    }
  }

  // --- 私有实现 ---

  static void _showOverlay(
    BuildContext context,
    Widget child, {
    required Duration duration,
    required bool preventTap,
  }) {
    // 如果已有 Toast，先移除
    dismiss();

    final overlayState = Overlay.of(context);

    // 创建 OverlayEntry
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastAnimateWrapper(
        preventTap: preventTap,
        onDismiss: () => dismiss(),
        child: child,
      ),
    );

    overlayState.insert(_overlayEntry!);
    _isVisible = true;

    // 只有非 Loading 状态才自动倒计时关闭
    if (duration < const Duration(hours: 1)) {
      _dismissTimer = Timer(duration, () {
        dismiss();
      });
    }
  }
}

enum _ToastType { text, success, warning, loading }

/// 负责动画和点击阻断的包装器
class _ToastAnimateWrapper extends StatefulWidget {
  final Widget child;
  final bool preventTap;
  final VoidCallback onDismiss;

  const _ToastAnimateWrapper({
    Key? key,
    required this.child,
    required this.preventTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_ToastAnimateWrapper> createState() => _ToastAnimateWrapperState();
}

class _ToastAnimateWrapperState extends State<_ToastAnimateWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // 进场动画时长
      reverseDuration: const Duration(milliseconds: 200), // 离场动画
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeOutBack), // 轻微的回弹效果，显得高级
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. 阻断点击层 (如果是 preventTap，放一个透明全屏组件吃掉点击事件)
        if (widget.preventTap)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // 拦截点击
              child: Container(color: Colors.transparent),
            ),
          ),

        // 2. Toast 内容层
        Positioned.fill(
          child: Center(
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 核心 UI 组件
class _ToastWidget extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? iconColor;
  final _ToastType type;

  const _ToastWidget({
    Key? key,
    this.text,
    this.icon,
    this.iconColor,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 视觉配置：模仿 iOS HUD 的深色磨砂质感
    const backgroundColor = Color(0xB3000000); // 70% 透明度黑色
    const borderRadius = BorderRadius.all(Radius.circular(12));
    const contentPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      decoration: null,
      height: 1.2,
    );

    // 构建内容
    Widget content;

    if (type == _ToastType.loading) {
      // Loading 样式
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(
              radius: 16, color: Colors.white), // iOS 风格菊花更优雅
          if (text != null && text!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(text!, style: textStyle, textAlign: TextAlign.center),
          ]
        ],
      );
    } else if (icon != null) {
      // 带图标样式
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: iconColor ?? Colors.white),
          const SizedBox(height: 12),
          Text(text ?? '', style: textStyle, textAlign: TextAlign.center),
        ],
      );
    } else {
      // 纯文本样式
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(8)), // 纯文本圆角稍微小一点
        ),
        child: Text(text ?? '', style: textStyle, textAlign: TextAlign.center),
      );
    }

    // 正方形 HUD 容器 (Icon 或 Loading 模式)
    return Container(
      constraints: const BoxConstraints(minWidth: 100, minHeight: 100),
      padding: contentPadding,
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: content,
    );
  }
}
