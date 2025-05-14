// 账本卡片头部
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/routers.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../models/activity.dart';

Widget activityCard(
    Activity activity, BuildContext context, Function refreshFunc,
    {Widget? footerWidget, Widget? topRightWidget}) {
  double usage = 0;
  if (activity.budget != null &&
      activity.budget != 0 &&
      activity.remainingBudget != null) {
    usage = ((activity.budget! - activity.remainingBudget!) / activity.budget!)
        .toPrecision(4);
  }

  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () => Get.toNamed(Routers.CreateActivityUrl, arguments: activity),
    child: Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.40,
                    height: 38.40,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF0052D9),
                      shape: RoundedRectangleBorder(
                        side:
                            const BorderSide(width: 0.80, color: Colors.white),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        activity.activityName.length > 1
                            ? activity.activityName.substring(0, 2)
                            : activity.activityName.isNotEmpty
                                ? activity.activityName
                                : "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.8,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityName,
                        style: const TextStyle(
                          color: Color(0xff000000),
                          fontSize: 14,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "当前账本",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              topRightWidget ?? buildOperationAvatar(activity, context),
            ],
          ),
          const SizedBox(height: 8),
          BrnBarBottomDivider(),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // if (showMode == "expense") {
                  refreshFunc();
                  // }
                },
                child: const Row(
                  children: [
                    Text(
                      "支出",
                      style: TextStyle(
                        color: Color(0xCC666666),
                        fontSize: 12,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Icon(Icons.currency_exchange_rounded)
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text("¥"),
                  Text(
                    "${(activity.totalExpense ?? 0)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontFamily: 'SourceCodePro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "收入",
                        style: TextStyle(
                          color: Color(0xCC666666),
                          fontSize: 12,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        (activity.totalIncome ?? 0).toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "结余",
                        style: TextStyle(
                          color: Color(0xCC666666),
                          fontSize: 12,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        ((activity.totalIncome ?? 0) - (activity.totalExpense ?? 0)).toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'SourceCodePro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          if (activity.budget != null &&
              activity.budget! > 0 &&
              activity.remainingBudget != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: usage > 1
                          ? 1
                          : usage < 0
                              ? 0
                              : usage,
                      backgroundColor: const Color(0xCCDEDEDE),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF3C3C43)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "预算使用${(usage * 100).toStringAsFixed(2)}%，剩余${(activity.remainingBudget ?? 0).toStringAsFixed(2)}元",
                  style: const TextStyle(
                    color: Color(0xCC666666),
                    fontSize: 12,
                    fontFamily: 'SourceCodePro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          footerWidget == null
              ? const SizedBox(
                  height: 0,
                )
              : const SizedBox(
                  height: 14,
                ),
          footerWidget ?? const SizedBox()
        ],
      ),
    ),
  );
}

// 用户头像
Widget buildOperationAvatar(Activity activity, BuildContext context) {
  List<String> avatarList = activity.userList.take(3).map((e) {
    return e.avatarUrl;
  }).toList();
  return GestureDetector(
    onTap: () {
      Get.toNamed(Routers.InvitePageUrl, arguments: activity);
    },
    child: Container(
      alignment: Alignment.centerRight,
      child: TDAvatar(
          avatarSize: 30,
          size: TDAvatarSize.small,
          type: TDAvatarType.display,
          displayText: activity.userList.length > 3
              ? '${activity.userList.length}+'
              : "+",
          avatarDisplayList: avatarList,
          onTap: () {
            TDToast.showText('点击了操作', context: context);
          }),
    ),
  );
}
