import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  debug, // 调试信息
  info, // 一般信息
  warning, // 警告信息
  error, // 错误信息
  success, // 成功信息
}

/// 模块标识
enum Module {
  app, // 应用主模块
  auth, // 认证模块
  todo, // 待办事项模块
  ui, // UI模块
  network, // 网络模块
  cache, // 缓存模块
  focus, // 焦点管理模块
  chat, // 聊天/智能助手模块
  recurrence, // 重复任务模块
  recommendation, // 任务推荐模块
  notification, // 通知模块
  analytics, // 埋点分析模块
  sync, // 同步模块
}

/// 应用日志管理器
/// 提供统一的日志输出格式和级别控制
class AppLogger {
  static const String _appName = 'TidyDay';

  /// 当前日志级别（只有大于等于此级别的日志才会输出）
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// 设置日志级别
  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// 获取模块标识字符串
  static String _getModuleTag(Module module) {
    switch (module) {
      case Module.app:
        return 'APP';
      case Module.auth:
        return 'AUTH';
      case Module.todo:
        return 'TODO';
      case Module.ui:
        return 'UI';
      case Module.network:
        return 'NET';
      case Module.cache:
        return 'CACHE';
      case Module.focus:
        return 'FOCUS';
      case Module.chat:
        return 'CHAT';
      case Module.recurrence:
        return 'RECUR';
      case Module.recommendation:
        return 'RECOMMEND';
      case Module.notification:
        return 'NOTIFY';
      case Module.analytics:
        return 'ANALYTICS';
      case Module.sync:
        return 'SYNC';
    }
  }

  /// 获取日志级别图标
  static String _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.success:
        return '✅';
    }
  }

  /// 检查是否应该输出日志
  static bool _shouldLog(LogLevel level) {
    return level.index >= _currentLevel.index;
  }

  /// 格式化日志消息
  static String _formatMessage(Module module, LogLevel level, String message,
      [Map<String, dynamic>? data]) {
    final timestamp =
        DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.SSS
    final icon = _getLevelIcon(level);
    final moduleTag = _getModuleTag(module);

    String formattedMessage =
        '$icon [$_appName][$moduleTag][$timestamp] $message';

    if (data != null && data.isNotEmpty) {
      final dataStr = data.entries.map((e) => '${e.key}=${e.value}').join(', ');
      formattedMessage += ' | $dataStr';
    }

    return formattedMessage;
  }

  /// 调试日志
  static void debug(Module module, String message,
      [Map<String, dynamic>? data]) {
    if (_shouldLog(LogLevel.debug)) {
      debugPrint(_formatMessage(module, LogLevel.debug, message, data));
    }
  }

  /// 信息日志
  static void info(Module module, String message,
      [Map<String, dynamic>? data]) {
    if (_shouldLog(LogLevel.info)) {
      debugPrint(_formatMessage(module, LogLevel.info, message, data));
    }
  }

  /// 警告日志
  static void warning(Module module, String message,
      [Map<String, dynamic>? data]) {
    if (_shouldLog(LogLevel.warning)) {
      debugPrint(_formatMessage(module, LogLevel.warning, message, data));
    }
  }

  /// 错误日志
  static void error(Module module, String message,
      [Map<String, dynamic>? data, Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.error)) {
      debugPrint(_formatMessage(module, LogLevel.error, message, data));
      if (error != null) {
        debugPrint('   └─ Error: $error');
      }
      if (stackTrace != null && kDebugMode) {
        debugPrint('   └─ StackTrace: $stackTrace');
      }
    }
  }

  /// 成功日志
  static void success(Module module, String message,
      [Map<String, dynamic>? data]) {
    if (_shouldLog(LogLevel.success)) {
      debugPrint(_formatMessage(module, LogLevel.success, message, data));
    }
  }

  /// 网络请求日志
  static void networkRequest(String method, String url,
      [Map<String, dynamic>? headers]) {
    debug(Module.network, 'Request: $method $url', headers);
  }

  /// 网络响应日志
  static void networkResponse(String url, int statusCode, [String? response]) {
    final level = statusCode >= 200 && statusCode < 300
        ? LogLevel.success
        : LogLevel.error;
    final message = 'Response: $statusCode $url';
    final data = response != null ? {'response': response} : null;

    if (level == LogLevel.success) {
      success(Module.network, message, data);
    } else {
      error(Module.network, message, data);
    }
  }

  /// 状态变化日志
  static void stateChange(
      Module module, String stateName, dynamic oldValue, dynamic newValue) {
    debug(module, 'State changed: $stateName', {
      'from': oldValue?.toString() ?? 'null',
      'to': newValue?.toString() ?? 'null'
    });
  }

  /// 用户操作日志
  static void userAction(String action, [Map<String, dynamic>? context]) {
    info(Module.ui, 'User action: $action', context);
  }

  /// 性能日志
  static void performance(Module module, String operation, Duration duration,
      [Map<String, dynamic>? context]) {
    final message = 'Performance: $operation took ${duration.inMilliseconds}ms';
    if (duration.inMilliseconds > 1000) {
      warning(module, message, context);
    } else {
      debug(module, message, context);
    }
  }

  /// 分隔线日志（用于重要的开始/结束标记）
  static void separator([String? title]) {
    if (_shouldLog(LogLevel.info)) {
      final line = '=' * 50;
      if (title != null) {
        final padding = (50 - title.length - 2) ~/ 2;
        final paddedTitle = '${' ' * padding} $title ${' ' * padding}';
        debugPrint('$line\n$paddedTitle\n$line');
      } else {
        debugPrint(line);
      }
    }
  }
}
