import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:journal/core/log.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/routers.dart';
import 'package:journal/util/dialog_util.dart';
import 'package:journal/util/icons.dart';
import 'package:journal/util/toast_util.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// 记账消息 - 暗黑科技风改造
Widget buildExpenseMessage(types.Message message, controller, context) {
  var item = message.metadata!;

  // 获取动态主题色
  Color themeColor =
      controller.currentCharacter.value?.themeColor ?? const Color(0xFF2962FF);
  const Color kTextPrimary = Colors.white; // 主文字
  const Color kTextSecondary = Colors.white54; // 次要文字
  final char = controller.currentCharacter.value;
  List<Color> gradientColors = char?.bgColors ?? [themeColor, themeColor];
  if (gradientColors.isEmpty) gradientColors = [themeColor, themeColor];
  return Container(
    // 限制卡片最大宽度，防止在大屏上太宽
    width: 260,
    decoration: BoxDecoration(
      // 背景：深色半透明 + 极淡的主题色倾向
      color: Color.alphaBlend(themeColor.withOpacity(0.05),
          const Color(0xFF1A1A1A).withOpacity(0.9)),
      borderRadius: BorderRadius.circular(16),
      // 边框：使用渐变边框或者微弱的主题色边框
      border: Border.all(color: themeColor.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    ),
    padding: const EdgeInsets.all(16), // 增加内边距，呼吸感更强
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 顶部：标题与时间
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "已记账",
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              item['expenseTime'].toString().substring(0, 10),
              style: const TextStyle(
                color: kTextSecondary, // 日期稍微暗一点
                fontSize: 12,
                fontFamily: 'SourceCodePro',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        // 分割线：换成细微的白线
        Divider(height: 1, color: Colors.white.withOpacity(0.1)),
        const SizedBox(height: 12),

        // 2. 中部：图标、分类、金额
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // 图标容器
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      // 科技蓝低透明度背景
                      color: themeColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: themeColor.withOpacity(0.3), width: 1)),
                  child: Icon(
                    CategoryIconMap.getIcon(item['type']),
                    size: 18,
                    color: themeColor, // 亮蓝色图标
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['type'],
                      style: const TextStyle(
                        color: kTextPrimary, // 纯白
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['label'] ?? '', // 防止 label 为空报错
                      style: const TextStyle(
                        color: kTextSecondary, // 灰色备注
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // 金额显示
            Text(
              "${item['positive'] == 0 ? '-' : '+'}¥${item['price']}",
              style: const TextStyle(
                color: kTextPrimary, // 金额纯白高亮
                fontSize: 16,
                fontFamily: 'SourceCodePro',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. 底部：操作按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 编辑按钮
            _buildActionButton(
              text: '编辑',
              textColor: Colors.white,
              bgColor: Colors.white.withOpacity(0.1), // 半透白底
              onTap: () {
                item['userNickname'] = "temp";
                item['userAvatar'] = "";
                Get.toNamed(Routers.ExpenseItemPageUrl,
                    arguments: Expense.fromJson(item));
                Log().d(item['expenseId']);
              },
            ),
            const SizedBox(width: 8),
            // 删除按钮
            _buildActionButton(
              text: '删除',
              textColor: const Color(0xFFFF5252), // 亮红色
              bgColor: const Color(0xFFFF5252).withOpacity(0.1), // 半透红底
              onTap: () {
                ToastUtil.lightImpact();
                PremiumGlassDialog.show(Get.context!,
                    title: "删除提示", content: "确认删除这条账单吗？", onConfirm: () {
                  controller.deleteExpense(item['expenseId']);
                }, onCancel: () {
                  Get.back();
                });
              },
            ),
          ],
        ),
      ],
    ),
  );
}

// 提取按钮组件，保持代码整洁
Widget _buildActionButton({
  required String text,
  required Color textColor,
  required Color bgColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
