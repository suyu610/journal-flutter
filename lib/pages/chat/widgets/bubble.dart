import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/theme/base/brn_default_config_utils.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'expense_message.dart';

Widget buildBubble(
  Widget child,
  controller, {
  required types.Message message,
  required nextMessageInGroup,
}) =>
    Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (message.author.id != controller.user.id &&
            message.type == MessageType.custom &&
            message.metadata!['msgType'] == "expense")
          const SizedBox(),
        Bubble(
          showNip: true,
          nip: message.author.id == controller.user.id
              ? BubbleNip.rightBottom
              : BubbleNip.leftBottom,
          padding: BubbleEdges.symmetric(horizontal: 12.0.w, vertical: 12.h),
          borderWidth: 1,
          borderColor: const Color(0xfff3f3f3),
          color: message.author.id != controller.user.id
              ? Colors.white
              : BrnDefaultConfigUtils.defaultCommonConfig.brandPrimary,
          shadowColor: const Color.fromARGB(84, 243, 243, 243),
          child: _buildMessage(message, controller, Get.context!),
        ),
      ],
    );

// 普通消息
_buildMessage(types.Message message, controller, context) {
  if (message.type == types.MessageType.custom &&
      message.metadata!['msgType'] == "expense") {
    return buildExpenseMessage(message, controller, context);
  }
  if (message.type == types.MessageType.text) {
    // cast
    var textMessage = message as types.TextMessage;
    if (Get.find<LayoutController>().user.value.vip &&
        message.text != "对方正在输入..." &&
        message.author.id != controller.user.id &&
        controller.messages.length > 1) {
      return GestureDetector(
        onTap: () {
          // 点一下朗读
          if (message.author.id != controller.user.id) {
            controller.tts(textMessage.text, context);
          }
        },
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              child: Text(
                textMessage.text,
                style: TextStyle(
                    fontSize: 14,
                    color: message.author.id != controller.user.id
                        ? Colors.black
                        : Colors.white),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      );
    } else {
      return Text(
        textMessage.text,
        style: TextStyle(
            fontSize: 14,
            color: message.author.id != controller.user.id
                ? Colors.black
                : Colors.white),
      );
    }
  }
}
