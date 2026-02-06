import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/cell_group.dart';
import 'package:journal/components/journal_toast.dart';
// 1. 引入你的主题颜色定义
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'index.dart';

class ProfilePage extends GetView<ProfileController> {
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      id: "profile",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          // 背景色跟随主题
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: null,
          body: _buildView(context),
        );
      },
    );
  }

  // --- 重构的主视图 ---
  Widget _buildView(BuildContext context) {
    // 获取当前主题颜色配置
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          // 1. 头部区域 (传入 appColors)
          _buildHeaderSection(context, appColors),

          const SizedBox(height: 12),

          // 2. 常用功能 - 宫格卡片
          _buildToolsCard(context, appColors),

          const SizedBox(height: 12),

          // 3. 其他设置 - 列表
          _buildSettingsList(context, appColors),

          SizedBox(height: 20.h),

          // 4. 版本号
          FutureBuilder(
            future: appVersion(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return Text(
                "Version ${snapshot.data ?? ""}",
                style: TextStyle(
                    color: appColors.secondaryText, // 使用次要文本色
                    fontSize: 11,
                    letterSpacing: 0.5),
              );
            },
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  // --- 头部区域 ---
  Widget _buildHeaderSection(BuildContext context, AppThemeColors appColors) {
    var user = controller.user.value;
    bool isVip = user.vip;

    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          bottom: 20,
          left: 24,
          right: 24),
      // 移除硬编码的 Colors.white，保持透明以展示页面背景，或者使用 cardBackground
      // 这里建议透明，显得更通透
      color: Colors.transparent,
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
                    // 边框颜色适配深色模式
                    border: Border.all(
                        color: appColors.secondaryText.withOpacity(0.2),
                        width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.avatarUrl,
                      height: 64.r, // 稍微加大一点点
                      width: 64.r,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          color: appColors.chartPalette[4], // 使用主题盘里的浅色
                          width: 64.r,
                          height: 64.r),
                    ),
                  ),
                ),
                if (isVip)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: appColors.cardBackground, // 适配背景
                          shape: BoxShape.circle),
                      child: const Icon(Icons.verified,
                          size: 18, color: Color(0xFFD4AF37)),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 20),

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
                      child: Text(
                        user.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            color: appColors.primaryText), // 适配文字颜色
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildVipBadge(isVip, appColors),
                  ],
                ),
                const SizedBox(height: 8),

                // 第二行：ID 和 编辑
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: user.userId))
                            .then((v) {
                          if (context.mounted) {
                            JournalToast.showSuccess(context, "已复制");
                          }
                        });
                      },
                      child: Text("ID: ${user.userId}",
                          style: TextStyle(
                              fontSize: 12,
                              color: appColors.secondaryText, // 适配次要文字
                              fontFamily: "DIN")),
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 1,
                        height: 10,
                        color: appColors.secondaryText.withOpacity(0.3)),
                    GestureDetector(
                      onTap: () => _showEditNameDialog(context, user.nickname),
                      child: Row(
                        children: [
                          Text("编辑",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: appColors.secondaryText)),
                          Icon(Icons.navigate_next,
                              size: 14, color: appColors.secondaryText)
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

  // --- 常用功能宫格卡片 ---
  Widget _buildToolsCard(BuildContext context, AppThemeColors appColors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 适配卡片背景
        borderRadius: BorderRadius.circular(24), // 大圆角
        boxShadow: [
          // 细腻的阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGridItem(
            icon: Icons.supervisor_account_outlined,
            label: "AI角色",
            appColors: appColors,
            onTap: () => Get.toNamed(Routers.AIConfigPageV2Url),
          ),
          _buildGridItem(
            icon: Icons.notifications_none_rounded,
            label: "记账提醒",
            appColors: appColors,
            onTap: () => Get.toNamed(Routers.ReminderSettingsPageUrl),
          ),
          _buildGridItem(
            icon: Icons.category_outlined,
            label: "分类规则",
            appColors: appColors,
            onTap: () => Get.toNamed(Routers.ClassificationRulesPageUrl),
          ),
          _buildGridItem(
            icon: Icons.science_outlined,
            label: "实验室",
            appColors: appColors,
            onTap: () => Get.toNamed(Routers.LabPageUrl, arguments: {}),
          ),
        ],
      ),
    );
  }

  // --- 宫格单项 ---
  Widget _buildGridItem(
      {required IconData icon,
      required String label,
      required AppThemeColors appColors,
      required VoidCallback onTap}) {
    // 统一使用主题色，显得更高级（不再使用花花绿绿的颜色）
    final itemColor = appColors.primaryText;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              // 背景色使用 primaryText 的极低透明度，这样深浅模式都通用
              color: itemColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: itemColor, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: appColors.primaryText.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- 设置列表 ---
  Widget _buildSettingsList(BuildContext context, AppThemeColors appColors) {
    // 列表的图标颜色
    final iconColor = appColors.primaryText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CellGroup(
          // 如果 CellGroup 有背景色参数，设为透明
          // backgroundColor: Colors.transparent,
          children: [
            Cell(
              title: "联系我们",
              icon: _buildIcon(Icons.headset_mic_outlined, iconColor),
              onTap: () => controller.contact(),
            ),
            Cell(
              icon: _buildIcon(Icons.star_outline_rounded, iconColor),
              title: "评价我们",
              onTap: () => controller.showRatingDialog(context),
            ),
            Cell(
              icon: _buildIcon(Icons.dark_mode_outlined, iconColor),
              title: "主题设置",
              onTap: () => controller.showThemeDialog(context),
            ),
            Cell(
              icon: _buildIcon(Icons.privacy_tip_outlined, iconColor),
              title: "隐私协议",
              onTap: () {
                Get.toNamed(Routers.WebViewPageUrl, arguments: {
                  "url": "https://blog.uuorb.com/archives/journal-privacy",
                  "title": "隐私协议"
                });
              },
            ),
            Cell(
              icon: _buildIcon(Icons.logout, iconColor),
              title: "退出登录",
              onTap: () => controller.logout(context),
            ),
            Cell(
              icon:
                  _buildIcon(Icons.delete_outline, Colors.red.withOpacity(0.8)),
              title: "注销账号",
              // 如果 Cell 支持 titleStyle，建议在这里加上
              // titleStyle: TextStyle(color: Colors.red),
              onTap: () => controller.deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- 图标包装 ---
  Widget _buildIcon(IconData icon, Color color) {
    // 这里不再加背景色，保持列表的简洁干净 (Minimalist style)
    // 如果你喜欢之前的背景块，可以加回去
    return Icon(icon, size: 20, color: color);
  }

  // --- VIP 徽章 ---
  Widget _buildVipBadge(bool isVip, AppThemeColors appColors) {
    if (!isVip) {
      // 非VIP：极简灰色胶囊
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: appColors.secondaryText.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "Basic",
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: appColors.secondaryText,
              height: 1.1),
        ),
      );
    }

    // VIP：黑金质感 (深色模式下稍微调整背景色)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B), // 保持深色底，显出金色的贵气
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.4), width: 0.5)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 10, color: Color(0xFFFFD700)),
          SizedBox(width: 4),
          Text(
            "VIP!!!",
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD700),
                height: 1.1),
          ),
        ],
      ),
    );
  }

  // 辅助方法
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
