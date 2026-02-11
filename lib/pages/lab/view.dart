import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/cell_group.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/lab/controller.dart';
import 'package:journal/pages/lab/smart_merge/view.dart';
import 'package:journal/routers.dart';

class LabPage extends GetView<LabController> {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<LabController>(
      init: LabController(),
      id: "lab",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          // 背景色稍微给一点灰度，突出卡片的白色
          backgroundColor: appColors.backgroundColor,
          appBar: _navibar(context, appColors),
          body: _buildView(context, appColors),
        );
      },
    );
  }

  PreferredSizeWidget _navibar(BuildContext context, AppThemeColors appColors) {
    return JournalNavBar(
      backgroundColor: Colors.transparent,
      height: 48,
      useDefaultBack: false,
      leftBarItems: [
        NavBarItem(
          icon: Icons.arrow_back_ios_new,
          iconSize: 20,
          onTap: () => Get.back(),
        )
      ],
      titleWidget: Text(
        "实验室",
        style: TextStyle(
          fontFamily: "SmileySans",
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: appColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, AppThemeColors appColors,
      {Color? customColor}) {
    // 允许传入自定义颜色，或者默认使用主色
    final color = customColor ?? appColors.primaryText;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // 透明度稍微调高一点点，更有质感
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  // 构建分组标题
  Widget _buildSectionHeader(String title, AppThemeColors appColors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: appColors.secondaryText, // 使用次级文本颜色
        ),
      ),
    );
  }

  Widget _buildView(BuildContext context, AppThemeColors appColors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // 添加回弹效果
      padding: const EdgeInsets.only(bottom: 40), // 底部留白
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 第一组：智能与效率 ---
          _buildSectionHeader("智能与效率", appColors),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // 单独控制每个组的圆角
              child: CellGroup(
                children: [
                  Cell(
                    title: "智能合并",
                    // 给重要功能一些特殊的 Icon 颜色，打破单调
                    icon: _buildIcon(Icons.auto_awesome, appColors,
                        customColor: Colors.orange),
                    onTap: () => Get.to(const SmartMergePage()),
                  ),
                  Cell(
                    title: "自动记账",
                    icon: _buildIcon(Icons.fact_check_outlined, appColors,
                        customColor: Colors.blueAccent),
                    onTap: () => Get.toNamed(Routers.AutoWriteIntroPageUrl),
                  ),
                ],
              ),
            ),
          ),
// --- 第三组：系统与调试 ---
          _buildSectionHeader("系统工具", appColors),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CellGroup(
                children: [
                  Cell(
                    title: "底部导航排序",
                    icon: _buildIcon(Icons.layers_outlined, appColors),
                    onTap: () => Get.toNamed(Routers.TabBarSettingPageUrl),
                  ),
                  Cell(
                    title: "本地服务概览",
                    icon: _buildIcon(Icons.lan_outlined, appColors),
                    onTap: () => Get.toNamed(Routers.LocalServicePageUrl),
                  ),
                  Cell(
                    title: "小票打印机",
                    icon: _buildIcon(Icons.print_outlined, appColors),
                    onTap: () => Get.toNamed(Routers.MedicalCardUrl),
                  ),
                  Cell(
                    title: "重置引导动画",
                    icon: _buildIcon(Icons.refresh_rounded, appColors),
                    onTap: () => controller.resetGuide(),
                  ),
                ],
              ),
            ),
          ),
          // --- 第二组：创意组件 ---
          _buildSectionHeader("创意互动", appColors),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CellGroup(
                children: [
                  Cell(
                    title: "桑基图分析",
                    icon: _buildIcon(Icons.hub_outlined, appColors,
                        customColor: Colors.purple),
                    onTap: () => controller.nav2SankeyChart(),
                  ),
                  Cell(
                    title: "电子鱼缸",
                    icon: _buildIcon(Icons.water, appColors,
                        customColor: Colors.cyan),
                    onTap: () => Get.toNamed(Routers.FishTankFlamePageUrl),
                  ),
                  Cell(
                    title: "存钱罐",
                    icon: _buildIcon(Icons.savings_outlined, appColors,
                        customColor: Colors.redAccent),
                    onTap: () => Get.toNamed(Routers.MoneyJarPageUrl),
                  ),
                  Cell(
                    title: "许愿树",
                    icon: _buildIcon(Icons.eco_outlined, appColors,
                        customColor: Colors.green),
                    onTap: () => Get.toNamed(Routers.GrowingTreeUrl),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
