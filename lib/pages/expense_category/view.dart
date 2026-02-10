import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:journal/util/icons.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'index.dart';

class ExpenseCategoryPage extends GetView<ExpenseTypePickerController> {
  const ExpenseCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<ExpenseTypePickerController>(
        init: ExpenseTypePickerController(),
        id: "expense_type_picker",
        builder: (_) {
          return Scaffold(
            backgroundColor: appColors.backgroundColor,
            appBar: _buildAppbar(context, appColors),
            body: _buildView(appColors),
          );
        });
  }

  // 替换为标准 AppBar 以适配主题
  PreferredSizeWidget _buildAppbar(
          BuildContext context, AppThemeColors appColors) =>
      AppBar(
        backgroundColor: appColors.backgroundColor, // 与背景一致
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: appColors.primaryText, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "选择分类",
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: appColors.primaryText // 适配文字颜色
              ),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: () => controller.toggleEditMode(),
                child: Text(
                  controller.isEditMode.value ? "完成" : "管理",
                  style: TextStyle(
                    color: appColors.primaryText,
                    fontSize: 14.sp,
                    fontWeight: controller.isEditMode.value
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              )),
          SizedBox(width: 8.w),
        ],
      );

  Widget _buildView(AppThemeColors appColors) {
    return ContainedTabBarView(
      tabs: const [
        Text('支出'),
        Text('收入'),
      ],
      tabBarProperties: TabBarProperties(
        height: 48,
        background: Container(
          color: appColors.cardBackground,
          padding: const EdgeInsets.only(bottom: 6),
        ),
        // 指示器颜色
        indicatorColor: appColors.primaryText,
        indicatorWeight: 3,
        // 选中文字颜色
        labelColor: appColors.primaryText,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        // 未选中文字颜色
        unselectedLabelColor: appColors.secondaryText,
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      ),
      views: [
        _buildGridList(controller.expenseList, appColors, isExpense: true),
        _buildGridList(controller.incomeList, appColors, isExpense: false),
      ],
    );
  }

  Widget _buildGridList(
      List<Map<String, dynamic>> list, AppThemeColors appColors,
      {required bool isExpense}) {
    return Container(
      color: appColors.cardBackground,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Obx(() {
        return ReorderableGridView.builder(
          onReorder: (oldIndex, newIndex) {
            controller.onReorder(oldIndex, newIndex, isExpense);
          },
          dragWidgetBuilderV2:
              DragWidgetBuilderV2(builder: (index, child, screenshot) {
            return Material(
              color: Colors.transparent,
              shadowColor: Colors.black.withOpacity(0.1),
              elevation: 3,
              borderRadius: BorderRadius.circular(20),
              child: Transform.scale(scale: 1.2, child: child),
            );
          }),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 0.w,
            childAspectRatio: 0.85,
          ),
          itemCount: list.length + 1,
          itemBuilder: (context, index) {
            // 修正 1：Key 必须是稳定的，不能包含 index
            // 使用 labelName 作为唯一标识（如果有 id 更好，没有就用名字）
            final keyContent = index == list.length
                ? "add_btn_key" // 固定的添加按钮Key
                : "item_${list[index]['labelName']}"; // 移除 _$index

            final Key itemKey = ValueKey(keyContent);

            // 添加按钮处理
            if (index == list.length) {
              // 修正 2：Key 必须给到最外层的 Opacity，而不是里面的 Container
              return Opacity(
                key: itemKey, // <--- 移到这里
                opacity: controller.isEditMode.value ? 0.3 : 1.0,
                child: Container(
                  // key: itemKey, // <--- 这里删掉
                  child: IgnorePointer(
                    ignoring: controller.isEditMode.value,
                    child: _buildAddButton(isExpense, context, appColors),
                  ),
                ),
              );
            }

            final item = list[index];
            final bool isCustom = item['id'] != null;

            return Container(
              key: itemKey, // 普通 Item 这一层就是最外层，没问题
              child: _buildCategoryItem(
                label: item['labelName'],
                iconData: CategoryIconMap.getIcon(item['labelName']),
                appColors: appColors,
                isCustom: isCustom,
                isEditMode: controller.isEditMode.value,
                onTap: () {
                  if (controller.isEditMode.value) return;
                  Get.back(result: {
                    "type": item['labelName'],
                    "positive": isExpense ? 0 : 1
                  });
                },
                onDelete: () {
                  _showDeleteDialog(context, isExpense, item, controller);
                },
              ),
            );
          },
        );
      }),
    );
  }

  // 单个类别的组件
  Widget _buildCategoryItem({
    required String label,
    required IconData iconData,
    required VoidCallback onTap,
    required VoidCallback onDelete, // 删除回调
    required bool isCustom,
    required bool isEditMode, // 是否编辑模式
    required AppThemeColors appColors,
  }) {
    // 1. 动画/样式逻辑
    // 如果是编辑模式，且是系统图标(非Custom)，则变透明一点
    final double opacity = (isEditMode && !isCustom) ? 0.4 : 1.0;

    // 如果是编辑模式，且是自定义图标，可以给一个轻微的抖动动画 (这里用 Transform 简单模拟或由 flutter_animate 实现)
    // 简单起见，这里只做静态的 Badge

    return GestureDetector(
      onTap: onTap,
      // 移除 onLongPress，改为统一用右上角按钮进入模式，避免冲突
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none, // 允许角标超出范围
        alignment: Alignment.topCenter,
        children: [
          // 主体内容
          Opacity(
            opacity: opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: appColors.primaryText.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    // 编辑模式下的自定义图标，加个虚线框或者背景色变化，增强“可操作”感
                    border: (isEditMode && isCustom)
                        ? Border.all(
                            color: Colors.red.withOpacity(0.3), width: 1)
                        : null,
                  ),
                  child: Icon(
                    iconData,
                    size: 26,
                    color: appColors.primaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: appColors.primaryText.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // --- 核心优化 3：删除角标 (只在编辑模式 + 自定义图标 显示) ---
          if (isEditMode && isCustom)
            Positioned(
              right: 10.w, // 根据实际 icon 大小调整
              top: -5.h,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onDelete();
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2), // 白边让它更明显
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ]),
                  child: Icon(
                    Icons.remove, // 或者 Icons.close
                    size: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 显示删除确认框
  void _showDeleteDialog(BuildContext context, bool isExpense,
      Map<String, dynamic> item, ExpenseTypePickerController controller) {
    PremiumGlassDialog.show(context,
        title: "删除分类", content: "确定要删除“${item['labelName']}”吗？", onConfirm: () {
      controller.deleteCategory(
          isExpense, item['id'], item['labelName'], context);
    });
  }

  // "添加" 按钮组件
  Widget _buildAddButton(
      bool isExpense, BuildContext context, AppThemeColors appColors) {
    return GestureDetector(
      onTap: () => controller.onAddTapCategory(isExpense, context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              // 背景透明或极淡
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  // 边框适配：淡色
                  color: appColors.primaryText.withOpacity(0.1),
                  width: 1),
            ),
            child: Icon(
              Icons.add,
              size: 26,
              color: appColors.secondaryText, // 图标适配次要色
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "自定义",
            style: TextStyle(
              color: appColors.secondaryText, // 文字适配次要色
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
