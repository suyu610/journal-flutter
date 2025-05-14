import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/voice_touch_point_change.dart';
import 'package:journal/util/keyboard_util.dart';
import '../controller.dart';

Widget buildBottomWidget(ChatController controller, BuildContext context) {
  bool voiceLongPress = false; //是否长按了 按住说话
  bool canPass = false;

  return Container(
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.all(12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(width: 0.50, color: Color(0xFFE7E7E7)),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Obx(() {
            bool isLongPressing = controller.isLongPressing.value;
            return controller.keyboardMode.value
                ? Container(
                    height: 42,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: controller.keyboardMode.value
                          ? const Color(0xFFF3F3F3)
                          : (isLongPressing
                              ? const Color(0xFFE0E0E0)
                              : const Color(0xFFF3F3F3)),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFDCDCDC)),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: TDInput(
                      controller: controller.textEditingController,
                      focusNode: controller.focusNode,
                      inputAction: TextInputAction.send,
                      maxLines: 1,
                      width: 385.w,
                      cursorColor: const Color(0xFF0064FF),
                      contentPadding: const EdgeInsets.only(
                          left: 16, bottom: 8, top: 8, right: 8),
                      textStyle: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                        fontSize: 16,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                      ),
                      onSubmitted: (text) {
                        controller.handleSendPressed(PartialText(text: text));
                      },
                    ))
                : Listener(
                    onPointerMove: (PointerMoveEvent move) {
                      if (canPass == true &&
                          voiceLongPress == true &&
                          voiceSendEnough == false) {
                        eventBus.fire(VoiceTouchPointChange(move.localPosition,
                            VoiceMessageSendWidgetStatus.recording));
                      }
                    },
                    onPointerUp: (PointerUpEvent event) {
                      voiceLongPress = false;
                      controller.isLongPressing.value = false;
                      eventBus.fire(VoiceTouchPointChange(
                          null, VoiceMessageSendWidgetStatus.end));
                    },
                    child: GestureDetector(
                      onLongPressDown: (LongPressDownDetails details) async {
                        controller.isLongPressing.value = true;
                        Future.delayed(const Duration(milliseconds: 1), () {
                          HapticFeedback.lightImpact();
                        });
                        Future.delayed(const Duration(milliseconds: 2), () {
                          voiceSendEnough = false;
                          canPass = true;
                          eventBus.fire(VoiceTouchPointChange(
                              null, VoiceMessageSendWidgetStatus.recording));
                          voiceLongPress = true;
                        });
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: controller.keyboardMode.value
                              ? const Color(0xFFF3F3F3)
                              : (isLongPressing
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFFF3F3F3)),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFFDCDCDC)),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '长按识别',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.9),
                              fontSize: 16,
                              fontFamily: 'PingFang SC',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
          }),
        ),
        Visibility(
            visible: PlatformUtil.isIOS, child: const SizedBox(width: 12)),
        Visibility(
          visible: PlatformUtil.isIOS,
          child: GestureDetector(
            onTap: () {
              controller.keyboardMode.value = !controller.keyboardMode.value;
              if (!controller.keyboardMode.value) {
                KeyboardUtils.hideKeyboard(context);
              } else {
                controller.focusNode.requestFocus();
              }
            },
            child: Obx(() => Icon(
                  controller.keyboardMode.value
                      ? Icons.keyboard_voice
                      : Icons.keyboard,
                  size: 24,
                  color: Colors.black.withOpacity(0.9),
                )),
          ),
        ),
      ],
    ),
  );
}
