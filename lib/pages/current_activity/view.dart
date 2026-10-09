import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/activity_card.dart';
import 'package:journal/components/custom_floating_action_button_location.dart';
import 'package:journal/components/empty_item.dart';
import 'package:journal/components/expense_item.dart';
import 'package:journal/components/journal_nav_bar.dart';
// 1. 引入主题扩展
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/pages/current_activity/expense_category_group.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/date_util.dart';
import 'package:journal/util/icons.dart';
import 'package:journal/util/toast_util.dart';
import 'package:showcaseview/showcaseview.dart';

import 'index.dart';

class CurrentActivityPage extends GetView<CurrentActivityController> {
  final GlobalKey? activitySwitcherGuideKey;

  const CurrentActivityPage({super.key, this.activitySwitcherGuideKey});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<CurrentActivityController>(
      init: CurrentActivityController(),
      id: "current_activity",
      autoRemove: false,
      builder: (_) {
        return Obx(() => Scaffold(
              // 背景色跟随主题
              backgroundColor: appColors.backgroundColor,
              appBar: _navibar(context),
              body: _buildView(context),
              floatingActionButtonAnimator:
                  FloatingActionButtonAnimator.scaling,
              floatingActionButton: _buildFloatingActionButton(context),
              floatingActionButtonLocation: CustomFloatingActionButtonLocation(
                  FloatingActionButtonLocation.endContained,
                  0,
                  controller.shouldShowAddButton.value ? -24.h : 999.h),
            ));
      },
    );
  }

  // 主视图
  Widget _buildView(BuildContext context) {
    Activity activity = controller.currentActivity.value;
    // 移除硬编码背景色，直接透明，由 Scaffold 控制背景
    return Container(
      color: Colors.transparent,
      child: activity.activityId == ""
          ? _buildEmptyCard()
          : _buildCurrentActivityCard(activity, context),
    );
  }

  _buildEmptyCard() {
    return JournalEmptyItem(
        title: "暂无默认账本",
        operateText: "添加",
        action: () {
          Get.toNamed(Routers.CreateActivityUrl);
        });
  }

  // 当前账本卡片
  Widget _buildCurrentActivityCard(Activity activity, BuildContext context) {
    return SizedBox(
      width: 385.w,
      child: EasyRefresh(
        onRefresh: () async {
          ToastUtil.heavyImpact();
          await controller.initData();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16), // 统一边距
          controller: controller.scrollController,
          children: [
            SizedBox(height: 12.h),

            // 顶部的大卡片 (建议你也检查一下 activityCard 内部是否使用了 appColors)
            activityCard(
              activity,
              context,
              controller.updateView,
            ),

            _buildActivityDetail(activity, context),

            if (controller.displayMode.value != ExpenseDisplayMode.category &&
                controller.listError != null)
              TextButton.icon(
                onPressed: controller.retryList,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(controller.listError!),
              )
            else if (controller.displayMode.value !=
                    ExpenseDisplayMode.category &&
                controller.isLoading.value)
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 16),
                child: CupertinoActivityIndicator(),
              )
            else if (controller.displayMode.value !=
                    ExpenseDisplayMode.category &&
                controller.expenseDateGroupList.isNotEmpty &&
                !controller.hasNextPage.value)
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                child: Center(
                  child: Text(
                    "没有更多了",
                    style: TextStyle(
                        // 适配深色
                        color: Theme.of(context)
                            .extension<AppThemeColors>()!
                            .secondaryText,
                        fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 当前账本详情
  Widget _buildActivityDetail(Activity activity, BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final activeTextStyle = TextStyle(
      color: appColors.primaryText,
      fontSize: 12,
      fontFamily: 'SourceCodePro',
      fontWeight: FontWeight.w700,
    );
    final inactiveTextStyle = TextStyle(
      color: appColors.secondaryText,
      fontSize: 12,
      fontFamily: 'SourceCodePro',
      fontWeight: FontWeight.w400,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 16, 6, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('账单列表', style: inactiveTextStyle),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeOption('详细', ExpenseDisplayMode.detailed,
                      activeTextStyle, inactiveTextStyle),
                  Text(' / ', style: inactiveTextStyle),
                  _buildModeOption('概括', ExpenseDisplayMode.summary,
                      activeTextStyle, inactiveTextStyle),
                  Text(' / ', style: inactiveTextStyle),
                  _buildModeOption('按分类', ExpenseDisplayMode.category,
                      activeTextStyle, inactiveTextStyle),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: 38,
          margin: const EdgeInsets.fromLTRB(6, 0, 6, 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: appColors.outlineBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.search,
                  size: 17, color: appColors.secondaryText),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(color: appColors.primaryText, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '搜索名称或金额',
                    hintStyle:
                        TextStyle(color: appColors.secondaryText, fontSize: 13),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (controller.searchController.text.isNotEmpty)
                IconButton(
                  tooltip: '清除搜索',
                  onPressed: controller.clearSearch,
                  icon: Icon(CupertinoIcons.clear_circled_solid,
                      size: 17, color: appColors.secondaryText),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                )
              else
                const SizedBox(width: 32),
            ],
          ),
        ),
        if (controller.searchPending)
          const CupertinoActivityIndicator()
        else if (controller.displayMode.value == ExpenseDisplayMode.category)
          _buildCategoryList(context, appColors)
        else if (controller.expenseDateGroupList.isEmpty &&
            !controller.isLoading.value &&
            controller.listError == null)
          _buildEmptyResult(appColors)
        else
          ...controller.expenseDateGroupList
              .map((group) => _buildSingleDateCard(group, context, appColors)),
      ],
    );
  }

  Widget _buildModeOption(String label, ExpenseDisplayMode mode,
      TextStyle activeTextStyle, TextStyle inactiveTextStyle) {
    final selected = controller.displayMode.value == mode;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.setDisplayMode(mode),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label,
              style: selected ? activeTextStyle : inactiveTextStyle),
        ),
      ),
    );
  }

  Widget _buildEmptyResult(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Text(
        controller.searchKeyword.isEmpty ? '暂无账单' : '没有找到匹配的账单',
        style: TextStyle(color: colors.secondaryText, fontSize: 13),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, AppThemeColors colors) {
    if (controller.categoryLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: Column(
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(height: 10),
            Text('正在整理 ${controller.categoryLoadedCount} 笔账单',
                style: TextStyle(color: colors.secondaryText, fontSize: 12)),
          ],
        ),
      );
    }
    if (controller.categoryError != null) {
      return TextButton.icon(
        onPressed: controller.retryCategories,
        icon: const Icon(Icons.refresh, size: 18),
        label: Text(controller.categoryError!),
      );
    }
    if (controller.categoryGroups.isEmpty) return _buildEmptyResult(colors);
    return Column(
      children: controller.categoryGroups
          .map((group) => _buildCategoryCard(group, context, colors))
          .toList(),
    );
  }

  Widget _buildCategoryCard(
      ExpenseCategoryGroup group, BuildContext context, AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(CategoryIconMap.getIcon(group.name),
                  size: 20, color: colors.primaryText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
              Text('${group.entries.length} 笔',
                  style: TextStyle(color: colors.secondaryText, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 4,
            children: [
              if (group.expenseTotal > 0 || group.incomeTotal == 0)
                Text('-¥${group.expenseTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              if (group.incomeTotal > 0)
                Text('+¥${group.incomeTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFF00A870),
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colors.outlineBorder),
          const SizedBox(height: 14),
          ...group.entries.map((entry) => ActivityExpenseItem(entry, context)),
        ],
      ),
    );
  }

  // 单日卡片 / 概览卡片
  Widget _buildSingleDateCard(ExpenseDateGroup expenseDateGroup,
      BuildContext context, AppThemeColors appColors) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      margin: const EdgeInsets.only(bottom: 16), // 卡片间距加大，更有呼吸感
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: appColors.cardBackground, // 适配深色背景
        borderRadius: BorderRadius.circular(24), // 统一 24px 大圆角
        boxShadow: [
          // 高端弥散阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片头部：日期 + 总额
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateUtil.getFriendlyDate(expenseDateGroup.date),
                style: TextStyle(
                  color: appColors.primaryText,
                  fontSize: 15,
                  fontFamily: 'SourceCodePro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("支出",
                      style: TextStyle(
                          color: appColors.secondaryText,
                          fontSize: 12,
                          fontFamily: 'SourceCodePro')),
                  const SizedBox(width: 6),
                  Text(expenseDateGroup.totalExpense.toStringAsFixed(2),
                      style: TextStyle(
                          color: appColors.primaryText,
                          fontSize: 16,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 2),
                  Text("元",
                      style: TextStyle(
                          color: appColors.secondaryText,
                          fontSize: 12,
                          fontFamily: 'SourceCodePro'))
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 分割线：使用极淡的主题色
          Divider(
              height: 1,
              thickness: 0.5,
              color: appColors.primaryText.withOpacity(0.05)),

          // ------------------------------------------------------
          // 2. 核心内容区域
          // ------------------------------------------------------
          Obx(() {
            // [模式 A]: 详细模式
            if (controller.displayMode.value == ExpenseDisplayMode.detailed) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  ...expenseDateGroup.expenses
                      .map((e) => ActivityExpenseItem(e, context)),
                  const SizedBox(height: 8),
                ],
              );
            } else {
              // [模式 B]: 概括模式 (分类统计)
              var typeMap = expenseDateGroup.expensesByType;
              var sortedList = typeMap.entries.map((entry) {
                double subTotal = entry.value.fold(0.0, (prev, curr) {
                  return curr.positive == 0 ? prev + curr.price : prev;
                });
                return {
                  "typeName": entry.key,
                  "list": entry.value,
                  "subTotal": subTotal,
                };
              }).toList();

              sortedList.sort((a, b) =>
                  (b["subTotal"] as double).compareTo(a["subTotal"] as double));

              double totalExpense = expenseDateGroup.totalExpense;
              if (totalExpense == 0) totalExpense = 1;

              return Column(
                children: [
                  const SizedBox(height: 16),
                  ...sortedList.map((data) {
                    String typeName = data["typeName"] as String;
                    List<Expense> typeList = data["list"] as List<Expense>;
                    double subTotal = data["subTotal"] as double;
                    double maxBarWidth = screenWidth - 160.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // 统计条
                              Container(
                                width: (subTotal / totalExpense * screenWidth)
                                    .clamp(65.0, maxBarWidth),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  // 核心修改：使用 primaryText 的极低透明度
                                  // 这样在黑/白模式下，都能显示出淡淡的条纹，非常高级
                                  color:
                                      appColors.primaryText.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  typeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    // 条纹内的文字颜色
                                    color:
                                        appColors.primaryText.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${typeList.length}笔",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appColors.secondaryText,
                                ),
                              ),
                            ],
                          ),

                          // 右侧金额
                          Text(
                            "¥${subTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: appColors.primaryText, // 适配深色
                              fontFamily: 'SourceCodePro',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  // 回到顶部按钮
  Widget _buildFloatingActionButton(BuildContext context) {
    // 按钮颜色跟随主题 (mainButtonBg)
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return FloatingActionButton(
      mini: true,
      elevation: 4, // 稍微加一点阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      onPressed: () {
        controller.scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      },
      // 使用配置好的按钮色
      backgroundColor: appColors.mainButtonBg,
      child: Icon(
        Icons.arrow_upward_rounded,
        color: appColors.mainButtonIcon, // 图标颜色
        size: 20,
      ),
    );
  }

  // NavBar
  PreferredSizeWidget _navibar(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;
    final switcher = GestureDetector(
      onTap: () => _showActivitySwitchBottomSheet(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() => Text(
                controller.shouldShowAddButton.value &&
                        controller.currentActivity.value.activityName.isNotEmpty
                    ? controller.currentActivity.value.activityName
                    : "当前账本",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: "SmileySans",
                    color: appColors.primaryText),
              )),
          SizedBox(width: 4.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: appColors.primaryText,
            size: 20.sp,
          ),
        ],
      ),
    );

    return JournalNavBar(
        height: 48,
        useDefaultBack: false,
        backgroundColor: Colors.transparent, // 沉浸式
        titleWidget: activitySwitcherGuideKey == null
            ? switcher
            : Showcase(
                key: activitySwitcherGuideKey!,
                title: '切换账本',
                description: '点击这里切换账本，也可以新建或加入账本。',
                targetPadding: const EdgeInsets.all(6),
                child: switcher,
              ));
  }

// 切换账本的底部弹窗
  void _showActivitySwitchBottomSheet(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.75, // 稍微调高一点点给新按钮留空间
          ),
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 顶部小把手
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: appColors.secondaryText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 16.h),

              // 2. 弹窗标题栏 (加入“全部”按钮)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 居中标题
                    Text(
                      "切换账本",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: appColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 3. 最近账本列表 (这里不需要包 Obx 如果你已经在外部处理好或者不需要响应式)
              Expanded(
                child: ListView.builder(
                  itemCount: controller.activityList.length,
                  itemBuilder: (context, index) {
                    var activity = controller.activityList[index];
                    bool isCurrent = activity.activityId ==
                        controller.currentActivity.value.activityId;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      leading: Icon(
                        Icons.my_library_books_outlined,
                        color: isCurrent
                            ? appColors.mainButtonBg
                            : appColors.secondaryText,
                      ),
                      title: Text(
                        activity.activityName,
                        style: TextStyle(
                            color: isCurrent
                                ? appColors.mainButtonBg
                                : appColors.primaryText,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15.sp),
                      ),
                      trailing: isCurrent
                          ? Icon(Icons.check_circle_rounded,
                              color: appColors.mainButtonBg)
                          : null,
                      onTap: () {
                        controller.switchActivity(activity);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),

              // 4. 底部增量操作区 (新建 & 加入)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: SafeArea(
                  child: Row(
                    children: [
                      // 左侧：新建账本
                      Expanded(
                        child: _buildBottomActionButton(
                          context: context,
                          icon: Icons.add_rounded,
                          text: "新建",
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(Routers.CreateActivityUrl);
                          },
                        ),
                      ),
                      SizedBox(width: 16.w), // 中间留白
                      // 右侧：加入他人账本
                      Expanded(
                        child: _buildBottomActionButton(
                          context: context,
                          icon: Icons.group_add_outlined, // 多人协作的图标
                          text: "加入",
                          onTap: () {
                            Navigator.pop(context);

                            Get.toNamed(Routers.JoinActivityPageUrl);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // 抽取出的底部按钮组件，保持代码整洁
  Widget _buildBottomActionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          border: Border.all(color: appColors.primaryText.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: appColors.primaryText, size: 20),
            SizedBox(width: 6.w),
            Text(text,
                style: TextStyle(
                  color: appColors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
