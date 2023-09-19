import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {

  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future _notificationDetails() async {

    return const NotificationDetails(
      android: AndroidNotificationDetails(
        '001',
        'notify_main',
        channelDescription: 'Alert user if a task is finished',
        importance: Importance.max,
        icon: "@mipmap/ic_launcher",
        playSound: false,
        enableVibration: false,
        color: ThemeColor.darkPurple
      ),
    );
  }

  static Future _uploadingNotificationDetails() async {

    return const NotificationDetails(
      android: AndroidNotificationDetails(
        '002',
        'notify_main_1',
        channelDescription: 'Alert user for ongoing task',
        importance: Importance.max,
        icon: "@mipmap/ic_launcher",
        playSound: false,
        enableVibration: false,
        ongoing: true,
        autoCancel: false,
        color: ThemeColor.darkPurple
      ),
    );
  }

  static Future _audioNotificationDetails() async {

    return const NotificationDetails(
      android: AndroidNotificationDetails(
        '003',
        'notify_main_1',
        channelDescription: 'Alert user for playing audio',
        importance: Importance.max,
        icon: "@mipmap/ic_launcher",
        playSound: false,
        enableVibration: false,
        ongoing: true,
        autoCancel: false,
        color: ThemeColor.darkPurple
      ),
    );
  }

  static Future showUploadingNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload
  }) async => _notifications.show(
    id, title, body, await _uploadingNotificationDetails(),payload: payload);
    
  static Future showAudioNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload
  }) async => _notifications.show(
    id, title, body, await _audioNotificationDetails(), payload: payload);
    
  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload
  }) async => _notifications.show(
    id, title, body, await _notificationDetails(),payload: payload);
    
  static Future stopNotification(int id) async {
    await _notifications.cancel(id);
  }
}