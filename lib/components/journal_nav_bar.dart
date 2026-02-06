import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 定义操作项的数据模型
class NavBarItem {
  final IconData? icon;
  final Widget? iconWidget; // 支持自定义Widget
  final Color? color;
  final VoidCallback? onTap;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  NavBarItem({
    this.icon,
    this.iconWidget,
    this.color,
    this.onTap,
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  /// 转为 Widget
  Widget toWidget(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: iconWidget ??
            Icon(
              icon,
              size: iconSize,
              color: color ?? Theme.of(context).iconTheme.color,
            ),
      ),
    );
  }
}

class JournalNavBar extends StatefulWidget implements PreferredSizeWidget {
  const JournalNavBar({
    Key? key,
    this.title = '',
    this.titleWidget,
    this.titleColor,
    this.titleSize = 18,
    this.titleFontWeight = FontWeight.w600,
    this.centerTitle = true,
    this.backgroundColor,
    this.leftBarItems,
    this.rightBarItems,
    this.useDefaultBack = true,
    this.onBack,
    this.backIconColor,
    this.height = 44.0, // 标准导航栏高度
    this.elevation = 0,
    this.systemOverlayStyle,
    this.bottomWidget,
  }) : super(key: key);

  /// 标题文字
  final String title;

  /// 自定义标题组件 (优先级高于 title)
  final Widget? titleWidget;

  /// 标题颜色
  final Color? titleColor;

  /// 标题大小
  final double titleSize;

  /// 标题粗细
  final FontWeight titleFontWeight;

  /// 标题是否居中
  final bool centerTitle;

  /// 背景颜色
  final Color? backgroundColor;

  /// 左侧按钮集合
  final List<NavBarItem>? leftBarItems;

  /// 右侧按钮集合
  final List<NavBarItem>? rightBarItems;

  /// 是否使用默认返回按钮
  final bool useDefaultBack;

  /// 返回按钮点击回调
  final VoidCallback? onBack;

  /// 返回按钮颜色
  final Color? backIconColor;

  /// 导航栏内容高度 (不含状态栏)
  final double height;

  /// 阴影高度
  final double elevation;

  /// 状态栏样式 (深色/浅色)
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// 底部扩展组件 (如下面的分割线或搜索框)
  final PreferredSizeWidget? bottomWidget;

  @override
  State<JournalNavBar> createState() => _MyNavBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottomWidget?.preferredSize.height ?? 0));
}

class _MyNavBarState extends State<JournalNavBar> {
  /// 构建返回按钮
  Widget _buildBackButton() {
    return NavBarItem(
      icon: Icons.arrow_back_ios_new, // 使用原生图标
      iconSize: 22,
      color: widget.backIconColor ?? Theme.of(context).iconTheme.color,
      padding: const EdgeInsets.only(left: 16, right: 8), // 调整间距
      onTap: () {
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.maybePop(context);
        }
      },
    ).toWidget(context);
  }

  /// 构建左右两侧的操作区
  Widget _buildActions(List<NavBarItem>? items, {bool isLeft = false}) {
    List<Widget> children = [];

    // 如果是左侧且需要返回按钮
    if (isLeft && widget.useDefaultBack) {
      children.add(_buildBackButton());
    }

    // 添加自定义按钮
    if (items != null) {
      children.addAll(items.map((e) => e.toWidget(context)));
    }

    // 如果没有内容，返回空 SizedBox
    if (children.isEmpty) return const SizedBox();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    if (widget.titleWidget != null) return widget.titleWidget!;

    return Text(
      widget.title,
      style: TextStyle(
        fontSize: widget.titleSize,
        color:
            widget.titleColor ?? Theme.of(context).textTheme.titleLarge?.color,
        fontWeight: widget.titleFontWeight,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 处理状态栏颜色
    final SystemUiOverlayStyle overlayStyle = widget.systemOverlayStyle ??
        (Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Container(
        color:
            widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: widget.height,
                decoration: widget.elevation > 0
                    ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: const Offset(0, 1),
                            blurRadius: widget.elevation,
                          )
                        ],
                      )
                    : null,
                child: NavigationToolbar(
                  leading: _buildActions(widget.leftBarItems, isLeft: true),
                  middle: _buildTitle(),
                  trailing: _buildActions(widget.rightBarItems, isLeft: false),
                  centerMiddle: widget.centerTitle,
                  middleSpacing: 16, // 标题左右的最小间距
                ),
              ),
              if (widget.bottomWidget != null) widget.bottomWidget!,
            ],
          ),
        ),
      ),
    );
  }
}
