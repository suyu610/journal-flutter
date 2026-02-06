import 'package:flutter/material.dart';
// 1. 记得引入你的主题颜色文件
import 'package:journal/core/app_theme_colors.dart';

/// 1. 设置组容器 (卡片风格)
class CellGroup extends StatelessWidget {
  final List<Widget> children;

  // 支持自定义背景色，有时候可能需要在透明背景下使用
  final Color? backgroundColor;

  const CellGroup({Key? key, required this.children, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取主题颜色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? appColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        // 统一的高级阴影
      ),
      // 使用 ClipRRect 确保子元素的点击水波纹不溢出圆角
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildChildrenWithDividers(appColors),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers(AppThemeColors appColors) {
    List<Widget> list = [];
    for (int i = 0; i < children.length; i++) {
      list.add(children[i]);
      // 如果不是最后一行，添加一条分割线
      if (i != children.length - 1) {
        list.add(Divider(
          height: 1,
          thickness: 0.5, // 极细线条
          indent: 52, // 让分割线对齐文字，不切断图标
          endIndent: 16,
          // 关键：使用主题色的极低透明度，深浅模式通用
          color: appColors.primaryText.withOpacity(0.05),
        ));
      }
    }
    return list;
  }
}

/// 2. 单个设置项 Cell
class Cell extends StatelessWidget {
  final String title;
  final Widget? icon; // 左侧图标
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? titleColor; // 支持自定义文字颜色（如删除红色）
  final String? subtitle; // 新增：支持右侧显示副标题（如版本号）

  const Cell({
    Key? key,
    required this.title,
    this.icon,
    this.onTap,
    this.showArrow = true,
    this.titleColor,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Material(
      color: Colors.transparent, // 必须透明，否则挡住 Group 的背景
      child: InkWell(
        onTap: onTap,
        // 点击反馈颜色也需要适配，不要太重
        highlightColor: appColors.primaryText.withOpacity(0.02),
        splashColor: appColors.primaryText.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 18), // 高度稍微加大，增加呼吸感
          child: Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 14), // 图标和文字间距略微加大
              ],

              // 标题
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15, // 14 -> 15，更清晰
                    fontWeight: FontWeight.w500,
                    // 适配深色模式文字
                    color: titleColor ?? appColors.primaryText,
                  ),
                ),
              ),

              // 副标题 (可选，如 "v1.0.0")
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: appColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 4),
              ],

              // 箭头
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14, // 精致的小箭头
                  color: appColors.secondaryText.withOpacity(0.5), // 低调的灰色
                ),
            ],
          ),
        ),
      ),
    );
  }
}
