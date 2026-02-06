import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:journal/core/app_theme_colors.dart'; // 确保引入你的主题配置

enum JournalButtonType {
  primary, // 实心背景（主色调）
  outline, // 轮廓模式（透明背景）
  ghost, // 纯文字模式（无边框）
}

class JournalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final JournalButtonType type;
  final double? width;
  final double? height;
  final bool isLoading;

  const JournalButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.type = JournalButtonType.primary, // 默认是实心
    this.icon,
    this.width,
    this.height,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 自动获取主题色，如果获取不到则使用默认兜底
    final appColors = Theme.of(context).extension<AppThemeColors>();
    final primaryColor = appColors?.primaryText ?? Colors.black;
    final onPrimaryColor =
        appColors?.cardBackground ?? Colors.white; // 假设实心按钮文字颜色是背景色（反色）

    // 统一尺寸配置
    final buttonHeight = height ?? 52.h;
    final borderRadius = BorderRadius.circular(12.r);

    // 文本样式
    final textStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    // 构建内容（支持 Loading 状态）
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: type == JournalButtonType.primary
                  ? onPrimaryColor
                  : primaryColor,
            ),
          ),
          SizedBox(width: 8.w),
        ] else if (icon != null) ...[
          Icon(icon, size: 20.sp),
          SizedBox(width: 8.w),
        ],
        Text(text, style: textStyle),
      ],
    );

    // 1. 实心按钮 (Primary)
    if (type == JournalButtonType.primary) {
      return SizedBox(
        width: width ?? double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: onPrimaryColor, // 文字颜色
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            // 按压效果：白色微透
            overlayColor: Colors.white.withOpacity(0.1),
          ),
          child: content,
        ),
      );
    }

    // 2. 轮廓按钮 (Outline)
    // 3. 幽灵按钮 (Ghost - 逻辑类似，只是无边框)
    final isOutline = type == JournalButtonType.outline;

    return SizedBox(
      width: width ?? double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          // 文字和图标颜色
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // 边框设置
          side: isOutline
              ? BorderSide(color: primaryColor.withOpacity(0.8), width: 1.2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          // 按压水波纹：主色调微透
          overlayColor: primaryColor.withOpacity(0.05),
        ),
        child: content,
      ),
    );
  }
}
