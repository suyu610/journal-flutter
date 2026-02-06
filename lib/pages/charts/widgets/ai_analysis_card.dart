import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller.dart';

class AiAnalysisCard extends GetView<ChartsController> {
  const AiAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. 显示分析结果
      if (controller.judgeString.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[50]!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.blueGrey[100]!, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16.sp, color: Colors.amber),
                  SizedBox(width: 8.w),
                  Text(
                    "本周 AI 洞察",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blueGrey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                controller.judgeString.value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      }

      // 2. 显示 Loading 状态
      if (controller.isAnalyzing.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.blueGrey),
                ),
                SizedBox(width: 12.w),
                Text("AI 正在分析本周数据...",
                    style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
              ],
            ),
          ),
        );
      }

      // 3. 默认不显示
      return const SizedBox();
    });
  }
}
