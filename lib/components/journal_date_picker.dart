import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum JournalDatePickerMode {
  date, // 年月日
  time, // 时分
  dateTime, // 年月日 时分
}

// ... 之前的 enum 定义保持不变 ...

class JournalDatePicker {
  static void show(
    BuildContext context, {
    required Function(DateTime) onConfirm,
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    JournalDatePickerMode mode = JournalDatePickerMode.date,
    String title = "选择时间",
  }) {
    final initDate = initialDate ?? DateTime.now();
    final minimumDate = minDate ?? DateTime(1900);
    final maximumDate = maxDate ?? DateTime(2100);
    DateTime tempPickedDate = initDate;

    // 根据模式确定 Cupertino 模式
    CupertinoDatePickerMode cupertinoMode;
    switch (mode) {
      case JournalDatePickerMode.date:
        cupertinoMode = CupertinoDatePickerMode.date;
        break;
      case JournalDatePickerMode.time:
        cupertinoMode = CupertinoDatePickerMode.time;
        break;
      case JournalDatePickerMode.dateTime:
        cupertinoMode = CupertinoDatePickerMode.dateAndTime;
        break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // 获取当前主题颜色，用于适配
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Container(
          height: 340,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), // 更大的圆角，更现代
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 1. 顶部操作栏 (加粗字体，加大间距)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Text("取消",
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 16)),
                    ),
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: textColor)),
                    GestureDetector(
                      onTap: () {
                        onConfirm(tempPickedDate);
                        Navigator.pop(ctx);
                      },
                      child: const Text("确定",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                    ),
                  ],
                ),
              ),

              // 2. 滚轮区域 (核心优化点)
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 20, // 稍微加大字号
                        color: textColor,
                        fontWeight: FontWeight.normal, // 默认字体
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: cupertinoMode,
                    initialDateTime: initDate,
                    minimumDate: minimumDate,
                    maximumDate: maximumDate,
                    use24hFormat: true,
                    // 关键视觉优化：去除背景色，纯净模式
                    backgroundColor: Colors.transparent,
                    // 关键视觉优化：增加选中项放大效果，看起来更有质感
                    itemExtent: 44, // 每一行的高度
                    onDateTimeChanged: (val) => tempPickedDate = val,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}
