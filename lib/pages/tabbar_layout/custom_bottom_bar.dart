import 'package:flutter/material.dart';
import 'package:journal/models/app_tab_item.dart';
import 'package:showcaseview/showcaseview.dart'; // 1. 引入库

class CustomBottomBar extends StatelessWidget {
  final List<AppTabItem> tabs;
  final int currentIndex;
  final Function(int index, AppTabItem tab) onTap;
  final Function(int index, AppTabItem tab)? onLongPress;

  // 2. 新增参数：接收 GlobalKey
  final GlobalKey? specialButtonKey;

  const CustomBottomBar({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.onLongPress,
    this.specialButtonKey, // 3. 构造函数加入
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double paddingBottom = MediaQuery.of(context).padding.bottom;
    final double height = 60 + paddingBottom;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
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
                return Expanded(
                  child: _buildTabItem(context, index, tabs[index]),
                );
              }),
            ),
          ),
          SizedBox(height: paddingBottom),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, AppTabItem tab) {
    bool isSpecialTab = tab.id == 'chat';
    bool isSelected = !isSpecialTab && currentIndex == index;

    // 4. 构建具体内容
    Widget iconWidget = isSpecialTab
        ? _buildSpecialIcon(tab.icon)
        : _buildNormalItem(tab, isSelected);

    // 5.如果是特殊按钮，并且传入了Key，就包裹 Showcase
    if (isSpecialTab && specialButtonKey != null) {
      iconWidget = Showcase(
        key: specialButtonKey!,
        title: '👋 试试长按', // 加个Emoji显得更生动
        description: '长按中间按钮\n即可快速开启手动记账',

        // 呼吸感
        targetPadding: const EdgeInsets.all(6),
        targetBorderRadius: BorderRadius.circular(24),

        // 【关键：纯白卡片】
        tooltipBackgroundColor: Colors.white,
        tooltipBorderRadius: BorderRadius.circular(16),

        // 【关键：标题用你的主色调】
        titleTextStyle: TextStyle(
          color: Colors.blueGrey[900], // 呼应你的按钮颜色
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        descTextStyle: const TextStyle(
          color: Colors.grey, // 正文用灰色
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),

        // 【高级感细节】调整气泡内部间距
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

  Widget _buildNormalItem(AppTabItem tab, bool isSelected) {
    final Color color = isSelected ? Colors.black : Colors.grey;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(tab.icon, size: 28, color: color),
      ],
    );
  }

  Widget _buildSpecialIcon(IconData icon) {
    return Container(
      width: 48,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
