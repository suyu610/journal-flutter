import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  // 主视图
  Widget _buildView(context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        TDCellGroup(theme: TDCellGroupTheme.cardTheme, cells: [
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.wysiwyg_outlined,
              size: 18,
            ),
            title: "存钱罐",
            onClick: (v) {
              Get.toNamed(Routers.MoneyJarPageUrl, arguments: {});
            },
          ),
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.wysiwyg_outlined,
              size: 18,
            ),
            title: "本地服务",
            onClick: (v) {
              Get.toNamed(Routers.LocalServicePageUrl, arguments: {});
            },
          ),
          // tabbar设置页
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.settings_outlined,
              size: 18,
            ),
            title: "底部功能排序",
            onClick: (v) {
              Get.toNamed(Routers.TabBarSettingPageUrl, arguments: {});
            },
          ),
          TDCell(
            arrow: true,
            leftIconWidget: const Icon(
              Icons.fact_check_outlined,
              size: 18,
            ),
            title: "自动记账",
            onClick: (v) {
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
