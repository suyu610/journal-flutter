import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/core/app_theme_colors.dart';
import '../controller.dart';

class ChartNavBar extends StatelessWidget implements PreferredSizeWidget {
  final ChartsController controller;
  final GlobalKey actionKey;

  const ChartNavBar({
    super.key,
    required this.controller,
    required this.actionKey,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return JournalNavBar(
      // useBorderStyle: false,
      backgroundColor: Colors.transparent,
      height: 48,
      useDefaultBack: false,
      leftBarItems: [
        NavBarItem(
          iconWidget: Obx(() {
            if (controller.allActivityList.isEmpty) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 10),
              child: GestureDetector(
                key: actionKey,
                onTap: () => _showActivityPicker(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.currentActivity.value.activityName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: "SmileySans", // 保持你的字体
                        color: appColors.primaryText, // 适配颜色
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        size: 20.sp, color: appColors.primaryText),
                  ],
                ),
              ),
            );
          }),
        )
      ],
      rightBarItems: [
        NavBarItem(
          icon: Icons.auto_awesome_outlined,
          padding: EdgeInsets.only(right: 12.w),
          onTap: () => controller.judgeActivity(),
        ),
        NavBarItem(
          icon: Icons.print_outlined,
          onTap: () => controller.handlePrintAction(context),
        )
      ],
    );
  }

  void _showActivityPicker(BuildContext context) {
    // BrnPopupListWindow 是第三方组件，样式可能受限，
    // 但通常它会跟随 Theme 的 cardColor，我们在 App.dart 里已经全局配置了 cardColor
    BrnPopupListWindow.showPopListWindow(
      context,
      actionKey,
      offset: 10,
      data: controller.allActivityList.isEmpty
          ? ["加载中"]
          : controller.allActivityList.map((e) => e.activityName).toList(),
      onItemClick: (index, name) {
        if (controller.allActivityList.isNotEmpty) {
          controller.currentActivity.value = controller.allActivityList[index];
          controller.onInit();
          controller.update(['charts']);
        }
        Get.back();
        return true;
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
