// view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:journal/core/app_theme_colors.dart';

import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/pages/tabbar_layout/custom_bottom_bar.dart';
import 'package:journal/routers.dart';
import 'package:journal/services/guide_manager.dart';
import 'package:journal/services/widget_service.dart';
import 'package:showcaseview/showcaseview.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const _welcomeGuideId = 'home_overview_v2';

  @override
  void initState() {
    super.initState();

    ShowcaseView.register(
      blurValue: 1,
      enableAutoScroll: true,
      globalTooltipActions: const [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: '跳过',
          backgroundColor: Colors.transparent,
          textStyle: TextStyle(color: Color(0xFF697279), fontSize: 12),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: '下一步',
          backgroundColor: Color(0xFF2D3436),
          textStyle: TextStyle(color: Colors.white, fontSize: 12),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ],
    );

    Get.find<LayoutController>().onReplayGuide =
        () => _showWelcomeGuide(force: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showWelcomeGuide();
    });

    _checkForWidgetLaunch();

    // 2. 监听 App 在后台时被 Widget 唤起
    HomeWidget.widgetClicked.listen((Uri? uri) {
      _handleWidgetUri(uri);
    });
  }

  // 检查冷启动
  void _checkForWidgetLaunch() async {
    await WidgetSyncService.setAppGroupId();

    Uri? widgetUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (widgetUri != null) {
      _handleWidgetUri(widgetUri);
    }
  }

  // 统一处理跳转逻辑
  void _handleWidgetUri(Uri? uri) async {
    await WidgetSyncService.setAppGroupId();
    if (uri != null && uri.scheme == 'journal' && uri.host == 'widget_1') {
      Get.toNamed(Routers.ChatDetailPageUrl);
    }
  }

  @override
  void dispose() {
    Get.find<LayoutController>().onReplayGuide = null;
    ShowcaseView.get().unregister();
    super.dispose();
  }

  void _showWelcomeGuide({bool force = false}) {
    if (!mounted) return;
    final controller = Get.find<LayoutController>();
    if (force) {
      final homeIndex =
          controller.activeTabs.indexWhere((tab) => tab.id == 'home');
      if (homeIndex >= 0 && controller.pageController.hasClients) {
        controller.pageController.jumpToPage(homeIndex);
        controller.currentIndex.value = homeIndex;
      }
    }
    final targets = controller.guideTargets;
    final enabledIds = controller.activeTabs.map((tab) => tab.id).toSet();
    final currentIndex = controller.currentIndex.value;
    final currentTabId =
        currentIndex >= 0 && currentIndex < controller.activeTabs.length
            ? controller.activeTabs[currentIndex].id
            : null;
    GuideManager.show(
      context,
      featureId: _welcomeGuideId,
      force: force,
      keys: [
        if (currentTabId == 'home') targets.activitySwitcher,
        if (enabledIds.contains('chat')) targets.quickAdd,
        if (enabledIds.contains('misson')) targets.mission,
        if (enabledIds.contains('analytics')) targets.analytics,
        if (enabledIds.contains('profile')) targets.profile,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    LayoutController controller = Get.find<LayoutController>();
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Obx(() => PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            children: controller.activeTabs
                .map((e) => KeyedSubtree(
                      key: ValueKey(e.id),
                      child: e.page ?? const SizedBox.shrink(),
                    ))
                .toList(),
          )),
      bottomNavigationBar: _buildBottomTabBar(context, controller),
    );
  }

  Widget _buildBottomTabBar(BuildContext context, LayoutController controller) {
    final targets = controller.guideTargets;
    return Obx(() {
      if (controller.activeTabs.isEmpty) return const SizedBox();

      return Obx(() => CustomBottomBar(
            tabs: controller.activeTabs.toList(growable: false),
            currentIndex: controller.currentIndex.value,
            guideKeys: {
              'chat': targets.quickAdd,
              'misson': targets.mission,
              'analytics': targets.analytics,
              'profile': targets.profile,
            },
            onTap: (index, tab) {
              controller.jumpToPage(index, tab, context);
            },
            onLongPress: (index, tab) {
              controller.longPress(index, tab, context);
            },
          ));
    });
  }

  @override
  bool get wantKeepAlive => true;
}
