import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }

      // Android 12+ exact alarm permission
      if (Platform.isAndroid) {
        await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermission();
      }
    }
  }

  // ============================================
  // MEDICATION NOTIFICATIONS
  // ============================================

  static Future<void> scheduleMedicationReminder({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    String? mealTiming,
    String? instructions,
  }) async {
    final notificationId = medicationId.hashCode;

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for scheduled medications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('medication_alert'),
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'take',
          'Take Now',
          showsUserInterface: true,
          titleColor: Color(0xFF10B981),
        ),
        AndroidNotificationAction(
          'snooze',
          'Snooze 10min',
          icon: DrawableResourceAndroidBitmap('ic_snooze'),
        ),
        AndroidNotificationAction(
          'skip',
          'Skip',
          contextual: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'medication_alert.aiff',
      categoryIdentifier: 'MEDICATION_REMINDER',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final mealInfo = mealTiming != null ? '\n${_formatMealTiming(mealTiming)}' : '';
    final instructionInfo = instructions != null ? '\n$instructions' : '';

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Time for $medicationName',
      '$dosage$mealInfo$instructionInfo',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'medication:$medicationId',
    );
  }

  static Future<void> scheduleRecurringMedicationReminder({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required TimeOfDay time,
    String? mealTiming,
    RepeatInterval repeatInterval = RepeatInterval.daily,
    List<int>? daysOfWeek, // For weekly reminders [1=Mon, 7=Sun]
  }) async {
    final notificationId = medicationId.hashCode;

    // Schedule for daily
    if (repeatInterval == RepeatInterval.daily) {
      await _scheduleDaily(
        notificationId: notificationId,
        medicationName: medicationName,
        dosage: dosage,
        time: time,
        mealTiming: mealTiming,
        medicationId: medicationId,
      );
    }
    // Schedule for specific days of week
    else if (daysOfWeek != null && daysOfWeek.isNotEmpty) {
      for (final dayOfWeek in daysOfWeek) {
        await _scheduleWeekly(
          notificationId: notificationId + dayOfWeek,
          medicationName: medicationName,
          dosage: dosage,
          time: time,
          dayOfWeek: dayOfWeek,
          mealTiming: mealTiming,
          medicationId: medicationId,
        );
      }
    }
  }

  static Future<void> _scheduleDaily({
    required int notificationId,
    required String medicationName,
    required String dosage,
    required TimeOfDay time,
    String? mealTiming,
    required String medicationId,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for scheduled medications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      category: AndroidNotificationCategory.alarm,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('take', 'Take Now', showsUserInterface: true),
        AndroidNotificationAction('snooze', 'Snooze 10min'),
        AndroidNotificationAction('skip', 'Skip'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'MEDICATION_REMINDER',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final mealInfo = mealTiming != null ? '\n${_formatMealTiming(mealTiming)}' : '';

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Time for $medicationName',
      '$dosage$mealInfo',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'medication:$medicationId',
    );
  }

  static Future<void> _scheduleWeekly({
    required int notificationId,
    required String medicationName,
    required String dosage,
    required TimeOfDay time,
    required int dayOfWeek,
    String? mealTiming,
    required String medicationId,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Adjust to next occurrence of dayOfWeek
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for scheduled medications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('take', 'Take Now', showsUserInterface: true),
        AndroidNotificationAction('snooze', 'Snooze 10min'),
        AndroidNotificationAction('skip', 'Skip'),
      ],
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    final mealInfo = mealTiming != null ? '\n${_formatMealTiming(mealTiming)}' : '';

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Time for $medicationName',
      '$dosage$mealInfo',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'medication:$medicationId',
    );
  }

  static Future<void> snoozeReminder(int notificationId, int minutes) async {
    await cancelNotification(notificationId);

    final snoozeTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Medication Reminder (Snoozed)',
      'Time to take your medication',
      snoozeTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ============================================
  // WORKOUT NOTIFICATIONS
  // ============================================

  static Future<void> scheduleWorkoutReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'workout_reminders',
      'Workout Reminders',
      channelDescription: 'Reminders for scheduled workouts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_workout',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      'workout_reminder'.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'workout',
    );
  }

  // ============================================
  // REFILL REMINDERS
  // ============================================

  static Future<void> scheduleRefillReminder({
    required String medicationName,
    required DateTime refillDate,
    int daysBeforeReminder = 7,
  }) async {
    final reminderDate = refillDate.subtract(Duration(days: daysBeforeReminder));

    const androidDetails = AndroidNotificationDetails(
      'refill_reminders',
      'Medication Refill Reminders',
      channelDescription: 'Reminders to refill medications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_refill',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      'refill:$medicationName'.hashCode,
      '🔔 Refill Reminder',
      '$medicationName needs refilling in $daysBeforeReminder days',
      tz.TZDateTime.from(reminderDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'refill:$medicationName',
    );
  }

  // ============================================
  // UTILITY FUNCTIONS
  // ============================================

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // ============================================
  // CALLBACKS
  // ============================================

  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handle iOS foreground notification
    print('iOS Notification: $title - $body');
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    print('Notification tapped: $payload, action: $actionId');

    // Handle notification tap
    if (payload?.startsWith('medication:') ?? false) {
      final medicationId = payload!.split(':')[1];
      _handleMedicationAction(medicationId, actionId);
    } else if (payload == 'workout') {
      _handleWorkoutNotification();
    }
  }

  static void _handleMedicationAction(String medicationId, String? actionId) {
    if (actionId == 'take') {
      // Navigate to log medication as taken
      print('Logging medication as taken: $medicationId');
    } else if (actionId == 'snooze') {
      // Snooze for 10 minutes
      snoozeReminder(medicationId.hashCode, 10);
    } else if (actionId == 'skip') {
      // Log as skipped
      print('Medication skipped: $medicationId');
    }
  }

  static void _handleWorkoutNotification() {
    // Navigate to workouts page
    print('Opening workouts page');
  }

  static String _formatMealTiming(String timing) {
    switch (timing) {
      case 'before_meal':
        return '🍽️ Take before meal';
      case 'with_meal':
        return '🍽️ Take with meal';
      case 'after_meal':
        return '🍽️ Take after meal';
      case 'empty_stomach':
        return '⏰ Take on empty stomach';
      default:
        return '';
    }
  }
}

enum RepeatInterval {
  daily,
  weekly,
  custom,
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
