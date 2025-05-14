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
      body: Obx(() => PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            children: controller.user.value.vip
                ? [
                    const CurrentActivityPage(),
                    const ActivityListPage(),
                    const ChartsPage(),
                    ProfilePage(),
                  ]
                : [
                    const CurrentActivityPage(),
                    const ActivityListPage(),
                    ProfilePage(),
                  ],
          )),
      bottomNavigationBar: _buildBottomTabBar(context, controller),
    );
  }

  Widget _buildBottomTabBar(BuildContext context, LayoutController controller) {
    return Obx(() => TDBottomTabBar(
          TDBottomTabBarBasicType.iconText,
          useVerticalDivider: false,
          currentIndex: controller.currentIndex.value,
          barHeight: 60,
          backgroundColor: Colors.white,
          navigationTabs: controller.user.value.vip
              ? [
                  TDBottomTabBarTabConfig(
                    tabText: '首页',
                    selectedIcon: const Icon(Icons.home_outlined,
                        color: Color(0xFF0052D9)),
                    unselectedIcon:
                        const Icon(Icons.home_outlined, color: Colors.grey),
                    onTap: () => controller.jumpToPage(0),
                  ),
                  TDBottomTabBarTabConfig(
                    tabText: '账本',
                    selectedIcon: const Icon(Icons.folder_outlined,
                        color: Color(0xFF0052D9)),
                    unselectedIcon:
                        const Icon(Icons.folder_outlined, color: Colors.grey),
                    onTap: () => controller.jumpToPage(1),
                  ),
                  TDBottomTabBarTabConfig(
                    tabText: '图表',
                    selectedIcon: const Icon(Icons.analytics_outlined,
                        color: Color(0xFF0052D9)),
                    unselectedIcon: const Icon(Icons.analytics_outlined,
                        color: Colors.grey),
                    onTap: () => controller.jumpToPage(2),
                  ),
                  TDBottomTabBarTabConfig(
                    tabText: '我的',
                    selectedIcon: const Icon(Icons.person_outline,
                        color: Color(0xFF0052D9)),
                    unselectedIcon:
                        const Icon(Icons.person_outline, color: Colors.grey),
                    onTap: () => controller.jumpToPage(3),
                  ),
                ]
              : [
                  TDBottomTabBarTabConfig(
                    tabText: '首页',
                    selectedIcon: const Icon(Icons.home_outlined,
                        color: Color(0xFF0052D9)),
                    unselectedIcon:
                        const Icon(Icons.home_outlined, color: Colors.grey),
                    onTap: () => controller.jumpToPage(0),
                  ),
                  TDBottomTabBarTabConfig(
                    tabText: '账本',
                    selectedIcon: const Icon(Icons.folder_outlined,
                        color: Color(0xFF0052D9)),
                    unselectedIcon:
                        const Icon(Icons.folder_outlined, color: Colors.grey),
                    onTap: () => controller.jumpToPage(1),
                  ),
                  TDBottomTabBarTabConfig(
                    tabText: '我的',
                    selectedIcon: const Icon(Icons.person_outline,
                        color: Color(0xFF0052D9)),
                    unselectedIcon:
                        const Icon(Icons.person_outline, color: Colors.grey),
                    onTap: () => controller.jumpToPage(2),
                  ),
                ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
