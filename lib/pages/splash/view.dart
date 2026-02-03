import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于控制状态栏
import 'package:get/get.dart';
import 'package:journal/routers.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<Offset> _textSlideAnim;
  late Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();

    // 0. 沉浸式状态栏 (让背景白到底，不留黑边)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // 黑色图标
    ));

    // 1. 初始化动画控制器 (总时长 2秒)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 2. 定义动画 (交错执行)

    // Logo: 0ms ~ 800ms，带弹性的缩放
    _logoScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack), // 重点：回弹曲线
      ),
    );
    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Slogan: 600ms ~ 1400ms，从下往上浮出
    _textSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutQuart),
      ),
    );
    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    // 3. 启动动画并在结束后跳转
    _controller.forward().then((_) async {
      // 稍微停顿一下，让用户看清 Slogan
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAndToNamed(Routers.LayoutPageUrl);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 或者 Color(0xFFF9F9F9) 稍微带点灰更有质感
      body: Stack(
        fit: StackFit.expand,
        children: [
          // A. 中间 Logo 区域
          Center(
            child: FadeTransition(
              opacity: _logoFadeAnim,
              child: ScaleTransition(
                scale: _logoScaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 这里换成你的 Logo
                    // 如果你的logo只是文字，建议直接用 Image，保证字体渲染一致性
                    Image.asset(
                      'assets/images/logo.png',
                      width: 100, // 不宜过大，精致为主
                      height: 100,
                    ),
                    // 如果 Logo 自带文字，下面这个 SizedBox 不需要太大
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // B. 底部 Slogan 区域 (带上浮动画)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 60, // 适配全面屏底部
            child: SlideTransition(
              position: _textSlideAnim,
              child: FadeTransition(
                opacity: _textFadeAnim,
                child: Column(
                  children: [
                    // 中文 Slogan
                    const Text(
                      '记录，构筑生活秩序',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC', // 最好指定一个好看的字体，或者系统默认
                        fontSize: 13,
                        color: Colors.black87,
                        letterSpacing: 6.0, // 极宽字间距，这是高级感的来源
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 英文 Slogan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 装饰线条 (左)
                        Container(width: 20, height: 1, color: Colors.black12),
                        const SizedBox(width: 10),
                        const Text(
                          "Regain order, one entry at a time.",
                          style: TextStyle(
                            fontFamily: 'Courier', // 使用等宽字体呼应“小票”概念
                            fontSize: 10,
                            color: Colors.black45,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 装饰线条 (右)
                        Container(width: 20, height: 1, color: Colors.black12),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
