// view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:journal/pages/activity_list/index.dart';
import 'package:journal/pages/charts/index.dart';
import 'package:journal/pages/current_activity/index.dart';
import 'package:journal/pages/profile/index.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

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
      // 动态 PageView
      body: Obx(() => PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            // 直接映射 activeTabs 里的 page
            children: controller.activeTabs.map((e) => e.page).toList(),
          )),
      // 动态 TabBar
      bottomNavigationBar: _buildBottomTabBar(context, controller),
    );
  }

  Widget _buildBottomTabBar(BuildContext context, LayoutController controller) {
    // return Text(controller.activeTabs.map((e) => e.id).toList().toString());
    return Obx(() {
      // 如果没有 tab (极少情况)，返回空
      if (controller.activeTabs.isEmpty) return const SizedBox();

      return Obx(() => TDBottomTabBar(
            TDBottomTabBarBasicType.icon,
            useVerticalDivider: false,
            currentIndex: controller.currentIndex.value,
            barHeight: 60,
            backgroundColor: Colors.white,
            // 动态映射 activeTabs 到 TDBottomTabBarTabConfig
            navigationTabs: controller.activeTabs.map((tab) {
              return TDBottomTabBarTabConfig(
                selectedIcon: Icon(tab.icon, color: Colors.black), // 选中黑色
                unselectedIcon: Icon(tab.icon, color: Colors.grey), // 未选中灰色
                onTap: () {
                  // 找到当前 tab 在 activeTabs 里的真实索引
                  int index = controller.activeTabs.indexOf(tab);
                  controller.jumpToPage(index);
                },
              );
            }).toList(),
          ));
    });
  }

  @override
  bool get wantKeepAlive => true;
}
