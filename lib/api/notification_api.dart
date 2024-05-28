import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {
  
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<NotificationDetails> _notificationDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
    bool ongoing = false,
  }) async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        icon: '@mipmap/ic_launcher',
        playSound: false,
        enableVibration: false,
        ongoing: ongoing,
        autoCancel: !ongoing,
        color: ThemeColor.darkPurple,
      ),
    );
  }

  static Future showUploadingNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(
          channelId: '002',
          channelName: 'Ongoing Upload',
          channelDescription: 'Alert user for ongoing task',
          ongoing: true,
        ),
        payload: payload,
      );

  static Future showAudioNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(
          channelId: '003',
          channelName: 'Audio Player',
          channelDescription: 'Alert user for playing audio',
          ongoing: true,
        ),
        payload: payload,
      );

  static Future showOnFinishTaskNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(
          channelId: '001',
          channelName: 'On finish upload',
          channelDescription: 'Alert user if a task is finished',
        ),
        payload: payload,
      );

  static Future stopNotification(int id) async {
    await _notifications.cancel(id);
  }
  
}