import 'package:journal/models/activity.dart';
import 'package:journal/models/expense.dart';
import 'package:journal/models/paging.dart';
import 'package:journal/request/request.dart';
import 'package:journal/services/journal_backup.dart';

abstract class BackupApi {
  Future<dynamic> get(String path);
  Future<dynamic> post(String path, Map<String, dynamic> body);
}

class HttpBackupApi implements BackupApi {
  @override
  Future<dynamic> get(String path) => _request(Method.get, path);

  @override
  Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _request(Method.post, path, body: body);

  Future<dynamic> _request(Method method, String path, {dynamic body}) async {
    final response = await HttpRequest.request<dynamic>(
      method,
      path,
      params: body,
    );
    if (response is! Map || response['code'] != 0) {
      throw StateError(response is Map
          ? response['errorMsg']?.toString() ?? '请求失败'
          : '网络请求失败');
    }
    return response['data'];
  }
}

class BackupImportException implements Exception {
  final int createdLedgers;
  final int createdEntries;
  final Object cause;

  const BackupImportException(
      this.createdLedgers, this.createdEntries, this.cause);
}

class JournalBackupService {
  final BackupApi api;

  JournalBackupService({BackupApi? api}) : api = api ?? HttpBackupApi();

  Future<JournalBackup> exportBackup() async {
    final rawActivities = await api.get('/activity/list');
    if (rawActivities is! List) {
      throw const FormatException('账本列表格式错误');
    }

    final activities = rawActivities
        .map((raw) => Activity.fromJson(raw as Map<String, dynamic>))
        .toList();
    final ledgers = <BackupLedger>[];
    for (final activity in activities) {
      final entries = await _loadAllEntries(activity.activityId);
      ledgers.add(BackupLedger.fromActivity(activity, entries));
    }
    return JournalBackup(exportedAt: DateTime.now().toUtc(), ledgers: ledgers);
  }

  Future<List<Expense>> _loadAllEntries(String activityId) async {
    final entries = <Expense>[];
    final seenIds = <String>{};
    var pageNumber = 1;
    var hasNextPage = true;
    while (hasNextPage) {
      final rawPage = await api.get(
        '/expense/list/$activityId?pageNum=$pageNumber',
      );
      if (rawPage is! Map<String, dynamic>) {
        throw const FormatException('账单列表格式错误');
      }
      final page = Paging.fromJson(rawPage);
      var added = 0;
      for (final raw in page.list) {
        final entry = Expense.fromJson(raw as Map<String, dynamic>);
        if (seenIds.add(entry.expenseId)) {
          entries.add(entry);
          added++;
        }
      }
      hasNextPage = page.hasNextPage;
      if (hasNextPage && added == 0) {
        throw const FormatException('账单分页未继续更新');
      }
      pageNumber++;
    }
    return entries;
  }

  Future<void> importBackup(
    JournalBackup backup, {
    void Function(int createdLedgers, int createdEntries)? onProgress,
  }) async {
    var createdLedgers = 0;
    var createdEntries = 0;

    try {
      for (final ledger in backup.ledgers) {
        final created = await api.post('/activity', {
          'activityName': ledger.name,
          'budget': ledger.budget,
          'budgetType': ledger.budgetType,
          'activated': false,
        });
        if (created is! Map || created['activityId'] is! String) {
          throw const FormatException('创建账本的响应无效');
        }
        final activityId = created['activityId'] as String;
        if (activityId.isEmpty) {
          throw const FormatException('新账本缺少 ID');
        }
        createdLedgers++;
        onProgress?.call(createdLedgers, createdEntries);

        for (final entry in ledger.entries) {
          await api.post('/expense', {
            ...entry.toJson(),
            'activityId': activityId,
          });
          createdEntries++;
          onProgress?.call(createdLedgers, createdEntries);
        }
      }
    } catch (cause) {
      throw BackupImportException(createdLedgers, createdEntries, cause);
    }
  }
}
