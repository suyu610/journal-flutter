import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:journal/core/app_theme_colors.dart';

/// 按钮的结构样式
enum JournalButtonType {
  filled, // 实心填充 (默认)
  outline, // 描边轮廓
  ghost, // 纯文字/无边框
}

/// 按钮的颜色语义主题
enum JournalButtonTheme {
  primary, // 品牌主色 (默认)
  danger, // 危险/错误色
  secondary, // 次要/中性色 (可选)
}

class JournalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;

  // 双属性控制
  final JournalButtonType type;
  final JournalButtonTheme theme;

  final double? width;
  final double? height;
  final bool isLoading;
  final double? borderRadius;

  const JournalButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.type = JournalButtonType.filled, // 默认为实心
    this.theme = JournalButtonTheme.primary, // 默认为主色
    this.icon,
    this.width,
    this.height,
    this.isLoading = false,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    // ================= 1. 确定基础色板 (Color Palette) =================
    Color baseColor; // 基础色 (通常是背景色或主色)
    Color onBaseColor; // 基础色上的内容色 (通常是反色)

    switch (theme) {
      case JournalButtonTheme.primary:
        baseColor = appColors.brandColor;
        onBaseColor = appColors.onBrandColor;
        break;
      case JournalButtonTheme.danger:
        baseColor = appColors.dangerColor;
        onBaseColor = Colors.white; // 危险色背景上通常用白色文字
        break;
      case JournalButtonTheme.secondary:
        baseColor = appColors.secondaryText;
        onBaseColor = Colors.white;
        break;
    }

    // ================= 2. 根据 Type 生成最终样式 (Style Logic) =================
    Color bgColor; // 最终背景色
    Color fgColor; // 最终前景色 (文字/图标)
    Color? borderColor; // 最终边框色
    Color overlayColor; // 水波纹颜色

    switch (type) {
      // 实心模式：背景有色，文字反白
      case JournalButtonType.filled:
        bgColor = baseColor;
        fgColor = onBaseColor;
        borderColor = null;
        overlayColor = onBaseColor.withOpacity(0.1);
        break;

      // 描边模式：背景透明，文字和边框由主题色决定
      case JournalButtonType.outline:
        bgColor = Colors.transparent;
        fgColor = baseColor; // 文字颜色等于主题色 (红/蓝)
        // 边框稍微淡一点，更有质感
        borderColor = baseColor.withOpacity(0.8);
        overlayColor = baseColor.withOpacity(0.05);
        break;

      // 幽灵模式：背景透明，无边框，文字由主题色决定
      case JournalButtonType.ghost:
        bgColor = Colors.transparent;
        fgColor = baseColor;
        borderColor = null;
        overlayColor = baseColor.withOpacity(0.05);
        break;
    }

    // ================= 3. 构建 UI =================
    final buttonHeight = height ?? 52.h;
    final radius = borderRadius ?? 12.r;

    final textStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: fgColor,
    );

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fgColor,
            ),
          ),
          SizedBox(width: 8.w),
        ] else if (icon != null) ...[
          Icon(icon, size: 20.sp, color: fgColor),
          SizedBox(width: 8.w),
        ],
        Text(text, style: textStyle),
      ],
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          backgroundColor: bgColor,
          elevation: 0,
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1.2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          overlayColor: overlayColor,
        ),
        child: content,
      ),
    );
  }
}
