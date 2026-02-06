import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';
// 1. 引入主题配置
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/icons.dart';

// ignore: non_constant_identifier_names
Widget ActivityExpenseItem(Expense e, BuildContext context) {
  GetTimeAgo.setDefaultLocale('zh');

  // 2. 获取主题颜色
  final appColors = Theme.of(context).extension<AppThemeColors>()!;

  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      Get.toNamed(Routers.ExpenseItemPageUrl, arguments: e);
    },
    child: Container(
      width: double.infinity,
      color: Colors.transparent,
      // 稍微增加底部间距，配合大圆角卡片
      margin: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 左侧图标 ---
          Container(
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: appColors.primaryText.withOpacity(0.05),
              shape: BoxShape.circle, // 直接用圆形，代码更干净
            ),
            child: Icon(
              CategoryIconMap.getIcon(e.type),
              size: 20,
              // 图标颜色：跟随主文字色
              color: appColors.primaryText.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 14), // 间距微调

          // --- 右侧内容 ---
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. 标题与备注
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.type,
                        style: TextStyle(
                          color: appColors.primaryText, // 适配深色
                          fontSize: 15,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // 备注：如果有才显示，且处理溢出
                      if (e.label.isNotEmpty) ...[
                        Text(
                          e.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: appColors.secondaryText, // 适配次要色
                            fontSize: 12,
                            fontFamily: 'SourceCodePro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        GetTimeAgo.parse(DateTime.parse(e.expenseTime)),
                        style: TextStyle(
                          color: appColors.secondaryText.withOpacity(0.8),
                          fontSize: 11,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. 金额与用户
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 折扣原价信息
                    if (e.hasDiscount)
                      Text(
                        '${e.positive == 0 ? '-' : '+'}${e.originalPrice}',
                        style: TextStyle(
                          color: appColors.secondaryText, // 适配深色
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          // 删除线颜色也需要适配
                          decorationColor: appColors.secondaryText,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                    // 实际价格
                    Text(
                      '${e.positive == 0 ? '-' : '+'}${e.price}',
                      style: TextStyle(
                        // 支出用主色(黑/白)，收入用绿色(保持不变)
                        color: e.positive == 0
                            ? appColors.primaryText
                            : const Color(0xFF00A870),
                        fontSize: 17, // 稍微加大一点，突出金额
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.userNickname ?? "",
                      style: TextStyle(
                        color: appColors.secondaryText,
                        fontSize: 11,
                        fontFamily: 'SourceCodePro',
                        fontWeight: FontWeight.w400,
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
