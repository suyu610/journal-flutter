import 'package:flutter/material.dart';
import 'package:journal/util/sp_util.dart';
import 'package:showcaseview/showcaseview.dart';

class GuideTargets {
  final activitySwitcher = GlobalKey();
  final quickAdd = GlobalKey();
  final mission = GlobalKey();
  final analytics = GlobalKey();
  final profile = GlobalKey();
}

class GuideManager {
  static void show(
    BuildContext context, {
    required String featureId,
    required List<GlobalKey> keys,
    bool force = false,
  }) {
    if (!force && SpUtil.hasShownGuide(featureId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted || (!force && SpUtil.hasShownGuide(featureId))) {
        return;
      }
      if (keys.isEmpty) return;
      _runShowcase(featureId, keys);
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  static void _runShowcase(String featureId, List<GlobalKey> keys) {
    try {
      final showcase = ShowcaseView.get();
      if (showcase.isShowcaseRunning) return;
      showcase.startShowCase(keys);
      SpUtil.setGuideShown(featureId);
    } catch (e) {
      debugPrint('引导启动失败: $e');
    }
  }
}
