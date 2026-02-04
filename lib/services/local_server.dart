import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart'; // 必须引入，用于 compute
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
// 假设这是你的工具类路径
import 'package:journal/util/device_util.dart';
import 'package:journal/util/sp_util.dart';

class LocalServer {
  static HttpServer? _server;

  // 用于防止重复初始化的锁
  static Completer<String>? _initCompleter;

  /// 获取当前服务的基础 URL
  static String get baseUrl =>
      _server != null ? 'http://localhost:${_server!.port}' : '';

  static bool get isRunning => _server != null;

  /// 启动服务
  /// 返回: 服务的基础 URL (例如 http://localhost:12345)
  static Future<String> start() async {
    // 1. 如果正在初始化中，等待之前的初始化完成
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }
    _server?.idleTimeout = null;

    // 2. 如果服务已经运行，直接返回 URL
    if (_server != null) {
      return baseUrl;
    }

    _initCompleter = Completer<String>();

    try {
      final rawPath = await _prepareAssets();
      final docPath = await _findRealWebRoot(rawPath);
      final indexFile = File('$docPath/index.html');
      if (!await indexFile.exists()) {
        print("❌ 致命错误：修正路径后仍未找到 index.html。正在打印目录结构...");
        await _debugPrintDir(rawPath); // 打印出来看看究竟有什么
        throw Exception("index.html 文件缺失，请查看上方日志中的目录结构");
      }
      var handler = createStaticHandler(
        docPath,
        defaultDocument: 'index.html',
        listDirectories: false,
      );

      // 3. 核心修改：使用 port: 0，让系统自动分配一个未被占用的端口
      // shared: true 允许在不同 isolate 共享（通常本地服务不需要，视情况而定，false更安全）
      _server = await io.serve(handler, InternetAddress.loopbackIPv4, 0,
          shared: false);

      final url = 'http://localhost:${_server!.port}';
      print('✅ 本地服务已启动: $url (目录: $docPath)');

      _initCompleter!.complete(url);
      return url;
    } catch (e, stack) {
      print("❌ 本地服务启动失败: $e\n$stack");
      _server = null;
      _initCompleter!.completeError(e);
      rethrow;
    }
  }

  static void stop() {
    if (_server != null) {
      _server!.close(force: true);
      _server = null;
      _initCompleter = null; // 重置初始化状态
      print("🛑 本地服务已停止");
    }
  }

// --- 路径修正逻辑 ---
  static Future<String> _findRealWebRoot(String basePath) async {
    final rootIndex = File('$basePath/index.html');
    if (await rootIndex.exists()) {
      return basePath;
    }

    print("⚠️ 根目录下未找到 index.html，尝试搜索子目录...");
    final dir = Directory(basePath);
    // 遍历第一层子目录
    try {
      final List<FileSystemEntity> entities = await dir.list().toList();
      for (var entity in entities) {
        if (entity is Directory) {
          // 检查子目录里有没有 index.html (例如 web_root/dist/index.html)
          final subIndex = File('${entity.path}/index.html');
          if (await subIndex.exists()) {
            print("✅ 在子目录找到资源，自动修正路径为: ${entity.path}");
            return entity.path;
          }
        }
      }
    } catch (e) {
      print("路径搜索失败: $e");
    }

    return basePath; // 没找到就返回原路径，让后面抛出具体错误
  }

  /// 准备资源文件（包含版本检查和后台解压）
  static Future<String> _prepareAssets() async {
    final directory = await getApplicationSupportDirectory();
    final String targetPath = '${directory.path}/web_root';
    final Directory webDir = Directory(targetPath);

    final String currentAppVersion = await DeviceUtil.appVersion();
    final String savedZipVersion = SpUtil.getZipVersion();

    // 检查是否需要解压：
    bool needUnzip =
        !webDir.existsSync() || currentAppVersion != savedZipVersion;

    if (!needUnzip) {
      print("资源已存在且版本一致，跳过解压。");
      return targetPath;
    }

    print("开始更新资源文件 (App版本: $currentAppVersion)...");

    try {
      // 读取 Assets 二进制数据 (这一步必须在主线程做，因为 rootBundle 依赖主线程上下文)
      final ByteData data = await rootBundle.load('assets/web.zip');
      final List<int> bytes = data.buffer.asUint8List();

      // --- 关键优化：使用 compute 在后台 Isolate 进行解压和IO写入 ---
      await compute(
          _unzipWorker, _UnzipMessage(zipBytes: bytes, targetPath: targetPath));

      // 更新版本号标记
      await SpUtil.setZipVersion(currentAppVersion);
      print("解压完成！");
    } catch (e) {
      // 如果解压失败，删除可能损坏的目录，确保下次重试
      if (webDir.existsSync()) {
        await webDir.delete(recursive: true);
      }
      throw Exception("解压资源失败: $e");
    }

    return targetPath;
  }
}

// --- 以下代码独立于类之外，或者是静态方法，以便 compute 调用 ---

/// 传递给后台 Isolate 的数据对象
class _UnzipMessage {
  final List<int> zipBytes;
  final String targetPath;

  _UnzipMessage({required this.zipBytes, required this.targetPath});
}

/// 后台解压逻辑 (必须是 top-level 函数或 static 方法)
Future<void> _unzipWorker(_UnzipMessage message) async {
  final targetDir = Directory(message.targetPath);

  // 1. 为了数据纯净，解压前先清空旧目录
  if (targetDir.existsSync()) {
    targetDir.deleteSync(recursive: true);
  }
  targetDir.createSync(recursive: true);

  // 2. 解析 Zip
  final archive = ZipDecoder().decodeBytes(message.zipBytes);

  // 3. 写入文件
  for (final file in archive) {
    final filename = '${message.targetPath}/${file.name}';
    if (file.isFile) {
      final outFile = File(filename);
      // 确保父目录存在
      outFile.parent.createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(filename).createSync(recursive: true);
    }
  }
}

// 3. 添加：调试打印目录结构 (报错时会自动调用)
Future<void> _debugPrintDir(String path) async {
  print("--- 目录 $path 内容开始 ---");
  try {
    final dir = Directory(path);
    if (!await dir.exists()) {
      print("目录不存在");
      return;
    }
    await for (var entity in dir.list(recursive: true)) {
      // 打印相对路径
      print("📄 ${entity.path.replaceFirst(path, '')}");
    }
  } catch (e) {
    print("无法列出目录: $e");
  }
  print("--- 目录内容结束 ---");
}
