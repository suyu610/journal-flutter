import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/cell_group.dart';
import 'package:journal/components/journal_nav_bar.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/lab/controller.dart';
import 'package:journal/routers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LabPage extends GetView<LabController> {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 获取主题色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<LabController>(
      init: LabController(),
      id: "lab",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          // 背景色跟随主题
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _navibar(context, appColors),
          body: SafeArea(
            child: _buildView(context, appColors),
          ),
        );
      },
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
        "实验室",
        style: TextStyle(
          fontFamily: "SmileySans",
          fontSize: 17, // 稍微加大一点
          fontWeight: FontWeight.w500,
          color: appColors.primaryText, // 适配标题颜色
        ),
      ),
    );
  }

  static Future<String> appVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // --- Icon 构建器：使用主题色 ---
  Widget _buildIcon(IconData icon, AppThemeColors appColors) {
    // 使用主色的极低透明度作为背景，主色作为图标色
    // 这样在深色/亮色模式下都非常和谐
    final color = appColors.primaryText;

    return Container(
      padding: const EdgeInsets.all(8), // 稍微加大内边距
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10), // 圆角稍微圆润一点
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  // 主视图
  Widget _buildView(BuildContext context, AppThemeColors appColors) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // CellGroup 已经自带了卡片背景和阴影适配，直接使用即可
        CellGroup(children: [
          Cell(
            title: "重置引导动画",
            icon: _buildIcon(Icons.refresh, appColors),
            onTap: () => controller.resetGuide(),
          ),
          Cell(
            icon: _buildIcon(Icons.fitbit_sharp, appColors),
            title: "鱼缸",
            onTap: () {
              Get.toNamed(Routers.FishTankFlamePageUrl, arguments: {});
            },
          ),
          Cell(
            icon: _buildIcon(Icons.wysiwyg_outlined, appColors),
            title: "存钱罐",
            onTap: () {
              Get.toNamed(Routers.MoneyJarPageUrl, arguments: {});
            },
          ),
          Cell(
            icon: _buildIcon(Icons.eco_outlined, appColors),
            title: "小树苗",
            onTap: () {
              Get.toNamed(Routers.GrowingTreeUrl, arguments: {});
            },
          ),

          Cell(
            icon: _buildIcon(Icons.local_hospital, appColors),
            title: "本地服务",
            onTap: () {
              Get.toNamed(Routers.LocalServicePageUrl, arguments: {});
            },
          ),
          // tabbar设置页
          Cell(
            icon: _buildIcon(Icons.settings_outlined, appColors),
            title: "底部功能排序",
            onTap: () {
              Get.toNamed(Routers.TabBarSettingPageUrl, arguments: {});
            },
          ),
          Cell(
            icon: _buildIcon(Icons.fact_check_outlined, appColors),
            title: "自动记账",
            onTap: () {
              Get.toNamed(Routers.AutoWriteIntroPageUrl);
            },
          ),
        ]),

        SizedBox(height: 30.h),

        FutureBuilder(
          future: appVersion(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Text(
              "v${snapshot.data ?? ""}",
              style: TextStyle(
                  // 适配次要文本颜色
                  color: appColors.secondaryText.withOpacity(0.5),
                  fontSize: 12,
                  fontFamily: "SourceCodePro" // 加上字体更显极客
                  ),
            );
          },
        ),
      ],
    );
  }
}
