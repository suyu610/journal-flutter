import 'package:flutter/material.dart';

// 自定义颜色扩展类
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color primaryText; // 主要文字（深色）
  final Color secondaryText; // 次要文字（浅灰）
  final Color cardBackground; // 卡片背景
  final Color chartLine; // 图表线条颜色
  final List<Color> chartPalette; // 饼图色盘
  final Color navActive; // 底部导航选中色
  // --- 新增字段 ---
  final Color navInactive; // 底部导航未选中色
  final Color mainButtonBg; // 中间大按钮背景
  final Color mainButtonIcon; // 中间大按钮图标色

  const AppThemeColors({
    required this.primaryText,
    required this.secondaryText,
    required this.cardBackground,
    required this.chartLine,
    required this.chartPalette,
    required this.navActive,
    // --- 新增构造参数 ---
    required this.navInactive,
    required this.mainButtonBg,
    required this.mainButtonIcon, // 中间大按钮图标色
  });

  @override
  ThemeExtension<AppThemeColors> copyWith({
    Color? primaryText,
    Color? secondaryText,
    Color? cardBackground,
    Color? chartLine,
    List<Color>? chartPalette,
    Color? navActive,
    // --- 新增参数 ---
    Color? navInactive,
    Color? mainButtonBg,
    Color? mainButtonIcon, // 中间大按钮图标色
  }) {
    return AppThemeColors(
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      cardBackground: cardBackground ?? this.cardBackground,
      chartLine: chartLine ?? this.chartLine,
      chartPalette: chartPalette ?? this.chartPalette,
      navActive: navActive ?? this.navActive,
      // --- 新增参数 ---
      navInactive: navInactive ?? this.navInactive,
      mainButtonBg: mainButtonBg ?? this.mainButtonBg,
      mainButtonIcon: mainButtonIcon ?? this.mainButtonIcon, // 中间大按钮图标色
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
      ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      chartLine: Color.lerp(chartLine, other.chartLine, t)!,
      // 列表颜色插值比较复杂，这里简化处理，直接取其一
      chartPalette: t < 0.5 ? chartPalette : other.chartPalette,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      // --- 新增参数 ---
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      mainButtonBg: Color.lerp(mainButtonBg, other.mainButtonBg, t)!,
      mainButtonIcon:
          Color.lerp(mainButtonIcon, other.mainButtonIcon, t)!, // 中间大按钮图标色
    );
  }
}
