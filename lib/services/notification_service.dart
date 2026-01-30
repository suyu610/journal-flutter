import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journal/constants/spkey.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final RxBool isEnabled = false.obs;
  final RxList<String> reminderTimes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 2. 修复：处理冷启动跳转
    final NotificationAppLaunchDetails? launchDetails =
        await _notifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      // 等待一小会儿确保 GetX 路由就绪
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.toNamed('/expense');
      });
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    Get.toNamed('/expense');
  }

  Future<void> _loadSettings() async {
    final sp = Get.find<SharedPreferences>();
    isEnabled.value = sp.getBool(SPKey.reminderEnabled) ?? false;
    final timesJson = sp.getString(SPKey.reminderTimes);
    if (timesJson != null) {
      reminderTimes.value = List<String>.from(json.decode(timesJson));
    }
  }

  Future<void> saveSettings() async {
    final sp = Get.find<SharedPreferences>();
    await sp.setBool(SPKey.reminderEnabled, isEnabled.value);
    await sp.setString(SPKey.reminderTimes, json.encode(reminderTimes));

    if (isEnabled.value) {
      await scheduleAllNotifications();
    } else {
      await cancelAllNotifications();
    }
  }

  Future<void> scheduleAllNotifications() async {
    await _notifications.cancelAll();

    for (int i = 0; i < reminderTimes.length; i++) {
      await _scheduleNotification(reminderTimes[i], i);
    }
  }

  Future<void> _scheduleNotification(String time, int id) async {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'journal_reminder',
      '记账提醒',
      channelDescription: '提醒您记录今天的账目',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.zonedSchedule(
      id,
      '记账提醒',
      '该记录今天的账目了',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> requestPermissions() async {
    bool granted = false;

    if (GetPlatform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? result =
          await androidImplementation?.requestNotificationsPermission();
      granted = result ?? false;
    } else if (GetPlatform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final bool? result = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
    }

    isEnabled.value = granted;
    await saveSettings();
  }

  Future<bool> checkPermissions() async {
    bool granted = false;

    if (GetPlatform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidImplementation?.areNotificationsEnabled();
      granted = result == true;
    } else if (GetPlatform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final result = await iosImplementation?.checkPermissions();
      granted = result?.isEnabled == true;
    }

    return granted;
  }

  void addReminderTime(String time) {
    if (!reminderTimes.contains(time)) {
      reminderTimes.add(time);
      reminderTimes.sort();
      saveSettings();
    }
  }

  void removeReminderTime(String time) {
    reminderTimes.remove(time);
    saveSettings();
  }

  void toggleEnabled(bool value) {
    isEnabled.value = value;
    saveSettings();
  }
}
