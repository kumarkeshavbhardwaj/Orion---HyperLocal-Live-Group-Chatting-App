import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:orion/firebasecontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    print('myBackgroundMessageHandler data');
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    print('myBackgroundMessageHandler notification');
    final dynamic notification = message['notification'];
  }
  // Or do other work.
}

class NotificationController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static NotificationController get instance => NotificationController();

//  NotificationController() {
//    takeFCMTokenWhenAppLaunch();
//    initLocalNotification();
//  }
  User firebaseUser = FirebaseAuth.instance.currentUser;

  Future takeFCMTokenWhenAppLaunch() async {
    try {
      if (Platform.isIOS) {
        _firebaseMessaging.requestNotificationPermissions(
            IosNotificationSettings(sound: true, badge: true, alert: true));
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userToken = prefs.getString('FCMToken');
      print('splash init success $userToken');
      if (userToken == null) {
        _firebaseMessaging.getToken().then((val) async {
          print('Token: ' + val);
          prefs.setString('FCMToken', val);
          String userID = prefs.get('id');
          if (userID != null) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .update({
              'devtoken': val,
            });
          }
        });
      }

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          String msg = 'notibody';
          String name = 'chatapp';
          if (Platform.isIOS) {
            msg = message['aps']['alert']['body'];
            name = message['aps']['alert']['title'];
          } else {
            msg = message['notification']['body'];
            name = message['notification']['title'];
          }

          String currentChatRoom = (prefs.get('currentChatRoom') ?? 'None');

          if (Platform.isIOS) {
            if (message['chatroomid'] != currentChatRoom) {
              sendLocalNotification(name, msg);
            }
          } else {
            if (message['data']['chatroomid'] != currentChatRoom) {
              sendLocalNotification(name, msg);
            }
          }

          FirebaseController.instance.getUnreadMSGCount();
        },
        onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );
    } catch (e) {
      print(e.message);
    }
  }

  Future initLocalNotification() async {
    if (Platform.isIOS) {
      // set iOS Local notification.
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    } else {
      // set Android Local notification.
      var initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    }
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  Future _selectNotification(String payload) async {}

  sendLocalNotification(name, msg) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin
        .show(0, name, msg, platformChannelSpecifics, payload: 'item x');
  }

  // Send a notification message
  final String serverToken = yourtoken

  Future<void> sendNotificationMessageToPeerUser(peerusername, unreadmsgcount,
      textFromTextField, chatID, peerUserToken) async {
    print('count is $unreadmsgcount');
    print('msg is $textFromTextField');
    print('chatid is $chatID');
    print('peername is $peerusername');
    print('peertoken is $peerUserToken');

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$textFromTextField',
            'title': '$peerusername sent you',
            'badge': '$unreadmsgcount', //'$unReadMSGCount'
            "sound": 'default',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'chatroomid': chatID,
            // 'sound': 'default'
          },
          'to': peerUserToken,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }

  Future<void> sendNotificationMessageToLPeerUser(peerusername, unreadmsgcount,
      textFromTextField, chatID, peerUserToken) async {
    print('count is $unreadmsgcount');
    print('msg is $textFromTextField');
    print('chatid is $chatID');
    print('peername is $peerusername');
    print('peertoken is $peerUserToken');

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$textFromTextField',
            'title': 'Anonymous',
            'badge': '$unreadmsgcount', //'$unReadMSGCount'
            "sound": 'default',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'chatroomid': chatID,
            'sound': 'default'
          },
          'to': peerUserToken,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }

  Future<void> sendNotificationMessageToSPeerUser(myindex, peerusername,
      unreadmsgcount, textFromTextField, chatID, peerUserToken) async {
    print('count is $unreadmsgcount');
    print('msg is $textFromTextField');
    print('chatid is $chatID');
    print('peername is $peerusername');
    print('peertoken is $peerUserToken');

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$textFromTextField',
            'title': '$peerusername sent in group $myindex',
            'badge': '$unreadmsgcount', //'$unReadMSGCount'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'chatroomid': chatID,
            // 'sound': 'default'
          },
          'to': peerUserToken,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }

  Future<void> notifylchatuser(textFromTextField, peerUserToken) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'someone connected with you ',
            'title': 'LUCKY ME',
            // 'badge': '$unreadmsgcount', //'$unReadMSGCount'
            "sound": 'default',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            // 'chatroomid': chatID,
            'sound': 'default'
          },
          'to': peerUserToken,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }

  Future<void> notifyschatuser1(
    peer2name,
    peer3name,
    peer4name,
    peerUserToken,
  ) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'You are joined with $peer2name, $peer3name & $peer4name',
            'title': 'go Global',
            // 'badge': '$unreadmsgcount', //'$unReadMSGCount'
            "sound": 'default',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            // 'chatroomid': chatID,
            // 'sound': 'default'
          },
          'to': peerUserToken,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }

  Future<void> notifyschatuser2(
      peer1name, peer3name, peer4name, peerUserToken2) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'You are joined with $peer1name, $peer3name & $peer4name',
            'title': 'go Global',
            // 'badge': '$unreadmsgcount', //'$unReadMSGCount'
            "sound": 'default',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            // 'chatroomid': chatID,
            // 'sound': 'default'
          },
          'to': peerUserToken2,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }

  Future<void> notifyschatuser3(
      peer1name, peer2name, peer4name, peerUserToken3) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'You are joined with $peer1name, $peer2name & $peer4name',
            'title': 'go Global',
            // 'badge': '$unreadmsgcount', //'$unReadMSGCount'
            "sound": 'default',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            // 'chatroomid': chatID,
            // 'sound': 'default'
          },
          'to': peerUserToken3,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }

   Future<void> commentnotification(peerusername,
      textFromTextField, peerUserToken) async {
    // print('count is $unreadmsgcount');
    print('msg is $textFromTextField');
    // print('chatid is $chatID');
    print('peername is $peerusername');
    print('peertoken is $peerUserToken');

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$textFromTextField',
            'title': '$peerusername commented on your post',
            // 'badge': '$unreadmsgcount', //'$unReadMSGCount'
            "sound": 'default',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            // 'chatroomid': chatID,
            'sound': 'default'
          },
          'to': peerUserToken,
        },
      ),
    );
    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );
  }
}
