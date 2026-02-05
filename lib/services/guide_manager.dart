import 'package:flutter/material.dart';
import 'package:journal/util/sp_util.dart';
import 'package:showcaseview/showcaseview.dart';
// import '你的SpHelper路径';

class GuideManager {
  static void show(
    BuildContext context, {
    required String featureId,
    required List<GlobalKey> keys,
    Duration? delay, // 可选：有时需要等一下动画或网络请求
  }) {
    // 1. 先检查是否已经展示过
    if (SpUtil.hasShownGuide(featureId)) {
      return; // 如果展示过，直接结束
    }

    // 2. 等待页面渲染完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 可选：如果需要延迟（比如等底部弹窗动画结束）
      if (delay != null) {
        Future.delayed(delay, () => _runShowcase(featureId, keys));
      } else {
        _runShowcase(featureId, keys);
      }
    });
  }

  static void _runShowcase(String featureId, List<GlobalKey> keys) {
    try {
      ShowcaseView.get().startShowCase(keys);

      // 4. 立刻标记为已展示，防止下次再出
      SpUtil.setGuideShown(featureId);
    } catch (e) {
      // 捕捉异常：有时候页面切换太快，Context可能失效，避免崩溃
      debugPrint('引导启动失败: $e');
    }
  }
}
