import 'package:flutter/material.dart';
import 'package:journal/models/app_tab_item.dart';
// 引入你的主题颜色类文件
import 'package:journal/core/app_theme_colors.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomBottomBar extends StatelessWidget {
  final List<AppTabItem> tabs;
  final int currentIndex;
  final Function(int index, AppTabItem tab) onTap;
  final Function(int index, AppTabItem tab)? onLongPress;
  final GlobalKey? specialButtonKey;

  const CustomBottomBar({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.onLongPress,
    this.specialButtonKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double paddingBottom = MediaQuery.of(context).padding.bottom;
    final double height = 60 + paddingBottom;
    // 【1. 获取当前主题颜色】
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          // 边框也建议稍微淡一点，适配深色
          top: BorderSide(
              color: appColors.secondaryText.withOpacity(0.2), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(tabs.length, (index) {
                // 传参 appColors
                return Expanded(
                  child: _buildTabItem(context, index, tabs[index], appColors),
                );
              }),
            ),
          ),
          SizedBox(height: paddingBottom),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, AppTabItem tab,
      AppThemeColors appColors) {
    bool isSpecialTab = tab.id == 'chat';
    bool isSelected = !isSpecialTab && currentIndex == index;

    Widget iconWidget = isSpecialTab
        ? _buildSpecialIcon(tab.icon, appColors)
        : _buildNormalItem(tab, isSelected, appColors);

    if (isSpecialTab && specialButtonKey != null) {
      iconWidget = Showcase(
        key: specialButtonKey!,
        title: '👋 试试长按',
        description: '长按中间按钮\n即可快速开启手动记账',
        targetPadding: const EdgeInsets.all(6),
        targetBorderRadius: BorderRadius.circular(24),

        // 【关键修复】：气泡背景跟随主题（深色模式下变深色卡片）
        tooltipBackgroundColor: appColors.cardBackground,
        tooltipBorderRadius: BorderRadius.circular(16),

        // 【关键修复】：文字跟随主题
        titleTextStyle: TextStyle(
          color: appColors.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        descTextStyle: TextStyle(
          color: appColors.secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        tooltipPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: iconWidget,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => onLongPress?.call(index, tab),
      onTap: () => onTap(index, tab),
      child: Container(
        alignment: Alignment.center,
        child: iconWidget,
      ),
    );
  }

  // 普通按钮：使用 navActive / navInactive
  Widget _buildNormalItem(
      AppTabItem tab, bool isSelected, AppThemeColors appColors) {
    final Color color =
        isSelected ? appColors.navActive : appColors.navInactive;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(tab.icon, size: 28, color: color),
      ],
    );
  }

  // 特殊按钮：使用 mainButtonBg / mainButtonIcon
  Widget _buildSpecialIcon(IconData icon, AppThemeColors appColors) {
    return Container(
      width: 48,
      height: 36,
      decoration: BoxDecoration(
        color: appColors.mainButtonBg, // 这里的颜色现在会随主题变化了
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: appColors.mainButtonIcon, size: 22),
    );
  }
}
