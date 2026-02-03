import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于震动反馈
import 'package:get/get.dart';
import 'package:journal/models/app_tab_item.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';

class TabBarSettingPage extends StatefulWidget {
  const TabBarSettingPage({Key? key}) : super(key: key);

  @override
  State<TabBarSettingPage> createState() => _TabBarSettingPageState();
}

class _TabBarSettingPageState extends State<TabBarSettingPage> {
  late LayoutController layoutCtrl;
  late List<AppTabItem> _tempTabs;

  @override
  void initState() {
    super.initState();
    layoutCtrl = Get.find<LayoutController>();
    // 深拷贝列表，以免修改影响原数据
    _tempTabs = List.from(layoutCtrl.allTabsPool);
  }

  void _onSave() {
    layoutCtrl.updateTabsOrder(_tempTabs);
    Get.back();
    Get.snackbar(
      "设置已生效",
      "底部菜单布局已更新",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // 浅灰背景，突出卡片
      appBar: AppBar(
        title: const Text("自定义菜单"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text("保存",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "长按拖拽排序，点击开关隐藏",
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _tempTabs.length,
              // 1. 优化拖拽时的视觉效果 (ProxyDecorator)
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    final double animValue =
                        Curves.easeInOut.transform(animation.value);
                    final double elevation = lerpDouble(0, 10, animValue)!;
                    final double scale = lerpDouble(1, 1.02, animValue)!;
                    return Transform.scale(
                      scale: scale,
                      child: Material(
                        elevation: elevation,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        shadowColor: Colors.black26,
                        child: child,
                      ),
                    );
                  },
                  child: child,
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _tempTabs.removeAt(oldIndex);
                  _tempTabs.insert(newIndex, item);
                });
                // 增加震动反馈
                HapticFeedback.lightImpact();
              },
              itemBuilder: (context, index) {
                return _buildCardItem(index, _tempTabs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(int index, AppTabItem item) {
    // 逻辑：判断是否被锁定 (个人中心 profile 强制不许关)
    bool isProfile = item.id == 'profile';
    // 逻辑：判断是否是VIP功能且用户非VIP
    bool isVipFeatureButNotVip = item.isVipOnly && !layoutCtrl.user.value.vip;

    // 决定是否禁用 Switch
    bool isSwitchDisabled = isProfile || isVipFeatureButNotVip;

    return Container(
      key: ValueKey(item.id), // 必须有Key
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // 左侧图标容器
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isVipFeatureButNotVip
                ? Colors.grey[100]
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon,
              color: isVipFeatureButNotVip ? Colors.grey : Colors.black87),
        ),
        // 标题
        title: Row(
          children: [
            Text(
              item.label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isVipFeatureButNotVip ? Colors.grey : Colors.black87),
            ),
            if (item.isVipOnly) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("PRO",
                    style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
        // 副标题 (显示锁定原因)
        subtitle: isProfile
            ? const Text("系统核心模块不可隐藏",
                style: TextStyle(fontSize: 10, color: Colors.blueGrey))
            : (isVipFeatureButNotVip
                ? const Text("需订阅会员解锁",
                    style: TextStyle(fontSize: 10, color: Colors.grey))
                : null),

        // 右侧操作区
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 开关
            Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                value: item.isEnabled,
                activeColor: Colors.black,
                activeTrackColor: Colors.blueGrey[900],
                onChanged: isSwitchDisabled
                    ? null
                    : (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          item.isEnabled = val;
                        });
                      },
              ),
            ),
            const SizedBox(width: 8),
            // 拖拽手柄
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.transparent, // 扩大触摸区域
                child: const Icon(Icons.drag_indicator, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
