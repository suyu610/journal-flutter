// view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

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
  final GlobalKey _addBtnKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    ShowcaseView.register(
      blurValue: 1,
      autoPlayDelay: const Duration(seconds: 3),
    );

    // 一行代码搞定
    GuideManager.show(
      context,
      featureId: 'home_manual_record_v1', // 唯一ID
      keys: [_addBtnKey],
    );

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
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    LayoutController controller = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            children: controller.activeTabs.map((e) => e.page).toList(),
          )),
      bottomNavigationBar: _buildBottomTabBar(context, controller),
    );
  }

  Widget _buildBottomTabBar(BuildContext context, LayoutController controller) {
    return Obx(() {
      if (controller.activeTabs.isEmpty) return const SizedBox();

      return Obx(() => CustomBottomBar(
            tabs: controller.activeTabs,
            currentIndex: controller.currentIndex.value,
            specialButtonKey: _addBtnKey,
            onTap: (index, tab) {
              controller.jumpToPage(index, tab);
            },
            onLongPress: (index, tab) {
              controller.longPress(index, tab);
            },
          ));
    });
  }

  @override
  bool get wantKeepAlive => true;
}
