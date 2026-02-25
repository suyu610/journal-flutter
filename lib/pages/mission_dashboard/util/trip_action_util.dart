// 文件路径: lib/pages/mission_dashboard/util/trip_action_util.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/core/app_theme_colors.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class TripActionUtil {
  /// 统一跳转入口
  static void launchApp(BuildContext context, String type) async {
    if (type == 'map') {
      _openMapsSheet(context);
    } else if (type == '12306') {
      _launchDeepLink(
        context,
        schemeUrl: "mt12306://",
        fallbackUrl: "https://www.12306.cn",
      );
    } else if (type == 'ctrip') {
      _launchDeepLink(
        context,
        // 修复：使用标准的 ctrip 协议
        schemeUrl: "ctrip://wireless",
        fallbackUrl: "https://m.ctrip.com",
      );
    }
  }

  /// 内部方法：处理 DeepLink 跳转
  static void _launchDeepLink(BuildContext context,
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("无法打开链接: $fallbackUrl")),
          );
        }
      }
    }
  }

  /// 内部方法：打开地图选择 Sheet
  static void _openMapsSheet(BuildContext context) async {
    try {
      // TODO: 这里坐标暂时是写死的，后续可以根据 TripModel 里的地点名称去 Geocoding 获取真实坐标
      final coords = Coords(37.759392, -122.5107336);
      const title = "目的地";
      final availableMaps = await MapLauncher.installedMaps;

      if (context.mounted) {
        final appColors = Theme.of(context).extension<AppThemeColors>()!;

        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                color: appColors.cardBackground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
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
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close,
                                color: appColors.secondaryText, size: 22),
                          )
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    if (availableMaps.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text("未检测到已安装的地图应用",
                            style: TextStyle(color: appColors.secondaryText)),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                  Expanded(
                                    child: Text(
                                      _translateMapName(map.mapName),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: appColors.primaryText,
                                      ),
                                    ),
                                  ),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      print("Map launcher error: $e");
    }
  }

  static String _translateMapName(String mapName) {
    switch (mapName) {
      case "Google Maps":
        return "Google 地图";
      case "Apple Maps":
        return "Apple 地图";
      case "Amap":
        return "高德地图";
      case "Baidu Maps":
        return "百度地图";
      case "Tencent Maps":
        return "腾讯地图";
      default:
        return mapName;
    }
  }
}
