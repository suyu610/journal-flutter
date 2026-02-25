// 文件路径: lib/pages/mission_dashboard/widget/trip_card_item.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/trip_card_model.dart';
import 'package:journal/pages/mission_dashboard/util/trip_action_util.dart'; // 引入工具类
import 'package:remixicon/remixicon.dart';

class ExquisiteTripCard extends StatefulWidget {
  final TripModel? tripModel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExquisiteTripCard({
    Key? key,
    this.tripModel,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ExquisiteTripCard> createState() => _ExquisiteTripCardState();
}

class _ExquisiteTripCardState extends State<ExquisiteTripCard> {
  late TripModel trip;
  Timer? _timer;
  String _countdownText = "";
  Color _countdownColor = Colors.blue;
  bool _isDeparted = false;

  @override
  void initState() {
    super.initState();
    trip = widget.tripModel!;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ExquisiteTripCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tripModel != oldWidget.tripModel) {
      setState(() {
        trip = widget.tripModel!;
      });
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    void tick() {
      if (!mounted) return;
      final now = DateTime.now();
      try {
        final dateStr = trip.depDate.contains("-")
            ? trip.depDate
            : DateTime.now().toString().substring(0, 10);
        final depTime = DateTime.parse("$dateStr ${trip.depTime}:00");
        final diff = depTime.difference(now);

        setState(() {
          if (diff.isNegative) {
            _isDeparted = true;
            _countdownText = "已出发";
            _countdownColor = Colors.grey;
          } else {
            _isDeparted = false;
            if (diff.inDays > 0) {
              _countdownText = "${diff.inDays}天${diff.inHours % 24}小时后出发";
              _countdownColor = const Color(0xFF2E7D32);
            } else if (diff.inHours > 0) {
              _countdownText = "${diff.inHours}小时${diff.inMinutes % 60}分后出发";
              _countdownColor = Colors.blueAccent.shade700;
            } else {
              _countdownText = "仅剩 ${diff.inMinutes} 分钟";
              _countdownColor = const Color(0xFFD32F2F);
            }
          }
        });
      } catch (e) {
        // print("Time parse error: $e");
      }
    }

    tick();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => tick());
  }

  @override
  Widget build(BuildContext context) {
    final isTrain = trip.type == 'Train';
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    // 过期变灰逻辑
    final primaryColor = _isDeparted
        ? appColors.secondaryText.withOpacity(0.8)
        : appColors.chartPalette[0];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: _isDeparted ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: _isDeparted
              ? Border.all(color: appColors.primaryText.withOpacity(0.08))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上半部分
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Column(
                children: [
                  _buildHeader(isTrain, appColors),
                  const SizedBox(height: 16),
                  _buildRouteMain(primaryColor, isTrain, appColors),
                ],
              ),
            ),

            // 虚线分割
            _buildTicketDivider(appColors),

            // 下半部分
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailsGrid(primaryColor, appColors),
                    Column(
                      children: [
                        Divider(
                            height: 1,
                            color: appColors.secondaryText.withOpacity(0.1)),
                        const SizedBox(height: 12),
                        _buildActionBar(isTrain, appColors),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTrain, AppThemeColors appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: appColors.primaryText.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                  isTrain
                      ? Icons.train_outlined
                      : Icons.flight_takeoff_outlined,
                  color: appColors.primaryText,
                  size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              trip.depDate,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: appColors.primaryText),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _isDeparted
                ? appColors.secondaryText.withOpacity(0.08)
                : _countdownColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _countdownText,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _isDeparted ? appColors.secondaryText : _countdownColor),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteMain(
      Color primaryColor, bool isTrain, AppThemeColors appColors) {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: _buildCityColumn(
              time: trip.depTime,
              city: trip.depCity,
              station: trip.depStation,
              align: CrossAxisAlignment.start,
              appColors: appColors,
            )),
        Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(trip.number,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor)),
                // 省略中间图标部分代码以节省篇幅，保持原样即可
                const SizedBox(height: 2),
                Icon(Icons.arrow_right_alt,
                    color: appColors.secondaryText.withOpacity(0.3)),
                const SizedBox(height: 2),
                Text(trip.duration,
                    style: TextStyle(
                        fontSize: 11, color: appColors.secondaryText)),
              ],
            )),
        Expanded(
            flex: 3,
            child: _buildCityColumn(
              time: trip.arrTime,
              city: trip.arrCity,
              station: trip.arrStation,
              align: CrossAxisAlignment.end,
              appColors: appColors,
              dayDiff: trip.dayDiff,
            )),
      ],
    );
  }

  Widget _buildCityColumn({
    required String time,
    required String city,
    String? station,
    required CrossAxisAlignment align,
    required AppThemeColors appColors,
    int dayDiff = 0,
  }) {
    // 逻辑：如果站点存在且与城市名不同，才显示站点详情
    final shouldShowStation =
        station != null && station.isNotEmpty && station != city;

    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: appColors.primaryText,
                    height: 1.0)),
            if (dayDiff > 0)
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text("+$dayDiff",
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold)),
              )
          ],
        ),
        const SizedBox(height: 6),
        Text(city,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: appColors.primaryText)),
        if (shouldShowStation)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(station,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: appColors.secondaryText)),
          ),
      ],
    );
  }

  Widget _buildDetailsGrid(Color primaryColor, AppThemeColors appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailItem("检票口",
            trip.depGate?.isNotEmpty == true ? trip.depGate! : "--", appColors,
            highlight: true, highlightColor: primaryColor),
        _buildDetailItem("席别", trip.seatClass ?? "--", appColors),
        _buildDetailItem("座位号", trip.seatDetail ?? "--", appColors,
            crossAlign: CrossAxisAlignment.end),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, AppThemeColors appColors,
      {bool highlight = false,
      Color? highlightColor,
      CrossAxisAlignment crossAlign = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: appColors.secondaryText)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: highlight ? highlightColor : appColors.primaryText)),
      ],
    );
  }

  Widget _buildActionBar(bool isTrain, AppThemeColors appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
            icon: RemixIcons.map_2_line,
            label: "导航",
            // 核心修改：调用工具类
            onTap: () => TripActionUtil.launchApp(context, 'map'),
            appColors: appColors),
        if (isTrain) ...[
          _buildVerticalDivider(appColors),
          _buildActionButton(
              icon: Icons.train_outlined,
              label: "12306",
              onTap: () => TripActionUtil.launchApp(context, '12306'),
              appColors: appColors),
        ],
        _buildVerticalDivider(appColors),
        _buildActionButton(
            icon: RemixIcons.app_store_line,
            label: "携程",
            onTap: () => TripActionUtil.launchApp(context, 'ctrip'),
            appColors: appColors),
        _buildVerticalDivider(appColors),
        _buildActionButton(
            icon: Icons.settings_outlined,
            label: "更多",
            onTap: () => _showActionSheet(context),
            appColors: appColors),
      ],
    );
  }

  Widget _buildVerticalDivider(AppThemeColors appColors) {
    return Container(
        width: 1, height: 14, color: appColors.secondaryText.withOpacity(0.2));
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required AppThemeColors appColors}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 15, color: appColors.secondaryText),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: appColors.secondaryText)),
          ],
        ),
      ),
    );
  }

  // --- 分割线 ---
  Widget _buildTicketDivider(AppThemeColors appColors) {
    return SizedBox(
        height: 24,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
              size: const Size(double.infinity, 1),
              painter: DashedLinePainter(
                  color: appColors.secondaryText.withOpacity(0.15))),
          Positioned(
              left: -12,
              child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                      color: appColors.backgroundColor,
                      shape: BoxShape.circle))),
          Positioned(
              right: -12,
              child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                      color: appColors.backgroundColor,
                      shape: BoxShape.circle))),
        ]));
  }

  void _showActionSheet(BuildContext context) {
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 灰色小横条 (Handle)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appColors.secondaryText.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // 选项 1：编辑
            _buildSheetItem(
              icon: Icons.edit_outlined,
              text: "编辑行程",
              color: appColors.primaryText,
              onTap: () {
                Get.back(); // 关闭弹窗
                widget.onEdit?.call();
              },
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: appColors.secondaryText.withOpacity(0.1)),
            const SizedBox(height: 12),

            // 选项 2：删除
            _buildSheetItem(
              icon: Icons.delete_outline,
              text: "删除此行程",
              color: const Color(0xFFFF4D4F), // 警示红
              onTap: () {
                Get.back();
                widget.onDelete?.call();
              },
            ),

            const SizedBox(height: 16),

            // 取消按钮
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: appColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text("取消",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: appColors.secondaryText)),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true, // 允许弹窗高度自适应
    );
  }

  Widget _buildSheetItem(
      {required IconData icon,
      required String text,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Text(text,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  String translateMapName(String mapName) {
    switch (mapName) {
      case "Google Maps":
        return "Google 地图";
      case "Apple Maps":
        return "Apple 地图";
      case "Amap":
        return "高德地图";
      case "Baidu Maps":
        return "百度地图";
      case "Mapbox":
        return "Mapbox";
      case "Tencent Maps":
        return "腾讯地图";
      default:
        return mapName;
    }
  }
}

// 虚线 Painter (保持不变)
class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    var max = size.width;
    var dashWidth = 4.0;
    var dashSpace = 4.0;
    double startX = 0;
    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
