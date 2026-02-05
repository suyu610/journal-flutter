import 'package:flutter/material.dart';

/// 1. 设置组容器 (卡片风格)
class CellGroup extends StatelessWidget {
  final List<Widget> children;

  const CellGroup({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 外边距
      decoration: BoxDecoration(
        color: Colors.white, // 背景色，适配暗黑模式可改为 Theme.of(context).cardColor
        borderRadius: BorderRadius.circular(12), // 圆角
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // 极淡的阴影
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // 使用 ListView.separated 的逻辑来自动添加分割线，但不滚动
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildChildrenWithDividers(),
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    List<Widget> list = [];
    for (int i = 0; i < children.length; i++) {
      list.add(children[i]);
      // 如果不是最后一行，添加一条分割线
      if (i != children.length - 1) {
        list.add(const Divider(
          height: 1,
          thickness: 0.5,
          indent: 50, // 让分割线不切断图标
          endIndent: 16,
          color: Color(0xFFF0F0F0),
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

  const Cell({
    Key? key,
    required this.title,
    this.icon,
    this.onTap,
    this.showArrow = true,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // 按压水波纹也是圆角
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16), // 增加高度，看起来更透气
          child: Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 12), // 图标和文字的间距
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, // 稍微小一点的精致字体
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? const Color(0xFF333333),
                  ),
                ),
              ),
              if (showArrow)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16, // 箭头小一点更精致
                  color: Color(0xFFC4C4C4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
