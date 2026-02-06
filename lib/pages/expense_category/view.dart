import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/components/navbar/brn_appbar.dart';
import 'package:journal/components/bruno/src/theme/configs/brn_appbar_config.dart';
import 'package:journal/util/icons.dart';
import 'index.dart';

class ExpenseCategoryPage extends GetView<ExpenseTypePickerController> {
  const ExpenseCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Get.put 确保 Controller 被加载 (如果你没有在 Binding 中配置的话)
    final controller = Get.put(ExpenseTypePickerController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppbar(),
      body: _buildView(controller),
    );
  }

  PreferredSizeWidget _buildAppbar() => BrnAppBar(
        themeData: BrnAppBarConfig.light(),
        showDefaultBottom: true,
        title: const Text(
          "选择分类",
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      );

  Widget _buildView(ExpenseTypePickerController controller) {
    return ContainedTabBarView(
      tabs: const [
        Text('支出'),
        Text('收入'),
      ],
      tabBarProperties: TabBarProperties(
        height: 48,
        background: Container(
          color: Colors.white,
          // 增加底部细线，增强层次感
          padding: const EdgeInsets.only(bottom: 6),
        ),
        indicatorColor: Colors.black,
        indicatorWeight: 3,
        labelColor: Colors.black,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelColor: Colors.grey,
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      ),
      views: [
        // 支出列表
        Obx(() => _buildGridList(controller.expenseList, isExpense: true)),
        // 收入列表
        Obx(() => _buildGridList(controller.incomeList, isExpense: false)),
      ],
    );
  }

  Widget _buildGridList(List<Map<String, dynamic>> list,
      {required bool isExpense}) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: GridView.builder(
        // 使用 builder 性能更好
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 0.w,
          childAspectRatio: 1, // 调整比例让文字显示更宽松
        ),
        // 列表长度 + 1 是为了放最前面的 "添加" 按钮
        itemCount: list.length + 1,
        itemBuilder: (context, index) {
          if (index == list.length) {
            return _buildAddButton(isExpense, context);
          }
          final item = list[index];
          return _buildCategoryItem(
            label: item['labelName'],
            iconData:
                CategoryIconMap.getIcon(item['labelName']), // 假设你用这个方法获取 Icon
            onTap: () {
              // 选中逻辑
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
              color: const Color(0xFFF5F5F5), // 柔和的浅灰色背景
              borderRadius: BorderRadius.circular(20), // 方圆角，比正圆更现代
            ),
            child: Icon(
              iconData,
              size: 26,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // "添加" 按钮组件
  Widget _buildAddButton(bool isExpense, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onAddTapCategory(isExpense, context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFE0E0E0), width: 1), // 虚线或浅色实线边框
            ),
            child: const Icon(
              Icons.add,
              size: 26,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          const Text(
            "自定义",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
