// 文件路径: lib/pages/mission_dashboard/widget/trip_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/components/empty_item.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/pages/mission_dashboard/controller.dart';
import 'package:journal/pages/mission_dashboard/widget/trip_card_item.dart';

class TripListView extends GetView<MissionController> {
  const TripListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appColors = Theme.of(context).extension<AppThemeColors>()!;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏 (内联，减少文件碎片)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("当前行程",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appColors.primaryText)),
                TextButton(
                  onPressed: () => controller.showUploadDialog(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child:
                      Icon(Icons.add, size: 24, color: appColors.primaryText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 内容区域
          Obx(() {
            if (controller.trips.isEmpty) {
              return JournalEmptyItem(
                title: "暂无行程",
                operateText: "添加",
                action: () => controller.showUploadDialog(context),
              );
            }

            return SizedBox(
              height: 300,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.trips.length,
                onReorder: controller.reorderTrips,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.05)
                          .animate(animation),
                      child: Opacity(opacity: 0.8, child: child),
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final trip = controller.trips[index];
                  return Container(
                    key: ValueKey(trip.id),
                    width: 340,
                    margin: const EdgeInsets.only(right: 12),
                    child: ExquisiteTripCard(
                      tripModel: trip,
                      onEdit: () => controller.showConfirmDialog(trip, context,
                          existingTrip: trip),
                      onDelete: () => controller.deleteTrip(trip, context),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
