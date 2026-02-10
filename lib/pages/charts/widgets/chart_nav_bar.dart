import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/journal_nav_bar.dart';
import 'package:journal/components/journal_pop_menu.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/util/toast_util.dart';
import '../controller.dart';

// 确保引入了 ChartDimension 枚举，如果它定义在 controller 或 index 中
import '../index.dart';

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

    return Container(
      color: appColors.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min, // 高度包裹内容
          children: [
            // 第一行：标题和操作栏
            JournalNavBar(
              backgroundColor: Colors.transparent,
              height: 48,
              useDefaultBack: false,
              leftBarItems: [
                NavBarItem(
                  iconWidget: Obx(() {
                    if (controller.allActivityList.isEmpty) {
                      return const SizedBox();
                    }
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
                                fontFamily: "SmileySans",
                                color: appColors.primaryText,
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
                  iconWidget: Hero(
                    tag: 'printer_hero_tag', // 【关键】必须和终点一致的唯一 Tag
                    child: Icon(
                      Icons.print_outlined,
                      color: appColors.primaryText, // 确保有颜色，否则飞行时可能变色
                      size: 24.sp,
                    ),
                  ),
                  onTap: () => controller.handlePrintAction(context),
                )
              ],
            ),

            // 第二行：Tab 切换栏
            Padding(
              padding: EdgeInsets.only(bottom: 8.h), // 底部稍微留点空隙
              child: _buildDimensionTabs(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionTabs(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Obx(() {
      return Container(
        height: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w), // 加上左右边距
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(18.h),
        ),
        child: Row(
          children: [
            _buildTabItem(context, "周度", ChartDimension.week),
            _buildTabItem(context, "月度", ChartDimension.month),
            _buildTabItem(context, "年度", ChartDimension.year),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem(BuildContext context, String text, ChartDimension type) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final isSelected = controller.currentDimension.value == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ToastUtil.lightImpact();
          controller.changeDimension(type);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? appColors.primaryText : Colors.transparent,
            borderRadius: BorderRadius.circular(14.h),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? appColors.backgroundColor
                  : appColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  void _showActivityPicker(BuildContext context) {
    JournalPopMenu.show(
      context,
      width: 180,
      items: controller.allActivityList.isEmpty
          ? ["加载中"]
          : controller.allActivityList.map((e) => e.activityName).toList(),
      currentSelect: controller.currentActivity.value.activityName,
      onSelected: (index, name) {
        if (controller.allActivityList.isNotEmpty) {
          controller.currentActivity.value = controller.allActivityList[index];
          controller.onInit();
          controller.update(['charts']);
        }
      },
    );
  }

  @override
  // 计算首选高度：NavBar(48) + Tab(36.h) + BottomPadding(8.h)
  Size get preferredSize => Size.fromHeight(48 + 36.h + 8.h);
}
