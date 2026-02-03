import 'package:flutter/material.dart';
import 'package:journal/models/app_tab_item.dart';

class CustomBottomBar extends StatelessWidget {
  final List<AppTabItem> tabs;
  final int currentIndex;
  final Function(int index, AppTabItem tab) onTap;

  const CustomBottomBar({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取底部安全区域高度
    final double paddingBottom = MediaQuery.of(context).padding.bottom;
    // 基础高度 60 + 安全区
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
          // 填充底部安全区，防止背景色断层
          SizedBox(height: paddingBottom),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, AppTabItem tab) {
    // 1. 判断是否是特殊样式的 Tab (比如聊天/发布)
    bool isSpecialTab = tab.id == 'chat';

    // 2. 判断是否选中 (特殊 Tab 永远不算“选中”，因为它只是一个按钮)
    bool isSelected = !isSpecialTab && currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // 扩大点击区域
      onTap: () {
        // 触发回调
        onTap(index, tab);
      },
      child: Container(
        alignment: Alignment.center,
        child: isSpecialTab
            ? _buildSpecialIcon(tab.icon) // 特殊样式
            : _buildNormalItem(tab, isSelected), // 普通样式
      ),
    );
  }

  // 普通 Tab 样式 (图标 + 文字)
  Widget _buildNormalItem(AppTabItem tab, bool isSelected) {
    final Color color = isSelected ? Colors.black : Colors.grey;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(tab.icon, size: 28, color: color),
        // const SizedBox(height: 4),
        // Text(
        //   tab.label,
        //   style: TextStyle(
        //     fontSize: 10,
        //     fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        //     color: color,
        //   ),
        // )
      ],
    );
  }

  // 特殊 Tab 样式 (胶囊背景/圆圈)
  Widget _buildSpecialIcon(IconData icon) {
    return Container(
      width: 48,
      height: 36, // 胶囊高度
      decoration: BoxDecoration(
        color: Colors.blueGrey[900], // 深色背景
        borderRadius: BorderRadius.circular(18), // 圆角
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
