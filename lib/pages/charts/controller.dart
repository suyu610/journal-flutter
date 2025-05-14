import 'package:get/get.dart';
import 'package:journal/components/bruno/bruno.dart';
import 'package:journal/core/log.dart';
import 'package:journal/event_bus/event_bus.dart';
import 'package:journal/event_bus/need_refresh_data.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/pages/charts/view.dart';
import 'package:journal/pages/tabbar_layout/controller.dart';
import 'package:journal/request/request.dart';

class ChartsController extends GetxController {
  ChartsController();
  RxList<DBDataNodeModel> charts =
      RxList<DBDataNodeModel>.empty(growable: true);
  RxList<DBDataNodeModel> chartsIncome =
      RxList<DBDataNodeModel>.empty(growable: true);

  RxList<DBDataNodeModel> groupByTypeCharts =
      RxList<DBDataNodeModel>.empty(growable: true);
  RxList<Activity> allActivityList = RxList<Activity>.empty(growable: true);
  Rx<Activity> currentActivity = Rx<Activity>(Activity.empty());
  Rx<BrnDoughnutDataItem> selectedItem =
      BrnDoughnutDataItem(value: 0, title: "").obs;
  RxBool showTitleWhenSelected = false.obs;
  selectItem(BrnDoughnutDataItem? item) {
    if (item == null) {
      return;
    }
    selectedItem.value = item;
    update(["charts"]);
  }

  _initData() {
    allActivityList.clear();
    chartsIncome.clear();
    charts.clear();
    groupByTypeCharts.clear();
    LayoutController layoutController = Get.find<LayoutController>();
    var currentActivityId = currentActivity.value.activityId == ""
        ? layoutController.user.value.currentActivityId
        : currentActivity.value.activityId;

    HttpRequest.request(
      Method.get,
      "/activity/list",
      success: (data) {
        var selfActivityList = (data as List).map((e) {
          var tmp = Activity.fromJson(e);
          if (tmp.activityId == currentActivityId) {
            currentActivity.value = tmp;
          }
          return tmp;
        }).toList();

        HttpRequest.request(
          Method.get,
          "/activity/list/joined",
          success: (data) {
            var joinedActivityList = (data as List).map((e) {
              var tmp = Activity.fromJson(e);
              if (tmp.activityId == currentActivityId) {
                currentActivity.value = tmp;
              }
              return tmp;
            }).toList();

            selfActivityList.addAll(joinedActivityList);
            allActivityList.value = selfActivityList;
            HttpRequest.request(Method.get, "/charts/weekly/$currentActivityId",
                fail: (code, msg) {}, success: (data) {
              if (data != null) {
                charts.value = (data as List)
                    .map((e) => DBDataNodeModel.fromJson(e))
                    .toList();
                HttpRequest.request(
                    Method.get, "/charts/weekly/type/$currentActivityId",
                    fail: (code, msg) {
                  Log().d(msg);
                }, success: (data) {
                  // 这周的收入
                  HttpRequest.request(
                      Method.get, "/charts/weekly/income/$currentActivityId",
                      fail: (code, msg) {}, success: (data) {
                    if (data != null) {
                      chartsIncome.value = (data as List)
                          .map((e) => DBDataNodeModel.fromJson(e))
                          .toList();
                    }
                  });

                  if (data != null) {
                    groupByTypeCharts.value = (data as List)
                        .map((e) => DBDataNodeModel.fromJson(e))
                        .toList();
                  }

                  update(["charts"]);
                });
              }
            });
          },
          fail: (code, msg) {},
        );
      },
      fail: (code, msg) {},
    );
  }

  void onTap() {}

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onReady() {
    super.onReady();
    eventBus.on<NeedRefreshData>().listen((NeedRefreshData data) {
      Log().d("need refresh data: $data");
      if (data.refreshChartsList) {
        _initData();
      }
    });
  }

  void swtichShowTitleWhenSelected() {
    showTitleWhenSelected.value = !showTitleWhenSelected.value;
    update(["charts"]);
  }
}
