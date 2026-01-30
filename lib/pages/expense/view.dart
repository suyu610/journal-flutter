import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/log.dart';
import 'package:journal/pages/image_preview_page.dart';
import 'package:journal/routers.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'index.dart';

class ExpenseItemPage extends GetView<ExpensePageController> {
  const ExpenseItemPage({super.key});

  // 主视图
  Widget _buildView(context) {
    var expense = controller.expense.value;
    return Column(
      children: [
        TDCell(
          title: "类别",
          arrow: true,
          noteWidget: Text(
            expense.type,
            style: const TextStyle(fontSize: 16),
          ),
          onClick: (t) {
            var result = Get.toNamed(
              Routers.ExpenseCategoryPageUrl,
            );
            if (result != null) {
              result.then((result) {
                if (result != null) {
                  expense.type = result['type'];
                  expense.positive = result['positive'];
                  controller.update(['expense_item']);
                }
              });
            }

            print("hello");
            return;
          },
        ),
        BrnBarBottomDivider(),
        BrnTextInputFormItem(
          title: "金额",
          controller: controller.expensePriceTextEditController,
          inputType: BrnInputType.decimal,
          onChanged: (value) {
            controller.modifyExpensePrice(value);
          },
          onSubmitted: (v) {
            controller.modifyExpensePrice(v);
          },
        ),
        BrnBarBottomDivider(),
        // 账单备注
        BrnTextInputFormItem(
          title: "备注",
          controller: controller.expenseLabelTextEditController,
          onSubmitted: (v) {
            controller.modifyExpenseLabel(v);
          },
          onChanged: (v) {
            expense.label = v;
          },
        ),

        // 收入/支出
        TDCell(
          title: "收入/支出",
          arrow: true,
          noteWidget: Text(
            expense.positive == 0 ? "支出" : "收入",
            style: TextStyle(
                fontSize: 16,
                color: expense.positive == 0 ? Colors.red : Colors.green),
          ),
          onClick: (v) {
            expense.positive = expense.positive == 0 ? 1 : 0;
            controller.update(['expense_item']);
          },
        ),
        // === 修改：在备注下面插入图片选择器 ===
        BrnBarBottomDivider(),
        // 账单日期
        TDCell(
          titleWidget: const Text(
            "账单时间",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          disabled: false,
          arrow: false,
          noteWidget: Text(
            expense.expenseTime,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          onClick: (v) {
            var date = DateTime.parse(expense.expenseTime);

            TDPicker.showDatePicker(context, title: '选择时间',
                onConfirm: (selected) {
              // 转成 yyyy-mm-dd hh:mm:ss

              var str =
                  "${selected['year']}-${selected['month']}-${selected['day']} ${selected['hour']}:${selected['minute']}:${selected['second']}";
              Log().d(str.toString());
              controller.modifyExpenseTime(str); //.value.createTime = str;
              Navigator.of(context).pop();
            },
                useYear: true,
                useMonth: true,
                useDay: true,
                useHour: true,
                useMinute: true,
                useSecond: true,
                dateStart: [
                  2019,
                  01,
                  01
                ],
                dateEnd: [
                  2030,
                  12,
                  31
                ],
                initialDate: [
                  date.year,
                  date.month,
                  date.day,
                  date.hour,
                  date.minute,
                  date.second
                ]);
          },
        ),
        BrnBarBottomDivider(),
        _buildImageSection(context),

        TDButton(
          margin: EdgeInsets.only(top: 28.h, left: 16, right: 16),
          height: 44,
          isBlock: true,
          theme: TDButtonTheme.primary,
          text: "保存",
          onTap: () {
            controller.updateExpense(context);
          },
        ),

        TDButton(
          margin: EdgeInsets.only(top: 10.h, left: 16, right: 16),
          isBlock: true,
          height: 44,
          theme: TDButtonTheme.danger,
          text: "删除",
          type: TDButtonType.outline,
          onTap: () {
            showGeneralDialog(
              barrierLabel: "关闭",
              context: context,
              barrierDismissible: true,
              pageBuilder: (BuildContext buildContext,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return TDAlertDialog(
                  buttonStyle: TDDialogButtonStyle.text,
                  title: "确认删除本账单？",
                  rightBtn: TDDialogButtonOptions(
                      title: "删除",
                      type: TDButtonType.text,
                      theme: TDButtonTheme.danger,
                      titleColor: const Color(0xffFF3B30),
                      action: () {
                        controller.deleteExpenseItem();
                      }),
                );
              },
            );
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildappbar() => BrnAppBar(
        themeData: BrnAppBarConfig.light(),
        showDefaultBottom: true,
        showLeadingDivider: true,
        automaticallyImplyLeading: true,
        title: const Text(
          "账单",
          style: TextStyle(fontSize: 16),
        ),
        //多icon
        actions: const <Widget>[],
      );
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpensePageController>(
      init: ExpensePageController(),
      id: "expense_item",
      builder: (_) {
        return Scaffold(
          appBar: _buildappbar(),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }

  // === 新增：构建图片附件区域 ===
  Widget _buildImageSection(BuildContext context) {
    var expense = controller.expense.value;
    var fileList = expense.fileList ?? []; // 确保不为空

    // 计算网格宽度，一行3个
    double itemWidth = (MediaQuery.of(context).size.width - 32 - 20) / 3;

    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("附件图片", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // 1. 渲染已有图片
              ...List.generate(fileList.length, (index) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // 图片本体
                    GestureDetector(
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return ImagePreviewPage(
                              urls: fileList,
                              initialIndex: index,
                            );
                          },
                        );

                        print("查看大图: ${fileList[index]}");
                      },
                      child: Container(
                        width: itemWidth,
                        height: itemWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: NetworkImage(fileList[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // 删除按钮 (小红叉)
                    GestureDetector(
                      onTap: () {
                        // 从列表中移除
                        expense.fileList?.removeAt(index);
                        controller.update(['expense_item']);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    )
                  ],
                );
              }),

              // 2. 添加按钮 (如果图片数量没达到上限，比如9张，才显示)
              if (fileList.length < 9)
                GestureDetector(
                  onTap: () {
                    controller.pickAndUploadImage(context);
                  },
                  child: Container(
                    width: itemWidth,
                    height: itemWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.add, color: Colors.grey, size: 30),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
