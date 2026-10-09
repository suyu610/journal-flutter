import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_toast.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/app_tab_item.dart';
import 'package:journal/models/user.dart';

import 'package:journal/pages/charts/view.dart';
import 'package:journal/pages/chat/view.dart';
import 'package:journal/pages/current_activity/view.dart';
import 'package:journal/pages/expense/view.dart';
import 'package:journal/pages/lab/controller.dart';
import 'package:journal/pages/lab/smart_merge/view.dart';
import 'package:journal/pages/mission_dashboard/view.dart';
import 'package:journal/pages/profile/controller.dart';
import 'package:journal/pages/profile/view.dart';
import 'package:journal/pages/tabbar_layout/manual_expense_activity.dart';
import 'package:journal/request/request.dart';
import 'package:journal/routers.dart';
import 'package:journal/services/guide_manager.dart';
import 'package:journal/util/sp_util.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

class LayoutController extends GetxController {
  final guideTargets = GuideTargets();
  VoidCallback? onReplayGuide;
  late PageController pageController;

  void replayGuide() => onReplayGuide?.call();
  final XgFlutterPlugin tpush = XgFlutterPlugin();

  RxMap systemConfig = {}.obs;

  // 推送相关
  Future<void> initPlatformState(String userId) async {
    /// 开启DEBUG
    tpush.setEnableDebug(true);
    tpush.setAccount(userId, AccountType.UNKNOWN);

    /// 添加回调事件
    tpush.addEventHandler(
      /// TPNS注册失败会走此回调
      onRegisteredDeviceToken: (String msg) async {
        print("[push] onRegisteredDeviceToken: $msg");
      },

      /// TPNS注册成功会走此回调
      onRegisteredDone: (String msg) async {
        HttpRequest.request(Method.post, "/user/device?deviceId=$msg");
      },
      unRegistered: (String msg) async {
        print("[push] unRegistered: $msg");
      },
      onReceiveNotificationResponse: (Map<String, dynamic> msg) async {
        print("[push] onReceiveNotificationResponse $msg");
      },
      onReceiveMessage: (Map<String, dynamic> msg) async {},
      xgPushNetworkConnected: (String msg) async {
        print("[push] xgPushNetworkConnected: $msg");
      },
      xgPushDidSetBadge: (String msg) async {
        print("[push] xgPushDidSetBadge: $msg");

        // _showAlert(msg);
      },

      /// V1.2.8开始返回类型由String->Map，新增code及type标识！
      xgPushDidBindWithIdentifier: (Map<String, dynamic> result) async {
        print("[push] xgPushDidBindWithIdentifier: $result");

        // _showAlert(result["msg"]);
      },

      /// V1.2.8开始返回类型由String->Map，新增code及type标识！
      xgPushDidUnbindWithIdentifier: (Map<String, dynamic> result) async {},

      /// V1.2.8开始返回类型由String->Map，新增code及type标识！
      xgPushDidUpdatedBindedIdentifier: (Map<String, dynamic> result) async {},

      /// V1.2.8开始返回类型由String->Map，新增code及type标识！
      xgPushDidClearAllIdentifiers: (Map<String, dynamic> result) async {},
      xgPushClickAction: (Map<String, dynamic> msg) async {
        print("[push] xgPushClickAction: $msg");
        print(msg["custom"]);
      },
    );

    tpush.configureClusterDomainName("tpns.sh.tencent.com");

    if (Platform.isIOS) {
      tpush.startXg("1680021651", "IFZ9SASOVVI9");
    } else {
      // todo: 还未适配安卓
      // tpush.startXg("1500004343", "ANCVHDQ0DO3E");
    }
  }

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
  bool _openingManualExpense = false;

  void longPress(int index, AppTabItem tab, BuildContext context) {
    if (tab.id == 'chat') {
      HapticFeedback.mediumImpact();
      openManualExpense(context);
      return;
    } else {
      jumpToPage(index, tab, context);
    }
  }

  void jumpToPage(int index, AppTabItem tab, BuildContext context) {
    if (tab.id == 'chat') {
      openManualExpense(context);
      return;
    }

    if (tab.routeName != null) {
      Get.toNamed(tab.routeName!);
      return;
    }
    if (tab.onOpen != null) {
      tab.onOpen!(context);
      return;
    }

    pageController.jumpToPage(index);
    currentIndex.value = index;
  }

  Future<void> openManualExpense(BuildContext context) async {
    if (_openingManualExpense) return;
    _openingManualExpense = true;

    try {
      final activityId = await resolveManualExpenseActivity(
        currentActivityId: user.value.currentActivityId,
        refreshDefaultActivityId: () async {
          JournalToast.showLoading(context, text: '正在获取账本...');
          try {
            final profile = await _requestData('/user/profile/me');
            user.value = User.fromJson(profile as Map<String, dynamic>);
            return user.value.currentActivityId;
          } finally {
            JournalToast.dismiss();
          }
        },
        loadActivities: () async {
          if (!context.mounted) return [];
          JournalToast.showLoading(context, text: '正在获取账本...');
          try {
            return await _fetchActivities();
          } finally {
            JournalToast.dismiss();
          }
        },
        createActivity: () async {
          if (!context.mounted) return false;
          return await Get.toNamed<bool>(Routers.CreateActivityUrl) == true;
        },
        selectActivity: (activities) async {
          if (!context.mounted) return null;
          return _selectActivity(context, activities);
        },
      );

      if (!context.mounted || activityId == null || activityId.isEmpty) return;
      await showCupertinoModalBottomSheet(
        expand: true,
        context: context,
        barrierColor: Colors.black38,
        settings: RouteSettings(
          arguments: {'mode': 'create', 'activityId': activityId},
        ),
        builder: (_) => const ExpenseItemPage(),
      );
    } catch (error) {
      Log().d('打开记账页失败: $error');
      if (context.mounted) {
        JournalToast.showError(context, '获取账本失败，请稍后重试');
      }
    } finally {
      _openingManualExpense = false;
    }
  }

  Future<dynamic> _requestData(String path) async {
    final response = await HttpRequest.request<dynamic>(Method.get, path);
    if (response is! Map || response['code'] != 0) {
      throw StateError('请求 $path 失败');
    }
    return response['data'];
  }

  Future<List<Activity>> _fetchActivities() async {
    final data = await _requestData('/activity/list/all');
    if (data is! List) throw const FormatException('账本列表格式错误');
    return data
        .map((item) => Activity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Activity?> _selectActivity(
    BuildContext context,
    List<Activity> activities,
  ) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return showModalBottomSheet<Activity>(
      context: context,
      backgroundColor: colors.backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  '选择记账账本',
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ListTile(
                      leading: Icon(
                        Icons.book_outlined,
                        color: colors.primaryText,
                      ),
                      title: Text(
                        activity.activityName,
                        style: TextStyle(color: colors.primaryText),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colors.secondaryText,
                      ),
                      onTap: () => Navigator.of(sheetContext).pop(activity),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openActivityFeature(BuildContext context, String route) async {
    try {
      final activities = await _fetchActivities();
      if (!context.mounted) return;
      if (activities.isEmpty) {
        await Get.toNamed(Routers.ActivityListPageUrl);
        return;
      }
      final defaultId = user.value.currentActivityId;
      Activity? activity;
      for (final candidate in activities) {
        if (candidate.activityId == defaultId) {
          activity = candidate;
          break;
        }
      }
      activity ??= activities.length == 1
          ? activities.first
          : await _selectActivity(context, activities);
      if (activity != null && context.mounted) {
        await Get.toNamed(route, arguments: activity);
      }
    } catch (error) {
      Log().d('打开账本功能失败: $error');
      if (context.mounted) {
        JournalToast.showError(context, '获取账本失败，请稍后重试');
      }
    }
  }

  void _initTabsPool() {
    // 1. 每次初始化先创建标准的池子 (默认全是 enabled = true)
    allTabsPool = [
      AppTabItem(
          id: 'home',
          label: '当前账本',
          icon: Icons.home_outlined,
          page: CurrentActivityPage(
              activitySwitcherGuideKey: guideTargets.activitySwitcher)),
      // AppTabItem(
      //     id: 'folder',
      //     label: '账本列表',
      //     icon: Icons.folder_outlined,
      //     page: const ActivityListPage()),
      AppTabItem(
          id: 'misson',
          label: '面板',
          icon: Icons.bookmark_outline_rounded,
          page: const MissionPage(),
          isEnabled: true),
      // AppTabItem(
      //     id: 'template_page',
      //     label: '模板库',
      //     icon: Icons.card_travel,
      //     page: const TemplateListPage(),
      //     isEnabled: true),
      AppTabItem(
          id: 'chat', label: '记账', icon: Icons.add, page: const ChatPage()),
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
      AppTabItem(
          id: 'activity_list',
          label: '账本列表',
          icon: Icons.folder_outlined,
          routeName: Routers.ActivityListPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'expense_list',
          label: '账单明细',
          icon: Icons.receipt_long_outlined,
          onOpen: (context) =>
              _openActivityFeature(context, Routers.ExpenseListPageUrl),
          isEnabled: false),
      AppTabItem(
          id: 'create_activity',
          label: '创建账本',
          icon: Icons.create_new_folder_outlined,
          routeName: Routers.CreateActivityUrl,
          isEnabled: false),
      AppTabItem(
          id: 'join_activity',
          label: '加入账本',
          icon: Icons.group_add_outlined,
          routeName: Routers.JoinActivityPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'invite',
          label: '邀请成员',
          icon: Icons.person_add_alt_outlined,
          onOpen: (context) =>
              _openActivityFeature(context, Routers.InvitePageUrl),
          isEnabled: false),
      AppTabItem(
          id: 'categories',
          label: '分类管理',
          icon: Icons.category_outlined,
          routeName: Routers.ExpenseCategoryPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'assistant',
          label: 'AI聊天',
          icon: Icons.chat_bubble_outline,
          routeName: Routers.ChatDetailPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'ai_config',
          label: 'AI角色',
          icon: Icons.smart_toy_outlined,
          routeName: Routers.AIConfigPageV2Url,
          isEnabled: false),
      AppTabItem(
          id: 'reminders',
          label: '提醒设置',
          icon: Icons.notifications_outlined,
          routeName: Routers.ReminderSettingsPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'item_library',
          label: '物品库',
          icon: Icons.inventory_2_outlined,
          routeName: Routers.ItemLibraryPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'templates',
          label: '模板库',
          icon: Icons.view_list_outlined,
          routeName: Routers.TemplateListPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'trips',
          label: '行程清单',
          icon: Icons.checklist_outlined,
          routeName: Routers.TripChecklistPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'lab',
          label: '实验室',
          icon: Icons.science_outlined,
          routeName: Routers.LabPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'classification_rules',
          label: '分类规则',
          icon: Icons.rule_outlined,
          routeName: Routers.ClassificationRulesPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'smart_merge',
          label: '智能合并',
          icon: Icons.auto_awesome_outlined,
          onOpen: (_) async => Get.to(const SmartMergePage()),
          isEnabled: false),
      AppTabItem(
          id: 'sankey',
          label: '桑基图分析',
          icon: Icons.hub_outlined,
          onOpen: (_) async => LabController().nav2SankeyChart(),
          isEnabled: false),
      AppTabItem(
          id: 'random_photo',
          label: '随机照片',
          icon: Icons.photo_outlined,
          routeName: Routers.RandomPhotoPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'local_service',
          label: '本地服务',
          icon: Icons.lan_outlined,
          routeName: Routers.LocalServicePageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'fish_tank',
          label: '电子鱼缸',
          icon: Icons.water_outlined,
          routeName: Routers.FishTankFlamePageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'money_jar',
          label: '存钱罐',
          icon: Icons.savings_outlined,
          routeName: Routers.MoneyJarPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'growing_tree',
          label: '许愿树',
          icon: Icons.park_outlined,
          routeName: Routers.GrowingTreeUrl,
          isEnabled: false),
      AppTabItem(
          id: 'tabbar_settings',
          label: '导航排序',
          icon: Icons.tune_outlined,
          routeName: Routers.TabBarSettingPageUrl,
          isEnabled: false),
      AppTabItem(
          id: 'more',
          label: '更多功能',
          icon: Icons.more_horiz,
          onOpen: (_) async {
            if (!Get.isRegistered<ProfileController>()) {
              Get.put(ProfileController());
            }
            await Get.toNamed(Routers.MoreFunctionPageUrl);
          },
          isEnabled: false),
    ];

    // 2.【新增】从本地读取“被禁用”的 Tab ID 列表
    List<String> disabledTabIds = SpUtil().getDisabledTabs();

    // 3.【新增】应用禁用状态
    for (var tab in allTabsPool) {
      if (tab.id != 'profile' && disabledTabIds.contains(tab.id)) {
        tab.isEnabled = false;
      }
    }

    // 4. 读取排序并应用 (原有的逻辑)
    List<String> order = SpUtil().getTabOrder();
    if (order.isNotEmpty) {
      final originalPositions = {
        for (var index = 0; index < allTabsPool.length; index++)
          allTabsPool[index].id: index,
      };
      allTabsPool.sort((a, b) {
        int indexA = order.indexOf(a.id);
        int indexB = order.indexOf(b.id);
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;
        final comparison = indexA.compareTo(indexB);
        return comparison != 0
            ? comparison
            : originalPositions[a.id]!.compareTo(originalPositions[b.id]!);
      });
    }

    // 5. 刷新生效列表
    _refreshActiveTabs();
  }

  // 给设置页调用的方法：更新排序和开关
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
    final selectedId = currentIndex.value < activeTabs.length
        ? activeTabs[currentIndex.value].id
        : 'home';
    var newList = allTabsPool.where((tab) {
      if (tab.isVipOnly && !user.value.vip) return false;
      return tab.isEnabled;
    }).toList();

    activeTabs.assignAll(newList);
    var selectedIndex = activeTabs
        .indexWhere((tab) => tab.id == selectedId && tab.page != null);
    selectedIndex = selectedIndex != -1
        ? selectedIndex
        : activeTabs.indexWhere((tab) => tab.id == 'home' && tab.page != null);
    selectedIndex = selectedIndex != -1
        ? selectedIndex
        : activeTabs.indexWhere((tab) => tab.page != null);
    if (selectedIndex == -1) return;
    currentIndex.value = selectedIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed && pageController.hasClients) {
        pageController.jumpToPage(selectedIndex);
      }
    });
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
        initPlatformState(user.value.userId);
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
