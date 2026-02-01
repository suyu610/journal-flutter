import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:journal/pages/tabbar_layout/controller.dart';
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
  // 如果是自定义的消费消息，并且你想完全自定义样式（不带气泡尖角），
  // 可以直接返回内容，或者保留在气泡里。这里我保留在气泡里，但适配深色。
  return Bubble(
    // 气泡尖角位置
    nip: isUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
    showNip: !isExpenseMessage,
    // 调整尖角的大小，不用太尖
    nipWidth: 8,
    nipHeight: 10,
    radius: const Radius.circular(8), // 更圆润的圆角
    nipRadius: 2, // 尖角圆角
    // nipRadius <= nipWidth / 2 && nipRadius <= nipHeight / 2
    // 内边距
    padding: isExpenseMessage
        ? BubbleEdges.symmetric(horizontal: 0.w, vertical: 10.h)
        : BubbleEdges.symmetric(horizontal: 14.w, vertical: 10.h),

    // 边框逻辑：AI的气泡加一个极细的亮边，增加玻璃质感
    borderWidth: isExpenseMessage || isUser ? 0 : 1,
    borderColor: isUser ? Colors.transparent : Colors.white.withOpacity(0.1),

    // 背景颜色
    color: isExpenseMessage
        ? Colors.transparent
        : isUser
            ? kUserBubbleColor.withOpacity(0.9)
            : kAiBubbleColor.withOpacity(0.9),

    // 阴影：给用户的蓝色气泡加一点发光效果
    elevation: isUser ? 4 : 0,
    shadowColor:
        isUser ? kUserBubbleColor.withOpacity(0.4) : Colors.transparent,

    child: _buildMessage(message, controller, Get.context!),
  );
}

// 消息内容构建
Widget _buildMessage(types.Message message, controller, context) {
  bool isUser = message.author.id == controller.user.id;

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
        fontSize: 15.sp, // 稍微加大一点字号，更易读
        height: 1.4, // 增加行高，不仅好看也更像文章
        color: kTextColor, // 无论谁发，在深色背景下都用白色字
        fontWeight: FontWeight.w400,
      ),
    );

    // VIP 朗读逻辑判断
    // 只有当：是VIP + 不是“正在输入” + 是对方发的 + 有历史消息时 才触发
    bool enableTTS = Get.find<LayoutController>().user.value.vip &&
        message.text != "对方正在输入..." &&
        !isUser &&
        controller.messages.length >= 1;
    return textWidget;

    if (enableTTS) {
      return InkWell(
        onTap: () {
          controller.tts(textMessage.text, context);
        },
        // 使用 InkWell 配合透明材质，点击时不会有难看的水波纹背景块
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textWidget,
            // 可选：加一个小喇叭图标提示可以点击朗读（如果不想要可以删掉）
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Icon(
                Icons.volume_up_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.4),
              ),
            )
          ],
        ),
      );
    } else {}
  }

  return const SizedBox();
}
