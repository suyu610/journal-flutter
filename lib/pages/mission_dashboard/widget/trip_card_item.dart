import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:journal/models/trip_card_model.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart'; // 实际项目请解开此注释

class ExquisiteTripCard extends StatefulWidget {
  final TripModel? tripModel;
  // 回调函数
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
    // 简单处理：如果没有传模型，这里应该报错或显示空状态，暂且认为一定有值
    trip = widget.tripModel!;
    _startTimer();
  }

  // 监听父组件数据变化，更新内部状态
  @override
  void didUpdateWidget(covariant ExquisiteTripCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tripModel != oldWidget.tripModel) {
      setState(() {
        trip = widget.tripModel!;
      });
      _startTimer(); // 重置倒计时
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
        // 容错处理：确保日期格式正确
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
              // 修正：小时数显示逻辑
              _countdownText = "${diff.inHours}小时${diff.inMinutes % 60}分后出发";
              _countdownColor = Colors.blueAccent.shade700;
            } else {
              _countdownText = "仅剩 ${diff.inMinutes} 分钟";
              _countdownColor = const Color(0xFFD32F2F);
            }
          }
        });
      } catch (e) {
        print("时间解析错误: $e");
      }
    }

    tick();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => tick());
  }

  void _launchApp(String type) async {
    if (type == 'map') {
      openMapsSheet(context);
    } else if (type == '12306') {
      _launchDeepLink(
        // 12306 很难直接唤起并跳到订单页（那是私有协议），通常做法是尝试打开 App，打不开跳官网
        schemeUrl: "mt12306://", // 尝试唤起
        fallbackUrl: "https://www.12306.cn",
      );
    } else if (type == 'ctrip') {
      _launchDeepLink(
        schemeUrl: "CtripWireless://", // 唤起携程
        fallbackUrl: "https://m.ctrip.com",
      );
    }
  }

  openMapsSheet(BuildContext context) async {
    try {
      final coords = Coords(37.759392, -122.5107336);
      const title = "Ocean Beach";
      final availableMaps = await MapLauncher.installedMaps;

      // 获取主题色
      if (context.mounted) {
        final appColors = Theme.of(context).extension<AppThemeColors>()!;

        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent, // 关键：背景透明，以便自定义圆角
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                color: appColors.cardBackground, // 使用你的卡片背景色
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 高度自适应
                  children: [
                    // 1. 顶部拖动条 (Handle)
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // 2. 标题栏
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("选择地图导航",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: appColors.primaryText)),
                          // 关闭按钮 (可选)
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close,
                                color: appColors.secondaryText, size: 22),
                          )
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

                    // 3. 地图列表
                    ListView.builder(
                      shrinkWrap: true, // 关键：列表自适应高度
                      physics:
                          const NeverScrollableScrollPhysics(), // 禁用列表滚动，使用外层滚动
                      itemCount: availableMaps.length,
                      itemBuilder: (context, index) {
                        final map = availableMaps[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            map.showMarker(coords: coords, title: title);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                // 地图名称
                                Expanded(
                                  child: Text(
                                    // 中文
                                    translateMapName(map.mapName),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: appColors.primaryText,
                                    ),
                                  ),
                                ),

                                // 右侧箭头
                                Icon(Icons.arrow_forward_ios,
                                    size: 14,
                                    color: appColors.secondaryText
                                        .withOpacity(0.5)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20), // 底部留白
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _launchDeepLink(
      {required String schemeUrl, required String fallbackUrl}) async {
    final Uri uri = Uri.parse(schemeUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // 失败则跳转网页
      final Uri webUri = Uri.parse(fallbackUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("无法打开链接: $fallbackUrl")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTrain = trip.type == 'Train';
    final appColors = Theme.of(context).extension<AppThemeColors>()!;

    // 💡 核心修改 1：如果是“已出发”的行程，将高亮的“主题色”（车次号、检票口）强行变成低调的灰色
    final primaryColor = _isDeparted
        ? appColors.secondaryText.withOpacity(0.8)
        : appColors.chartPalette[0];

    // 💡 核心修改 2：使用 AnimatedOpacity 包裹整个卡片，不仅能变透明，倒计时结束瞬间还会有淡出动画
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      // 过去状态透明度降低到 55%，视觉上彻底“退居二线”
      opacity: _isDeparted ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: _isDeparted
              ? Border.all(color: appColors.primaryText.withOpacity(0.08))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 紧凑布局
          children: [
            // 上半部分：头部 + 路线
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Column(
                children: [
                  _buildHeader(isTrain, appColors),
                  const SizedBox(height: 16),
                  // 这里的 primaryColor 现在是动态的了！如果是过去的行程，车次号会自动变灰
                  _buildRouteMain(primaryColor, isTrain, appColors),
                ],
              ),
            ),

            // 分割线
            _buildTicketDivider(appColors),

            // 下半部分：详情 + 底部栏
            Expanded(
              // 填充剩余空间
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 上下分布
                  children: [
                    // 详情里的高亮色（检票口等）也跟随 primaryColor 变灰
                    _buildDetailsGrid(primaryColor, appColors),
                    Column(
                      children: [
                        Divider(
                            height: 1,
                            color: appColors.secondaryText.withOpacity(0.1)),
                        const SizedBox(height: 12),
                        // 底部操作栏（导航、12306等），因为外层有 Opacity，也会跟着变淡，不再抢夺注意力
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

// --- 头部 ---
  Widget _buildHeader(bool isTrain, AppThemeColors appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 左侧：图标 + 日期
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

        // 右侧：倒计时 / 状态标签 (核心修改)
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                // 💡 如果已过期，用极淡的冷灰色；未过期用原本的彩色
                color: _isDeparted
                    ? appColors.secondaryText.withOpacity(0.08)
                    : _countdownColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                // 💡 过期的标签还可以加个细边框，更像一个“印章”
                border: _isDeparted
                    ? Border.all(
                        color: appColors.secondaryText.withOpacity(0.15))
                    : null,
              ),
              child: Text(
                // 💡 这里的 _countdownText 就是我们在计时器里算出来的“昨日已出发” / “已出发 2 天”
                // 如果你更喜欢直接显示固定文字，可以直接改成： _isDeparted ? "已过期" : _countdownText
                _countdownText,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    // 💡 文字颜色也相应变灰
                    color: _isDeparted
                        ? appColors.secondaryText
                        : _countdownColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 中部行程 (复用原有逻辑，微调样式) ---
  Widget _buildRouteMain(
      Color primaryColor, bool isTrain, AppThemeColors appColors) {
    return Row(
      children: [
        // 出发
        Expanded(
            flex: 3,
            child: _buildCityColumn(
                trip.depTime,
                trip.depStation ?? trip.depCity,
                CrossAxisAlignment.start,
                appColors)),

        // 中间箭头
        Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(trip.number,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: appColors.secondaryText.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                          isTrain
                              ? Icons.directions_railway
                              : Icons.airplanemode_active,
                          size: 14,
                          color: appColors.secondaryText.withOpacity(0.5)),
                    ),
                    Expanded(
                        child: Divider(
                            color: appColors.secondaryText.withOpacity(0.3))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(trip.duration,
                    style: TextStyle(
                        fontSize: 11, color: appColors.secondaryText)),
              ],
            )),

        // 到达
        Expanded(
            flex: 3,
            child: _buildCityColumn(
                trip.arrTime,
                trip.arrStation ?? trip.arrCity,
                CrossAxisAlignment.end,
                appColors,
                dayDiff: trip.dayDiff)),
      ],
    );
  }

  Widget _buildCityColumn(String time, String station, CrossAxisAlignment align,
      AppThemeColors appColors,
      {int dayDiff = 0}) {
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
        Text(station,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: appColors.secondaryText)),
      ],
    );
  }

  // --- 详情栅格 ---
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

  // --- 底部栏 ---
  Widget _buildActionBar(bool isTrain, AppThemeColors appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
            icon: RemixIcons.map_2_line,
            label: "导航",
            onTap: () => _launchApp('map'),
            appColors: appColors),

        if (isTrain) ...[
          Container(
              width: 1,
              height: 14,
              color: appColors.secondaryText.withOpacity(0.2)),
          _buildActionButton(
              icon: Icons.train_outlined,
              label: "12306",
              onTap: () => _launchApp('12306'),
              appColors: appColors),
        ],
        Container(
            width: 1,
            height: 14,
            color: appColors.secondaryText.withOpacity(0.2)),
        _buildActionButton(
            icon: RemixIcons.app_store_line,
            label: "携程",
            onTap: () => _launchApp('ctrip'),
            appColors: appColors),

        // 更多
        Container(
            width: 1,
            height: 14,
            color: appColors.secondaryText.withOpacity(0.2)),
        _buildActionButton(
            icon: Icons.settings_outlined,
            label: "更多",
            onTap: () => _showActionSheet(context),
            appColors: appColors),
      ],
    );
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
