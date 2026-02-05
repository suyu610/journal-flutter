import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/pages/chat/widgets/bottom.dart';

import 'package:journal/services/local_server.dart';
import 'package:webview_flutter/webview_flutter.dart';
// 保持你原有的引用
import 'package:journal/components/voice_record/message_voice_send_widget.dart';
import 'package:journal/pages/chat/widgets/bubble.dart';
import 'index.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 设置状态栏文字为白色（适应深色背景）
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return GetBuilder<ChatController>(
      init: ChatController(),
      id: "chat",
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: false, // 基础底色：深邃夜空蓝，防止加载时闪白屏
          backgroundColor: const Color(0xFF1A1A2E),
          extendBodyBehindAppBar: true,
          appBar: _buildTransparentAppBar(context),
          body: Stack(
            children: [
              // ==============================
              // 1. 背景层：温馨的星空/极光渐变
              // ==============================
              Positioned.fill(
                child: Obx(() {
                  final bgColors =
                      controller.currentCharacter.value?.bgColors ??
                          [
                            const Color(0xFF2E335A), // 顶部：深紫蓝 (更有二次元夜晚感)
                            const Color(0xFF1C1B33), // 中部：过渡深色
                            const Color(0xFF000000), // 底部：纯黑 (保证输入框清晰)
                          ];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: bgColors.length == 2
                            ? [
                                ...bgColors,
                              ] // 强制加一个黑色底部，保证输入框清晰
                            : bgColors,
                      ),
                    ),
                    // 叠加一层黑色遮罩在底部，保证输入框区域的可读性
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.5, 0.8, 1.0],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // ==============================
              // 1.1 氛围光 (关键：增加温馨感)
              // ==============================
              // 在人物背后加一个淡淡的暖色光晕，像是一个温暖的灵魂
              // ==============================
// 1.1 氛围光 (优化版：极致柔和)
// ==============================
              Positioned(
                top: 100.h, //稍微上移一点，让光更自然地散落在头部周围
                left: 0,
                right: 0,
                // 不需要限制 height，让光自由发散
                child: Center(
                  child: Obx(() {
                    final themeColor =
                        controller.currentCharacter.value?.themeColor ??
                            const Color(0xFFFF9A9E);
                    return ImageFiltered(
                      imageFilter: ImageFilter.blur(
                          sigmaX: 20, sigmaY: 20), // 大数值模糊，消除一切硬边
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 800), // 变色更慢一点，更柔
                        curve: Curves.easeOutQuart,
                        width: 280.w,
                        height: 280.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // 关键修改 2: 使用纯色混合模式或简单的 BoxShadow 模拟核心光
                          // 这里的渐变用于制造光的层次
                          gradient: RadialGradient(
                            colors: [
                              themeColor.withOpacity(0.8), // 中心稍微亮一点
                              Colors.white.withOpacity(0.2), // 中间过渡
                              Colors.transparent, // 边缘完全消失
                            ],
                            stops: const [0.0, 0.4, 1.0], // 控制光晕的扩散范围
                            radius: 0.8,
                          ),
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
                    top: 120.h, // 稍微上移，让人物占据上半部分
                    left: 0,
                    right: 0,
                    // 根据你的模型调整高度，通常占屏幕一半多一点
                    height: 0.65.sh,
                    child: controller.isModelLoaded.value
                        ? live2D("${LocalServer.baseUrl}/index.html")
                        : const SizedBox(),
                  )),

              // ==================== 新增：游戏风格对话气泡层 ====================
              // 位置：放在 Live2D 头部上方 (根据 top: 110.h 估算，头部大概在 120-150 左右，气泡放在 60-80)
              Positioned(
                top: 60.h,
                left: 40.w, // 左右留出边距，防止贴边
                right: 40.w,
                child: Obx(() => AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: controller.isBubbleVisible.value ? 1.0 : 0.0,
                      child: Column(
                        children: [
                          // 气泡本体
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95), // 稍微一点点透
                              borderRadius:
                                  BorderRadius.circular(20), // 圆润的游戏风格
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                              border: Border.all(
                                  color: const Color(0xFFE0E0E0), width: 1),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.bubbleText.value,
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500, // 加粗一点，像游戏字幕
                                    fontFamily: "ZCOOLKuaiLle", // 如果你有圆体字库更好
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
                top: 110.h, // 避开头部区域
                bottom: 100.h, // 避开底部输入框
                child: ShaderMask(
                  // 顶部边缘渐隐遮罩：让消息向上滚动时慢慢消失，而不是生硬切断
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white, Colors.white],
                      stops: [0.0, 0.15, 1.0],
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
                        // 自定义气泡构建
                        bubbleBuilder: (Widget widget,
                            {required types.Message message,
                            required bool nextMessageInGroup}) {
                          return buildBubble(widget, controller,
                              message: message,
                              nextMessageInGroup: nextMessageInGroup);
                        },
                        // 使用下方定义的温馨暗黑主题
                        theme: _buildCozyDarkTheme(),
                        customBottomWidget: const SizedBox(), // 底部留空，我们自己做浮动的
                      )),
                ),
              ),

              // ==============================
              // 6. 语音录制组件
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
  // 组件：透明 AppBar (带状态指示)
  // --------------------------------------------------------------------------
  AppBar _buildTransparentAppBar(context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      forceMaterialTransparency: true,
      elevation: 0,
      centerTitle: true,
      // title: Column(
      //   children: [
      //     Text(
      //       controller.activity.value.activityName,
      //       style: TextStyle(color: Colors.white, fontSize: 14.sp, shadows: [
      //         Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)
      //       ]),
      //     ),
      //   ],
      // ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () {
          print("推出聊天页面");
          Get.back();
        },
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.more_horiz, color: Colors.white),
      //     onPressed: () {
      //       Get.toNamed(Routers.CreateActivityUrl,
      //           arguments: controller.currentActivity.value);
      //     },
      //   )
      // ],
    );
  }

  // --------------------------------------------------------------------------
  // 主题配置：温馨暗色调
  // --------------------------------------------------------------------------
  ChatTheme _buildCozyDarkTheme() {
    // 1. 安全获取当前角色
    final char = controller.currentCharacter.value;
    // 2. 智能取色逻辑：优先取背景渐变的第一个颜色（通常更鲜艳适合做气泡），如果没有则用主题色
    Color activeColor = char?.bgColors.isNotEmpty == true
        ? char!.bgColors.first
        : (char?.themeColor ?? const Color(0xFF667EEA));
    // 3. 智能文字反色：计算背景亮度，如果太亮，文字就用黑色
    bool isLightColor = activeColor.computeLuminance() > 0.5;
    Color textColor =
        isLightColor ? Colors.black.withOpacity(0.8) : Colors.white;

    return DefaultChatTheme(
      emptyChatPlaceholderTextStyle: const TextStyle(
        color: Colors.transparent,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.transparent,

      // 机器人气泡：半透明的深色，带一点紫灰，不突兀
      secondaryColor: const Color(0xFF1E1E1E).withOpacity(0.8),
      receivedMessageBodyTextStyle: const TextStyle(
        color: Color(0xFFEBEBEB),
        fontSize: 15,
        height: 1.4,
      ),

      // 用户气泡（发送）：使用角色的“主氛围色”
      primaryColor: activeColor,
      sentMessageBodyTextStyle: TextStyle(
        color: textColor, // <--- 动态文字颜色
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),

      // 细节优化
      messageBorderRadius: 16,
      messageInsetsHorizontal: 14,
      messageInsetsVertical: 10,
      dateDividerTextStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 10,
          fontWeight: FontWeight.w500),
      inputBackgroundColor: Colors.transparent,
    );
  }

  // --------------------------------------------------------------------------
  // Live2D WebView
  // --------------------------------------------------------------------------
  Widget live2D(String url) {
    WebViewController webController = controller.webViewController;
    // 赋值给 controller 方便调用
    return WebViewWidget(controller: webController);
  }
}
