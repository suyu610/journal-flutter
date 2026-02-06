// --------------------------------------------------------------------------
// 透明 AppBar
// --------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';

PreferredSizeWidget buildTransparentAppBar(
    BuildContext context, AppThemeColors appColors, bool isDark) {
  return AppBar(
    backgroundColor: Colors.transparent,
    forceMaterialTransparency: true,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: appColors.cardBackground),
      onPressed: () {
        Get.back();
      },
    ),
  );
}
