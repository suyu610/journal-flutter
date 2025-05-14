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
  bool cancelHighlight = false;
  RxString text = "".obs;
  VoiceMessageSendWidgetStatus _status = VoiceMessageSendWidgetStatus.end;
  late AnimationController controller;
  late Animation<double> animation;

  double bottom = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();

  void startRecongnize() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );
    if (available) {
      // ToastUtil.lightImpact();
      _speech.listen(
          onResult: (result) {
            text.value = result.recognizedWords;
          },
          localeId: "zh-CN");
    }
  }

  void stopRecongnize() {
    Log().d("stopRecongnize");
    _speech.stop();
    _speech.cancel();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    controller = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.normal,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    animation = Tween<double>(begin: 1.0, end: 1.15).animate(controller)
      ..addListener(() => setState(() {}));

    eventBus.on<VoiceTouchPointChange>().listen((VoiceTouchPointChange bean) {
      //position 空代表手指停止移动，有值代表手指正在移动
      if (mounted) {
        setState(() {
          position = bean.position;
          VoiceMessageSendWidgetStatus currentBean = bean.status;

          if (currentBean == VoiceMessageSendWidgetStatus.recording) {
            if (_status != VoiceMessageSendWidgetStatus.recording) {
              _speaking();
            }
          } else {
            _status = bean.status;

            widget.hasImpact = false;

            // 正常发送
            // if (!cancelHighlight) {
            //   cancelHighlight = false;
            //   controller.animateBack(0);
            //   _stopRecordAudio();
            //   return;
            // }
          }

          _status = bean.status;
          if (_status == VoiceMessageSendWidgetStatus.end) {
            controller.animateBack(0);
            _stopRecordAudio(cancelHighlight);
            cancelHighlight = false;
          }
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        _stopRecordAudio(false); //进入后台发出消息
        break;
      case AppLifecycleState.detached: // APP结束时调用
        break;
      case AppLifecycleState.hidden:
    }
  }

  _speaking() async {
    debugPrint('录制--开始');
    text.value = "";
    startRecongnize();
  }

  //手松开 或者15s到了
  _stopRecordAudio(cancel) {
    debugPrint('录音--结束');
    stopRecongnize();

    widget.sendVoiceMessage(cancel, text.value, 1);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == VoiceMessageSendWidgetStatus.end) {
      return Container();
    }

    String title = '松开发送';
    cancelHighlight = false;
    controller.animateBack(0);

    if (_status == VoiceMessageSendWidgetStatus.recording) {
      if (position != null && position!.dy <= 10) {
        title = '松开取消发送';
        cancelHighlight = true;
        controller.forward();
      } else {
        widget.hasImpact = false;
      }
    }

    return Container(
      width: 385.w,
      color: const Color(0xff474747),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
          ClipPath(
            clipper: VoiceSendArcClipper(),
            child: Container(
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
                  // color: cancelHighlight
                  //     ? const Color(0xff3C3C3E)
                  //     : Color(0xffbbbbbb),
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

    int tmp = widget.maxDuration - count; //倒数 所以减一下

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

    //上面的半圆
    path.quadraticBezierTo(size.width / 2, -35, size.width, 35);

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
