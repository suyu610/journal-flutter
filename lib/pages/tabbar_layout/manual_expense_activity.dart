import 'package:journal/models/activity.dart';

Future<String?> resolveManualExpenseActivity({
  required String? currentActivityId,
  required Future<String?> Function() refreshDefaultActivityId,
  required Future<List<Activity>> Function() loadActivities,
  required Future<bool> Function() createActivity,
  required Future<Activity?> Function(List<Activity>) selectActivity,
}) async {
  final currentId = currentActivityId?.trim() ?? '';
  if (currentId.isNotEmpty) return currentId;

  final refreshedId = (await refreshDefaultActivityId())?.trim() ?? '';
  if (refreshedId.isNotEmpty) return refreshedId;

  var activities = await loadActivities();
  if (activities.isEmpty) {
    if (!await createActivity()) return null;
    activities = await loadActivities();
    if (activities.isEmpty) {
      throw StateError('创建成功后未找到账本');
    }
    if (activities.length == 1) return activities.single.activityId;
  }

  return (await selectActivity(activities))?.activityId;
}
