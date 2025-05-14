// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:journal/util/date_util.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import 'app.dart';

class Log {
  static final Log _instance = Log._internal();

  factory Log() {
    return _instance;
  }

  late Logger logger;
  String className = "";
  String fileName = "";
  int lineNumber = 0;
  int maxLogLength = 1000;

  Log._internal() {
    ConsoleOutput output = ConsoleOutput();
    ConsoleFilter filter = ConsoleFilter();
    logger = Logger(
      filter: filter,
      output: output,
      printer: PrettyPrinter(
        noBoxingByDefault: true,
        methodCount: 0,
        printEmojis: false,
      ),
    );
  }

  void parseTrace(StackTrace trace) {
    var traceString = trace.toString().split("\n")[0];
    className = traceString.split(".")[0].replaceAll("#0", "").trim();
    var indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z_]+.dart'));
    var fileInfo = traceString.substring(indexOfFileName);
    var listOfInfo = fileInfo.split(":");
    fileName = listOfInfo[0];
    lineNumber = int.parse(listOfInfo[1]);
  }

  void d(String? string, {StackTrace? trace}) {
    // 将 StackTrace 对象转换成 Chain 对象
    // 当然，这里也可以直接用 Chain.current();
    final chain = Chain.forTrace(StackTrace.current);
    // 拿出其中一条信息
    final frames = chain.toTrace().frames;
    final frame = frames[1];

    var debugInfoStr = DateUtil.getCurrentTime();
    if (trace != null) {
      parseTrace(trace);
      debugInfoStr = '[$className:$lineNumber] $debugInfoStr';
    }

    // 打印
    debugInfoStr = "所在文件：${frame.uri} 所在行 ${frame.line} 所在列 ${frame.column}";

    if (string != null) {
      string =
          "======================\n$debugInfoStr\n$string\n======================\n";

      if (appEnv == Env.qa || appEnv == Env.beta) {
        for (int i = 0; i < string.length; i += maxLogLength) {
          if (i + maxLogLength < string.length) {
            debugPrint(string.substring(i, i + maxLogLength));
          } else {
            debugPrint(string.substring(i, string.length));
          }
        }
      }
      logger.d(string);
    }
  }

  void i(String string) {
    logger.i(string);
  }

  void w(String string) {
    logger.w(string);
  }
}

class ConsoleOutput extends LogOutput {
  final _lock = Lock();

  @override
  void output(OutputEvent event) {
    String time = DateUtil.getTimeEpoch(DateTime.now().millisecondsSinceEpoch);
    _lock.synchronized(() async {
      await _write("$time ===> ");
    });

    for (String line in event.lines) {
      _lock.synchronized(() async {
        await _write('$line\n');
      });
    }
  }

  // 获取日志文件夹
  Future<Directory?> getLogDirectory() async {
    Directory? directory;
    // beta QA环境下让测试同学可以抓取log日志使用StorageDirectory
    if (Platform.isAndroid && (appEnv == Env.qa || appEnv == Env.beta)) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return directory;
  }

  // 获取日志文件
  Future<File?> getLogFile() async {
    Directory? directory = await getLogDirectory();
    File? file;
    if (directory != null) {
      file = File('${directory.path}/app_log.log');
    }
    return file;
  }

  // 整理日志文件内容
  Future<void> clearUpLogFile({int size = 100}) async {
    Log().d('Clear UpLog File');
    File? file = await getLogFile();
    bool fileExists = await file?.exists() ?? false;
    if (file != null && fileExists) {
      String str = '';
      try {
        List<int> resultStr = await file.readAsBytes();
        str = const Utf8Codec().decode(resultStr);
      } on Exception catch (e) {
        Log().d('readAsString error $e');
      }
      int length = str.length;
      // 设置日志文件最大容量
      int maxLength = 1024 * 1024 * size;
      Log().d('当前日志文件大小：${(length / 1024 / 1024).toStringAsFixed(2)}MB');
      if (length >= maxLength) {
        var content = str.substring(length - maxLength, length);
        try {
          Log().d(
              '整理后的日志大小：${(content.length / 1024 / 1024).toStringAsFixed(2)}MB');
          await file.writeAsString(content, mode: FileMode.write, flush: true);
        } on Exception catch (e) {
          Log().d('writeAsString error $e');
        }
      }
    }
  }

  // 删除日志文件
  void removeLogFile() async {
    File? file = await getLogFile();
    if (file != null) {
      await file.delete();
      await file.writeAsString('log upload success \n',
          mode: FileMode.write, flush: true);
      Log().d('日志文件清理成功');
    }
  }

  ///写日志到文件
  _write(String text) async {
    File? file = await getLogFile();
    if (file != null) {
      await file.writeAsString(text,
          mode: FileMode.writeOnlyAppend, flush: true);
    }
  }
}

class ConsoleFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}
