import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/activity_card.dart';
import 'package:journal/components/expense_item.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/expense_date_group.dart';
import 'package:journal/routers.dart';

import 'index.dart';

class ExpenseListPage extends GetView<ExpenseListController> {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseListController>(
      init: ExpenseListController(),
      id: "expense_list",
      builder: (_) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: _buildView(context),
        );
      },
    );
  }

  // appbar
  PreferredSizeWidget _buildAppBar(context) {
    return AppBar(
      leadingWidth: 80.w,
      title: Text(
        controller.activity.value.activityName,
        style: TextStyle(
            fontSize: 18.sp, color: Colors.grey[800], fontFamily: "SmileySans"),
      ),
    );
  }

  // 主视图
  Widget _buildView(context) {
    Activity activity = controller.activity.value;

    return Stack(
      children: [
        Container(
            color: const Color(0xfff3f3f3),
            // height: 620.h,
            padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 0),
            // padding: const EdgeInsets.only(bottom: 15.0),
            child: buildMainView(activity, context)),
        // const Align(
        //   // bottom: 10,
        //   heightFactor: 80,
        //   alignment: Alignment.bottomCenter,
        //   child: Padding(
        //     padding: EdgeInsets.all(8.0),
        //     child: BrnBigMainButton(
        //       title: "按人均模式结算",
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget buildMainView(Activity activity, context) {
    return Container(
      width: 385.w,
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            activityCard(activity, context, controller.update,
                topRightWidget: const SizedBox()
                // topRightWidget: const Padding(
                // padding: EdgeInsets.only(right: 0.0, top: 4),
                // child: Icon(
                // Icons.analytics_outlined,
                // color: Color(0xCC3C3C43),
                // ),),)
                ),
            SizedBox(
              height: 12.h,
            ),
            _buildActivityDetail(activity, context),
            SizedBox(
              height: 20.h,
            ),
            // 苹果的那个圆圈 loading
            controller.hasNextPage.value
                ? const CupertinoActivityIndicator()
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                      child: Text(
                        "没有更多了",
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _buildActivityDetail(Activity activity, context) {
    List<ExpenseDateGroup> groupList = controller.expenseDateGroupList;
    return Container(
        child: Column(
            children: groupList
                .map((e) => _buildSingleDateCard(e, context))
                .toList()));
  }

  Widget _buildSingleDateCard(ExpenseDateGroup expenseDateGroup, context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color.fromARGB(12, 0, 0, 0), blurRadius: 8)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            expenseDateGroup.date,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 16.h,
          ),
          ...expenseDateGroup.expenses
              .map((e) => ActivityExpenseItem(e, context))
        ],
      ),
    );
  }

  // 消费详情
  // ignore: unused_element
  Widget _buildActivityConsumptionItem(Expense e, context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routers.ExpenseItemPageUrl, arguments: e);
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.ideographic,
                  children: [
                    Text(
                      e.type,
                      style: TextStyle(
                          color: const Color(0xff666666),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 6.w,
                    ),
                    Text(
                      "¥${e.price}",
                      style: TextStyle(
                          color: const Color(0xff666666),
                          fontFamily: "SourceCodePro",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  e.expenseTime,
                  style: TextStyle(
                      color: const Color(0xff666666),
                      fontSize: 12.sp,
                      fontFamily: "SourceCodePro"),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  e.label,
                  style: TextStyle(
                    color: const Color(0xff666666),
                    fontSize: 12.sp,
                  ),
                )
              ],
            ),
            Row(
              children: [
                // 圆形裁切
                ClipOval(
                  child: Image.network(
                    e.userAvatar,
                    width: 20.r,
                    height: 20.r,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  e.userNickname,
                  style: TextStyle(
                      color: const Color(0xff666666), fontSize: 14.sp),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
