import 'package:flutter/material.dart';

// 自定义颜色扩展类
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  // === 1. 你原有的基础字段 ===
  final Color backgroundColor; // 背景颜色
  final Color primaryText; // 主要文字
  final Color secondaryText; // 次要文字
  final Color cardBackground; // 卡片背景
  final Color chartLine; // 图表线条颜色
  final List<Color> chartPalette; // 饼图色盘
  final Color navActive; // 底部导航选中色
  final Color navInactive; // 底部导航未选中色
  final Color mainButtonBg; // 中间大按钮背景
  final Color mainButtonIcon; // 中间大按钮图标色

  // === 2. 新增的语义化字段 (用于 JournalButton) ===
  final Color brandColor; // 品牌主色 (用于 Primary 实心按钮背景)
  final Color onBrandColor; // 品牌色上的文字颜色 (通常是反色)
  final Color dangerColor; // 危险色 (用于删除、退出按钮)
  final Color outlineBorder; // 默认边框颜色 (非激活状态)

  const AppThemeColors({
    // 新增
    required this.backgroundColor,
    // 原有
    required this.primaryText,
    required this.secondaryText,
    required this.cardBackground,
    required this.chartLine,
    required this.chartPalette,
    required this.navActive,
    required this.navInactive,
    required this.mainButtonBg,
    required this.mainButtonIcon,
    // 新增
    required this.brandColor,
    required this.onBrandColor,
    required this.dangerColor,
    required this.outlineBorder,
  });

  @override
  ThemeExtension<AppThemeColors> copyWith({
    // 新增
    Color? backgroundColor,
    // 原有
    Color? primaryText,
    Color? secondaryText,
    Color? cardBackground,
    Color? chartLine,
    List<Color>? chartPalette,
    Color? navActive,
    Color? navInactive,
    Color? mainButtonBg,
    Color? mainButtonIcon,
    // 新增
    Color? brandColor,
    Color? onBrandColor,
    Color? dangerColor,
    Color? outlineBorder,
  }) {
    return AppThemeColors(
      // 新增
      backgroundColor: backgroundColor ?? this.backgroundColor,
      // 原有
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      cardBackground: cardBackground ?? this.cardBackground,
      chartLine: chartLine ?? this.chartLine,
      chartPalette: chartPalette ?? this.chartPalette,
      navActive: navActive ?? this.navActive,
      navInactive: navInactive ?? this.navInactive,
      mainButtonBg: mainButtonBg ?? this.mainButtonBg,
      mainButtonIcon: mainButtonIcon ?? this.mainButtonIcon,
      // 新增
      brandColor: brandColor ?? this.brandColor,
      onBrandColor: onBrandColor ?? this.onBrandColor,
      dangerColor: dangerColor ?? this.dangerColor,
      outlineBorder: outlineBorder ?? this.outlineBorder,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
      ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      // 新增
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      // 原有
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      chartLine: Color.lerp(chartLine, other.chartLine, t)!,
      // 列表插值简化处理
      chartPalette: t < 0.5 ? chartPalette : other.chartPalette,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      mainButtonBg: Color.lerp(mainButtonBg, other.mainButtonBg, t)!,
      mainButtonIcon: Color.lerp(mainButtonIcon, other.mainButtonIcon, t)!,
      // 新增
      brandColor: Color.lerp(brandColor, other.brandColor, t)!,
      onBrandColor: Color.lerp(onBrandColor, other.onBrandColor, t)!,
      dangerColor: Color.lerp(dangerColor, other.dangerColor, t)!,
      outlineBorder: Color.lerp(outlineBorder, other.outlineBorder, t)!,
    );
  }
}
