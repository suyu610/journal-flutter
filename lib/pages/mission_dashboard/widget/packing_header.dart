// 文件路径: lib/pages/mission_dashboard/widget/packing_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_switch.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/mission_dashboard/controller.dart';

class PackingHeader extends GetView<MissionController> {
  const PackingHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appColors = Theme.of(context).extension<AppThemeColors>()!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("物品清单",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: appColors.primaryText)),
                  const SizedBox(width: 8),
                  Obx(() => JournalSwitch(
                        value: controller.isPackingMode.value,
                        activeIcon: Icons.lock_open_outlined,
                        inactiveIcon: Icons.lock_outlined,
                        onChanged: (v) => controller.isPackingMode.value = v,
                        width: 44,
                        height: 26,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                controller.nav2ToTripList(context);
              },
              child: Row(
                children: [
                  Text("其他行程",
                      style: TextStyle(
                          fontSize: 14,
                          color: appColors.secondaryText.withOpacity(0.5))),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: appColors.secondaryText.withOpacity(0.5),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
