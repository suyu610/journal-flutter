import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

// 假设的主题色
const Color backgroundColor = Color(0xFFF2F5F8);

// ==================== 定义一个简单的类来保存每棵树的数据 ====================
class TreeData {
  final int seed;
  final double left; // X轴位置
  final double bottom; // Y轴位置 (距离底部)
  final double size; // 大小

  TreeData({
    required this.seed,
    required this.left,
    required this.bottom,
    required this.size,
  });
}

// ==================== 第一部分：主页面 (森林) ====================
class ForestPage extends StatefulWidget {
  const ForestPage({Key? key}) : super(key: key);

  @override
  _ForestPageState createState() => _ForestPageState();
}

class _ForestPageState extends State<ForestPage> {
  final List<TreeData> _trees = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _generateForest();
  }

  void _generateForest() {
    _trees.clear();
    // 生成 12 棵树
    for (int i = 0; i < 12; i++) {
      // 随机大小：180 到 320 之间
      double size = 180 + _rnd.nextDouble() * 140;

      // 随机位置 (大概范围，可根据屏幕调整)
      // bottom 越大越远，越小越近
      double bottom = 50 + _rnd.nextDouble() * 300;

      // left 范围：允许稍微超出屏幕边缘，更自然
      double left = -50 + _rnd.nextDouble() * 350;

      _trees.add(TreeData(
        seed: i,
        left: left,
        bottom: bottom,
        size: size,
      ));
    }

    // 【关键步骤】排序！
    // 按照 bottom 值从大到小排序。
    // 远处的树 (bottom大) 排在前面先绘制；近处的树 (bottom小) 后绘制。
    // 这样 Stack 堆叠时，近处的树才能遮挡住远处的树。
    _trees.sort((a, b) => b.bottom.compareTo(a.bottom));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // --- 背景层 ---
          Positioned.fill(child: Container(color: backgroundColor)),

          // --- 树木层 ---
          // 遍历排好序的列表生成 Widget
          for (var tree in _trees)
            Positioned(
              bottom: tree.bottom, // 远近错落
              left: tree.left, // 左右随机
              width: tree.size, // 大小不一
              height: tree.size,
              child: SelfGrowingTree(randomSeed: tree.seed),
            ),

          // --- 文字层 (放在最后，浮在所有树上面) ---
          const Positioned(
            top: 60,
            left: 20,
            child: SafeArea(
              child: Text(
                "我的随机森林",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 增加一个刷新按钮，方便你测试随机效果
          Positioned(
            top: 60,
            right: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black87),
                onPressed: () {
                  setState(() {
                    _generateForest();
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ==================== 自生长树组件 (优化了生长速度逻辑) ====================
class SelfGrowingTree extends StatefulWidget {
  final int randomSeed;

  const SelfGrowingTree({Key? key, required this.randomSeed}) : super(key: key);

  @override
  _SelfGrowingTreeState createState() => _SelfGrowingTreeState();
}

class _SelfGrowingTreeState extends State<SelfGrowingTree> {
  StateMachineController? _controller;
  SMIInput<double>? _progressInput;
  Timer? _timer;
  late Random _random;

  // 新增：这棵树专属的基础生长倍率 (相当于它的基因)
  late double _baseGrowthSpeed;

  @override
  void initState() {
    super.initState();
    _random = Random(widget.randomSeed);

    // 【核心修改 1】决定这棵树是“快郎中”还是“慢郎中”
    // 范围：0.3 (非常慢) 到 2.5 (非常快)
    // 这样树与树之间的拉开的差距会非常明显
    _baseGrowthSpeed = 0.3 + _random.nextDouble() * 2.2;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    // 随机延迟启动，错开每棵树的“生日”
    int delay = _random.nextInt(3000);

    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;

      final controller =
          StateMachineController.fromArtboard(artboard, 'State Machine 1');

      if (controller != null) {
        artboard.addController(controller);
        _controller = controller;
        _progressInput = controller.findInput<double>('input');

        // 初始高度随机
        _progressInput?.value = _random.nextDouble() * 20;

        _startGrowthLoop();
      }
    });
  }

  void _startGrowthLoop() {
    // 【优化建议】把刷新频率从 100ms 提高到 32ms (约30FPS)，
    // 这样速度的差异会表现得更丝滑，不会有“卡顿式”增长的感觉
    _timer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (!mounted || _progressInput == null) return;

      // 【核心修改 2】计算当前的增量
      // 基础增量 (0.2) * 这棵树的基因倍率 (_baseGrowthSpeed)
      // 这里的 0.2 是配合 32ms 的高刷新率调整的（刷新快了，每次加的就要少一点）
      double increment = 0.2 * _baseGrowthSpeed;

      // 【可选】加一点点“环境噪音”，模拟大自然的风吹草动 (±10% 的波动)
      // 这样即使是同一棵树，生长速度也会有微小的呼吸感
      double noise = 0.9 + _random.nextDouble() * 0.2;

      double currentValue = _progressInput!.value + (increment * noise);

      if (currentValue >= 100) {
        currentValue = 0;
        // 如果你想让它们长满后停顿更久再重开，可以在这里加逻辑
      }

      // 直接赋值，无需 setState
      _progressInput!.value = currentValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/rive/tree-2.riv',
      fit: BoxFit.contain,
      onInit: _onRiveInit,
    );
  }
}
