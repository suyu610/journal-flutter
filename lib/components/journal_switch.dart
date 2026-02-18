import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:journal/core/app_theme_colors.dart';

class JournalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double? width;
  final double? height;

  // 修改：将原来的 icon 拆分为开启和关闭两种状态的图标
  final IconData? activeIcon;
  final IconData? inactiveIcon;

  const JournalSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width,
    this.height,
    this.activeIcon,
    this.inactiveIcon, // 新增到构造函数
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
    final activeColor = appColors.primaryText;
    final inactiveColor = appColors.secondaryText.withOpacity(0.2);
    final thumbColor = appColors.cardBackground;

    // 3. 根据当前状态判断要显示的图标
    final currentIcon = value ? activeIcon : inactiveIcon;

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
                alignment: Alignment.center, // 确保内部的图标绝对居中
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: thumbColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                // 修改：使用 currentIcon，并加入切换动画效果
                child: currentIcon != null
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        // 新增：自定义过渡动画（缩放 + 渐变），图标替换时更丝滑
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          currentIcon,
                          // 依赖 ValueKey<bool> 触发切换：当 value 改变时，旧图标缩小消失，新图标放大出现
                          key: ValueKey<bool>(value),
                          size: circleSize * 0.55,
                          color: value
                              ? activeColor
                              : appColors.secondaryText.withOpacity(0.6),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
