import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ 请输入参数: -local 或 -prod');
    return;
  }

  final mode = args[0];
  final File file = File('lib/config/api_config.dart');

  if (!await file.exists()) {
    print('❌ 找不到配置文件: ${file.path}');
    return;
  }

  print('📝 正在读取配置文件...');
  String content = await file.readAsString();

  if (mode == '-local') {
    await _switchToLocal(content, file);
  } else if (mode == '-prod') {
    await _switchToProd(content, file);
  } else {
    print('❌ 未知参数: $mode');
  }
}

/// 切换到本地环境
Future<void> _switchToLocal(String content, File file) async {
  print('🔍 正在获取本机 IP...');

  // 执行 ipconfig getifaddr en0
  final result = await Process.run('ipconfig', ['getifaddr', 'en0']);

  if (result.exitCode != 0) {
    print('❌ 获取 IP 失败，请检查是否连接网络或 en0 网卡是否存在。');
    print('错误信息: ${result.stderr}');
    return;
  }

  final ip = result.stdout.toString().trim();

  if (ip.isEmpty) {
    print('❌ 获取到的 IP 为空，请检查网络连接。');
    return;
  }

  print('✅ 获取到本机 IP: $ip');

  // --- 🔥 新增功能: 检查后端端口是否通畅 ---
  await _checkServerStatus(ip, 5666);
  // -------------------------------------

  // 1. 修改 localBaseUrl 的值
  final localUrlPattern = RegExp(r'static String localBaseUrl = ".*?";');
  final newLocalUrlLine = 'static String localBaseUrl = "http://$ip:5666/api";';

  if (!content.contains(localUrlPattern)) {
    print('⚠️ 警告: 未在文件中找到 localBaseUrl 定义');
  }
  content = content.replaceAll(localUrlPattern, newLocalUrlLine);

  // 2. 修改 baseUrl 指向 localBaseUrl
  final baseUrlPattern = RegExp(r'static String baseUrl = .*?;');
  const newBaseUrlLine = 'static String baseUrl = localBaseUrl;';

  content = content.replaceAll(baseUrlPattern, newBaseUrlLine);

  await file.writeAsString(content);
  print('🎉 已切换到 Local 环境:');
  print('   👉 $newLocalUrlLine');
  print('   👉 $newBaseUrlLine');
}

/// 切换到生产环境
Future<void> _switchToProd(String content, File file) async {
  // 修改 baseUrl 指向 prodBaseUrl
  final baseUrlPattern = RegExp(r'static String baseUrl = .*?;');
  const newBaseUrlLine = 'static String baseUrl = prodBaseUrl;';

  content = content.replaceAll(baseUrlPattern, newBaseUrlLine);

  await file.writeAsString(content);
  print('🎉 已切换到 Prod 环境:');
  print('   👉 $newBaseUrlLine');
}

/// 🔥 新增辅助方法: 检测端口连通性
Future<void> _checkServerStatus(String ip, int port) async {
  print('📡 正在检测后端服务 ($ip:$port)...');
  try {
    // 尝试建立 TCP 连接，设置 2 秒超时
    Socket socket =
        await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
    socket.destroy(); // 连接成功后立即断开
    print('✅ 后端服务已启动，连接正常！');
  } catch (e) {
    print('\n${'=' * 40}');
    print('⚠️  警告: 无法连接到后端服务器 ($ip:$port)');
    print('👉 请确保你的后端服务已启动！');
    print('👉 错误详情: 连接被拒绝或超时');
    print('${'=' * 40}\n');
    // 注意：这里我们只提示，不中断脚本，因为可能用户正准备启动后端
  }
}
