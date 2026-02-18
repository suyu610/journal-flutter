import 'dart:math';

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
                    child: ShakeActor(
                      active: controller.shouldRemindPrint, // 【关键】绑定逻辑条件
                      child: Icon(
                        Icons.print_outlined,
                        color: appColors.primaryText, // 确保有颜色，否则飞行时可能变色
                        size: 24.sp,
                      ),
                    ),
                  ),
                  onTap: () => controller.handlePrintAction(context),
                )
              ],
            ),

            // 第二行：Tab 切换栏
            // Padding(
            //   padding: EdgeInsets.only(bottom: 8.h), // 底部稍微留点空隙
            //   child: _buildDimensionTabs(context),
            // ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
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
  Size get preferredSize => Size.fromHeight(48 + 8.h); // + 36.h
}

class ShakeActor extends StatefulWidget {
  final Widget child;
  final bool active; // 是否激活摇晃
  final Duration duration;

  const ShakeActor({
    Key? key,
    required this.child,
    this.active = false,
    this.duration = const Duration(milliseconds: 2500), // 摇晃周期
  }) : super(key: key);

  @override
  _ShakeActorState createState() => _ShakeActorState();
}

class _ShakeActorState extends State<ShakeActor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(ShakeActor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.repeat();
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用简单的旋转摇晃，模拟铃铛效果
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!widget.active) return child!;

        // 这是一个间歇性的摇晃曲线：摇晃几下 -> 停顿 -> 再摇晃
        final sineValue = sin(4 * pi * _controller.value);
        // 0.0 到 0.2 之间摇晃，其余时间静止，避免太烦人
        final isShakingPhase = _controller.value < 0.2;

        return Transform.rotate(
          angle: isShakingPhase ? sineValue * 0.1 : 0, // 0.1 弧度约等于 5度
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
