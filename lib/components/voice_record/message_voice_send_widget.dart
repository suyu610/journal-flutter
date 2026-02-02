import 'dart:async'; // 引入 Async 用于 StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../event_bus/voice_touch_point_change.dart';

class VoiceMessageSendWidget extends StatefulWidget {
  final Function(bool cancel, String text, int duration) sendVoiceMessage;
  final bool talentMassSend;
  final int maxDuration;
  final int minDuration;
  bool hasImpact = false;

  VoiceMessageSendWidget(this.sendVoiceMessage,
      {this.talentMassSend = false, this.maxDuration = 4, this.minDuration = 0})
      : super();

  @override
  State<StatefulWidget> createState() {
    return _VoiceMessageSendWidget();
  }
}

class _VoiceMessageSendWidget extends State<VoiceMessageSendWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final double _height = 132;

  Offset? position;
  int remind = 0;
  bool cancelHighlight = false; // 是否处于取消发送区域
  RxString text = "".obs;
  VoiceMessageSendWidgetStatus _status = VoiceMessageSendWidgetStatus.end;

  // 动画控制器
  late AnimationController controller;
  late Animation<double> animation;

  // 事件订阅对象，用于销毁防止内存泄露
  StreamSubscription? _eventSubscription;

  double bottom = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 初始化动画控制器
    controller = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.normal,
      duration: const Duration(milliseconds: 200),
    );
    animation = Tween<double>(begin: 1.0, end: 1.15).animate(controller);
    // 注意：不再需要 addListener setState，因为我们用 AnimatedBuilder 局部刷新
  }

  // 确保在视图加载完成后再监听事件，或者直接在 initState 监听但处理逻辑加 mounted 判断
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 防止重复订阅
    _eventSubscription?.cancel();

    _eventSubscription = eventBus
        .on<VoiceTouchPointChange>()
        .listen((VoiceTouchPointChange bean) {
      if (!mounted) return;

      // 在这里处理所有逻辑，而不是在 build 里
      setState(() {
        position = bean.position;
        VoiceMessageSendWidgetStatus newStatus = bean.status;

        // 1. 处理录音状态逻辑
        if (newStatus == VoiceMessageSendWidgetStatus.recording) {
          // 如果是从非录音状态切过来的，开始录音
          if (_status != VoiceMessageSendWidgetStatus.recording) {
            _speaking();
          }

          // 计算手指位置，决定是否触发“取消高亮”和动画
          // 这里的 10 是阈值，根据你的 UI 调整
          if (position != null && position!.dy <= 10) {
            if (!cancelHighlight) {
              cancelHighlight = true;
              controller.forward(); // 播放变大动画
            }
          } else {
            if (cancelHighlight) {
              cancelHighlight = false;
              controller.reverse(); // 恢复原状
            }
            widget.hasImpact = false;
          }
        }
        // 2. 处理结束状态逻辑
        else if (newStatus == VoiceMessageSendWidgetStatus.end) {
          // 只有当状态真正改变时才执行停止逻辑
          if (_status != VoiceMessageSendWidgetStatus.end) {
            controller.reset(); // 重置动画
            // 传入当前的 cancelHighlight 状态来决定是发送还是取消
            _stopRecordAudio(cancelHighlight);
            cancelHighlight = false;
          }
        }

        // 更新状态
        _status = newStatus;
      });
    });
  }

  void startRecongnize() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );
    if (available) {
      // ToastUtil.lightImpact();
      _speech.listen(
          onResult: (result) {
            if (mounted) {
              text.value = result.recognizedWords;
            }
          },
          localeId: "zh-CN");
    }
  }

  void stopRecongnize() {
    Log().d("stopRecongnize");
    _speech.stop();
    // _speech.cancel(); // stop 停止监听，cancel 是彻底取消
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused: // 界面不可见，后台
        if (_status == VoiceMessageSendWidgetStatus.recording) {
          _stopRecordAudio(false); // 进入后台强制发送（或可以改为 true 取消）
          setState(() {
            _status = VoiceMessageSendWidgetStatus.end;
          });
        }
        break;
      default:
        break;
    }
  }

  _speaking() async {
    debugPrint('录制--开始');
    text.value = "";
    startRecongnize();
  }

  // 手松开 或者15s到了
  _stopRecordAudio(bool cancel) {
    debugPrint('录音--结束, 是否取消: $cancel');
    stopRecongnize();
    // 只有在 mounted 时才回调，防止组件销毁后调用
    if (mounted) {
      widget.sendVoiceMessage(cancel, text.value, 1);
    }
  }

  @override
  void dispose() {
    // 【核心修复】必须销毁所有监听和控制器
    WidgetsBinding.instance.removeObserver(this);
    _eventSubscription?.cancel(); // 销毁 EventBus 监听
    controller.dispose(); // 销毁动画控制器
    _speech.cancel(); // 销毁语音服务
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果状态是结束，直接返回空容器（隐藏）
    if (_status == VoiceMessageSendWidgetStatus.end) {
      return Container();
    }

    // 纯 UI 渲染，不含逻辑副作用
    String title = cancelHighlight ? '松开取消发送' : '松开发送';

    return Container(
      width: 385.w,
      color: const Color(0xff474747),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 顶部声波动画
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xffa9e77b),
              ),
              child: Lottie.asset('assets/json/sound_wave.json',
                  width: 100, height: 50)),
          const SizedBox(
            height: 12,
          ),

          // 语音转文字预览
          Obx(() => Text(
                text.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              )),
          const SizedBox(
            height: 64,
          ),

          // 垃圾桶图标（带缩放动画）
          AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Image.asset(
                'assets/icons/${cancelHighlight ? "message_voice_cancel.png" : "message_voice_cancel_default.png"}',
                width: 64 * animation.value,
                height: 64 * animation.value,
              );
            },
          ),
          const SizedBox(
            height: 24,
          ),

          // 底部半圆区域
          ClipPath(
            clipper: VoiceSendArcClipper(),
            child: AnimatedContainer(
              // 底部背景颜色渐变动画
              duration: const Duration(milliseconds: 200),
              height: _height + MediaQuery.of(context).padding.bottom,
              width: 385.w,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      stops: const [0, 0.5, 1.0],
                      colors: cancelHighlight
                          ? [
                              const Color(0xff3C3C3E),
                              const Color(0xff3C3C3E),
                              const Color(0xff3C3C3E)
                            ]
                          : [
                              const Color(0xff9d9d9d),
                              const Color(0xffcecece),
                              const Color(0xffcecece),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: Offset(0, 0))
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xff5f5f5f),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  String coverIntToMMss(int count) {
    String time = "00:${widget.maxDuration}";
    int tmp = widget.maxDuration - count;
    if (tmp >= 10) {
      time = "00:$tmp";
    } else {
      time = "00:0$tmp";
    }
    return time;
  }
}

class VoiceSendArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 35);
    // 上面的半圆
    path.quadraticBezierTo(size.width / 2, -35, size.width, 35);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; // 路径不经常变，返回 false 优化性能
  }
}
