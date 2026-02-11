import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'controller.dart';

class AiConfigV2Page extends GetView<AiConfigV2Controller> {
  const AiConfigV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.put(AiConfigV2Controller());

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. 动态背景层
          _buildAnimatedBackground(context),

          // 2. Live2D 层
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: 30.h, bottom: 200.h),
              child: Obx(() {
                final char =
                    controller.characters[controller.currentIndex.value];

                if (char.id == "Empty") {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grid_view_rounded,
                            size: 80.sp, color: Colors.white.withOpacity(0.15)),
                        SizedBox(height: 16.h),
                        Text(
                          "SYSTEM ONLINE",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 12.sp,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  );
                }

                return controller.isWebViewReady.value
                    ? WebViewWidget(controller: controller.webViewController)
                    : const Center(child: CircularProgressIndicator());
              }),
            ),
          ),

          // 3. 角色选择器 (已改造)
          _buildCharacterSelector(),

          // 4. 底部面板
          _buildBottomPanel(context, appColors, isDark),
        ],
      ),
    );
  }

  // ... _buildAnimatedBackground 和 _buildBottomPanel 保持不变 ...
  // (为了节省篇幅，这里省略了这两个方法的代码，直接用你原本的即可)

  // =========================================================
  // 🔥 核心改造区域：角色选择器
  // =========================================================
  Widget _buildCharacterSelector() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 300.h, // 根据实际布局调整位置
      child: SizedBox(
        height: 80.w, // 稍微调高一点高度
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          scrollDirection: Axis.horizontal,
          itemCount: controller.characters.length,
          separatorBuilder: (c, i) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            final char = controller.characters[index];

            // 如果是 "Empty" 角色，还是显示文字或者默认图标
            if (char.id == "Empty") {
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
                      color: char.themeColor, // 系统管家保持纯色背景
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                              color: char.themeColor.withOpacity(0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "System", // 或者 "无"
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              });
            }

            // 其他角色显示头像
            return Obx(() {
              final isSelected = controller.currentIndex.value == index;
              return GestureDetector(
                onTap: () => controller.selectCharacter(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 65.w : 55.w, // 容器多大，图片就多大
                  height: isSelected ? 65.w : 55.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // 形状：圆形
                    // 边框逻辑保持不变
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                    ],
                    // 🔥 修改点：在这里加载图片，配合 BoxFit.cover
                    image: DecorationImage(
                      image: AssetImage('assets/live2d/${char.id}.png'),
                      fit: BoxFit.cover, // 关键：充满容器并剪裁多余部分
                    ),
                  ),
                  // child 就不需要放 Image 了，除非你有其他遮罩
                ),
              );
            });
          },
        ),
      ),
    );
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
}
