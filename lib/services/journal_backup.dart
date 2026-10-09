import 'dart:convert';

import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';

class JournalBackup {
  static const format = 'journal-backup';
  static const version = 1;

  final DateTime exportedAt;
  final List<BackupLedger> ledgers;

  const JournalBackup({required this.exportedAt, required this.ledgers});

  int get entryCount =>
      ledgers.fold(0, (count, ledger) => count + ledger.entries.length);

  String toJsonString() => const JsonEncoder.withIndent('  ').convert({
        'format': format,
        'version': version,
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'ledgers': ledgers.map((ledger) => ledger.toJson()).toList(),
      });

  factory JournalBackup.fromJsonString(String source) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('文件不是有效的 JSON');
    }
    if (decoded is! Map<String, dynamic> || decoded['format'] != format) {
      throw const FormatException('这不是好享记账备份文件');
    }
    if (decoded['version'] != version) {
      throw FormatException('不支持的备份版本：${decoded['version']}');
    }
    final exportedAt =
        DateTime.tryParse(decoded['exportedAt']?.toString() ?? '');
    final rawLedgers = decoded['ledgers'];
    if (exportedAt == null || rawLedgers is! List) {
      throw const FormatException('备份文件缺少日期或账本列表');
    }
    return JournalBackup(
      exportedAt: exportedAt,
      ledgers: [
        for (final raw in rawLedgers) BackupLedger.fromJson(raw),
      ],
    );
  }
}

class BackupLedger {
  final String name;
  final num budget;
  final String budgetType;
  final List<BackupEntry> entries;

  const BackupLedger({
    required this.name,
    required this.budget,
    required this.budgetType,
    required this.entries,
  });

  factory BackupLedger.fromActivity(Activity activity, List<Expense> expenses) {
    return BackupLedger(
      name: activity.activityName,
      budget: activity.budget ?? 0,
      budgetType: activity.budgetType ?? 'TOTAL',
      entries: expenses.map(BackupEntry.fromExpense).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'budget': budget,
        'budgetType': budgetType,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };

  factory BackupLedger.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic> ||
        raw['name'] is! String ||
        (raw['name'] as String).trim().isEmpty ||
        raw['budget'] is! num ||
        raw['budgetType'] is! String ||
        raw['entries'] is! List) {
      throw const FormatException('备份中的账本数据无效');
    }
    final budget = raw['budget'] as num;
    if (!budget.toDouble().isFinite || budget < 0) {
      throw const FormatException('备份中的账本预算无效');
    }
    if (!const {'MONTH', 'WEEK', 'DAY', 'TOTAL'}.contains(raw['budgetType'])) {
      throw const FormatException('备份中的预算类型无效');
    }
    return BackupLedger(
      name: (raw['name'] as String).trim(),
      budget: budget,
      budgetType: raw['budgetType'] as String,
      entries: [
        for (final entry in raw['entries'] as List) BackupEntry.fromJson(entry)
      ],
    );
  }
}

class BackupEntry {
  final String type;
  final num price;
  final num? originalPrice;
  final String label;
  final int positive;
  final String expenseTime;
  final List<String> fileList;

  const BackupEntry({
    required this.type,
    required this.price,
    required this.originalPrice,
    required this.label,
    required this.positive,
    required this.expenseTime,
    required this.fileList,
  });

  factory BackupEntry.fromExpense(Expense expense) => BackupEntry(
        type: expense.type,
        price: expense.price,
        originalPrice: expense.originalPrice,
        label: expense.label,
        positive: expense.positive,
        expenseTime: expense.expenseTime,
        fileList: expense.fileList ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'price': price,
        'originalPrice': originalPrice,
        'label': label,
        'positive': positive,
        'expenseTime': expenseTime,
        'fileList': fileList,
      };

  factory BackupEntry.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic> ||
        raw['type'] is! String ||
        raw['price'] is! num ||
        raw['label'] is! String ||
        raw['positive'] is! int ||
        raw['expenseTime'] is! String ||
        raw['fileList'] is! List ||
        (raw['originalPrice'] != null && raw['originalPrice'] is! num)) {
      throw const FormatException('备份中的账单数据无效');
    }
    final price = raw['price'] as num;
    final originalPrice = raw['originalPrice'] as num?;
    final positive = raw['positive'] as int;
    final expenseTime = raw['expenseTime'] as String;
    final fileList = raw['fileList'] as List;
    if (!price.toDouble().isFinite ||
        price < 0 ||
        (originalPrice != null &&
            (!originalPrice.toDouble().isFinite || originalPrice < 0)) ||
        (raw['type'] as String).trim().isEmpty ||
        (positive != 0 && positive != 1) ||
        DateTime.tryParse(expenseTime.replaceFirst(' ', 'T')) == null ||
        fileList.any((file) => file is! String)) {
      throw const FormatException('备份中的账单数据无效');
    }
    return BackupEntry(
      type: raw['type'] as String,
      price: price,
      originalPrice: originalPrice,
      label: raw['label'] as String,
      positive: positive,
      expenseTime: expenseTime,
      fileList: fileList.cast<String>(),
    );
  }
}
