// 消费详情
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/icons.dart';

// ignore: non_constant_identifier_names
Widget ActivityExpenseItem(Expense e, context) {
  GetTimeAgo.setDefaultLocale('zh');
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      Get.toNamed(Routers.ExpenseItemPageUrl, arguments: e);
    },
    child: Container(
      width: double.infinity,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color.fromARGB(255, 0, 0, 0).withAlpha(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(799.20),
              ),
            ),
            child: Icon(CategoryIconMap.getIcon(e.type),
                size: 19.20, color: const Color.fromARGB(255, 0, 0, 0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.type,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.label,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 12,
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      GetTimeAgo.parse(DateTime.parse(e.expenseTime)),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 12,
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 折扣信息
                    if (e.hasDiscount)
                      Text(
                        '${e.positive == 0 ? '-' : '+'}${e.originalPrice}',
                        style: TextStyle(
                          color: e.positive == 0
                              ? const Color(0xFF000000)
                              : Colors.blueGrey[900],
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.black54,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    Text(
                      '${e.positive == 0 ? '-' : '+'}${e.price}',
                      style: TextStyle(
                        color: e.positive == 0
                            ? const Color(0xFF000000)
                            : const Color(0xFF00A870),
                        fontSize: 16,
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.userNickname ?? "",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 12,
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
