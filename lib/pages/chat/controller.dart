import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:journal/core/log.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/ai_config_model.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/profile/controller.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';
import 'package:journal/services/local_server.dart';
import 'package:journal/services/widget_service.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:journal/util/sp_util.dart';
import 'package:just_audio/just_audio.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:journal/models/ai_presets.dart';

class ChatController extends GetxController {
  ChatController();
  RxString bubbleText = "".obs; // 气泡内容
  RxBool isBubbleVisible = false.obs; // 气泡是否可见
  Timer? _bubbleTimer; // 自动隐藏定时器

  // 当前角色配置
  Rx<AICharacter?> currentCharacter = Rx<AICharacter?>(null);

// 显示气泡的方法
  void showBubble(String text) {
    bubbleText.value = text;
    isBubbleVisible.value = true;

    // 震动反馈，增加交互感
    HapticFeedback.lightImpact();

    // 每次显示前取消上一次的定时器
    _bubbleTimer?.cancel();

    // 5秒后自动消失，模仿游戏对话
    _bubbleTimer = Timer(const Duration(seconds: 5), () {
      isBubbleVisible.value = false;
    });
  }

  RxString bgImage = "".obs;

  // 添加这一行
  final isLongPressing = false.obs;
  // webview 加载完模型了
  final isModelLoaded = false.obs;

  Rx<Activity> activity = Activity.empty().obs;

  late TextEditingController textEditingController;
  RxBool keyboardMode = true.obs;
  types.User user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  final types.User aiUser = types.User(
      firstName: "智能助手",
      id: 'abcvd',
      imageUrl: Get.find<LayoutController>().user.value.aiAvatarUrl ??
          "assets/icons/img_avatar_new.png");

  RxList<types.Message> messages = RxList();

  final focusNode = FocusNode();
  static List<String> animationList = [
    "Dance",
    "Death",
    "Idle",
    "Jump",
    "No",
    "Punch",
    "Running",
    "Sitting",
    "Standing",
    "ThumbsUp",
    "Walking",
    "WalkJump",
    "Wave",
    "Yes"
  ];
  var animationName = animationList[2].obs;

  late WebViewController webViewController = WebViewController();

  /// 获取当前配置并回显
  void _fetchCurrentConfig() async {
    var result =
        await HttpRequest.request(Method.get, "/api/ai-config/current");

    if (result != null) {
      try {
        UserAIConfig config = UserAIConfig.fromJson(result['data']);

        // 查找对应的角色预设
        final preset = CharacterPresets.list.firstWhere(
          (c) => c.id == config.characterCode,
          orElse: () => CharacterPresets.list[0],
        );
        currentCharacter.value = preset;

        _initLive2D(config);
      } catch (e) {
        debugPrint("解析配置失败: $e");
      }
    }
  }

  _initData() async {
    // 从sp中获取
    keyboardMode.value = SpUtil.getKeyboardMode();
    // 取当前的AI配置
    _fetchCurrentConfig();
    update(["chat"]);
  }

  void handleSendPressed(types.PartialText message, context) {
    if (message.text.isEmpty) return;
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    messages.insert(0, textMessage);
    update(["chat"]);
    textEditingController.text = "";

    var loadingMessage = types.TextMessage(
        author: aiUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: '对方正在输入...');
    messages.insert(0, loadingMessage);
    update(['chat']);
    if (keyboardMode.value) {
      focusNode.requestFocus();
    }

    formatAndReply(textMessage.text, loadingMessage.id, context);
  }

  void formatAndReply(text, id, context) {
    HttpRequest.request(
      Method.get,
      "/ai/format/v2?sentence=$text&activityId=${activity.value.activityId}",
      fail: (code, msg) {
        messages.removeWhere((element) => element.id == id);
        var reMessage = types.TextMessage(
            author: aiUser,
            text: "未获取有效信息",
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: DateTime.now().millisecondsSinceEpoch.toString());
        // 删除思考中...
        messages.insert(0, reMessage);
        animationName.value = "No";
        HttpRequest.request(Method.get,
            "/ai/chat?sentence=$text&activityId=${activity.value.activityId}",
            success: (data) {
          showBubble(data.toString());
        });

        update(["chat"]);
      },
      success: (data) {
        praise(text);
        try {
          // 如果是纯文本（非记账数据），或者你想在记账成功时也说句话
          if (data is! List && data is! Map) {
            // 假设后端有时候直接返回字符串
            showBubble(data.toString());
          } else {
            // 记账成功，也可以让角色卖个萌
            showBubble("记下来啦！每笔开销都要精打细算哦~");
          }
          Log().d("AI返回数据: $data");
          messages.removeWhere((element) => element.id == id);

          if (data is List) {
            int now = DateTime.now().millisecondsSinceEpoch;
            int magicInterval = 610;
            for (var i = 0; i < data.length; i++) {
              var item = data[i];
              Expense expense = Expense.fromJson(item as Map<String, dynamic>);
              int fakeTimestamp = now - ((data.length - 1 - i) * magicInterval);
              var reMessage = types.CustomMessage(
                  author: aiUser,
                  metadata: {"msgType": "expense", ...expense.toJson()},
                  createdAt: fakeTimestamp,
                  id: expense.expenseId);

              messages.insert(0, reMessage);
            }
          } else if (data is Map) {
            // 兼容旧逻辑（万一后端返回单个对象）
            Expense expense = Expense.fromJson(data as Map<String, dynamic>);
            var reMessage = types.CustomMessage(
                author: aiUser,
                metadata: {"msgType": "expense", ...expense.toJson()},
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: expense.expenseId);
            messages.insert(0, reMessage);
          }

          update(["chat"]);

          // 检查是否需要显示评分弹窗
          _checkAndShowRatingPrompt();

          // 3. 刷新数据
          eventBus.fire(const NeedRefreshData(
              refreshChartsList: true,
              refreshActivityList: true,
              refreshCurrentActivity: true));
        } catch (e) {
          Log().d("解析失败: $e");
          // 解析失败，把原始返回显示出来用于调试
          var reMessage = types.TextMessage(
              author: aiUser,
              text: "解析错误: $data",
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: DateTime.now().millisecondsSinceEpoch.toString());
          messages.insert(0, reMessage);
          update(["chat"]);
        }
      },
    );
  }

  void praise(sentence) {
    DateTime.now().millisecondsSinceEpoch.toString();
    HttpRequest.request(
      Method.get,
      "/ai/praise/advance?sentence=$sentence&activityId=${activity.value.activityId}",
      success: (data) {
        // 【修改】夸奖的话最适合用气泡显示了！
        showBubble(data.toString());

        // 原有的动画逻辑保留
        animationName.value = "ThumbsUp";
        update(["chat"]);
      },
    );
  }

  /// 处理流式响应
  Future<void> processStreamResponse(Stream stream, String uuid) async {
    final StringBuffer buffer = StringBuffer();

    // 处理流式响应
    await for (var data in stream) {
      final bytes = data as List<int>;
      final decodedData = utf8.decode(bytes);
      List<String> jsonData = decodedData.split('data: ');
      jsonData = jsonData.where((element) => element.isNotEmpty).toList();
      for (var content in jsonData) {
        if (content == '[DONE]') {
          break;
        }

        try {
          if (content.isNotEmpty) {
            buffer.write(content);
            messages.removeWhere((element) => element.id == uuid);

            types.TextMessage newMsg = types.TextMessage(
                author: aiUser,
                text: buffer.toString(),
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: uuid);

            messages.insert(0, newMsg);
            update(["chat"]);
          }
          if (content == 'stop') {
            print(buffer.toString());
            break;
          }
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      }
    }
  }

  void onTap() {}
  Rx<Activity> currentActivity = Activity.empty().obs;

  void initCurrentActivity() {
    HttpRequest.request(
      Method.get,
      "/activity/current",
      success: (data) async {
        if (data == null) {
          Log().d("无当前账本");
          currentActivity.value = Activity.empty();
        } else {
          currentActivity.value =
              Activity.fromJson(data as Map<String, dynamic>);
          activity.value = currentActivity.value;
          // 3. 同步给小组件
          await WidgetSyncService.updateWidget(
            budgetType: currentActivity.value.budgetType ?? "total",
            todayExpense:
                (currentActivity.value.todayExpense ?? 0.0).toDouble(),
            weekExpense: (currentActivity.value.weekExpense ?? 0.0).toDouble(),
            monthExpense:
                (currentActivity.value.monthExpense ?? 0.0).toDouble(),
            totalExpense:
                (currentActivity.value.totalExpense ?? 0.0).toDouble(),
            budgetAmount: (currentActivity.value.budget ?? 0.0).toDouble(),
          );
        }
        update(["current_activity"]);
      },
      fail: (code, msg) {
        Log().d("获取当前账本失败:$msg");
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
// 【修改】开场白直接用气泡显示，而不是插入列表
    bgImage.value = SpUtil.getChatBg() ?? "";

    update(["chat"]);

    setKeyboardModeAndRequestFocus();

    // var greetingMessage = types.TextMessage(
    //     author: aiUser,
    //     text: "你好，我是你的财务助手，有什么可以帮助你的吗？",
    //     createdAt: DateTime.now().millisecondsSinceEpoch,
    //     id: DateTime.now().millisecondsSinceEpoch.toString());

    // messages.insert(0, greetingMessage);
    // update(["chat"]);

    // 这个地方得设计下
    if (Get.arguments == null) {
      initCurrentActivity();
    } else {
      activity.value = Get.arguments;
    }

    textEditingController = TextEditingController();
    update(["chat"]);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initLive2D(UserAIConfig config) {
    LocalServer.start();
    // 替换为你需要的角色 URL
    String url =
        "${LocalServer.baseUrl}/index.html?roleName=${config.characterCode}";
    LocalServer.start();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent) // 背景透明
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print("加载进度: $progress%");
          },
          onPageFinished: (String url) {
            // 再延迟2秒，确保人物加载完成
          },
        ),
      )
      ..addJavaScriptChannel(
        'ToFlutter',
        onMessageReceived: (JavaScriptMessage message) {
          _handleLive2DInteraction(message.message);
          final data = jsonDecode(message.message);
          if (data['event'] == 'init' && data['message'] == 'done') {
            Future.delayed(const Duration(milliseconds: 300), () {
              showBubble(config.openingStatement);
              isModelLoaded.value = true;
            });
          }
        },
      )
      ..loadRequest(Uri.parse(url));
  }

  void _handleLive2DInteraction(String data) {
    print("Live2D 交互: $data");
    // 可以在这里加震动反馈，或者让人物说句话
    if (data.contains("head") || data.contains("tap")) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void onClose() {
    focusNode.dispose();
    super.onClose();
  }

  void clearMsg() {
    messages.clear();
    update(["chat"]);
  }

  void deleteExpense(expenseId) {
    HttpRequest.request(
        Method.delete, "/expense/$expenseId/${activity.value.activityId}",
        success: (data) {
      eventBus.fire(const NeedRefreshData(
          refreshChartsList: true,
          refreshActivityList: true,
          refreshCurrentActivity: true));
      Get.back();
      messages.removeWhere((element) => element.id == expenseId);
      update(["chat"]);
    });
  }

  void setKeyboardModeAndRequestFocus() {
    keyboardMode.value = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  // 播放音频
  void tts(String text, BuildContext context) {
    PremiumGlassDialog.show(context, title: "播放语音？", onConfirm: () {
      Get.back();
      BrnLoadingDialog.show(context);
      HttpRequest.request(Method.get,
          "/ai/tts?sentence=$text&activityId=${activity.value.activityId}",
          fail: (code, msg) {}, success: (data) async {
        BrnLoadingDialog.dismiss(context);
        final player = AudioPlayer();
        // 1. 解码 Base64
        Uint8List bytes = base64Decode(data as String);

        // 2. 使用自定义 Source 加载
        await player.setAudioSource(MyBufferSource(bytes));
        player.play(); // 2. 加载并播放
      });
    });
  }

  void _checkAndShowRatingPrompt() {
    try {
      ProfileController profileController = Get.find<ProfileController>();
      if (profileController.shouldShowRatingPrompt()) {
        profileController.showRatingDialog(Get.context!);
      }
    } catch (e) {
      Log().d("ProfileController not found: $e");
    }
  }
}

class MyBufferSource extends StreamAudioSource {
  final List<int> bytes;
  MyBufferSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      contentType: 'audio/mpeg',
      stream: Stream.value(bytes.sublist(start, end)),
    );
  }
}
