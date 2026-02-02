import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/basic.dart' as basic;

// --- 全局配置 ---
const double kPhysicScale = 1.0;
const double kJarWidthPixels = 300.0;
const double kJarHeightPixels = 380.0;

const double kJarWidthMeters = kJarWidthPixels / kPhysicScale;
const double kJarHeightMeters = kJarHeightPixels / kPhysicScale;

// --- 新的配色方案 (暖色调/卡通感) ---
class CuteColors {
  // 背景更暖
  static const Color backgroundCenter = Color(0xFFFFFBE6);
  static const Color backgroundEdge = Color(0xFFFFEEDD);

  // 玻璃质感 (更柔和)
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x80FFFFFF);
  static const Color glassRim = Color(0xFFEDE7F6);
  static const Color glassShadow = Color(0x1A5D4037); // 暖棕色阴影

  // Emoji 球颜色
  static const Color emojiYellowMain = Color(0xFFFFD54F);
  static const Color emojiYellowLight = Color(0xFFFFECB3);
  static const Color emojiYellowDark = Color(0xFFFFA000);
  static const Color emojiFeature = Color(0xFF5D4037); // 表情五官颜色
  static const Color emojiBlush = Color(0xFFFFAB91); // 腮红

  // 软木塞颜色
  static const Color corkMain = Color(0xFFD7CCC8);
  static const Color corkDark = Color(0xFFA1887F);
  static const Color corkTexture = Color(0xFF8D6E63);

  static const Color shadow = Color(0x335D4037);
}

class MoneyJarApp extends StatelessWidget {
  const MoneyJarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Rounded',
        colorScheme:
            ColorScheme.fromSeed(seedColor: CuteColors.emojiYellowMain),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

// --------------------------------------------------------------------
// 1. 物理层 (Flame) - 核心逻辑不变，渲染层完全重构为 Emoji
// --------------------------------------------------------------------

// 定义几种简单的表情类型
enum EmojiFaceType { smile, laugh, wink, surprise, love, coin }

class CoinBody extends BodyComponent {
  @override
  final Vector2 position;
  final Random _random;
  late final EmojiFaceType faceType; // 改用表情类型
  late final double coinRadius;

  CoinBody({required this.position, required Random random})
      : _random = random {
    faceType =
        EmojiFaceType.values[_random.nextInt(EmojiFaceType.values.length)];
    // 球体稍微大一点，显得更Q弹
    coinRadius = 26.0 + _random.nextDouble() * 6.0;
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = coinRadius;
    final fixtureDef = FixtureDef(
      shape,
      // 提高弹性，让它们看起来像橡胶球
      restitution: 0.4,
      density: 5.0,
      friction: 0.4,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.dynamic,
      angle: _random.nextDouble() * 2 * pi,
      angularDamping: 0.5,
      linearDamping: 0.1,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    // 绘制柔和的阴影
    canvas.drawCircle(
      const Offset(2, 3),
      coinRadius * 0.9,
      Paint()
        ..color = CuteColors.shadow.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 绘制 Emoji 球体主体
    final spherePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          CuteColors.emojiYellowLight,
          CuteColors.emojiYellowMain,
          CuteColors.emojiYellowDark
        ],
        stops: [0.0, 0.7, 1.0],
        center: Alignment(-0.3, -0.3), // 高光偏左上
        radius: 1.3,
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: coinRadius));

    canvas.drawCircle(Offset.zero, coinRadius, spherePaint);

    // 绘制边缘高光，增加立体感
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.3);
    // ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawCircle(Offset.zero, coinRadius - 1, rimPaint);

    // 绘制表情五官
    _drawEmojiFace(canvas);
  }

  // 简单的程序化表情绘制
  void _drawEmojiFace(Canvas canvas) {
    final featurePaint = Paint()
      ..color = CuteColors.emojiFeature
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final blushPaint = Paint()
      ..color = CuteColors.emojiBlush.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final r = coinRadius;

    switch (faceType) {
      case EmojiFaceType.coin:
        // --- 这里是补全的金币绘制逻辑 ---

        // 2. 绘制 "$" 符号
        final textPainter = TextPainter(
          text: TextSpan(
            text: '\$', // 你也可以换成 '￥'
            style: TextStyle(
              color: CuteColors.emojiFeature, // 使用深棕色，像印上去的
              fontSize: r * 1, // 根据球体半径动态调整字体大小
              fontWeight: FontWeight.w500, // 超粗体看起来更可爱
              fontFamily: 'ZCOOLKuaiLle', // 确保有圆润的字体效果
              height: 1.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        // 将文字居中绘制
        textPainter.paint(
            canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        break;
      case EmojiFaceType.smile:
        // 眼睛
        canvas.drawCircle(Offset(-r * 0.35, -r * 0.1), r * 0.1, featurePaint);
        canvas.drawCircle(Offset(r * 0.35, -r * 0.1), r * 0.1, featurePaint);
        // 嘴巴
        final smilePath = Path()..moveTo(-r * 0.4, r * 0.2);
        smilePath.quadraticBezierTo(0, r * 0.6, r * 0.4, r * 0.2);
        canvas.drawPath(
            smilePath,
            featurePaint
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.08);
        // 腮红
        canvas.drawCircle(Offset(-r * 0.6, r * 0.15), r * 0.15, blushPaint);
        canvas.drawCircle(Offset(r * 0.6, r * 0.15), r * 0.15, blushPaint);
        break;
      case EmojiFaceType.laugh:
        // 眯眯眼
        final eyePath = Path();
        eyePath.moveTo(-r * 0.5, -r * 0.1);
        eyePath.quadraticBezierTo(-r * 0.35, -r * 0.25, -r * 0.2, -r * 0.1);
        eyePath.moveTo(r * 0.2, -r * 0.1);
        eyePath.quadraticBezierTo(r * 0.35, -r * 0.25, r * 0.5, -r * 0.1);
        canvas.drawPath(
            eyePath,
            featurePaint
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.08);
        // 大嘴
        canvas.drawArc(
            Rect.fromCircle(center: Offset(0, r * 0.1), radius: r * 0.4),
            0,
            pi,
            false,
            featurePaint..style = PaintingStyle.fill);
        break;
      case EmojiFaceType.wink:
        // 左眼睁
        canvas.drawCircle(Offset(-r * 0.35, -r * 0.1), r * 0.1, featurePaint);
        // 右眼闭
        final winkPath = Path()
          ..moveTo(r * 0.2, -r * 0.1)
          ..quadraticBezierTo(r * 0.35, -r * 0.25, r * 0.5, -r * 0.1);
        canvas.drawPath(
            winkPath,
            featurePaint
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.08);
        // 嘴巴
        canvas.drawArc(
            Rect.fromCircle(center: Offset(0, r * 0.15), radius: r * 0.3),
            0.2,
            pi - 0.4,
            false,
            featurePaint);
        break;
      case EmojiFaceType.surprise:
        // 眼睛
        canvas.drawCircle(Offset(-r * 0.35, -r * 0.15), r * 0.12, featurePaint);
        canvas.drawCircle(Offset(r * 0.35, -r * 0.15), r * 0.12, featurePaint);
        // O型嘴
        canvas.drawCircle(Offset(0, r * 0.3), r * 0.15, featurePaint);
        // 腮红
        canvas.drawCircle(Offset(-r * 0.6, r * 0.15), r * 0.15, blushPaint);
        canvas.drawCircle(Offset(r * 0.6, r * 0.15), r * 0.15, blushPaint);
        break;
      case EmojiFaceType.love:
        // 爱心眼 (简化为大圆点代替，完整爱心代码较多)
        featurePaint.color = const Color(0xFFE53935);
        canvas.drawCircle(Offset(-r * 0.35, -r * 0.1), r * 0.15, featurePaint);
        canvas.drawCircle(Offset(r * 0.35, -r * 0.1), r * 0.15, featurePaint);
        // 嘴巴
        featurePaint.color = CuteColors.emojiFeature;
        final smilePath2 = Path()..moveTo(-r * 0.3, r * 0.3);
        smilePath2.quadraticBezierTo(0, r * 0.5, r * 0.3, r * 0.3);
        canvas.drawPath(
            smilePath2,
            featurePaint
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.08);
        break;
    }
  }
}

class WallBody extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  WallBody(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    // 增加墙壁弹性
    final fixtureDef = FixtureDef(shape, friction: 0.1, restitution: 0.3);
    final bodyDef = BodyDef(type: BodyType.static);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class MoneyJarPhysicsGame extends Forge2DGame {
  MoneyJarPhysicsGame() : super(zoom: 1.0, gravity: Vector2(0, 900));

  late Vector2 screenCenterMeters;
  final Random _random = Random();
  final List<BodyComponent> _walls = [];
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateWalls();

    // 预先生成几个，避免空荡荡
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () => dropCoin());
    }

    _accelSubscription = accelerometerEventStream().listen((event) {
      const double sensitivity = 50.0;
      world.gravity =
          Vector2(-event.x * sensitivity, event.y * sensitivity + 800);
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateWalls();
  }

  void _updateWalls() {
    for (final wall in _walls) {
      wall.removeFromParent();
      world.destroyBody(wall.body);
    }
    _walls.clear();

    final Vector2 screenSizeMeters = camera.viewport.size;
    screenCenterMeters = screenSizeMeters / 2;

    // 稍微收缩边界
    const halfW = (kJarWidthMeters / 2) - 1.5;
    const halfH = (kJarHeightMeters / 2) - 2.0;

    final topLeft = screenCenterMeters + Vector2(-halfW, -halfH);
    final topRight = screenCenterMeters + Vector2(halfW, -halfH);
    final bottomLeft = screenCenterMeters + Vector2(-halfW, halfH);
    final bottomRight = screenCenterMeters + Vector2(halfW, halfH);

    final walls = [
      WallBody(bottomLeft, bottomRight),
      WallBody(topLeft, bottomLeft),
      WallBody(topRight, bottomRight),
    ];

    for (final wall in walls) {
      add(wall);
      _walls.add(wall);
    }
  }

  void dropCoin() {
    if (!isMounted) return;
    const halfH = kJarHeightMeters / 2;
    // 从瓶口下方生成
    final spawnY = screenCenterMeters.y - halfH + 20.0;
    const maxOffset = (kJarWidthMeters / 2) - 50.0;
    final randomX = (_random.nextDouble() * maxOffset * 2) - maxOffset;

    add(CoinBody(
      position: Vector2(screenCenterMeters.x + randomX, spawnY),
      random: _random,
    ));
  }

  @override
  void onDispose() {
    _accelSubscription?.cancel();
    super.onDispose();
  }
}

// --------------------------------------------------------------------
// 2. UI 层 (Flutter) - 视觉重构
// --------------------------------------------------------------------

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late final MoneyJarPhysicsGame _game;
  late AnimationController _floatController;
  late AnimationController _buttonScaleController;

  @override
  void initState() {
    super.initState();
    _game = MoneyJarPhysicsGame();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _game.onDispose();
    _floatController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  void _handleDropCoin() {
    _buttonScaleController
        .reverse()
        .then((_) => _buttonScaleController.forward());
    _game.dropCoin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 背景升级为更暖的径向渐变
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [CuteColors.backgroundCenter, CuteColors.backgroundEdge],
          ),
        ),
        child: Stack(
          children: [
            // 背景粒子 (颜色微调)
            Positioned.fill(
                child: CustomPaint(painter: GentleParticlesPainter())),

            // 游戏层 (Emoji球)
            Positioned.fill(child: GameWidget(game: _game)),

            // 玻璃罐和软木塞视觉层
            Center(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return basic.Transform.translate(
                    offset: Offset(0, sin(_floatController.value * pi * 2) * 3),
                    child: child,
                  );
                },
                // 使用新的卡通风格玻璃罐组件
                child: const CartoonGlassJarWithCork(),
              ),
            ),

            // 顶部标题 (颜色微调)
            Positioned(
              top: MediaQuery.of(context).padding.top + 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF8D6E63).withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5)),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("✨", style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        "开心存钱罐", // 改个名字应景
                        style: TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("✨", style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
            ),

            // 底部大按钮 (颜色微调，更黄一点)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTapDown: (_) => _handleDropCoin(),
                  child: AnimatedBuilder(
                    animation: _buttonScaleController,
                    builder: (context, child) => basic.Transform.scale(
                      scale: _buttonScaleController.value,
                      child: child,
                    ),
                    child: Container(
                      width: 220,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD54F),
                            Color(0xFFFFA000)
                          ], // 更鲜艳的黄色
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(38),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFFFA000).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8)),
                          BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 0,
                              offset: const Offset(0, 4),
                              spreadRadius: -2)
                        ],
                        border: Border.all(
                            color: Colors.white.withOpacity(0.7), width: 3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_emotions_rounded,
                              color: Colors.white, size: 34),
                          SizedBox(width: 10),
                          Text(
                            "放入一个",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                    color: Colors.black12,
                                    offset: Offset(1, 1),
                                    blurRadius: 2)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------
// 3. 新的卡通风格玻璃罐 + 软木塞
// --------------------------------------------------------------------

class CartoonGlassJarWithCork extends StatelessWidget {
  const CartoonGlassJarWithCork({super.key});

  @override
  Widget build(BuildContext context) {
    const double corkHeight = 40.0;
    const double corkWidthTop = 140.0;
    const double corkWidthBottom = 120.0;

    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: kJarWidthPixels,
          height: kJarHeightPixels + corkHeight - 10, // 增加总高度以容纳软木塞
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // --- 玻璃罐主体 ---
              Container(
                width: kJarWidthPixels,
                height: kJarHeightPixels,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. 背后的柔和光影
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: kJarWidthPixels * 0.85,
                        height: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: const [
                            BoxShadow(
                              color: CuteColors.glassShadow,
                              blurRadius: 50,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. 玻璃本体 (更透亮，减少模糊)
                    Container(
                      decoration: BoxDecoration(
                          // 极淡的暖色基底
                          color: const Color(0xFFFFF8E1).withOpacity(0.05),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                            bottom: Radius.circular(48),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.white.withOpacity(0.125),
                                blurRadius: 20,
                                spreadRadius: -5,
                                offset: const Offset(0, 5)),
                          ]),
                    ),

                    // 3. 卡通感柔和高光 (CustomPainter)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CartoonGlassReflectionsPainter(),
                      ),
                    ),

                    // 4. 瓶口加厚圈
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.7),
                                  Colors.white.withOpacity(0.1)
                                ])),
                      ),
                    )
                  ],
                ),
              ),

              // --- 软木塞 (位于顶部) ---
              const Positioned(
                top: 0,
                child: CorkStopper(
                  widthTop: corkWidthTop,
                  widthBottom: corkWidthBottom,
                  height: corkHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 绘制软木塞
class CorkStopper extends StatelessWidget {
  final double widthTop;
  final double widthBottom;
  final double height;

  const CorkStopper({
    super.key,
    required this.widthTop,
    required this.widthBottom,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: widthTop,
      child: CustomPaint(
        painter: CorkPainter(widthTop: widthTop, widthBottom: widthBottom),
        child: Container(
          // 添加一些杂色纹理
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [CuteColors.corkMain, CuteColors.corkDark],
                  stops: [0.2, 0.9])),
          child: ClipPath(
            clipper: CorkClipper(widthTop: widthTop, widthBottom: widthBottom),
            // child: CustomPaint(painter: CorkTexturePainter()),
          ),
        ),
      ),
    );
  }
}

// 软木塞形状裁剪
class CorkClipper extends CustomClipper<Path> {
  final double widthTop;
  final double widthBottom;
  CorkClipper({required this.widthTop, required this.widthBottom});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double inset = (widthTop - widthBottom) / 2;
    path.moveTo(0, 0); // Top Left
    path.lineTo(widthTop, 0); // Top Right
    path.lineTo(widthTop - inset, size.height); // Bottom Right
    path.lineTo(inset, size.height); // Bottom Left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// 软木塞基础形状和边缘
class CorkPainter extends CustomPainter {
  final double widthTop;
  final double widthBottom;

  CorkPainter({required this.widthTop, required this.widthBottom});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CuteColors.corkMain
      ..style = PaintingStyle.fill;

    final path = Path();
    final double inset = (widthTop - widthBottom) / 2;

    // 梯形主体
    path.moveTo(0, 0);
    path.lineTo(widthTop, 0);
    path.lineTo(widthTop - inset, size.height);
    path.lineTo(inset, size.height);
    path.close();

    // 绘制主体
    canvas.drawPath(path, paint);

    // 顶部高光面
    canvas.drawOval(Rect.fromLTWH(0, -5, widthTop, 10),
        Paint()..color = CuteColors.corkMain.withOpacity(0.8));
    canvas.drawOval(Rect.fromLTWH(2, -3, widthTop - 4, 6),
        Paint()..color = const Color(0xFFEFEBE9).withOpacity(0.5));

    // 边缘线
    final borderPaint = Paint()
      ..color = CuteColors.corkDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 软木塞表面的杂点纹理
class CorkTexturePainter extends CustomPainter {
  final Random _random = Random(123);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CuteColors.corkTexture.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 50; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final r = _random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 专门负责画柔和卡通高光的画笔
class CartoonGlassReflectionsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. 左上角柔和的大光斑
    final mainHighlightPath = Path();
    mainHighlightPath.addOval(const Rect.fromLTWH(20, 40, 60, 120));

    final mainHighlightPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20) // 强模糊
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(-10, 0);
    canvas.rotate(-0.1);
    canvas.drawPath(mainHighlightPath, mainHighlightPaint);
    canvas.restore();

    // 2. 右侧边缘柔光
    final secHighlightPath = Path();
    secHighlightPath.moveTo(size.width - 30, 60);
    secHighlightPath.quadraticBezierTo(
        size.width - 10, 180, size.width - 30, 300);

    final secPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12 // 更宽
      ..color = Colors.white.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(secHighlightPath, secPaint);

    // 3. 底部弧形反光
    final bottomRect = Rect.fromLTWH(40, size.height - 40, size.width - 80, 30);
    final bottomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.0),
        ],
        center: Alignment.bottomCenter,
        radius: 1.5,
      ).createShader(bottomRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final bottomPath = Path();
    bottomPath.addOval(bottomRect);
    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 柔和的背景粒子 (颜色微调，更暖)
class GentleParticlesPainter extends CustomPainter {
  final Random _random = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = 5.0 + _random.nextDouble() * 10.0;

      paint.color = i % 3 == 0
          ? const Color(0xFFFFECB3).withOpacity(0.3) // 暖黄
          : const Color(0xFFFFCCBC).withOpacity(0.2); // 暖橙

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
