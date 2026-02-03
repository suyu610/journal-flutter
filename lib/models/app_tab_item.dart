// 定义一个 Tab 模型
import 'package:flutter/material.dart';

class AppTabItem {
  final String id; // 唯一标识 (用于保存设置)
  final String label; // 设置页显示的名称
  final IconData icon; // 图标
  final Widget page; // 对应的页面
  final bool isVipOnly; // 是否 VIP 专属
  bool isEnabled; // 用户开关 (可变)

  AppTabItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.page,
    this.isVipOnly = false,
    this.isEnabled = true,
  });
}
