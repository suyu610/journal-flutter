import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/routers.dart'; // 建议引入这个库增加文艺感

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // 3秒后跳转到主页
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAndToNamed(Routers.LayoutPageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 中间的 Logo 区域
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo 图片
                Image.asset(
                  'assets/images/logo.png', // 确保路径正确
                  width: 120, // 根据实际效果调整大小
                  height: 120,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 2. 底部的 Slogan 区域
          const Positioned(
            left: 0,
            right: 0,
            bottom: 60, // 距离底部的位置
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    '记录，构筑生活秩序',
                    style: TextStyle(
                      fontSize: 14, // 稍微小一点，显精致
                      color: Colors.black87,
                      letterSpacing: 4.0, // 关键：宽字间距增加呼吸感
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Regain order, one entry at a time.",
                    style: TextStyle(
                      fontSize: 12, // 稍微小一点，显精致
                      color: Colors.black45,
                      letterSpacing: 1.0, // 关键：宽字间距增加呼吸感
                      fontWeight: FontWeight.w300,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
