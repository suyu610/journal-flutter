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
class BubbleComponent extends CircleComponent with HasGameRef {
  double speed = 0;
  double wobbleOffset = 0;
  double initialX = 0;
  double _time = 0; // 自己记录时间

  BubbleComponent() : super(radius: 0);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 变大：半径 3 ~ 8
    radius = 3 + Random().nextDouble() * 5;

    // 变亮
    paint = Paint()
      ..color = Colors.white.withOpacity(0.4 + Random().nextDouble() * 0.3)
      ..style = PaintingStyle.fill;

    initialX = Random().nextDouble() * gameRef.size.x;
    position = Vector2(initialX, gameRef.size.y + 20); // 从屏幕底下生成

    speed = 50 + Random().nextDouble() * 150; // 速度快慢不一
    wobbleOffset = Random().nextDouble() * 10;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // 向上飞
    position.y -= speed * dt;

    // 左右摇摆
    position.x = initialX + sin(_time * 3 + wobbleOffset) * (5 + radius);

    // 飞出屏幕上方销毁
    if (position.y < -50) removeFromParent();
  }
}

// --- 3. 动态水草组件 (贝塞尔曲线绘制) ---
class SeaweedComponent extends PositionComponent with HasGameRef {
  double swayTimingOffset = 0;
  Color color;
  double _time = 0; // 修复点：自己记录时间，不依赖 gameRef.elapsedTime

  SeaweedComponent({required this.color});

  @override
  Future<void> onLoad() async {
    anchor = Anchor.bottomCenter;
    // 随机高度：屏幕高度的 15% ~ 25%
    height = gameRef.size.y * (0.15 + Random().nextDouble() * 0.1);
    // 随机宽度
    width = 10 + Random().nextDouble() * 10;

    // 位置
    position = Vector2(Random().nextDouble() * gameRef.size.x, gameRef.size.y);
    swayTimingOffset = Random().nextDouble() * 10;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt; // 每帧累加时间
  }

  @override
  void render(Canvas canvas) {
    final path = Path();
    path.moveTo(width / 2, height); // 底部起点

    // 计算摇摆：顶端摆动幅度大
    double sway = sin(_time * 2 + swayTimingOffset) * 20;

    // 二次贝塞尔曲线绘制
    path.quadraticBezierTo(
        width / 2 + sway / 2, // 控制点 X
        height / 2, // 控制点 Y
        width / 2 + sway, // 终点 X
        0 // 终点 Y (顶部)
        );

    // 闭合路径形成叶片
    path.quadraticBezierTo(width / 2 + sway / 2, height / 2, width / 2, height);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
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
    for (int i = 0; i < 15; i++) {
      add(SeaweedComponent(
          color: const Color(0xFF0D4747).withOpacity(0.8) // 深墨绿
          ));
    }

    for (int i = 0; i < 8; i++) {
      add(SeaweedComponent(color: const Color(0xFF2D6E58).withOpacity(0.9)));
    }

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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A5F7A),
                  Color(0xFF002B45),
                  Color(0xFF001122),
                ],
                stops: [0.0, 0.6, 1.0],
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
