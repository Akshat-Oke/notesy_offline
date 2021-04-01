import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:notesy_offline/models/note_model.dart';
import 'package:notesy_offline/main.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants.dart';

/// Store all notification id's in Firebase and in the respective notes
class NotificationHelper {
  static var androidDetails = AndroidNotificationDetails(
      "channelId", "Note reminders", "Your note reminders",
      importance: Importance.high);

  static Future<dynamic>? handleReminderNotification(
      {required DateTime dateTime, required Note? note}) async {
    print(note?.hashCode.toString());
    var difference =
        dateTime.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    if (difference > 100) {
      var differenceDuration = Duration(milliseconds: difference);
      await showReminderNotification(
        differenceDuration: differenceDuration,
        title: note?.title,
        content: note?.content,
        payload: note?.key.toString(),
        id: note == null ? 0 : note.hashCode,
      );
      note?.setReminder(dateTime).then((value) => null);
    } else {
      print(difference.toString());
    }
  }

  static Future<dynamic> cancelNotification(int id) async {
    return await flutterLocalNotificationsPlugin1?.cancel(id);
  }

  static Future<dynamic> notificationSelected(String? payload) async {
    // showDialog(
    //   context: context
    // )
    print("Notif $payload");
    await Hive.openBox<Note>("notes");
    if (MyApp.navigatorKey?.currentContext != null)
      Navigator.pushNamed(MyApp.navigatorKey!.currentState!.context, "/note",
          arguments: {
            'note': Hive.box<Note>("notes").get(payload),
          });
    return Future.value(3);
  }

  static Future<dynamic>? showReminderNotification(
      {required Duration differenceDuration,
      String? title,
      String? content,
      required String? payload,
      int id = 0}) async {
    if (title == null && content == null) title = "A note reminder";
    print(differenceDuration.toString());
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin1?.zonedSchedule(
      id,
      title,
      content,
      tz.TZDateTime.now(tz.local).add(differenceDuration),
      // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      generalNotificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: false,
      payload: payload,
    );
  }

  static Future<dynamic>? showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidDetails = AndroidNotificationDetails(
        "channelId", "Note reminders", "channelDescription",
        importance: Importance.high);
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    // await flutterLocalNotificationsPlugin.show(0, "Task", "body", generalNotificationDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "scheduled title",
        "body",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        generalNotificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: false);
  }
  // final BehaviorSubject<ReminderNotification> didReceiveLocalNotificationSubject =
  //     BehaviorSubject<ReminderNotification>();
  //
  // final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();
}
