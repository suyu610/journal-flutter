// 文件路径: lib/pages/mission_dashboard/view.dart

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/trip_item.dart';
import 'package:journal/pages/mission_dashboard/widget/voice_assistant_button.dart';
import 'package:journal/util/toast_util.dart';
import 'controller.dart';

// 引入新的重构组件
import 'widget/trip_list_view.dart';
import 'widget/packing_header.dart';
import 'widget/suitcase_view.dart';
import 'widget/unpack_grid_view.dart';

class MissionPage extends GetView<MissionController> {
  const MissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    return GetBuilder<MissionController>(
      init: MissionController(),
      id: "mission",
      autoRemove: false,
      builder: (_) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: appColors.backgroundColor,
            body: Stack(
              children: [
                EasyRefresh(
                  triggerAxis: Axis.vertical,
                  controller: controller.refreshController,
                  onRefresh: () async {
                    ToastUtil.heavyImpact();
                    controller.loadInitialData();
                  },
                  // 接受从箱子里拖出来的物品
                  child: DragTarget<TripItem>(
                    onWillAccept: (item) {
                      if (!controller.isPackingMode.value) return false;
                      return item?.isPacked ?? false;
                    },
                    onAccept: (item) {
                      controller.toggleChecklistItem(item);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return CustomScrollView(
                        slivers: [
                          // 1. 行程卡片列表
                          const TripListView(),

                          // 2. 整理模式标题
                          const PackingHeader(),

                          // 3. 箱子区域
                          const SuitcaseView(),

                          // 4. 小标题
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 16, 20, 12),
                              child: Text("未装箱物品",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: appColors.secondaryText)),
                            ),
                          ),

                          // 5. 未装箱网格
                          const UnpackGridView(),

                          const SliverToBoxAdapter(
                              child: SizedBox(height: 100)),
                        ],
                      );
                    },
                  ),
                ),
                const VoiceAssistantButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}
