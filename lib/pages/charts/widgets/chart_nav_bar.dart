import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
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
    return TDNavBar(
      useBorderStyle: false,
      backgroundColor: Colors.transparent, // 假设背景色由父级控制
      height: 48,
      useDefaultBack: false,
      leftBarItems: [
        TDNavBarItem(
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        size: 20.sp, color: Colors.black),
                  ],
                ),
              ),
            );
          }),
        )
      ],
      rightBarItems: [
        TDNavBarItem(
          icon: Icons.auto_awesome_outlined,
          iconColor: Colors.black87,
          padding: EdgeInsets.only(right: 12.w),
          action: () => controller.judgeActivity(),
        ),
        TDNavBarItem(
          icon: Icons.print_outlined,
          iconColor: Colors.black87,
          action: () => controller.handlePrintAction(context),
        )
      ],
    );
  }

  void _showActivityPicker(BuildContext context) {
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
          controller.onInit(); // 触发刷新逻辑
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
