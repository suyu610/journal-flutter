// view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/pages/tabbar_layout/custom_bottom_bar.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
            // 点击回调
            onTap: (index, tab) {
              controller.jumpToPage(index, tab);
            },
          ));
    });
  }

  @override
  bool get wantKeepAlive => true;
}
