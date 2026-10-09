import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:journal/services/journal_backup.dart';
import 'package:journal/services/journal_backup_service.dart';

void main() {
  final sampleBackup = JournalBackup(
    exportedAt: DateTime.utc(2026, 10, 8),
    ledgers: const [
      BackupLedger(
        name: '日常',
        budget: 1200,
        budgetType: 'MONTH',
        entries: [
          BackupEntry(
            type: '餐饮',
            price: 12,
            originalPrice: 15,
            label: '早餐',
            positive: 0,
            expenseTime: '2026-10-08 08:00:00',
            fileList: ['https://example.com/photo.jpg'],
          ),
        ],
      ),
    ],
  );

  group('JournalBackup JSON', () {
    test('round trips with a format and schema version', () {
      final json =
          jsonDecode(sampleBackup.toJsonString()) as Map<String, dynamic>;
      expect(json['format'], JournalBackup.format);
      expect(json['version'], 1);

      final restored = JournalBackup.fromJsonString(jsonEncode(json));
      expect(restored.ledgers.single.name, '日常');
      expect(restored.ledgers.single.entries.single.originalPrice, 15);
      expect(restored.ledgers.single.entries.single.fileList, hasLength(1));
    });

    test('rejects unknown versions before import', () {
      final json =
          jsonDecode(sampleBackup.toJsonString()) as Map<String, dynamic>;
      json['version'] = 2;
      expect(
        () => JournalBackup.fromJsonString(jsonEncode(json)),
        throwsFormatException,
      );
    });

    test('validates all entries before any write', () {
      final json =
          jsonDecode(sampleBackup.toJsonString()) as Map<String, dynamic>;
      final ledger = (json['ledgers'] as List).single as Map<String, dynamic>;
      final entry = (ledger['entries'] as List).single as Map<String, dynamic>;
      entry['price'] = -1;
      expect(
        () => JournalBackup.fromJsonString(jsonEncode(json)),
        throwsFormatException,
      );
    });
  });

  group('JournalBackupService', () {
    test('exports all pages and keeps ledger fields', () async {
      final api = _FakeBackupApi({
        '/activity/list': [
          {
            'activityId': 'book-1',
            'activityName': '日常',
            'userId': 'user-1',
            'creatorName': '用户',
            'activated': true,
            'budget': 1200,
            'budgetType': 'MONTH',
            'createTime': '2026-10-01 00:00:00',
            'userList': <dynamic>[],
          },
        ],
        '/expense/list/book-1?pageNum=1': {
          'total': 2,
          'hasNextPage': true,
          'list': [_expense('first')],
        },
        '/expense/list/book-1?pageNum=2': {
          'total': 2,
          'hasNextPage': false,
          'list': [_expense('second')],
        },
      });

      final backup = await JournalBackupService(api: api).exportBackup();

      expect(backup.ledgers.single.budget, 1200);
      expect(backup.entryCount, 2);
      expect(
        backup.ledgers.single.entries.map((entry) => entry.label),
        ['first', 'second'],
      );
    });

    test('imports into a new ledger with its new ID', () async {
      final api = _FakeBackupApi({});
      final progress = <(int, int)>[];

      await JournalBackupService(api: api).importBackup(
        sampleBackup,
        onProgress: (ledgers, entries) => progress.add((ledgers, entries)),
      );

      expect(api.posts.map((request) => request.$1), ['/activity', '/expense']);
      expect(api.posts.last.$2['activityId'], 'new-book-1');
      expect(api.posts.last.$2['expenseTime'], '2026-10-08 08:00:00');
      expect(progress, [(1, 0), (1, 1)]);
    });

    test('reports partial write counts on failure', () async {
      final api = _FakeBackupApi({})..failOnPost = 2;

      await expectLater(
        JournalBackupService(api: api).importBackup(sampleBackup),
        throwsA(isA<BackupImportException>()
            .having((error) => error.createdLedgers, 'ledgers', 1)
            .having((error) => error.createdEntries, 'entries', 0)),
      );
    });
  });
}

Map<String, dynamic> _expense(String label) => {
      'expenseId': label,
      'type': '餐饮',
      'price': 12,
      'originalPrice': 15,
      'label': label,
      'userId': 'user-1',
      'expenseTime': '2026-10-08 08:00:00',
      'createTime': '2026-10-08 08:00:00',
      'activityId': 'book-1',
      'positive': 0,
      'fileList': <String>[],
    };

class _FakeBackupApi implements BackupApi {
  final Map<String, dynamic> responses;
  final List<(String, Map<String, dynamic>)> posts = [];
  int? failOnPost;

  _FakeBackupApi(this.responses);

  @override
  Future<dynamic> get(String path) async => responses[path];

  @override
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    posts.add((path, body));
    if (posts.length == failOnPost) throw StateError('simulated failure');
    if (path == '/activity') return {'activityId': 'new-book-1'};
    return null;
  }
}
