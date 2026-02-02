import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'controller.dart';

class AiConfigV2Page extends GetView<AiConfigV2Controller> {
  const AiConfigV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    // 注入 Controller
    Get.put(AiConfigV2Controller());

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. 动态背景层 (核心修改)
          _buildAnimatedBackground(),

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

          // 3. 切换按钮
          // _buildSwitchArrows(),
          _buildCharacterSelector(),
          // 4. 底部面板
          _buildBottomPanel(),
        ],
      ),
    );
  }

  // 核心修改：带动画的渐变背景
  Widget _buildAnimatedBackground() {
    return Obx(() {
      // 获取当前角色的渐变色数组
      final bgColors =
          controller.characters[controller.currentIndex.value].bgColors;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 600), // 600ms 平滑过渡
        curve: Curves.easeInOut, // 缓动曲线
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors, // 动态颜色
          ),
        ),
        child: Stack(
          children: [
            // 叠加一层顶部的聚光灯 (白色径向渐变)
            // 这样无论背景是什么颜色，头顶都有光照感
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
                      Colors.white.withOpacity(0.3), // 高光
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),

            // 叠加一层底部的深色阴影，让白色文字更清晰，同时增加空间纵深
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 300.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomPanel() {
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
              color: Colors.white.withOpacity(1), // 稍微透一点背景色出来
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                  top: BorderSide(
                      color: Colors.white.withOpacity(0.6), width: 1)),
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
                            color: Colors.black87),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: char.themeColor, // 标签颜色也跟随主题
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
                          fontSize: 13.sp, color: Colors.black54, height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),

                SizedBox(height: 20.h),

                // 输入框区域
                Row(
                  children: [
                    Expanded(
                        child:
                            _buildGlassInput("称呼", controller.nameController)),
                    SizedBox(width: 16.w),
                    Expanded(
                        child: _buildGlassInput(
                            "开场白", controller.openingController)),
                  ],
                ),

                SizedBox(height: 24.h),

                // 确认按钮
                Obx(() {
                  final char =
                      controller.characters[controller.currentIndex.value];
                  final bgColor = char.bgColors[0]; // 提取出背景色
                  final bool isLightColor = bgColor.computeLuminance() > 0.5;
                  final Color textColor =
                      isLightColor ? Colors.black87 : Colors.white;
                  return GestureDetector(
                    onTap: () => controller.saveConfig(), // 你的保存逻辑
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                          // 按钮也做成渐变，呼应背景
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
                          "确认签约 ${char.name.split('·').last}", // 只要名字后半部分
                          style: TextStyle(
                              color:
                                  textColor, // 【这里引用计算好的颜色】                              fontSize: 16.sp,
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

  // 磨砂风格输入框
  Widget _buildGlassInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black45,
                  fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1), // 极淡的灰
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            cursorColor: Colors.black54,
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

  // 2. 新增 _buildCharacterSelector 方法
  Widget _buildCharacterSelector() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 300.h, // 这里的数值取决于你的 BottomPanel 高度，根据实际调整
      child: SizedBox(
        height: 100.w, // 列表高度
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
                  width: isSelected ? 65.w : 50.w, // 选中变大
                  height: isSelected ? 65.w : 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: char.themeColor, // 使用角色主题色作为头像底色
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3) // 选中加白边
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
                  // 如果有图片资源，这里可以用 Image.asset
                  // 暂时用首字母代替
                  child: Center(
                    child: Text(
                      char.name.split('·').last, // 取名字第一个字
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
