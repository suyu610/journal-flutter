import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller.dart';

Widget buildBgImage(ChatController controller, BuildContext context) {
  return Visibility(
    visible: controller.bgImage.isNotEmpty,
    child: Opacity(
      opacity: .3,
      child: Image.asset(
        controller.bgImage.value,
        width: MediaQuery.of(context).size.width,
        height: 815.h,
        fit: BoxFit.fitWidth,
      ),
    ),
  );
}
