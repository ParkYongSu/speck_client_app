import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseMessaging firebaseMessaging;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

/// notification setting
void firebaseSettings() async {
  _localNotificationSetting();
  SharedPreferences sp = await SharedPreferences.getInstance();
  firebaseMessaging = FirebaseMessaging.instance;
  firebaseMessaging.requestPermission();
  firebaseMessaging.getToken().then((value) async {
    await sp.setString("fcmToken", value); // fcm 토큰을 저장
  });

  if (sp.getBool("pushNotification") == null) {
    firebaseMessaging.subscribeToTopic("pushNotification");
  }

  if (sp.getBool("newGalaxy") == null) {
    firebaseMessaging.subscribeToTopic("newGalaxy");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
    showNotification(event);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print('Message clicked!');
  });
}

void _localNotificationSetting() async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  var androidInitializationSettings =AndroidInitializationSettings('@drawable/ic_launcher');
  // 안드로이드 알림 올 때 앱 아이콘 설정

  var iOSInitializationSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true);
  // iOS 알림, 뱃지, 사운드 권한 셋팅
  // 만약에 사용자에게 앱 권한을 안 물어봤을 경우 이 셋팅으로 인해 permission check 함

  var initSetting = InitializationSettings(
      android: androidInitializationSettings, iOS: iOSInitializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initSetting);
}

Future<void> showNotification(RemoteMessage message) async {
  String title, body;

  title = message.notification.title;
  body = message.notification.body;
  print(message.data);
  var androidNotificationDetails = AndroidNotificationDetails('dexterous.com.flutter.local_notifications', title, body, importance: Importance.max, priority: Priority.max);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

  var details = NotificationDetails(android: androidNotificationDetails, iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(0, title, body, details);
}