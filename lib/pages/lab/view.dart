import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/cell_group.dart';
import 'package:journal/pages/lab/controller.dart';
import 'package:journal/routers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class LabPage extends GetView<LabController> {
  LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LabController>(
      init: LabController(),
      id: "lab",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          appBar: _navibar(context),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _navibar(BuildContext context) {
    return const TDNavBar(
      useBorderStyle: true,
      height: 48,
      useDefaultBack: true,
      titleWidget: Text(
        "实验室",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Future<String> appVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
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

  // 主视图
  Widget _buildView(context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        CellGroup(children: [
          Cell(
            title: "重置引导动画",
            icon: _buildIcon(Icons.refresh, Colors.blueGrey),
            onTap: () => controller.resetGuide(),
          ),
          Cell(
            icon: _buildIcon(
              Icons.fitbit_sharp,
              Colors.blueGrey,
            ),
            title: "鱼缸",
            onTap: () {
              Get.toNamed(Routers.FishTankFlamePageUrl, arguments: {});
            },
          ),
          Cell(
            icon: _buildIcon(
              Icons.wysiwyg_outlined,
              Colors.blueGrey,
            ),
            title: "存钱罐",
            onTap: () {
              Get.toNamed(Routers.MoneyJarPageUrl, arguments: {});
            },
          ),
          Cell(
            icon: _buildIcon(
              Icons.eco_outlined,
              Colors.blueGrey,
            ),
            title: "小树苗",
            onTap: () {
              Get.toNamed(Routers.GrowingTreeUrl, arguments: {});
            },
          ),

          Cell(
            icon: _buildIcon(
              Icons.local_hospital,
              Colors.blueGrey,
            ),
            title: "本地服务",
            onTap: () {
              Get.toNamed(Routers.LocalServicePageUrl, arguments: {});
            },
          ),
          // tabbar设置页
          Cell(
            icon: _buildIcon(
              Icons.settings_outlined,
              Colors.blueGrey,
            ),
            title: "底部功能排序",
            onTap: () {
              Get.toNamed(Routers.TabBarSettingPageUrl, arguments: {});
            },
          ),
          Cell(
            icon: _buildIcon(
              Icons.fact_check_outlined,
              Colors.blueGrey,
            ),
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
              style: TextStyle(color: Colors.grey[500]),
            );
          },
        ),
      ],
    );
  }
}
