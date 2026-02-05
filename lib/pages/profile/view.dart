import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/cell_group.dart';
import 'package:journal/config/theme_config.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class ProfilePage extends GetView<ProfileController> {
  ProfilePage({super.key});

  @override
// 在你的 ProfilePage 类中替换以下部分

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      id: "profile",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          // 稍微调整背景色，使其更融合
          backgroundColor: backgroundColor,
          // 隐藏默认 AppBar，为了做沉浸式头部，或者保留透明 AppBar
          appBar: null,
          body: _buildView(context),
        );
      },
    );
  }

  // --- 重构的主视图 ---
  Widget _buildView(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(), // 消除回弹的空白，质感更好
      child: Column(
        children: [
          // 1. 头部 (保持不变)
          _buildHeaderSection(context),

          const SizedBox(height: 12),

          // 3. [新增] 常用功能 - 宫格卡片设计
          _buildToolsCard(context),

          const SizedBox(height: 8),

          // 4. 其他设置 - 列表设计 (保留次要功能)
          _buildSettingsList(context),

          SizedBox(height: 20.h),

          // 5. 版本号
          FutureBuilder(
            future: appVersion(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return Text(
                "Version ${snapshot.data ?? ""}",
                style: TextStyle(
                    color: Colors.grey[400], fontSize: 11, letterSpacing: 0.5),
              );
            },
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

// --- 新增：常用功能宫格卡片 ---
  Widget _buildToolsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20), // 内边距大一点，呼吸感
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // 圆角大一点
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // 极淡的阴影
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 小标题，增加层级感
          // const Text(
          //   "常用服务",
          //   style: TextStyle(
          //       fontSize: 15,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.black87),
          // ),
          // const SizedBox(height: 20),

          // 宫格区域
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGridItem(
                icon: Icons.supervisor_account_outlined,
                color: Colors.blueGrey[700]!, // 蓝色
                label: "AI角色",
                onTap: () => Get.toNamed(Routers.AIConfigPageV2Url),
              ),
              _buildGridItem(
                icon: Icons.notifications_active_outlined, // 换了个更有动感的图标
                color: Colors.blueGrey[700]!, // 橙色
                label: "记账提醒",
                onTap: () => Get.toNamed(Routers.ReminderSettingsPageUrl),
              ),
              _buildGridItem(
                icon: Icons.category_outlined,
                color: Colors.blueGrey[700]!, // 绿色
                label: "分类规则", // 缩短文案，"自定义分类规则"太长容易折行
                onTap: () => Get.toNamed(Routers.ClassificationRulesPageUrl),
              ),
              _buildGridItem(
                icon: Icons.science_outlined,
                color: Colors.blueGrey[700]!, // 紫色
                label: "实验室",
                onTap: () => Get.toNamed(Routers.LabPageUrl, arguments: {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 宫格单项组件 ---
  Widget _buildGridItem(
      {required IconData icon,
      required Color color,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 扩大点击区域
      child: Column(
        children: [
          // 图标容器
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // 浅色背景
              borderRadius: BorderRadius.circular(14), // 方圆形
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          // 文字
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- 抽离出的设置列表 (保留列表样式) ---
  Widget _buildSettingsList(BuildContext context) {
    return CellGroup(
      children: [
        Cell(
          title: "联系我们",
          icon: _buildIcon(Icons.headset_mic_outlined, Colors.blueGrey),
          onTap: () => controller.contact(),
        ),
        Cell(
          icon: _buildIcon(Icons.star_outline_rounded, Colors.blueGrey[700]!),
          title: "评价我们",
          onTap: () => controller.showRatingDialog(context),
        ),
        Cell(
          icon: _buildIcon(Icons.privacy_tip_outlined, Colors.blueGrey[700]!),
          title: "隐私协议",
          onTap: () {
            Get.toNamed(Routers.WebViewPageUrl, arguments: {
              "url": "https://blog.uuorb.com/archives/journal-privacy",
              "title": "隐私协议"
            });
          },
        ),
        Cell(
          icon: _buildIcon(Icons.logout, Colors.blueGrey[700]!),
          title: "退出登录",
          onTap: () => controller.logout(context),
        ),
        Cell(
          icon: _buildIcon(Icons.delete_outline, Colors.blueGrey[700]!),
          title: "注销账号",
          // titleStyle: const TextStyle(color: Colors.redAccent), // 文字也变红，警示感
          onTap: () => controller.deleteAccount(context),
        ),
      ],
    );
  }

  // --- 新增：给 Icon 增加一点背景色，显得不那么单调 ---
  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  // --- 核心改造：头部区域 ---
  Widget _buildHeaderSection(BuildContext context) {
    var user = controller.user.value;
    bool isVip = user.vip; // 获取 VIP 状态

    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          bottom: 10, // 稍微减小底部间距
          left: 24, // 稍微加大左边距，显得更大气
          right: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. 头像区域
          GestureDetector(
            onTap: () => controller.changeUserAvatar(context),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.grey.shade100, width: 2), // 极淡的边框
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.avatarUrl,
                      height: 60.r,
                      width: 60.r,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[200], width: 60.r, height: 60.r),
                    ),
                  ),
                ),
                // 如果是 VIP，可以在头像右下角加个小金标，不喜欢的可以注释掉下面这段 Positioned
                if (isVip)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.verified,
                          size: 16, color: Color(0xFFD4AF37)),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 2. 右侧信息区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 第一行：昵称 + VIP徽章
                Row(
                  children: [
                    Flexible(
                      // 防止名字太长溢出
                      child: Text(
                        user.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, // 字重加粗一点
                            fontSize: 20.sp,
                            color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // --- 插入 VIP 徽章 ---
                    _buildVipBadge(isVip),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: user.userId))
                            .then((v) {
                          if (context.mounted) {
                            TDToast.showSuccess("已复制", context: context);
                          }
                        });
                      },
                      child: Text("ID: ${user.userId}",
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontFamily: "DIN")), // 建议用等宽或数字字体
                    ),

                    // 一个极小的分割线
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 1,
                        height: 10,
                        color: Colors.grey[300]),

                    // 编辑按钮
                    GestureDetector(
                      onTap: () {
                        // 你的修改昵称逻辑...
                        // 建议封装成 controller.showEditNameDialog(context);
                        _showEditNameDialog(context, user.nickname);
                      },
                      child: Row(
                        children: [
                          Text("编辑",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600])),
                          Icon(Icons.navigate_next,
                              size: 14, color: Colors.grey[400])
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 新增：低调质感的身份标识 ---
  Widget _buildVipBadge(bool isVip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // 极小的内边距
      decoration: BoxDecoration(
          // VIP用黑底，非VIP用极浅灰底
          color: isVip ? const Color(0xFF2B2B2B) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              // VIP用微弱的金边，非VIP无边框
              color: isVip
                  ? const Color(0xFFFFD700).withOpacity(0.3)
                  : Colors.transparent,
              width: 0.5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Icon(
            isVip
                ? Icons.workspace_premium
                : Icons.person_outline, // VIP用勋章，普通用人头
            size: 10, // 极小图标
            color:
                isVip ? const Color(0xFFFFD700) : Colors.grey[500], // 金色 vs 灰色
          ),
          const SizedBox(width: 3),
          // 文字
          Text(
            isVip ? "PRO" : "Basic", // 文案
            style: TextStyle(
                fontSize: 9, // 极小字体
                fontWeight: FontWeight.w900,
                // VIP用金色字，非VIP用灰色字
                color: isVip ? const Color(0xFFFFD700) : Colors.grey[500],
                height: 1.1),
          ),
        ],
      ),
    );
  }

  // 辅助方法：把原来的 Dialog 逻辑提出来，保持代码整洁
  void _showEditNameDialog(BuildContext context, String currentName) {
    controller.nicknameTextEditController.text = currentName;
    PremiumGlassDialog.show(context,
        title: "修改昵称",
        textInputAction: TextInputAction.done,
        confirmText: "确认", onConfirmWithInput: (v) {
      if (v.isEmpty) {
        Get.back();
      } else {
        controller.modifyNickname(v, context);
      }
    });
  }

  static Future<String> appVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
