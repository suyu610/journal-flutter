import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/mission_dashboard/controller.dart';
import 'package:journal/services/voice_service.dart';

class VoiceAssistantButton extends GetView<MissionController> {
  const VoiceAssistantButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final VoiceService voiceService = controller.voiceService;

    return Positioned(
      right: 20,
      bottom: 20,
      child: Obx(() {
        bool isListening = voiceService.isListening.value;
        String resultText = voiceService.textResult.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 实时显示的语音气泡
            if (isListening && resultText.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12, right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                constraints: const BoxConstraints(maxWidth: 200),
                decoration: BoxDecoration(
                  color: appColors.cardBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  resultText,
                  style: TextStyle(color: appColors.primaryText, fontSize: 14),
                ),
              ),

            // 带有呼吸效果的按钮
            GestureDetector(
              // 长按模式（推荐）：按下开始听，松开结束
              onLongPressStart: (_) {
                voiceService.startListening(onResult: (text) {
                  // 这里只负责更新 UI 显示，具体的指令分析交给 Controller 的防抖逻辑，或者松手时处理
                  controller.processVoiceCommand(text);
                });
              },
              onLongPressEnd: (_) {
                voiceService.stopListening();
              },
              // 点击模式：点一下开始，检测到停顿自动结束
              onTap: () {
                if (isListening) {
                  voiceService.stopListening();
                } else {
                  voiceService.startListening(onResult: (text) {
                    controller.processVoiceCommand(text);
                  });
                }
              },
              child: AvatarGlow(
                animate: isListening,
                glowColor: appColors.primaryText,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isListening
                        ? appColors.primaryText
                        : appColors.cardBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none_outlined,
                    color: isListening
                        ? appColors.backgroundColor
                        : appColors.primaryText,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
