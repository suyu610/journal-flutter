import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:journal/models/app_tab_item.dart';
// 引入你的主题颜色类文件
import 'package:journal/core/app_theme_colors.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomBottomBar extends StatefulWidget {
  final List<AppTabItem> tabs;
  final int currentIndex;
  final Function(int index, AppTabItem tab) onTap;
  final Function(int index, AppTabItem tab)? onLongPress;
  final Map<String, GlobalKey> guideKeys;

  const CustomBottomBar({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.onLongPress,
    this.guideKeys = const {},
  }) : super(key: key);

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSelectedTab());
  }

  @override
  void didUpdateWidget(covariant CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex ||
        !listEquals(
          oldWidget.tabs.map((tab) => tab.id).toList(),
          widget.tabs.map((tab) => tab.id).toList(),
        )) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showSelectedTab());
    }
  }

  void _showSelectedTab() {
    if (!mounted || !_scrollController.hasClients || widget.tabs.length <= 5) {
      return;
    }
    final width = MediaQuery.sizeOf(context).width;
    final offset = widget.currentIndex * 72 - (width - 72) / 2;
    _scrollController.jumpTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double paddingBottom = MediaQuery.of(context).padding.bottom;
    final double height = 60 + paddingBottom;
    // 【1. 获取当前主题颜色】
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: appColors.backgroundColor,
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
          Expanded(child: _buildItems(context, appColors)),
          SizedBox(height: paddingBottom),
        ],
      ),
    );
  }

  Widget _buildItems(BuildContext context, AppThemeColors appColors) {
    if (widget.tabs.length <= 5) {
      return Row(
        children: List.generate(
          widget.tabs.length,
          (index) => Expanded(
            child: _buildTabItem(context, index, widget.tabs[index], appColors),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          widget.tabs.length,
          (index) => SizedBox(
            width: 72,
            height: 60,
            child: _buildTabItem(context, index, widget.tabs[index], appColors),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, AppTabItem tab,
      AppThemeColors appColors) {
    bool isSpecialTab = tab.id == 'chat';
    bool isSelected = !isSpecialTab && widget.currentIndex == index;

    Widget iconWidget = isSpecialTab
        ? _buildSpecialIcon(tab.icon, appColors)
        : _buildNormalItem(tab, isSelected, appColors);

    final guideKey = widget.guideKeys[tab.id];
    if (guideKey != null) {
      final guideText = switch (tab.id) {
        'chat' => ('快速记账', '点这里添加账单；没有默认账本时会先让你选择或创建账本。'),
        'misson' => ('记账面板', '在这里查看账本面板和常用信息。'),
        'analytics' => ('数据统计', '按日期和分类查看收支变化。'),
        'profile' => ('我的', '备份与恢复、提醒和其他设置都在这里。'),
        _ => (tab.label, ''),
      };
      iconWidget = Showcase(
        key: guideKey,
        title: guideText.$1,
        description: guideText.$2,
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

    return Tooltip(
      message: tab.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => widget.onLongPress?.call(index, tab),
        onTap: () => widget.onTap(index, tab),
        child: Container(
          alignment: Alignment.center,
          child: iconWidget,
        ),
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
