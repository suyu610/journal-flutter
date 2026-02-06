import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
// 1. 引入你的主题定义
import 'package:journal/core/app_theme_colors.dart';
import 'controller.dart';

class AiConfigV2Page extends GetView<AiConfigV2Controller> {
  const AiConfigV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 获取当前主题颜色配置
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.put(AiConfigV2Controller());

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // 这里的背景色其实会被 Stack 里的 AnimatedContainer 盖住，但作为底色兜底
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 返回按钮：在深色遮罩上白色比较清晰，或者也可以用 primaryText
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. 动态背景层 (带深色模式压暗逻辑)
          _buildAnimatedBackground(context),

          // 2. Live2D 层
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: 30.h, bottom: 200.h),
              child: Obx(() => controller.isWebViewReady.value
                  ? WebViewWidget(controller: controller.webViewController)
                  : const Center(
                      child: CircularProgressIndicator(),
                    )),
            ),
          ),

          // 3. 角色选择器
          _buildCharacterSelector(),

          // 4. 底部面板 (传入 appColors)
          _buildBottomPanel(context, appColors, isDark),
        ],
      ),
    );
  }

  // 核心修改：带动画的渐变背景 + 深色模式“墨镜”处理
  Widget _buildAnimatedBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final bgColors =
          controller.characters[controller.currentIndex.value].bgColors;

      return Stack(
        children: [
          // 原始渐变层
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
          ),

          // 【新增】深色模式滤镜层
          // 既然觉得粉色太扎眼，就在上面盖一层半透明的黑色
          // 这样既保留了角色的主题色调，又不会像开灯一样亮
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            color: isDark
                ? Colors.black.withOpacity(0.4) // 深色模式压暗 40%
                : Colors.transparent,
          ),

          // 顶部高光 (保持)
          Positioned(
            top: -150,
            left: 0,
            right: 0,
            height: 600,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.7,
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.1 : 0.3), // 深色模式下高光也弱一点
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBottomPanel(
      BuildContext context, AppThemeColors appColors, bool isDark) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
            decoration: BoxDecoration(
              // 【核心修改】：背景色使用 cardBackground，并带一点透明度
              color: appColors.cardBackground.withOpacity(isDark ? 0.85 : 0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                  top: BorderSide(
                      // 边框颜色适配：深色模式用极淡的白，浅色模式用极淡的黑
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.6),
                      width: 1)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部：名字 + 性格标签
                Obx(() {
                  final char =
                      controller.characters[controller.currentIndex.value];
                  return Row(
                    children: [
                      Text(
                        char.name,
                        style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            // 【核心修改】：字体颜色跟随主题
                            color: appColors.primaryText),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: char.themeColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: char.themeColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Text(
                          char.defaultPersonality,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  );
                }),

                SizedBox(height: 12.h),

                // 描述文本
                Obx(() => Text(
                      controller.characters[controller.currentIndex.value]
                          .description,
                      style: TextStyle(
                          fontSize: 13.sp,
                          // 【核心修改】：次要文本颜色
                          color: appColors.secondaryText,
                          height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),

                SizedBox(height: 20.h),

                // 输入框区域
                Row(
                  children: [
                    Expanded(
                        child: _buildGlassInput(
                            "称呼", controller.nameController, appColors)),
                    SizedBox(width: 16.w),
                    Expanded(
                        child: _buildGlassInput(
                            "开场白", controller.openingController, appColors)),
                  ],
                ),

                SizedBox(height: 24.h),

                // 确认按钮
                Obx(() {
                  final char =
                      controller.characters[controller.currentIndex.value];
                  final bgColor = char.bgColors[0];
                  // 按钮逻辑保持不变，因为它是彩色的，但在深色模式下阴影可以调整一下
                  final bool isLightColor = bgColor.computeLuminance() > 0.5;
                  final Color textColor =
                      isLightColor ? Colors.black87 : Colors.white;

                  return GestureDetector(
                    onTap: () => controller.saveConfig(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                                color: bgColor
                                    .withOpacity(isLightColor ? 0.6 : 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6))
                          ]),
                      child: Center(
                        child: Text(
                          "确认签约 ${char.name.split('·').last}",
                          style: TextStyle(
                              color: textColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 磨砂风格输入框 - 适配主题色
  Widget _buildGlassInput(String label, TextEditingController controller,
      AppThemeColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12.sp,
                  // 【核心修改】：标签使用次要文本色
                  color: appColors.secondaryText,
                  fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            // 【核心修改】：背景色改为 primaryText 的极低透明度，这样深浅模式下都是淡淡的灰/白
            color: appColors.primaryText.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appColors.primaryText.withOpacity(0.05)),
          ),
          child: TextField(
            controller: controller,
            // 【核心修改】：输入文字颜色
            style: TextStyle(fontSize: 14.sp, color: appColors.primaryText),
            // 光标颜色
            cursorColor: appColors.primaryText,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            ),
          ),
        ),
      ],
    );
  }

  // 角色选择器保持不变，它的白色边框在深色模式下效果很好
  Widget _buildCharacterSelector() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 300.h,
      child: SizedBox(
        height: 100.w,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          scrollDirection: Axis.horizontal,
          itemCount: controller.characters.length,
          separatorBuilder: (c, i) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            final char = controller.characters[index];
            return Obx(() {
              final isSelected = controller.currentIndex.value == index;
              return GestureDetector(
                onTap: () => controller.selectCharacter(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 65.w : 50.w,
                  height: isSelected ? 65.w : 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: char.themeColor,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: char.themeColor.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      char.name.split('·').last,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSelected ? 14.sp : 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
