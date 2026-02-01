import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'expense_message.dart'; // 假设你保留了这个文件

// 定义一些常量颜色，方便统一修改
const Color kUserBubbleColor = Color(0xFF2962FF); // 科技蓝
const Color kAiBubbleColor = Color(0xFF1E1E1E); // 深灰
const Color kTextColor = Colors.white;

Widget buildBubble(
  Widget child,
  controller, {
  required types.Message message,
  required nextMessageInGroup,
}) {
  bool isUser = message.author.id == controller.user.id;
  bool isExpenseMessage = message.type == types.MessageType.custom &&
      message.metadata?['msgType'] == "expense";

// 获取角色配置
  final char = controller.currentCharacter.value;
  Color themeColor = char?.themeColor ?? const Color(0xFF2962FF);
  Color activeColor = char?.bgColors.isNotEmpty == true
      ? char!.bgColors.first
      : (char?.themeColor ?? const Color(0xFF667EEA));
  Color bgColor = isExpenseMessage
      ? Colors.transparent
      : isUser
          ? activeColor // 用户气泡颜色走 Theme
          : Color.alphaBlend(themeColor.withOpacity(0.05),
              const Color(0xFF1A1A1A).withOpacity(0.9));
  return Bubble(
    nip: isUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
    showNip: !isExpenseMessage,
    nipWidth: 8,
    nipHeight: 10,
    radius: const Radius.circular(8),
    nipRadius: 2,
    // 内边距
    padding: isExpenseMessage
        ? BubbleEdges.symmetric(horizontal: 0.w, vertical: 10.h)
        : BubbleEdges.symmetric(horizontal: 14.w, vertical: 10.h),
    borderWidth: isExpenseMessage ? 0 : 1,
    borderColor: Colors.white.withOpacity(.7),
    // 背景颜色
    color: bgColor,
    alignment: isUser
        ? Alignment.centerRight
        : isExpenseMessage
            ? Alignment.centerLeft
            : Alignment.topLeft,
    elevation: isUser ? 4 : 0,
    shadowColor: themeColor.withOpacity(0.4),
    margin: BubbleEdges.only(
      top: 4,
      bottom: 4,
      left: isUser ? 0 : 8,
      right: isUser ? 8 : 0,
    ),
    child: _buildMessage(message, controller, Get.context!, bgColor),
  );
}

// 消息内容构建
Widget _buildMessage(types.Message message, controller, context, bgColor) {
  final bool isLightColor = bgColor.computeLuminance() > 0.5;
  final Color textColor = isLightColor ? Colors.black87 : Colors.white;

  // 1. 处理自定义消息 (消费记录)
  if (message.type == types.MessageType.custom &&
      message.metadata?['msgType'] == "expense") {
    return buildExpenseMessage(message, controller, context);
  }

  // 2. 处理文本消息
  if (message.type == types.MessageType.text) {
    var textMessage = message as types.TextMessage;

    // 基础文本组件
    Widget textWidget = Text(
      textMessage.text,
      style: TextStyle(
        fontSize: 14.sp, // 稍微加大一点字号，更易读
        height: 1.4, // 增加行高，不仅好看也更像文章
        color: textColor, // 无论谁发，在深色背景下都用白色字
        fontWeight: FontWeight.w400,
      ),
    );

    return textWidget;
  }

  return const SizedBox();
}
