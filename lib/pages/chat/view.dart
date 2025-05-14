import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:journal/components/voice_record/message_voice_send_widget.dart';
import 'package:journal/pages/chat/widgets/bubble.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'index.dart';
import 'widgets/appbar.dart';
import 'widgets/avatar.dart';
import 'widgets/bg_image.dart';
import 'widgets/bottom.dart';

class ChatPage extends GetView<ChatController> {
  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      init: ChatController(),
      id: "chat",
      builder: (_) {
        return Obx(() => Scaffold(
              backgroundColor: controller.isLongPressing.value
                  ? const Color(0xffcecece)
                  : Colors.white,
              appBar: buildAppbar(context, controller),
              body: SafeArea(child: _buildView(context)),
            ));
      },
    );
  }

  // 主视图
  Widget _buildView(BuildContext context) {
    return Stack(
      children: [
        // 背景图
        buildBgImage(controller, context),
        chatView(controller, context),
        VoiceMessageSendWidget((cancel, text, seconds) {
          if (cancel == true || text == "") {
            return;
          }
          controller.handleSendPressed(PartialText(text: text));
        })
      ],
    );
  }
}

// 聊天主主体
Chat chatView(ChatController controller, BuildContext context) {
  return Chat(
    // 聊天气泡
    bubbleBuilder: (Widget widget,
        {required types.Message message, required bool nextMessageInGroup}) {
      return buildBubble(widget, controller,
          message: message, nextMessageInGroup: nextMessageInGroup);
    },
    messages: controller.messages,
    onSendPressed: controller.handleSendPressed,
    showUserAvatars: true,
    showUserNames: true,
    l10n: const ChatL10nZhCN(),
    user: controller.user,
    groupMessagesThreshold: 1,
    bubbleRtlAlignment: BubbleRtlAlignment.left,
    avatarBuilder: (author) => buildAvatar(author),
    dateFormat: DateFormat('yyyy-MM-dd'),
    timeFormat: DateFormat('HH:mm'),
    // 底部功能区
    customBottomWidget: buildBottomWidget(controller, context),
    theme: THEME(controller),
  );
}

// ignore: non_constant_identifier_names
ChatTheme THEME(ChatController controller) {
  return DefaultChatTheme(
    attachmentButtonMargin: EdgeInsets.zero,
    sendButtonMargin: EdgeInsets.zero,
    primaryColor: const Color(0xff02a2a2),
    sendButtonIcon: Container(
      height: 0,
    ),
    inputTextColor: Colors.black,
    inputElevation: 1,
    inputPadding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 5.w),
    inputTextStyle: const TextStyle(
      fontSize: 16.0,
    ),
    backgroundColor: controller.bgImage.value.isEmpty
        ? const Color(0xfff3f3f3)
        : Colors.transparent,
    inputBorderRadius: const BorderRadius.all(Radius.circular(0)),
    messageBorderRadius: 4,
    dateDividerTextStyle: const TextStyle(
      color: Color(0xFF666666),
      fontSize: 12,
      fontFamily: 'SourceCodePro',
      fontWeight: FontWeight.w400,
      height: 1,
    ),
    dateDividerMargin: const EdgeInsets.symmetric(vertical: 16),
    bubbleMargin: const EdgeInsets.only(left: 16, right: 0),
  );
}
