import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum FishState { swimming, idling, scared }

// --- 1. 智能鱼组件 ---
class SmartFishComponent extends SpriteComponent with HasGameRef, TapCallbacks {
  static const List<String> _fishAssets = [
    'flame/fish_01.png',
    'flame/fish_02.png',
    'flame/fish_03.png',
    'flame/fish_04.png',
    'flame/fish_05.png',
    'flame/fish_06.png',
    'flame/fish_07.png',
    'flame/fish_08.png',
    'flame/fish_09.png',
    'flame/fish_10.png',
    'flame/fish_11.png',
    'flame/fish_12.png',
  ];

  final double _baseSpeed = 40.0;
  final double _runSpeed = 150.0;

  Vector2 _targetPosition = Vector2.zero();
  FishState _currentState = FishState.swimming;
  Vector2 _currentVelocity = Vector2.zero();

  double _wobbleOffset = 0;
  double _wobbleSpeed = 0;
  double _turnSpeed = 0;

  double _idleTimer = 0;
  double _timeAlive = 0;
  final Random _random = Random();

  SmartFishComponent() : super(size: Vector2(100, 76));

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    _wobbleOffset = _random.nextDouble() * 100;
    _wobbleSpeed = 2 + _random.nextDouble() * 3;
    _turnSpeed = 1.5 + _random.nextDouble() * 2.0;

    try {
      final randomIndex = _random.nextInt(_fishAssets.length);
      final imageName = _fishAssets[randomIndex];
      sprite = await gameRef.loadSprite(imageName);

      double targetWidth = 60.0 + _random.nextDouble() * 40.0;
      double ratio = sprite!.originalSize.y / sprite!.originalSize.x;
      size = Vector2(targetWidth, targetWidth * ratio);
    } catch (e) {
      debugPrint("加载鱼失败: $e");
    }

    position = Vector2(
      _random.nextDouble() * gameRef.size.x,
      _random.nextDouble() * gameRef.size.y,
    );

    _pickNewTarget();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeAlive += dt;

    switch (_currentState) {
      case FishState.swimming:
        _updateSwimming(dt);
        break;
      case FishState.idling:
        _updateIdling(dt);
        break;
      case FishState.scared:
        _updateSwimming(dt);
        break;
    }
  }

  void _updateSwimming(double dt) {
    double distance = position.distanceTo(_targetPosition);
    if (distance < 20) {
      _startIdling();
      return;
    }

    Vector2 desiredDirection = (_targetPosition - position).normalized();
    double wobble = sin(_timeAlive * _wobbleSpeed + _wobbleOffset) * 0.5;
    desiredDirection.y += wobble;
    desiredDirection.normalize();

    if (_currentState != FishState.scared && _random.nextDouble() < 0.005) {
      _pickNewTarget();
    }

    double speed = _currentState == FishState.scared ? _runSpeed : _baseSpeed;
    Vector2 targetVelocity = desiredDirection * speed;
    _currentVelocity.lerp(targetVelocity, dt * _turnSpeed);

    position += _currentVelocity * dt;
    position.clamp(Vector2.zero(), gameRef.size);

    if (_currentVelocity.x > 0.1 && scale.x > 0) {
      flipHorizontally();
    } else if (_currentVelocity.x < -0.1 && scale.x < 0) {
      flipHorizontally();
    }
  }

  void _updateIdling(double dt) {
    _idleTimer -= dt;
    double floatOffset = sin(_timeAlive * 2) * 10 * dt;
    double driftOffset = cos(_timeAlive * 1.5) * 5 * dt;
    position += Vector2(driftOffset, floatOffset);

    if (_idleTimer <= 0) {
      _currentState = FishState.swimming;
      _pickNewTarget();
    }
  }

  void _pickNewTarget() {
    double x = 50 + _random.nextDouble() * (gameRef.size.x - 100);
    double y;
    double roll = _random.nextDouble();
    if (roll < 0.3) {
      y = 50 + _random.nextDouble() * (gameRef.size.y * 0.3);
    } else if (roll < 0.6) {
      y = gameRef.size.y * 0.7 +
          _random.nextDouble() * (gameRef.size.y * 0.3 - 50);
    } else {
      y = 50 + _random.nextDouble() * (gameRef.size.y - 100);
    }
    _targetPosition = Vector2(x, y);
  }

  void _startIdling() {
    _currentState = FishState.idling;
    _idleTimer = 0.5 + _random.nextDouble() * 1.5;
    _currentVelocity.scale(0.5);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _scareFish();
  }

  void _scareFish() {
    if (_currentState == FishState.scared) return;
    _currentState = FishState.scared;
    _pickNewTarget();
    _currentVelocity = (_targetPosition - position).normalized() * _runSpeed;
    add(ScaleEffect.by(
      Vector2.all(1.2),
      EffectController(
          duration: 0.1, reverseDuration: 0.2, curve: Curves.easeOut),
    ));
    Future.delayed(const Duration(seconds: 2), () {
      if (isMounted) _currentState = FishState.swimming;
    });
  }
}

// --- 2. 强化版气泡组件 (更明显、更动态) ---
// 替换原有的 BubbleComponent
class BubbleComponent extends CircleComponent with HasGameRef {
  double speed = 0;
  double wobbleOffset = 0;
  double initialX = 0;
  double _time = 0;

  BubbleComponent() : super(radius: 0);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 稍微调大一点，显得更Q弹
    radius = 4 + Random().nextDouble() * 6;

    initialX = Random().nextDouble() * gameRef.size.x;
    position = Vector2(initialX, gameRef.size.y + 20);
    speed = 50 + Random().nextDouble() * 100;
    wobbleOffset = Random().nextDouble() * 10;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    position.y -= speed * dt;
    position.x = initialX + sin(_time * 3 + wobbleOffset) * (10 + radius);
    if (position.y < -50) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    // 【修改点】使用径向渐变，画出像“玻璃珠”一样的立体感
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(radius * 0.3, -radius * 0.3), // 高光点偏移
        radius,
        [
          Colors.white.withOpacity(0.9), // 高光中心
          Colors.white.withOpacity(0.3), // 中间
          Colors.white.withOpacity(0.1), // 边缘
        ],
        [0.0, 0.5, 1.0],
      );

    // 移动画布中心到圆心，方便画径向渐变
    canvas.save();
    canvas.translate(radius, radius);
    canvas.drawCircle(Offset.zero, radius, paint);

    // 加一个淡淡的描边，增加轮廓
    canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withOpacity(0.2));

    canvas.restore();
  }
}

// 替换原来的 SeaweedComponent
class ImageSeaweedComponent extends SpriteComponent with HasGameRef {
  final String imagePath;

  ImageSeaweedComponent({required this.imagePath})
      : super(anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(imagePath); // 比如 'flame/seaweed_01.png'

    // 随机大小，保持比例
    final double targetHeight =
        gameRef.size.y * (0.15 + Random().nextDouble() * 0.15);
    final double ratio = sprite!.originalSize.x / sprite!.originalSize.y;
    size = Vector2(targetHeight * ratio, targetHeight);

    // 随机位置（底部）
    position = Vector2(
        Random().nextDouble() * gameRef.size.x, gameRef.size.y + 10 // 稍微埋进土里一点
        );

    // 【关键】添加摇摆动画 (模拟水流)
    // 利用 Flame 的 Effect 系统，让图片像不倒翁一样左右慢摇
    add(RotateEffect.by(
      0.05 + Random().nextDouble() * 0.1, // 摇摆弧度（不要太大，不然像断了）
      EffectController(
        duration: 2 + Random().nextDouble() * 2, // 摇摆速度（慢一点）
        reverseDuration: 2 + Random().nextDouble() * 2,
        infinite: true,
        curve: Curves.easeInOutSine, // 丝滑曲线
      ),
    ));
  }
}

// --- 3. 动态水草组件 (贝塞尔曲线绘制) ---
// 替换原有的 SeaweedComponent
class SeaweedComponent extends PositionComponent with HasGameRef {
  double swayTimingOffset = 0;
  Color color;
  double _time = 0;

  SeaweedComponent({required this.color});

  @override
  Future<void> onLoad() async {
    anchor = Anchor.bottomCenter;
    height = gameRef.size.y * (0.2 + Random().nextDouble() * 0.15); // 稍微加高
    width = 20; // 宽度不再随机，而是固定用于计算粗细
    position = Vector2(
        Random().nextDouble() * gameRef.size.x, gameRef.size.y + 10); // 稍微沉底一点
    swayTimingOffset = Random().nextDouble() * 10;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke // 关键：改为描边
      ..strokeWidth = width // 关键：非常粗的线条
      ..strokeCap = StrokeCap.round; // 关键：圆头，像手指搓出来的

    final path = Path();
    path.moveTo(width / 2, height);

    double sway = sin(_time * 1.5 + swayTimingOffset) * 5;

    // 使用三阶贝塞尔曲线，线条更顺滑柔软
    path.cubicTo(
        width / 2 + sway * 0.3,
        height * 0.6, // 控制点1
        width / 2 + sway * 0.8,
        height * 0.3, // 控制点2
        width / 2 + sway,
        0 // 终点
        );

    canvas.drawPath(path, paint);

    // (可选) 为了增加立体感，可以在左侧画一条细一点的高光线，这里暂且省略保持简洁
  }
}

// --- 4. 浮游粒子组件 ---
class PlanktonComponent extends CircleComponent with HasGameRef {
  double _time = 0;
  // 记录每个粒子独特的随机偏移，让它们不要同步运动
  late double _randomOffset;
  late double _speed;

  PlanktonComponent() : super(radius: 0);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    radius = 0.5 + Random().nextDouble() * 1.5;
    paint = Paint()
      ..color = Colors.white.withOpacity(0.1 + Random().nextDouble() * 0.2)
      ..style = PaintingStyle.fill;

    // 初始化位置
    position = Vector2(
      Random().nextDouble() * gameRef.size.x,
      Random().nextDouble() * gameRef.size.y,
    );

    _randomOffset = Random().nextDouble() * 100;
    _speed = 2 + Random().nextDouble() * 3; // 稍微慢一点，太快容易眼花
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // 1. 缓慢上浮
    position.y -= _speed * dt;

    // 2. 左右微晃 (不使用累加，而是基于初始位置的偏移，这样更稳定)
    // 这里其实简单的累加也没问题，但要确保幅度很小
    position.x += sin(_time + _randomOffset) * 5 * dt;

    // 3. 循环机制：如果飘出顶部，重置到底部
    if (position.y < -10) {
      position.y = gameRef.size.y + 10;
      position.x = Random().nextDouble() * gameRef.size.x; // X轴也随机重置一下
    }
  }
}

// --- 5. 光束组件 ---
class LightBeamComponent extends PositionComponent with HasGameRef {
  late Paint _paint;
  double _time = 0;
  final double _swaySpeed;

  LightBeamComponent() : _swaySpeed = 0.5 + Random().nextDouble();

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topCenter;
    size = Vector2(100 + Random().nextDouble() * 200, gameRef.size.y * 1.2);
    position = Vector2(Random().nextDouble() * gameRef.size.x, -50);
    angle = (Random().nextDouble() - 0.5) * 0.5;

    _paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.x / 2, 0),
        Offset(size.x / 2, size.y),
        [
          Colors.white.withOpacity(0.05 + Random().nextDouble() * 0.1),
          Colors.white.withOpacity(0),
        ],
      )
      ..blendMode = BlendMode.screen;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    angle += sin(_time * _swaySpeed) * 0.0002;
    scale.x = 1.0 + sin(_time * 2) * 0.0005;
  }

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..moveTo(size.x * 0.2, 0)
      ..lineTo(size.x * 0.8, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(path, _paint);
  }
}

// --- 6. 游戏主类 ---
class FishTankGame extends FlameGame with HasGameRef {
  double _bubbleTimer = 0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // 1. 光束
    // for (int i = 0; i < 2; i++) {
    add(LightBeamComponent());
    // }

    // 2. 水草 (先加深色的在后排，再加浅色的在前排，制造层次感)
    for (int i = 0; i < 4; i++) {
      add(SeaweedComponent(
          color: const Color(0xFF0D4747).withOpacity(0.8) // 深墨绿
          ));
    }

    for (int i = 0; i < 3; i++) {
      add(SeaweedComponent(color: const Color(0xFF2D6E58).withOpacity(0.9)));
    }

    // add(ImageSeaweedComponent(imagePath: 'flame/seaweed_01.png'));

    // 3. 浮游生物
    for (int i = 0; i < 40; i++) {
      add(PlanktonComponent());
    }

    // 4. 鱼
    for (int i = 0; i < 5; i++) {
      addNewFish();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 气泡生成逻辑 (高频检查)
    _bubbleTimer += dt;
    // 0.05秒检查一次，30%概率生成 -> 约每秒6个气泡
    if (_bubbleTimer > 0.2) {
      if (Random().nextDouble() < 0.3) {
        add(BubbleComponent());
      }
      _bubbleTimer = 0;
    }
  }

  void addNewFish() {
    var fish = SmartFishComponent();
    fish.scale = Vector2.all(0.8 + Random().nextDouble() * 0.7);
    add(fish);
  }
}

// --- 7. 页面层 ---
class FishTankFlamePage extends StatelessWidget {
  final FishTankGame _game = FishTankGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景层
          Container(
            decoration: const BoxDecoration(
              // 模拟摄影棚背景纸的径向渐变
              gradient: RadialGradient(
                center: Alignment(0, -0.2), // 光源稍微靠上
                radius: 1.2,
                colors: [
                  Color(0xFF2B4C6F), // 中心稍微亮一点的蓝
                  Color(0xFF101E2E), // 边缘深色
                ],
              ),
            ),
          ),

          // 游戏层
          GameWidget(game: _game),

          // 顶部光影遮罩
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3],
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 按钮
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: Colors.white.withOpacity(0.2),
              elevation: 0,
              onPressed: () => _game.addNewFish(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
