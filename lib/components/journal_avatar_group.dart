import 'package:flutter/material.dart';

class JournalAvatarGroup extends StatelessWidget {
  final List<String> avatarUrls; // 头像图片链接列表
  final int totalCount; // 总人数 (对应 activity.userList.length)
  final double size; // 头像大小，默认 32
  final double overlap; // 遮挡的宽度，默认 10
  final int maxDisplayCount; // 最多显示的头像数量（不含数字尾巴），默认 3
  final VoidCallback? onTap; // 点击回调

  const JournalAvatarGroup({
    Key? key,
    required this.avatarUrls,
    required this.totalCount,
    this.size = 32.0,
    this.overlap = 12.0, // 稍微调大一点重叠部分，视觉更紧凑
    this.maxDisplayCount = 3,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];

    // 1. 确定实际要渲染的头像数量
    // 如果总数超过限制，我们需要留一个位置给 "+N" 的圆圈
    int renderCount =
        totalCount > maxDisplayCount ? maxDisplayCount : totalCount;

    // 防止数组越界（以防 url 列表比 totalCount 少）
    if (renderCount > avatarUrls.length) {
      renderCount = avatarUrls.length;
    }

    // 2. 生成头像 Widget
    for (int i = 0; i < renderCount; i++) {
      stackChildren.add(
        Positioned(
          left: i * (size - overlap),
          child: _buildCircleItem(
            image: NetworkImage(avatarUrls[i]),
          ),
        ),
      );
    }

    // 3. 生成尾部数字/加号 Widget
    // 原有逻辑：>3 显示数字，否则显示 "+"
    // 只有当需要显示尾部（总数 > 0 且 需要操作）或者 超出显示限制时才渲染
    bool showTail = true;

    if (showTail) {
      String text;
      if (totalCount > maxDisplayCount) {
        text = '$totalCount+';
      } else {
        text = '+';
      }

      // 尾部的位置在最后一个头像之后
      double tailLeft = renderCount * (size - overlap);

      stackChildren.add(
        Positioned(
          left: tailLeft,
          child: _buildCircleItem(
            color: const Color(0xFFF2F3F5),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6), // 字体颜色
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    // 4. 计算容器总宽度
    // (数量 * (大小 - 重叠)) + 最后一个完整的大小
    // 注意：stackChildren.length 包含了头像 + 尾部组件
    double totalWidth = (stackChildren.length - 1) * (size - overlap) + size;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 确保空白区域也能响应点击
      child: SizedBox(
        width: totalWidth,
        height: size,
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }

  // 辅助方法：构建带白边的圆形
  Widget _buildCircleItem({ImageProvider? image, Color? color, Widget? child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0), // 关键：白色边框切割效果
        image: image != null
            ? DecorationImage(image: image, fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
