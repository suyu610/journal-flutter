import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildEmptyItem({
  required String title,
  required String operateText,
  required void Function() action,
}) {
  return Container(
    color: Colors.white,
    child: Center(
      child: GestureDetector(
        onTap: action.call,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              operateText,
              style: TextStyle(
                fontSize: 14.sp,
              ),
            )
          ],
        ),
      ),
    ),
  );
}
