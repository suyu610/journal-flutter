import 'package:flutter_test/flutter_test.dart';
import 'package:journal/models/activity.dart';
import 'package:journal/pages/tabbar_layout/manual_expense_activity.dart';

void main() {
  test('uses the default ledger without loading or prompting', () async {
    final calls = <String>[];
    final id = await resolveManualExpenseActivity(
      currentActivityId: 'default',
      refreshDefaultActivityId: () async {
        calls.add('profile');
        return null;
      },
      loadActivities: () async {
        calls.add('list');
        return [];
      },
      createActivity: () async {
        calls.add('create');
        return true;
      },
      selectActivity: (_) async {
        calls.add('select');
        return null;
      },
    );

    expect(id, 'default');
    expect(calls, isEmpty);
  });

  test('refreshes a default ledger before asking the user', () async {
    final id = await resolveManualExpenseActivity(
      currentActivityId: null,
      refreshDefaultActivityId: () async => 'new-default',
      loadActivities: () async => fail('should not load ledger list'),
      createActivity: () async => fail('should not create'),
      selectActivity: (_) async => fail('should not select'),
    );

    expect(id, 'new-default');
  });

  test('asks the user to choose when ledgers exist without a default',
      () async {
    final activities = [_activity('first'), _activity('second')];
    final id = await resolveManualExpenseActivity(
      currentActivityId: '',
      refreshDefaultActivityId: () async => null,
      loadActivities: () async => activities,
      createActivity: () async => fail('should not create'),
      selectActivity: (items) async {
        expect(items, activities);
        return items.last;
      },
    );

    expect(id, 'second');
  });

  test('opens the newly created ledger after an empty list', () async {
    var loads = 0;
    final id = await resolveManualExpenseActivity(
      currentActivityId: null,
      refreshDefaultActivityId: () async => null,
      loadActivities: () async {
        loads++;
        return loads == 1 ? [] : [_activity('new')];
      },
      createActivity: () async => true,
      selectActivity: (_) async => fail('should use the only new ledger'),
    );

    expect(id, 'new');
    expect(loads, 2);
  });

  test('stops when ledger creation is cancelled', () async {
    var loads = 0;
    final id = await resolveManualExpenseActivity(
      currentActivityId: null,
      refreshDefaultActivityId: () async => null,
      loadActivities: () async {
        loads++;
        return [];
      },
      createActivity: () async => false,
      selectActivity: (_) async => fail('should not select'),
    );

    expect(id, isNull);
    expect(loads, 1);
  });
}

Activity _activity(String id) {
  return Activity(
    userId: 'user',
    creatorName: 'user',
    activityName: id,
    activityId: id,
    activated: false,
    createTime: '2026-10-08',
    userList: [],
  );
}
