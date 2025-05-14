import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/src/components/navbar/brn_appbar.dart';
import 'package:journal/components/bruno/src/theme/configs/brn_appbar_config.dart';
import 'package:journal/constants/bill_column.dart';
import 'package:journal/util/icons.dart';
import 'index.dart';

class ExpenseCategoryPage extends GetView<ExpenseTypePickerController> {
  const ExpenseCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseTypePickerController>(
      init: ExpenseTypePickerController(),
      id: "expense_category",
      builder: (_) {
        return Scaffold(
          appBar: _buildappbar(),
          body: _buildView(),
        );
      },
    );
  }

  PreferredSizeWidget _buildappbar() => BrnAppBar(
        themeData: BrnAppBarConfig.light(),
        showDefaultBottom: true,
        showLeadingDivider: true,
        automaticallyImplyLeading: true,
        title: const Text(
          "账单类别",
          style: TextStyle(fontSize: 16),
        ),
        //多icon
        actions: const <Widget>[],
      );

  // 主视图
  Widget _buildView() {
    return ContainedTabBarView(
      tabs: const [
        Text('支出'),
        Text('收入'),
      ],
      tabBarProperties: TabBarProperties(
        background: Container(
          color: Colors.white,
        ),
        position: TabBarPosition.top,
        alignment: TabBarAlignment.end,
        indicatorColor: const Color(0xff0052D9),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black,
      ),
      views: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          color: Colors.white,
          child: GridView.count(
            crossAxisSpacing: 0.w,
            mainAxisSpacing: 0.h,
            crossAxisCount: 4,
            childAspectRatio: .8,
            children: billColumnList
                .map((e) => GestureDetector(
                    onTap: () {
                      Get.back(result: {"type": e['labelName'], "positive": 0});
                    },
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF0052D9).withAlpha(10),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 0.80, color: Colors.white),
                                borderRadius: BorderRadius.circular(799.20),
                              ),
                            ),
                            child: Icon(
                              getIconByType(e['labelName']),
                              size: 22,
                              color: const Color(0xFF0052D9),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            e["labelName"],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    )))
                .toList(),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          color: Colors.white,
          child: GridView.count(
            crossAxisSpacing: 0.w,
            mainAxisSpacing: 0.h,
            crossAxisCount: 4,
            childAspectRatio: .8,
            children: incomeColumnList
                .map((e) => GestureDetector(
                    onTap: () {
                      Get.back(result: {"type": e['labelName'], "positive": 1});
                    },
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF0052D9).withAlpha(10),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 0.80, color: Colors.white),
                                borderRadius: BorderRadius.circular(799.20),
                              ),
                            ),
                            child: Icon(
                              getIconByType(e['labelName']),
                              size: 22,
                              color: const Color(0xFF0052D9),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            e["labelName"],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    )))
                .toList(),
          ),
        ),
      ],
      onChange: (index) => print(index),
    );
  }
}
