import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/components/dialog/brn_dialog.dart';
import 'package:journal/core/log.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/icons.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:journal/util/toast_util.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

// 记账消息
Widget buildExpenseMessage(types.Message message, controller, context) {
  var item = message.metadata!;
  return Container(
    decoration: const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "已记账",
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontFamily: 'SourceCodePro',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  Text(
                    item['expenseTime'].toString().substring(0, 10),
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontFamily: 'SourceCodePro',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const TDDivider(),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(8),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF0052D9).withAlpha(10),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 0.80, color: Colors.white),
                              borderRadius: BorderRadius.circular(799.20),
                            ),
                          ),
                          child: Icon(
                            getIconByType(item['type']),
                            size: 16,
                            color: const Color(0xFF0052D9),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['type'],
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['label'],
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${item['positive'] == 0 ? '-' : '+'}¥${item['price']}",
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                item['userNickname'] = "temp";
                item['userAvatar'] = "";
                Get.toNamed(Routers.ExpenseItemPageUrl,
                    arguments: Expense.fromJson(item));
                Log().d(item['expenseId']);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF3F3F3),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFF3F3F3)),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  '编辑',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.9),
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                ToastUtil.lightImpact();
                BrnDialogManager.showConfirmDialog(context,
                    title: "删除提示",
                    cancel: '取消',
                    confirm: '确认',
                    message: "确认删除这条账单吗？", onConfirm: () {
                  controller.deleteExpense(item['expenseId']);
                }, onCancel: () {
                  Get.back();
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFFFFF0ED),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFFFF0ED)),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  '删除',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD54941),
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
