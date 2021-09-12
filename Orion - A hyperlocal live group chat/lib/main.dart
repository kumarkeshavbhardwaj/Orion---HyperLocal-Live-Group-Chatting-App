import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:orion/dob.dart';
import 'package:orion/firebasecontroller.dart';
import 'package:orion/firstpage.dart';
import 'package:orion/getinfo.dart';
import 'package:orion/homepage.dart';
import 'package:orion/notificationcontroller.dart';
import 'package:orion/signupscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Color.fromRGBO(252, 90, 39, 1),
          accentColor: Colors.white),
      title: 'orion',
      home: MyApp()));
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    FlutterLocalNotificationsPlugin flip =
        new FlutterLocalNotificationsPlugin();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();

    var settings = new InitializationSettings(android: android, iOS: ios);
    flip.initialize(settings);

    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    NotificationController.instance.initLocalNotification();

    NotificationController.instance.takeFCMTokenWhenAppLaunch();
    FirebaseController.instance.getUnreadMSGCount();
    checkifloggedin();
  }

  Future<void> checkifloggedin() async {
    // checknet();

    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var key = prefs.getString('key');
    var fp = prefs.getString('fp');
    var name = prefs.getString('name');
    var dob = prefs.getString('dob');

    if (key == null) {
      loginmethod();
    } else if (key != null && fp == null) {
      homemethod();
    } else if (key != null && fp != null && dob == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DOB(
                    key,
                  )),
          (Route<dynamic> route) => false);
      // Navigator.push(context, MaterialPageRoute(builder: (c) => Intro(key)));
    } else if (key != null && fp != null && dob != null && name==null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => InfoGet(key)),
          (Route<dynamic> route) => false);
      // Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage(key)));
    } else if(key!=null && fp!=null && dob!=null && name!=null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage(key)),
          (Route<dynamic> route) => false);
    }

    // key && name == null ? loginmethod() : homemethod();
  }

  checknet() async {
    var listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Data connection is available.');
          break;
        case DataConnectionStatus.disconnected:
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    'No Internet',
                    style: TextStyle(
                      fontFamily: 'Righteous',
                    ),
                  ),
                  content: Text(
                    'Internet is required to be an orion :)',
                    style: TextStyle(
                      fontFamily: 'Righteous',
                    ),
                  ),
                );
              });
          print('You are disconnected from the internet.');
          break;
      }
    });

    // close listener after 30 seconds, so the program doesn't run forever
    await Future.delayed(Duration(seconds: 30));
    await listener.cancel();
  }

  loginmethod() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Signupscreen()),
        (Route<dynamic> route) => false);
  }

  homemethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => FirstPage(
                  prefs.getString('id'),
                )),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var corecolor = Color.fromRGBO(252, 90, 39, 1);

    var width = MediaQuery.of(context).size.width / 100;

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: width * 10),

              // alignment: Alignment.center,
              child: Text(
                'orion',
                style: TextStyle(
                    color: corecolor,
                    fontFamily: 'Righteous',
                    fontWeight: FontWeight.w900,
                    fontSize: width * 20),
              )),
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: width * 10),
              // color: Colors.white,
              // alignment: Alignment.center,
              child: Text(
                'speak loudly in your location',
                style: TextStyle(
                    color: corecolor,
                    fontFamily: 'Blinker',
                    fontWeight: FontWeight.w900,
                    fontSize: width * 5),
              )),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
