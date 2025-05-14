
import 'dart:ui';

bool voiceSendEnough = false;

enum VoiceMessageSendWidgetStatus{
  recording,
  end,
}

class VoiceTouchPointChange{

  final Offset? position; //空代表手指停止移动，  有值代表手指正在移动
  final VoiceMessageSendWidgetStatus status;

  VoiceTouchPointChange(this.position, this.status);
}