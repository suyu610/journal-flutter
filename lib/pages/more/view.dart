import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:journal/components/cell_group.dart';
import 'package:journal/components/journal_nav_bar.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';

import 'package:journal/pages/profile/controller.dart';
import 'package:journal/routers.dart';

class MoreFunctionPage extends StatelessWidget {
  const MoreFunctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      appBar: _navibar(context, appColors),
      body: _buildView(context, appColors),
    );
  }

  PreferredSizeWidget _navibar(BuildContext context, AppThemeColors appColors) {
    return JournalNavBar(
      backgroundColor: Colors.transparent, // 沉浸式
      height: 48,
      useDefaultBack: false, // 自定义返回
      leftBarItems: [
        NavBarItem(
          icon: Icons.arrow_back_ios_new,
          iconSize: 20,
          onTap: () => Get.back(),
        )
      ],
      titleWidget: Text(
        "更多功能",
        style: TextStyle(
          fontFamily: "SmileySans",
          fontSize: 17, // 稍微加大一点
          fontWeight: FontWeight.w500,
          color: appColors.primaryText, // 适配标题颜色
        ),
      ),
    );
  }

  // --- 图标包装 ---
  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6), // 稍微加大内边距
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10), // 圆角稍微圆润一点
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  // 主视图
  Widget _buildView(BuildContext context, AppThemeColors appColors) {
    final iconColor = appColors.primaryText;
    final controller = Get.find<ProfileController>();
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CellGroup(
            children: [
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
                icon: _buildIcon(
                    Icons.delete_outline, Colors.red.withOpacity(0.8)),
                title: "注销账号",
                onTap: () => controller.deleteAccount(context),
              ),
            ],
          ),
        ));
  }
}
