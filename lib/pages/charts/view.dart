import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/util/keyboard_util.dart';

import 'index.dart';

class DBDataNodeModel {
  String? value;
  String name;
  DBDataNodeModel(this.value, this.name);

  // from json
  factory DBDataNodeModel.fromJson(Map<String, dynamic> json) {
    return DBDataNodeModel(json['value']?.toString(), json['name']);
  }
}

class ChartsPage extends GetView<ChartsController> {
  const ChartsPage({super.key});

  // 主视图
  Widget _buildView(context) {
    List<DBDataNodeModel> dailyData = controller.charts;
    List<DBDataNodeModel> groupByTypeData = controller.groupByTypeCharts;
    //
    double totalValue = groupByTypeData.fold(
        0.0, (prev, curr) => prev + double.parse(curr.value ?? '0'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: _getMaxValueForDemo1(dailyData) > 0,
              child: Text(
                "最近7天消费",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ),
            Visibility(
              visible: _getMaxValueForDemo1(dailyData) > 0,
              child: const SizedBox(
                height: 14,
              ),
            ),
            Visibility(
              visible: _getMaxValueForDemo1(dailyData) > 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: BrnBrokenLine(
                  size: Size((300).w, MediaQuery.of(context).size.height / 5),
                  lines: [
                    BrnPointsLine(
                      isShowPointText: false,
                      lineWidth: 2,
                      pointRadius: 3,
                      isShowPoint: true,
                      isCurve: true,
                      points: _linePointsForDemo1(dailyData),
                      shaderColors: [
                        const Color(0xff0052D9).withOpacity(0.3),
                        const Color(0xff0052D9).withOpacity(0.01)
                      ],
                      lineColor: const Color(0xff0052D9).withOpacity(.8),
                    ),
                  ],
                  yHintLineOffset: 20,
                  hintLineColor: Colors.grey[300],
                  isShowXHintLine: true,
                  xyDialLineWidth: .1,
                  showPointDashLine: true,
                  isTipWindowAutoDismiss: true,
                  xDialValues: _getXDialValuesForDemo1(dailyData),
                  xDialMin: 0,
                  xDialMax:
                      _getXDialValuesForDemo1(dailyData).length.toDouble(),
                  yDialValues: _getYDialValuesForDemo1(dailyData),
                  yDialMin: 0,
                  yDialMax: _getMaxValueForDemo1(dailyData),
                  isHintLineSolid: false,
                  isShowYDialText: true,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Visibility(
              visible: _getMaxValueForDemo1(controller.chartsIncome) > 0,
              child: Text(
                "最近7天收入",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ),
            Visibility(
              visible: _getMaxValueForDemo1(controller.chartsIncome) > 0,
              child: const SizedBox(
                height: 14,
              ),
            ),
            Visibility(
              visible: _getMaxValueForDemo1(controller.chartsIncome) > 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: BrnBrokenLine(
                  size: Size((300).w, MediaQuery.of(context).size.height / 5),
                  lines: [
                    BrnPointsLine(
                      isShowPointText: false,
                      lineWidth: 2,
                      pointRadius: 3,
                      isShowPoint: true,
                      isCurve: true,
                      points: _linePointsForDemo1(controller.chartsIncome),
                      shaderColors: [
                        Colors.green.withOpacity(0.3),
                        Colors.green.withOpacity(0.01)
                      ],
                      lineColor: Colors.green.withOpacity(.8),
                    ),
                  ],
                  yHintLineOffset: 20,
                  hintLineColor: Colors.grey[300],
                  isShowXHintLine: true,
                  xyDialLineWidth: .1,
                  showPointDashLine: true,
                  isTipWindowAutoDismiss: true,
                  xDialValues: _getXDialValuesForDemo1(dailyData),
                  xDialMin: 0,
                  xDialMax: _getXDialValuesForDemo1(controller.chartsIncome)
                      .length
                      .toDouble(),
                  yDialValues: _getYDialValuesForDemo1(controller.chartsIncome),
                  yDialMin: 0,
                  yDialMax: _getMaxValueForDemo1(controller.chartsIncome),
                  isHintLineSolid: false,
                  isShowYDialText: true,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "消费分类",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                ),
                BrnSwitchButton(
                    size: const Size(40, 24),
                    borderColor: Colors.grey[300]!,
                    value: controller.showTitleWhenSelected.value,
                    onChanged: (v) {
                      controller.swtichShowTitleWhenSelected();
                    }),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Container(
              width: 500,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: groupByTypeData.isEmpty
                  ? Container()
                  : BrnDoughnutChart(
                      height: MediaQuery.of(context).size.height / 4.3,
                      ringWidth: 50,
                      selectedItem: controller.selectedItem.value,
                      selectCallback: (selectedItem) {
                        controller.selectItem(selectedItem);
                      },
                      showTitleWhenSelected:
                          !controller.showTitleWhenSelected.value,
                      data: groupByTypeData
                          .map((item) => BrnDoughnutDataItem(
                              color: const Color.fromARGB(255, 15, 97, 230)
                                  .withOpacity(1 -
                                      groupByTypeData.indexOf(item) /
                                          groupByTypeData.length),
                              // colorList[groupByTypeData.indexOf(item) %   colorList.length],
                              value: double.parse((item).value!) / totalValue,
                              title: "${item.name}¥${item.value ?? ""}"))
                          .toList(),
                    ),
            ),
            SizedBox(height: 30.h)
          ],
        ),
      ),
    );
  }

  List<BrnPointData> _linePointsForDemo1(List<DBDataNodeModel> brokenData) {
    return brokenData
        .map((_) => BrnPointData(
            pointText: _.value,
            x: brokenData.indexOf(_).toDouble(),
            y: double.parse(_.value ?? "0"),
            lineTouchData: BrnLineTouchData(
                tipWindowSize: const Size(60, 40),
                onTouch: () {
                  return _.value;
                })))
        .toList();
  }

  List<BrnDialItem> _getYDialValuesForDemo1(List<DBDataNodeModel> brokenData) {
    double min = _getMinValueForDemo1(brokenData);
    double max = _getMaxValueForDemo1(brokenData);
    double dValue = (max - min) / 10;
    List<BrnDialItem> _yDialValue = [];
    for (int index = 0; index <= 10; index++) {
      _yDialValue.add(BrnDialItem(
        dialText: '${(min + index * dValue).ceil()}',
        dialTextStyle:
            const TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
        value: (min + index * dValue).ceilToDouble(),
      ));
    }
    _yDialValue.add(BrnDialItem(
      dialText: '4.5',
      dialTextStyle: const TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
      value: 4.5,
    ));
    return _yDialValue;
  }

  double _getMinValueForDemo1(List<DBDataNodeModel> brokenData) {
    double minValue = brokenData.isEmpty
        ? 0
        : double.tryParse(brokenData[0].value ?? "") ?? 0;
    for (DBDataNodeModel point in brokenData) {
      minValue = min(double.tryParse(point.value ?? "") ?? 0, minValue);
    }
    return minValue;
  }

  double _getMaxValueForDemo1(List<DBDataNodeModel> brokenData) {
    double maxValue = brokenData.isEmpty
        ? 0
        : double.tryParse(brokenData[0].value ?? "") ?? 0;
    for (DBDataNodeModel point in brokenData) {
      maxValue = max(double.tryParse(point.value ?? "") ?? 0, maxValue);
    }
    return maxValue;
  }

  List<BrnDialItem> _getXDialValuesForDemo1(List<DBDataNodeModel> brokenData) {
    List<BrnDialItem> _xDialValue = [];
    for (int index = 0; index < brokenData.length; index++) {
      _xDialValue.add(BrnDialItem(
        dialText: brokenData[index].name,
        dialTextStyle:
            const TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
        value: index.toDouble(),
      ));
    }
    return _xDialValue;
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey actionKey = GlobalKey();
    return GetBuilder<ChartsController>(
      init: ChartsController(),
      id: "charts",
      autoRemove: false,
      builder: (_) {
        return Scaffold(
          appBar: BrnAppBar(
            themeData: BrnAppBarConfig.light(),
            automaticallyImplyLeading: false,
            leadingWidth: 280.w,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: BrnTextAction(
                controller.currentActivity.value.activityName,
                key: actionKey,
                iconPressed: () {
                  BrnPopupListWindow.showPopListWindow(context, actionKey,
                      offset: 10, onItemClick: (index, name) {
                    controller.currentActivity.value =
                        controller.allActivityList[index];
                    controller.onInit();
                    controller.update(['charts']);
                    Get.back();
                    return true;
                  },
                      data: controller.allActivityList.isEmpty
                          ? ["加载中"]
                          : controller.allActivityList
                              .map((e) => e.activityName)
                              .toList());
                },
              ),
            ),
          ),
          body: SafeArea(
            child: controller.charts.isEmpty ||
                    controller.groupByTypeCharts.isEmpty
                ? _buildEmptyCard()
                : _buildView(context),
          ),
        );
      },
    );
  }

  _buildEmptyCard() {
    return BrnAbnormalStateWidget(
      img: Image.asset(
        'assets/images/no_data.png',
        scale: 3.0,
      ),
      isCenterVertical: true,
      title: "无数据",
      operateTexts: const <String>["刷新"],
      operateAreaType: OperateAreaType.textButton,
      action: (index) {
        KeyboardUtils.hide();
        controller.onInit();
      },
    );
  }
}
