import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/util/sp_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/voice_touch_point_change.dart';
import 'package:journal/util/keyboard_util.dart';
import '../controller.dart';

// --------------------------------------------------------------------------
// 组件：带毛玻璃效果的悬浮输入框
// --------------------------------------------------------------------------
Widget buildFloatingInput(BuildContext context) {
  ChatController controller = Get.find<ChatController>();
  bool voiceLongPress = false;
  bool canPass = false;

  return Container(
    padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).padding.bottom + 12.h, // 适配 iPhone 底部黑条
        top: 12.h),
    color: Colors.transparent,
    child: Obx(() {
      bool isKeyboard = controller.keyboardMode.value;
      return Row(
        children: [
          // 输入条胶囊
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: !isKeyboard
                        ? Colors.transparent
                        : const Color(0xFF2E2E3E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25),
                    border: isKeyboard
                        ? Border.all(
                            color: Colors.white.withOpacity(0.1), width: 1)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8.w),
                      // 切换键盘/语音按钮
                      GestureDetector(
                        onTap: () {
                          controller.keyboardMode.value =
                              !controller.keyboardMode.value;
                          SpUtil.setKeyboardMode(controller.keyboardMode.value);
                          if (!controller.keyboardMode.value) {
                            KeyboardUtils.hideKeyboard(context);
                          } else {
                            controller.textEditingController.clear();
                            controller.focusNode.requestFocus();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isKeyboard
                                ? Colors.transparent
                                : const Color(0xFF2E2E3E).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: isKeyboard
                              ? const EdgeInsets.all(8)
                              : const EdgeInsets.all(12),
                          margin: isKeyboard
                              ? EdgeInsets.zero
                              : EdgeInsets.only(right: 8.w),
                          child: Icon(
                            isKeyboard
                                ? Icons.keyboard_voice_rounded
                                : Icons.keyboard_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 24,
                          ),
                        ),
                      ),

                      // 输入区域
                      Expanded(
                        child: isKeyboard
                            ? _buildTextField(context)
                            : _buildVoiceButton(
                                context,
                                (move) {
                                  // onPointerMove
                                  if (canPass &&
                                      voiceLongPress &&
                                      !voiceSendEnough) {
                                    eventBus.fire(VoiceTouchPointChange(
                                        move.localPosition,
                                        VoiceMessageSendWidgetStatus
                                            .recording));
                                  }
                                },
                                (event) {
                                  // onPointerUp
                                  voiceLongPress = false;
                                  controller.isLongPressing.value = false;
                                  eventBus.fire(VoiceTouchPointChange(
                                      null, VoiceMessageSendWidgetStatus.end));
                                },
                                (details) {
                                  controller.isLongPressing.value = true;
                                  HapticFeedback.lightImpact();
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    voiceSendEnough = false;
                                    canPass = true;
                                    eventBus.fire(VoiceTouchPointChange(
                                        null,
                                        VoiceMessageSendWidgetStatus
                                            .recording));
                                    voiceLongPress = true;
                                  });
                                },
                              ),
                      ),

                      // 表情按钮 (仅键盘模式)
                      if (isKeyboard) ...[
                        Icon(Icons.emoji_emotions_outlined,
                            color: Colors.white.withOpacity(0.5), size: 22),
                        SizedBox(width: 12.w),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 发送按钮 (仅键盘模式)
          if (isKeyboard) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () {
                controller.handleSendPressed(
                    types.PartialText(
                        text: controller.textEditingController.text),
                    context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50.h,
                height: 50.h,
                decoration: BoxDecoration(
                    color: const Color(0xFF2E2E3E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25), // 变成圆形更好看
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E2E3E).withOpacity(0.13),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]),
                child:
                    const Icon(Icons.arrow_upward_rounded, color: Colors.white),
              ),
            )
          ]
        ],
      );
    }),
  );
}

Widget _buildTextField(BuildContext context) {
  ChatController controller = Get.find<ChatController>();
  return Obx(() {
    final themeColor = controller.currentCharacter.value?.themeColor ??
        const Color(0xFF667EEA);
    return TextField(
      controller: controller.textEditingController,
      focusNode: controller.focusNode,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: themeColor,
      decoration: InputDecoration(
        hintText: "说点什么...",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      onSubmitted: (text) {
        controller.handleSendPressed(types.PartialText(text: text), context);
      },
      // 禁用 iOS 原生菜单防止遮挡
      contextMenuBuilder: (context, editableTextState) {
        final List<ContextMenuButtonItem> buttonItems =
            editableTextState.contextMenuButtonItems;
        buttonItems.removeWhere((ContextMenuButtonItem buttonItem) {
          return buttonItem.type == ContextMenuButtonType.liveTextInput;
        });
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: buttonItems,
        );
      },
    );
  });
}

Widget _buildVoiceButton(
  BuildContext context,
  Function(PointerMoveEvent) onPointerMove,
  Function(PointerUpEvent) onPointerUp,
  Function(LongPressDownDetails) onLongPressDown,
) {
  ChatController controller = Get.find<ChatController>();
  return Listener(
    onPointerMove: onPointerMove,
    onPointerUp: onPointerUp,
    child: GestureDetector(
      onLongPressDown: onLongPressDown,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E2E3E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        height: 50.h,
        alignment: Alignment.center,
        child: Obx(() => Text(
              controller.isLongPressing.value ? '松手 发送' : '按住 说话',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: controller.isLongPressing.value
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            )),
      ),
    ),
  );
}
