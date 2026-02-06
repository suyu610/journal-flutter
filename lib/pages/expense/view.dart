import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/pages/image_preview_page.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/icons.dart';

import 'index.dart';

class ExpenseItemPage extends GetView<ExpensePageController> {
  const ExpenseItemPage({super.key});

  // 定义统一的风格常量
  final Color _backgroundColor = const Color(0xFFF6F7F9); // 首页同款浅灰背景
  final Color _cardColor = Colors.white;
  final double _cardRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpensePageController>(
      init: ExpensePageController(),
      id: "expense_item",
      builder: (_) {
        return Scaffold(
          backgroundColor: _backgroundColor,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 1.h),
            child: Column(
              children: [
                _buildTypeAndAmountCard(context),
                SizedBox(height: 12.h),
                _buildDetailsCard(context),
                SizedBox(height: 24.h),
                _buildSaveButton(context)
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.black87, size: 20),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        "记一笔",
        style: TextStyle(
            color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
      ),
      actions: [_buildDeleteButton(context)],
    );
  }

  // =======================================================
  // 【delete】 1. 顶部核心卡片：类型切换 + 金额输入 + 分类选择
  // =======================================================
  Widget __buildTypeAndAmountCard(BuildContext context) {
    var expense = controller.expense.value;
    bool isExpense = expense.positive == 0; // 0是支出，1是收入

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 收支切换 (类似 iOS 分段控制器)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildSegmentBtn("支出", isExpense, () {
                  expense.positive = 0;
                  controller.update(['expense_item']);
                }),
                _buildSegmentBtn("收入", !isExpense, () {
                  expense.positive = 1;
                  controller.update(['expense_item']);
                }),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // 2. 金额输入 (超大字体，类似首页金额展示)
          const Text("金额", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "¥",
                style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  cursorColor: Colors.black87,
                  focusNode: controller.expensePriceFocusNode,
                  controller: controller.expensePriceTextEditController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace', // 使用等宽字体或你首页用的数字字体
                      color: Colors.black),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(color: Color(0xFFE0E0E0)),
                    isDense: true,
                  ),
                  onChanged: (v) => controller.modifyExpensePrice(v),
                ),
              ),
            ],
          ),

          // 3. 划线价 (只有有值时才显示显眼，否则折叠或显示占位)
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text("原价",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    cursorColor: Colors.black87,
                    controller:
                        controller.expenseOriginalPriceTextEditController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[800],
                      decoration: TextDecoration.lineThrough, // 输入时就有划线效果
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "选填（如有优惠）",
                      hintStyle: TextStyle(
                          color: Color(0xFFDDDDDD),
                          fontSize: 12,
                          decoration: TextDecoration.none),
                      isDense: true,
                    ),
                    onChanged: (v) => controller.modifyExpenseOriginalPrice(v),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // 4. 分类选择 (改为一行，点击跳转)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Get.toNamed(Routers.ExpenseCategoryPageUrl)?.then((result) {
                if (result != null) {
                  expense.type = result['type'];
                  expense.positive = result['positive'];
                  controller.update(['expense_item']);
                }
              });
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.category_outlined,
                      color: Colors.white, size: 20),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("分类",
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                      expense.type.isEmpty ? "选择分类" : expense.type,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 收支切换按钮子组件
  Widget _buildSegmentBtn(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // 1. 顶部核心卡片：类型 -> 金额 -> 商品名(强) -> 分类
  // =======================================================
  Widget _buildTypeAndAmountCard(BuildContext context) {
    var expense = controller.expense.value;
    bool isExpense = expense.positive == 0;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w), // 底部padding减小，紧凑一点
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 收支切换
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildSegmentBtn("支出", isExpense, () {
                  expense.positive = 0;
                  controller.update(['expense_item']);
                }),
                _buildSegmentBtn("收入", !isExpense, () {
                  expense.positive = 1;
                  controller.update(['expense_item']);
                }),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // 2. 金额输入
          const Text("金额", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "¥",
                style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  cursorColor: Colors.black87,
                  focusNode: controller.expensePriceFocusNode,
                  controller: controller.expensePriceTextEditController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Colors.black),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(color: Color(0xFFE0E0E0)),
                    isDense: true,
                  ),
                  onChanged: (v) => controller.modifyExpensePrice(v),
                ),
              ),
            ],
          ),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 16.h),

          // 3. 商品名称输入 (强化显示，原“备注”) & AI 按钮
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("商品/事项",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    TextField(
                      cursorColor: Colors.black87,
                      controller: controller.expenseLabelTextEditController,
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "例如：好享记账会员",
                        hintStyle:
                            TextStyle(color: Colors.grey[300], fontSize: 16.sp),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      onChanged: (v) => controller.modifyExpenseLabel(v),
                    ),
                  ],
                ),
              ),
              // AI 智能分类按钮
              // 包裹一个 Obx 来监听状态变化
              Obx(() {
                bool isLoading = controller.isRec.value;

                return GestureDetector(
                  // 如果正在识别，禁止再次点击 (onTap 设为 null)
                  onTap: isLoading
                      ? null
                      : () {
                          controller.autoCategorizeByLabel(context);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300), // 增加一点呼吸动效
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      // 加载时背景稍微变淡一点
                      color: isLoading
                          ? Colors.blueGrey[900]!.withOpacity(0.05)
                          : Colors.blueGrey[900]!.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLoading
                            ? Colors.transparent
                            : Colors.blueGrey[900]!.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 紧凑布局
                      children: [
                        // 根据状态切换图标
                        if (isLoading)
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blueGrey[900],
                            ),
                          )
                        else
                          Icon(Icons.auto_awesome,
                              size: 14, color: Colors.blueGrey[900]),

                        SizedBox(width: 4.w),

                        // 根据状态切换文字
                        Text(
                          isLoading ? "分析中..." : "智能分类",
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.blueGrey[900],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              })
            ],
          ),

          SizedBox(height: 12.h),

          // 4. 分类选择 (样式微调，与上方对齐)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Get.toNamed(Routers.ExpenseCategoryPageUrl)?.then((result) {
                if (result != null) {
                  expense.type = result['type'];
                  expense.positive = result['positive'];
                  controller.update(['expense_item']);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: Color(0xFFFAFAFA), width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CategoryIconMap.getIcon(expense.type),
                        color: Colors.black87, size: 18),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    expense.type.isEmpty ? "选择分类" : expense.type,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // 2. 详情卡片：日期、备注、图片
  // =======================================================
  Widget __buildDetailsCard(BuildContext context) {
    var expense = controller.expense.value;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期选择
          GestureDetector(
            onTap: () => controller.showDatePicker(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: Colors.black54),
                SizedBox(width: 10.w),
                Text("日期",
                    style: TextStyle(fontSize: 15.sp, color: Colors.black87)),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    expense.expenseTime, // 这里假设是 String, 格式化逻辑建议放在 controller
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // 备注输入 (多行)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(Icons.edit_note_rounded,
                    size: 20, color: Colors.black54),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: controller.expenseLabelTextEditController,
                  cursorColor: Colors.black87,
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(fontSize: 15.sp),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "写点什么备注一下...",
                    hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => controller.modifyExpenseLabel(v),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // 图片选择 (复用你的逻辑，但美化 UI)
          const Text("附件图片",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          _buildImageGrid(context),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    var expense = controller.expense.value;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 日期选择
          GestureDetector(
            onTap: () => controller.showDatePicker(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: Colors.black54),
                SizedBox(width: 10.w),
                Text("日期",
                    style: TextStyle(fontSize: 15.sp, color: Colors.black87)),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    expense.expenseTime,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // 2. 原价 (弱化处理，移到此处)
          Row(
            children: [
              const Icon(Icons.price_change_outlined,
                  size: 18, color: Colors.black54),
              SizedBox(width: 10.w),
              Text("原价",
                  style: TextStyle(fontSize: 15.sp, color: Colors.black87)),
              SizedBox(width: 8.w),
              Text("(可选)",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              const Spacer(),
              SizedBox(
                width: 100.w,
                child: TextField(
                  cursorColor: Colors.black87,

                  controller: controller.expenseOriginalPriceTextEditController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end, // 靠右对齐
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                    decoration: TextDecoration.lineThrough, // 保持划线效果
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "无优惠",
                    hintStyle: TextStyle(
                        color: Color(0xFFDDDDDD),
                        fontSize: 14,
                        decoration: TextDecoration.none),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => controller.modifyExpenseOriginalPrice(v),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // 3. 图片附件
          const Text("附件图片",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          _buildImageGrid(context),
        ],
      ),
    );
  }

  // 图片网格 (美化版)
  Widget _buildImageGrid(BuildContext context) {
    var expense = controller.expense.value;
    var fileList = expense.fileList ?? [];
    // 计算大小：(屏幕宽 - padding*2 - spacing*2) / 3
    double totalPadding = 16.w * 2 + 20.w * 2; // 外层 padding + card padding
    double itemWidth =
        (MediaQuery.of(context).size.width - totalPadding - 80) / 3;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // 1. 已有图片
        ...List.generate(fileList.length, (index) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) =>
                        ImagePreviewPage(urls: fileList, initialIndex: index),
                  );
                },
                child: Container(
                  width: itemWidth,
                  height: itemWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(fileList[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () {
                    expense.fileList?.removeAt(index);
                    controller.update(['expense_item']);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5)),
                    child:
                        const Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
              )
            ],
          );
        }),

        // 2. 添加按钮
        if (fileList.length < 9)
          GestureDetector(
            onTap: () => controller.pickAndUploadImage(context),
            child: Container(
              width: itemWidth,
              height: itemWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.grey, size: 28),
            ),
          ),
      ],
    );
  }

  // =======================================================
  // 3. 底部按钮区
  // =======================================================
  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () => controller.updateExpense(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // 首页风格的主色调
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: const Text(
          "保存",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.showDeleteDialog(context),
      child: Container(
        width: 50.h,
        height: 50.h,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 24,
        ),
      ),
    );
  }
}
