import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/util/icons.dart';
import 'index.dart';

class ExpenseCategoryPage extends GetView<ExpenseTypePickerController> {
  const ExpenseCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Get.put 确保 Controller 被加载
    final controller = Get.put(ExpenseTypePickerController());
    // 2. 获取主题颜色
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppbar(context, appColors),
      body: _buildView(controller, appColors),
    );
  }

  // 替换为标准 AppBar 以适配主题
  PreferredSizeWidget _buildAppbar(
          BuildContext context, AppThemeColors appColors) =>
      AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 与背景一致
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
      );

  Widget _buildView(
      ExpenseTypePickerController controller, AppThemeColors appColors) {
    return ContainedTabBarView(
      tabs: const [
        Text('支出'),
        Text('收入'),
      ],
      tabBarProperties: TabBarProperties(
        height: 48,
        background: Container(
          // Tab栏背景：适配深色
          color: appColors.cardBackground,
          // 增加底部细线，增强层次感 (颜色适配)
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: appColors.primaryText.withOpacity(0.05),
                        width: 1))),
          ),
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
        // 支出列表
        Obx(() =>
            _buildGridList(controller.expenseList, appColors, isExpense: true)),
        // 收入列表
        Obx(() =>
            _buildGridList(controller.incomeList, appColors, isExpense: false)),
      ],
    );
  }

  Widget _buildGridList(
      List<Map<String, dynamic>> list, AppThemeColors appColors,
      {required bool isExpense}) {
    return Container(
      // 内容区域背景：适配深色
      color: appColors.cardBackground,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16.h, // 稍微加大间距
          crossAxisSpacing: 0.w,
          childAspectRatio: 0.85, // 调整比例，防止文字太挤
        ),
        itemCount: list.length + 1,
        itemBuilder: (context, index) {
          if (index == list.length) {
            return _buildAddButton(isExpense, context, appColors);
          }
          final item = list[index];
          return _buildCategoryItem(
            label: item['labelName'],
            iconData: CategoryIconMap.getIcon(item['labelName']),
            appColors: appColors,
            onTap: () {
              Get.back(result: {
                "type": item['labelName'],
                "positive": isExpense ? 0 : 1
              });
            },
          );
        },
      ),
    );
  }

  // 单个类别的组件 (美化版)
  Widget _buildCategoryItem({
    required String label,
    required IconData iconData,
    required VoidCallback onTap,
    required AppThemeColors appColors,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              // 背景色：使用 primaryText 的极低透明度，深浅通吃
              color: appColors.primaryText.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20), // 统一圆角
            ),
            child: Icon(
              iconData,
              size: 26,
              color: appColors.primaryText, // 图标适配
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: appColors.primaryText.withOpacity(0.8), // 文字适配
              fontSize: 13,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
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
