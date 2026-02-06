import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/chat/widgets/appbar.dart';
import 'package:journal/pages/chat/widgets/bottom.dart';

import 'package:journal/services/local_server.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:journal/components/voice_record/message_voice_send_widget.dart';
import 'package:journal/pages/chat/widgets/bubble.dart';
import 'index.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 设置状态栏
    SystemChrome.setSystemUIOverlayStyle(
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return GetBuilder<ChatController>(
      init: ChatController(),
      id: "chat",
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: buildTransparentAppBar(context, appColors, isDark),
          body: Stack(
            children: [
              // ==============================
              // 1. 背景层：动态渐变 + 智能遮罩
              // ==============================
              Positioned.fill(
                child: Obx(() {
                  // 获取角色背景色，如果没有则兜底
                  final List<Color> bgColors =
                      controller.currentCharacter.value?.bgColors ??
                          [
                            Theme.of(context).scaffoldBackgroundColor,
                            Theme.of(context).scaffoldBackgroundColor,
                          ];

                  return Stack(
                    children: [
                      // 1.1 原始彩色渐变
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: bgColors.length >= 2
                                ? bgColors
                                : [bgColors.first, bgColors.first],
                          ),
                        ),
                      ),

                      // 1.2 深色模式滤镜 (核心修改)
                      // 深色模式下盖一层半透明黑，压住刺眼的亮色
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        color: isDark
                            ? Colors.black.withOpacity(0.6) // 压暗 60%
                            : Colors.transparent,
                      ),

                      // 1.3 底部遮罩 (让底部输入框区域文字更清晰)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              // 深色模式下底部更黑一点
                              (isDark ? Colors.black : Colors.white)
                                  .withOpacity(0.0),
                              (isDark ? Colors.black : Colors.white)
                                  .withOpacity(isDark ? 0.8 : 0.4),
                            ],
                            stops: const [0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),

              // ==============================
              // 1.1 氛围光 (优化版)
              // ==============================
              Positioned(
                top: 80.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(() {
                    final originColor =
                        controller.currentCharacter.value?.themeColor ??
                            const Color(0xFFFF9A9E);

                    // 计算光晕颜色
                    Color glowColor;
                    double glowOpacity;

                    if (isDark) {
                      // 深色模式：颜色与黑色混合，降低饱和度
                      glowColor = Color.lerp(originColor, Colors.black, 0.5)!;
                      glowOpacity = 0.2; // 极其微弱的光，避免光污染
                    } else {
                      glowColor = originColor;
                      glowOpacity = 0.4;
                    }

                    return ImageFiltered(
                      imageFilter:
                          ImageFilter.blur(sigmaX: 60, sigmaY: 60), // 模糊度加大
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        width: 300.w,
                        height: 300.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: glowColor.withOpacity(glowOpacity),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // ==============================
              // 2. Live2D 人物层
              // ==============================
              Obx(() => Positioned(
                    top: 120.h,
                    left: 0,
                    right: 0,
                    height: 0.65.sh,
                    child: controller.isModelLoaded.value
                        ? live2D("${LocalServer.baseUrl}/index.html")
                        : const SizedBox(),
                  )),

              // ==================== 顶部状态气泡 ====================
              Positioned(
                top: 60.h,
                left: 40.w,
                right: 40.w,
                child: Obx(() => AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: controller.isBubbleVisible.value ? 1.0 : 0.0,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              // 深色模式下背景稍微实一点，提高可读性
                              color: appColors.cardBackground
                                  .withOpacity(isDark ? 0.95 : 0.85),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1), // 阴影加深
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                              border: Border.all(
                                  color:
                                      appColors.primaryText.withOpacity(0.05),
                                  width: 1),
                            ),
                            child: Text(
                              controller.bubbleText.value,
                              style: TextStyle(
                                color: appColors.primaryText,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: "ZCOOLKuaiLle",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )),
              ),

              // ==============================
              // 5. 聊天内容列表
              // ==============================
              Positioned.fill(
                top: 110.h,
                bottom: 100.h,
                child: ShaderMask(
                  // 顶部渐隐遮罩：使用 Alpha 通道遮罩
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black
                      ], // 这里的颜色本身不重要，重要的是Alpha
                      stops: [0.0, 0.1, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Obx(() => Chat(
                        messages: controller.messages,
                        onSendPressed: (types.PartialText text) =>
                            controller.handleSendPressed(text, context),
                        user: controller.user,
                        showUserAvatars: false,
                        showUserNames: false,
                        bubbleBuilder: (Widget widget,
                            {required types.Message message,
                            required bool nextMessageInGroup}) {
                          return buildBubble(widget, controller,
                              message: message,
                              nextMessageInGroup: nextMessageInGroup);
                        },
                        // 主题适配
                        theme: _buildCozyTheme(context, appColors, isDark),
                        customBottomWidget: const SizedBox(),
                      )),
                ),
              ),

              // ==============================
              // 6. 语音组件
              // ==============================
              VoiceMessageSendWidget((cancel, text, seconds) {
                if (cancel == true || text == "") return;
                controller.handleSendPressed(
                    types.PartialText(text: text), context);
              }),

              // ==============================
              // 7. 底部浮动输入框
              // ==============================
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: buildFloatingInput(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 主题配置：适配深浅模式
  // --------------------------------------------------------------------------
  ChatTheme _buildCozyTheme(
      BuildContext context, AppThemeColors appColors, bool isDark) {
    final char = controller.currentCharacter.value;

    // 1. 发送方 (用户)
    Color userBubbleColor = char?.themeColor ?? appColors.mainButtonBg;
    // 智能计算文字颜色：如果气泡颜色太亮，文字就用黑，否则用白
    bool isBubbleLight = userBubbleColor.computeLuminance() > 0.5;
    Color userTextColor =
        isBubbleLight ? Colors.black.withOpacity(0.8) : Colors.white;

    // 2. 接收方 (AI)
    // 深色模式：使用卡片背景色 (深灰)，亮色模式：半透明白
    Color aiBubbleColor = isDark
        ? appColors.cardBackground.withOpacity(0.9)
        : Colors.white.withOpacity(0.95);

    // 接收方文字颜色
    Color aiTextColor = appColors.primaryText;

    return DefaultChatTheme(
      emptyChatPlaceholderTextStyle: const TextStyle(
        color: Colors.transparent,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.transparent,

      // --- 接收方 (AI) ---
      secondaryColor: aiBubbleColor,
      receivedMessageBodyTextStyle: TextStyle(
        color: aiTextColor,
        fontSize: 15,
        height: 1.5,
      ),

      // --- 发送方 (用户) ---
      primaryColor: userBubbleColor,
      sentMessageBodyTextStyle: TextStyle(
        color: userTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),

      // 细节微调
      messageBorderRadius: 20,
      messageInsetsHorizontal: 16,
      messageInsetsVertical: 12,
      // 日期分割线
      dateDividerTextStyle: TextStyle(
          color: appColors.secondaryText.withOpacity(0.6),
          fontSize: 11,
          fontWeight: FontWeight.w500),
      inputBackgroundColor: Colors.transparent,
    );
  }

  Widget live2D(String url) {
    WebViewController webController = controller.webViewController;
    return WebViewWidget(controller: webController);
  }
}
