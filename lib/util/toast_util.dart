import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class ToastUtil {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void showSnackBar(String title, String content,
      {int duration = 3000}) {
    Get.snackbar(
      title,
      content,
      shouldIconPulse: true,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
      borderRadius: 20,
      margin: const EdgeInsets.all(15),
      isDismissible: true,
      duration: Duration(milliseconds: duration),
      forwardAnimationCurve: Curves.linear,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  static void hideLoading() {
    Get.back();
  }

  static void showBottomPopup(bool autoHeight, Widget widget,
      {bool enableDrag = true, bool isDismissible = true}) {
    Get.bottomSheet(
        // 点击遮罩不关闭
        isDismissible: isDismissible,
        barrierColor: Colors.black54,
        isScrollControlled: autoHeight,
        Container(color: Colors.white, child: widget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0.w),
            topRight: Radius.circular(10.0.w),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        enableDrag: enableDrag);
  }

  static void showLoading(String title) {
    Get.dialog(
      Container(
        color: Colors.black12,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                title,
                style: const TextStyle(
                     color: Colors.white),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showUpgradeDialog(
      String version, currentVersion, void Function() upgradeFromAppStore) {
    showGeneralDialog(
        context: Get.context!,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return TDAlertDialog(
            buttonStyle: TDDialogButtonStyle.text,

            title: "检测到新版本\n$version",
            content: "修复若干bug，建议更新",
            rightBtn: TDDialogButtonOptions(
                title: "立即更新",
                action: () => upgradeFromAppStore(),
                type: TDButtonType.fill,
                theme: TDButtonTheme.primary),
            // rightBtnAction: () async {
            //   upgradeFromAppStore();
            // },
          );
        });
  }
}
