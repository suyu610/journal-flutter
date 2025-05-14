import 'dart:convert';

import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:journal/core/log.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/pages/activity_list/controller.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';
import 'package:journal/util/sp_util.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ChatController extends GetxController {
  ChatController();

  RxString bgImage = "".obs;

  // 添加这一行
  final isLongPressing = false.obs;

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

  _initData() async {
    update(["chat"]);
  }

  void handleSendPressed(types.PartialText message) {
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
    update(['id']);
    if (keyboardMode.value) {
      focusNode.requestFocus();
    }

    formatAndReply(textMessage.text, loadingMessage.id);
  }

  void formatAndReply(text, id) {
    HttpRequest.request(
      Method.get,
      "/ai/format?sentence=$text&activityId=${activity.value.activityId}",
      fail: (code, msg) {
        messages.removeWhere((element) => element.id == id);
        var reMessage = types.TextMessage(
            author: aiUser,
            text: "未能获取有效信息",
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: DateTime.now().millisecondsSinceEpoch.toString());
        // 删除思考中...
        messages.insert(0, reMessage);
        update(["chat"]);
      },
      success: (data) {
        praise(text);

        try {
          Expense expense = Expense.fromJson(data as Map<String, dynamic>);
          Log().d("expense.expenseId${expense.expenseId}");
          var reMessage = types.CustomMessage(
              author: aiUser,
              metadata: {"msgType": "expense", ...expense.toJson()},
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: expense.expenseId);
          messages.removeWhere((element) => element.id == id);
          messages.insert(0, reMessage);
          update(["chat"]);
          eventBus.fire(const NeedRefreshData(
              refreshChartsList: true,
              refreshActivityList: true,
              refreshCurrentActivity: true));
        } catch (e) {
          Log().d(e.toString());
          var reMessage = types.TextMessage(
              author: aiUser,
              text: data.toString(),
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: DateTime.now().millisecondsSinceEpoch.toString());
          messages.insert(0, reMessage);
          update(["chat"]);
        }
      },
    );
  }

  void praise(sentence) {
    var uuid = DateTime.now().millisecondsSinceEpoch.toString();
    HttpRequest.request<Stream>(
      Method.get,
      "/ai/praise/stream?sentence=$sentence&activityId=${activity.value.activityId}",
      isStream: true,
      success: (stream) {
        var praiseMessage = types.TextMessage(
            author: aiUser,
            text: "对方正在输入...",
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: uuid);
        messages.insert(0, praiseMessage);
        processStreamResponse(stream, uuid);
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

  @override
  void onInit() {
    super.onInit();
    if (Get.find<LayoutController>().user.value.vip) {
      bgImage.value = SpUtil.getChatBg() ?? "";
    } else {
      bgImage.value = "";
    }

    setKeyboardModeAndRequestFocus();

    var greetingMessage = types.TextMessage(
        author: aiUser,
        text: "你好，我是你的财务助手，有什么可以帮助你的吗？",
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().millisecondsSinceEpoch.toString());

    messages.insert(0, greetingMessage);
    update(["chat"]);

    // 这个地方得设计下
    if (Get.arguments == null) {
      Activity? activatedActivity = Get.find<ActivityListController>()
          .activityList
          .firstWhereOrNull((activity) => activity.activated);
      if (activatedActivity != null) {
        activity.value = activatedActivity;
      } else {
        activity.value = Get.find<ActivityListController>().activityList.first;
      }
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
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return TDAlertDialog(
            buttonStyle: TDDialogButtonStyle.text,
            title: "播放语音？",
            rightBtn: TDDialogButtonOptions(
                title: "播放",
                action: () {
                  Get.back();
                  BrnLoadingDialog.show(context);

                  HttpRequest.request(Method.get,
                      "/ai/tts?sentence=$text&activityId=${activity.value.activityId}",
                      fail: (code, msg) {}, success: (data) async {
                    BrnLoadingDialog.dismiss(context);
                    Log().d("tts:$data");
                    final player = AudioPlayer();
                    await player.setUrl(data as String);
                    player.play();
                  });
                }),
          );
        });
  }
}
