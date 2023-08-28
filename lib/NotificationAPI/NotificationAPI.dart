import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi{
  static final _notifications = FlutterLocalNotificationsPlugin();
  static Future _notificationsDetails() async{
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel Name',
        channelDescription:"Channel Description",
        importance: Importance.max,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('dearly'),
      ),
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,

  }) async  =>
      _notifications.show(id, title, body, await _notificationsDetails());
}