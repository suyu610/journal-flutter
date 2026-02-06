import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:journal/core/app_theme_colors.dart';

class JournalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double? width;
  final double? height;

  const JournalSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // 1. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    // 默认尺寸 (参考 iOS 原生开关比例，稍微缩小一点适配你的设计)
    final w = width ?? 44.w;
    final h = height ?? 26.h;
    final circleSize = h - 4.h; // 圆球比高度小一点，留出边距

    // 2. 颜色定义
    // 开启状态：使用主文本色 (黑/白)，显得非常酷
    final activeColor = appColors.primaryText;
    // 关闭状态：使用次要文本色的淡化版，类似 iOS 的灰色背景
    final inactiveColor = appColors.secondaryText.withOpacity(0.2);
    // 圆球颜色：始终是卡片背景色 (反之亦然，形成对比)
    final thumbColor = appColors.cardBackground;

    return GestureDetector(
      onTap: () {
        // 增加轻微震动反馈，提升质感
        HapticFeedback.lightImpact();
        onChanged?.call(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: w,
        height: h,
        padding: EdgeInsets.all(2.w), // 内边距
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h / 2),
          color: value ? activeColor : inactiveColor,
          // 只有在关闭状态下才显示一点点细边框，增加层次
          border: value
              ? null
              : Border.all(
                  color: appColors.secondaryText.withOpacity(0.1), width: 0.5),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.decelerate, // 减速曲线，更有摩擦感
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: thumbColor,
                  // 给小圆球加一点点投影，立体感倍增
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
