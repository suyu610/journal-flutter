import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/app_tab_item.dart';
import 'package:journal/models/user.dart';
import 'package:journal/pages/activity_list/view.dart';
import 'package:journal/pages/charts/view.dart';
import 'package:journal/pages/chat/view.dart';
import 'package:journal/pages/current_activity/view.dart';
import 'package:journal/pages/profile/view.dart';
import 'package:journal/request/request.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/sp_util.dart';

class LayoutController extends GetxController {
  late PageController pageController;

  RxMap systemConfig = {}.obs;
// 1. 定义全量 Tab 池 (注意顺序)
  // 这里把所有可能的页面都列出来
  late List<AppTabItem> allTabsPool;

  // 2. 当前生效的 Tab 列表 (响应式)
  RxList<AppTabItem> activeTabs = <AppTabItem>[].obs;
  RxInt currentIndex = 0.obs;
  Rx<User> user = User(
          createTime: "",
          userId: '',
          nickname: '',
          vip: false,
          avatarUrl: 'https://cdn.uuorb.com/blog/suyu_LOGO_Full.png')
      .obs;

  RxBool hideTabbar = false.obs;

  void longPress(int index, AppTabItem tab) {
    if (tab.id == 'chat') {
      // 震动
      HapticFeedback.mediumImpact();
      // 检查逻辑
      if (user.value.currentActivityId == "") {
        Get.toNamed(Routers.CreateActivityUrl);
      } else {
        Get.toNamed(Routers.ExpenseItemPageUrl, arguments: {
          "mode": "create",
          "activityId": user.value.currentActivityId
        });
      }
      return;
    } else {
      jumpToPage(index, tab);
    }
  }

  void jumpToPage(int index, AppTabItem tab) {
    // 如果是第一次点击聊天按钮，则告诉他，长按可以进入自定义账本创建页面
    if (tab.id == 'chat') {
      if (user.value.currentActivityId == "") {
        Get.toNamed(Routers.CreateActivityUrl);
      } else {
        // 这里的 ChatDetailPageUrl 应该是一个新路由页面（Scaffold）
        Get.toNamed(Routers.ChatDetailPageUrl);
      }
      return;
    }

    // 2. 如果是普通 Tab (首页、列表、个人中心)
    // 切换 PageView
    pageController.jumpToPage(index);
    // 更新选中状态
    currentIndex.value = index;
  }

  void _initTabsPool() {
    // 1. 每次初始化先创建标准的池子 (默认全是 enabled = true)
    allTabsPool = [
      AppTabItem(
          id: 'home',
          label: '当前活动',
          icon: Icons.home_outlined,
          page: const CurrentActivityPage()),
      AppTabItem(
          id: 'folder',
          label: '活动列表',
          icon: Icons.folder_outlined,
          page: const ActivityListPage()),
      // AppTabItem(
      //     id: 'folder',
      //     label: '小树苗',
      //     icon: Icons.forest_outlined,
      //     page: ForestPage()),
      AppTabItem(
          id: 'chat', label: '聊天', icon: Icons.add, page: const ChatPage()),
      AppTabItem(
          id: 'analytics',
          label: '数据统计',
          icon: Icons.analytics_outlined,
          page: const ChartsPage(),
          isVipOnly: false),
      AppTabItem(
          id: 'profile',
          label: '个人中心',
          icon: Icons.person_outline,
          page: ProfilePage()),
    ];

    // 2.【新增】从本地读取“被禁用”的 Tab ID 列表
    List<String> disabledTabIds =
        SpUtil().getDisabledTabs(); // 需要在 SpUtil 补这个方法

    // 3.【新增】应用禁用状态
    for (var tab in allTabsPool) {
      if (disabledTabIds.contains(tab.id)) {
        tab.isEnabled = false;
      }
    }

    // 4. 读取排序并应用 (原有的逻辑)
    List<String> order = SpUtil().getTabOrder();
    if (order.isNotEmpty) {
      allTabsPool.sort((a, b) {
        int indexA = order.indexOf(a.id);
        int indexB = order.indexOf(b.id);
        // 如果是新加的功能(不在旧缓存里)，放到最后
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;
        return indexA - indexB;
      });
    }

    // 5. 刷新生效列表
    _refreshActiveTabs();
  }

// 给设置页调用的方法：更新排序和开关
  // 给设置页调用的方法
  void updateTabsOrder(List<AppTabItem> newOrder) {
    allTabsPool = newOrder; // 更新内存中的顺序和状态(newOrder里已经包含了isEnabled的变化)

    _refreshActiveTabs(); // 重新计算显示列表
    update(); // 触发 UI 刷新

    // 1. 保存顺序
    SpUtil().saveTabOrder(newOrder.map((tab) => tab.id).toList());

    // 2.【新增】保存禁用的 Tab 列表
    // 筛选出所有 isEnabled 为 false 的 ID 存起来
    List<String> disabledIds =
        newOrder.where((tab) => !tab.isEnabled).map((tab) => tab.id).toList();
    SpUtil().saveDisabledTabs(disabledIds); // 需要在 SpUtil 补这个方法
  }

  // 核心逻辑：计算当前应该显示哪些 Tab
  void _refreshActiveTabs() {
    // 逻辑：
    var newList = allTabsPool.where((tab) {
      if (tab.isVipOnly && !user.value.vip) return false;
      return tab.isEnabled;
    }).toList();

    activeTabs.assignAll(newList);

    // 如果当前选中的索引超出了新列表的范围，重置为 0
    if (currentIndex.value >= activeTabs.length) {
      currentIndex.value = 0;
      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _fetchUserProfile() {
    HttpRequest.request(
      Method.get,
      "/user/profile/me",
      success: (data) {
        user.value = User.fromJson(data as Map<String, dynamic>);
        // 获取完用户信息后，一定要手动刷新一次 Tab，因为 VIP 状态可能变了
        _refreshActiveTabs();
      },
      fail: (code, msg) => Log().d(msg),
    );
  }

  void _fetchSystemConfig() {
    // 获取系统设置
    HttpRequest.request(
      Method.get,
      "/system/config/all",
      success: (data) {
        for (var item in data as List<dynamic>) {
          systemConfig[item['key']] = item['value'];
          Log().d(item['key']);
          Log().d(item['value']);
        }
      },
      fail: (code, msg) => Log().d(msg),
    );
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0, keepPage: true);

    // 初始化 Tab 池
    _initTabsPool();

    // 监听 VIP 状态变化，一旦变化重新计算 Tabs
    ever(user, (_) => _refreshActiveTabs());

    // 原有的网络请求...
    _fetchUserProfile();
    _fetchSystemConfig();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
    Log().d("layout onClose");
  }
}
