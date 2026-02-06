import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class JournalSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String placeholder;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool autoFocus;
  final ValueChanged<String>? onTextChanged;
  final ValueChanged<String>? onSubmitted;
  final double borderRadius;
  final double height;

  const JournalSearchBar({
    Key? key,
    this.controller,
    this.placeholder = '搜索',
    this.backgroundColor,
    this.padding = EdgeInsets.zero,
    this.autoFocus = false,
    this.onTextChanged,
    this.onSubmitted,
    this.height = 40.0,
    this.borderRadius = 10.0, // 略微圆润的圆角，像 iOS 原生搜索栏
  }) : super(key: key);

  @override
  State<JournalSearchBar> createState() => _JournalSearchBarState();
}

class _JournalSearchBarState extends State<JournalSearchBar> {
  late TextEditingController _controller;
  final ValueNotifier<bool> _showClear = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    // 初始化时判断是否有内容
    _showClear.value = _controller.text.isNotEmpty;

    // 监听输入变化来控制清除按钮
    _controller.addListener(() {
      _showClear.value = _controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 适配深色模式的默认颜色
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor =
        isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F3F5);
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[500];

    return Container(
      padding: widget.padding,
      child: Container(
        height: widget.height, // 标准高度，既不臃肿也不局促
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? defaultBgColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. 搜索图标
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                CupertinoIcons.search, // 使用 Cupertino 图标更细致
                size: 20,
                color: iconColor,
              ),
            ),

            // 2. 输入框
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: widget.autoFocus,
                textInputAction: TextInputAction.search,
                onChanged: widget.onTextChanged,
                onSubmitted: widget.onSubmitted,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.2, // 修正文字垂直对齐
                ),
                cursorColor: Colors.blueAccent, // 光标颜色，可以换成你的 app 主题色
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    height: 1.2,
                  ),
                  border: InputBorder.none, // 去掉下划线
                  isDense: true, // 紧凑布局
                  contentPadding: EdgeInsets.zero, // 依靠父容器 Row 来对齐
                ),
              ),
            ),

            // 3. 清除按钮 (动态显示)
            ValueListenableBuilder<bool>(
              valueListenable: _showClear,
              builder: (context, show, child) {
                if (!show) return const SizedBox(width: 12);
                return GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onTextChanged?.call('');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: Colors.transparent, // 扩大点击热区
                    child: Icon(
                      CupertinoIcons.clear_circled_solid, // 实心删除球，质感好
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
