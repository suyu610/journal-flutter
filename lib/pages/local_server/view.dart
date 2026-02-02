import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:journal/services/local_server.dart'; // 确保路径正确

// 定义服务状态枚举，方便管理 UI 显示
enum ServerStatus { loading, running, stopped, error }

class LocalServicePage extends StatefulWidget {
  const LocalServicePage({super.key});

  @override
  State<LocalServicePage> createState() => _LocalServicePageState();
}

class _LocalServicePageState extends State<LocalServicePage> {
  WebViewController? _controller;

  // 核心状态管理
  ServerStatus _status = ServerStatus.loading;
  String? _errorMessage;

  // 服务信息
  String? _serverUrl;
  int? _serverPort;

  @override
  void initState() {
    super.initState();
    // 页面初始化时自动启动
    _startServerAndLoad();
  }

  /// 核心方法：启动服务并加载页面
  Future<void> _startServerAndLoad() async {
    try {
      setState(() {
        _status = ServerStatus.loading;
        _errorMessage = null;
      });

      // 1. 确保先停止之前的服务（防止端口占用或状态混乱）
      LocalServer.stop();

      // 2. 启动新服务
      final url = await LocalServer.start();
      final uri = Uri.parse(url);

      if (uri.host.isEmpty || uri.port <= 0) {
        throw Exception("服务启动返回无效 URL: $url");
      }

      // 3. 服务启动成功，更新状态
      if (mounted) {
        setState(() {
          _serverUrl = url;
          _serverPort = uri.port;
          _status = ServerStatus.running;
        });
      }

      // 4. 初始化或刷新 WebView
      if (_controller == null) {
        _initWebViewController(uri);
      } else {
        _controller!.loadRequest(uri);
      }
    } catch (e) {
      debugPrint("❌ 服务启动失败: $e");
      if (mounted) {
        setState(() {
          _status = ServerStatus.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// 专门用于“重启按钮”的动作
  Future<void> _handleRestart() async {
    // 加上震动反馈或 loading 延时，让用户感觉到重启发生了
    await HapticFeedback.mediumImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("正在重启本地服务..."),
            duration: Duration(milliseconds: 800)),
      );
    }
    await _startServerAndLoad();
  }

  void _initWebViewController(Uri uri) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => debugPrint('WebView Start: $url'),
          onWebResourceError: (error) =>
              debugPrint('WebView Error: ${error.description}'),
        ),
      )
      ..loadRequest(uri);

    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("本地服务控制台", style: TextStyle(fontSize: 16)),
        actions: [
          // 仅刷新 WebView 内容（不重启服务）
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "刷新页面",
            onPressed: () => _controller?.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 调试面板始终显示（除非服务从未启动过且不在loading）
          _buildDebugPanel(),

          // 内容区域
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_status == ServerStatus.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("正在启动本地服务..."),
          ],
        ),
      );
    }

    if (_status == ServerStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 10),
              Text(
                "服务启动失败",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage ?? "未知错误", textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _handleRestart,
                icon: const Icon(Icons.replay),
                label: const Text("重试启动"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      );
    }

    if (_controller == null) return const SizedBox();

    return WebViewWidget(controller: _controller!);
  }

  Widget _buildDebugPanel() {
    // 根据状态决定颜色
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_status) {
      case ServerStatus.running:
        statusColor = Colors.green;
        statusText = "运行中";
        statusIcon = Icons.check_circle;
        break;
      case ServerStatus.loading:
        statusColor = Colors.orange;
        statusText = "启动中...";
        statusIcon = Icons.hourglass_bottom;
        break;
      case ServerStatus.stopped:
        statusColor = Colors.grey;
        statusText = "已停止";
        statusIcon = Icons.stop_circle;
        break;
      case ServerStatus.error:
        statusColor = Colors.red;
        statusText = "异常";
        statusIcon = Icons.error;
        break;
    }

    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：状态指示器 + 重启按钮
          Row(
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: 8),
              Text(
                "状态: $statusText",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const Spacer(),

              // 端口号显示
              if (_serverPort != null)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "PORT: $_serverPort",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),

              // --- 核心功能：强制重启按钮 ---
              SizedBox(
                height: 30,
                child: ElevatedButton.icon(
                  onPressed:
                      (_status == ServerStatus.loading) ? null : _handleRestart,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50], // 浅红背景警示
                      foregroundColor: Colors.red, // 红色文字
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  icon: const Icon(Icons.power_settings_new, size: 16),
                  label: const Text("重启服务", style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),

          // 第二行：URL 展示 (只有运行中才显示)
          if (_serverUrl != null && _status == ServerStatus.running) ...[
            const Divider(height: 16),
            _buildInfoRow("URL", _serverUrl!),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
            maxLines: 1,
          ),
        ),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('URL 已复制'),
                  duration: Duration(milliseconds: 500)),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.copy, size: 16, color: Colors.grey),
          ),
        )
      ],
    );
  }
}
