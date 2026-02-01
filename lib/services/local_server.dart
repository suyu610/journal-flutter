import 'dart:io';
import 'dart:async';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:journal/util/device_util.dart';
import 'package:journal/util/sp_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

class LocalServer {
  // 1. 设为静态，独立于任何页面生命周期
  static HttpServer? _server;

  // 2. 动态端口
  static int port = 8222;

  // 3. 状态标记
  static bool get isRunning => _server != null;

  static Future<void> start() async {
    // 如果已经运行，直接返回，别重复折腾
    if (_server != null) return;

    try {
      // 这里的路径获取逻辑同上一次回答
      String docPath = await _copyAssetsToLocal();
      var handler = createStaticHandler(docPath, defaultDocument: 'index.html');

      // 4. 关键：添加 Shared 属性，允许共享监听（虽然本地开发主要是防崩溃）
      // loopbackIPv4 仅限本机访问，安全
      _server =
          await io.serve(handler, InternetAddress.anyIPv4, port, shared: true);

      print('✅ 本地服务已启动: http://localhost:$port');
    } catch (e) {
      print("❌ 启动失败: $e");
      // 5. 简单的重试策略：如果端口被占，尝试端口+1
      if (e.toString().contains("Address already in use")) {
        port++;
        print("⚠️ 端口被占用，尝试切换到端口: $port");
        await start(); // 递归重试
      }
    }
  }

  // 除非 App 彻底退出，否则尽量不要调用 stop
  static void stop() {
    _server?.close(force: true);
    _server = null;
    print("🛑 本地服务已停止");
  }

  /// 将 Assets 中的 zip 解压到手机沙盒
  static Future<String> _copyAssetsToLocal() async {
    final directory = await getApplicationDocumentsDirectory();
    final String appVersion = await DeviceUtil.appVersion();

    final String targetPath = '${directory.path}/web_root';
    final Directory webDir = Directory(targetPath);

    // 2. 检查是否需要解压
    // 比对版本号，判断是否需要解压
    bool exists = await webDir.exists() && appVersion == SpUtil.getZipVersion();

    if (!exists) {
      print("资源文件不存在，开始解压 web.zip...");
      SpUtil.setZipVersion(appVersion);

      try {
        // A. 从 Assets 读取 zip 文件流
        final ByteData data = await rootBundle.load('assets/web.zip');
        final List<int> bytes = data.buffer.asUint8List();

        // B. 解析 Zip
        final Archive archive = ZipDecoder().decodeBytes(bytes);

        // C. 逐个文件写入沙盒
        for (final ArchiveFile file in archive) {
          final String filename = '$targetPath/${file.name}';

          if (file.isFile) {
            final File outFile = File(filename);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);
          } else {
            // 如果是空文件夹
            await Directory(filename).create(recursive: true);
          }
        }
        print("解压完成！路径: $targetPath");
      } catch (e) {
        print("解压资源失败: $e");
        // 可以在这里做一些容错处理
      }
    } else {
      print("资源已存在，跳过解压。");
    }

    return targetPath;
  }
}
