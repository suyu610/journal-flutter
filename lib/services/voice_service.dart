import 'dart:developer';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:get/get.dart';
import 'dart:async';

class VoiceService extends GetxService {
  final SpeechToText _speech = SpeechToText();
  var isListening = false.obs;
  var textResult = "".obs; // 实时转换的文字
  var isAvailable = false.obs;

  Future<void> init() async {
    try {
      isAvailable.value = await _speech.initialize(
        onStatus: (status) => print('语音状态: $status'),
        onError: (error) => print('语音错误: $error'),
      );
    } catch (e) {
      print("语音初始化失败: $e");
    }
  }

  void startListening({required Function(String) onResult}) async {
    if (!isAvailable.value) await init();

    if (isAvailable.value) {
      isListening.value = true;
      textResult.value = "";
      _speech.listen(
        onResult: (result) {
          textResult.value = result.recognizedWords;
          log("识别到: ${result.recognizedWords}");
          // 实时回调结果
          onResult(result.recognizedWords);
        },
        localeId: "zh_CN", // 强制中文
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3), // 停顿3秒自动结束
        cancelOnError: true,
      );
    }
  }

  void stopListening() {
    isListening.value = false;
    textResult.value = "";
    _speech.stop();
  }

  void reset() {
    textResult.value = "";
  }
}
