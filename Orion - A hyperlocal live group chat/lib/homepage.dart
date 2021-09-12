import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orion/feeds.dart';
import 'package:orion/notificationcontroller.dart';
import 'package:orion/tapChat.dart';
import 'package:orion/settings.dart';

class HomePage extends StatefulWidget {
  final String currentuserid;
  HomePage(this.currentuserid);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int karma = 0;

  int came = 0;
  int gone = 0;
  var engminutes = 0.0;

  @override
  void initState() {
    super.initState();
    checknet();
    // triggerlocationagain();
    WidgetsBinding.instance.addObserver(this);
    updateonline();
    // updatelogincount();
    getdatafromnet();
    updatedailycounts();
    // updateengagement();
    NotificationController.instance.takeFCMTokenWhenAppLaunch();
  }

  

 

  // updateengagement() {

  //   FirebaseFirestore.instance.
  // }

  updatedailycounts() {
    print(DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now()));
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({
      'dailycounts': FieldValue.arrayUnion(
          [DateFormat.yMMMMd('en_US').add_jm().format(DateTime.now())])
    });
  }

  getdatafromnet() {
    Stream<DocumentSnapshot> ds = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .snapshots();

    ds.listen((event) {
      setState(() {
        karma = event.data()['karma'];
      });
    });
  }

  updatelogincount() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({'logincount': FieldValue.increment(1)});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        updateoffline();
        // updategone();
        // updateengagement();

        print('app is paused');
        break;

      case AppLifecycleState.inactive:
        updateoffline();
        // updategone();
        // updateengagement();
        print('app is inactive');

        break;

      case AppLifecycleState.resumed:
        updateonline();
        // updategone();
        // updateengagement();
        print('app is resumed');

        break;

      case AppLifecycleState.detached:
        updateoffline();
        // updategone();
        print('app is detached');

        break;
    }
  }

  updateoffline() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({'isonline': false});
  }

  updateonline() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({'isonline': true});
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

  var corecolor = Color.fromRGBO(252, 90, 39, 1);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width / 100;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // floatingActionButton: FloatingActionButton(onPressed: () {},child: Icon(Icons.add)),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: corecolor,
          // appBar: AppBar(backgroundColor: Color.fromRGBO(50, 168, 168, 5),
          // title: Text('', style: TextStyle(fontFamily: 'Righteous'),),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(
              //   'orion',
              //   style: TextStyle(
              //       fontFamily: 'Righteous',
              //       fontSize: 20,
              //       fontWeight: FontWeight.bold,
              //       color: Colors.white),
              // ),
              // SizedBox(
              //   width: 20,
              // ),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  //      SizedBox(
                  //   width: width*3,
                  // ),
                  Text(
                    'Nearby ',
                    style:
                        TextStyle(fontFamily: 'Righteous', color: Colors.white),
                  ),
                ],
              ),

              Text('Karma : $karma',
                  style: TextStyle(
                    fontFamily: 'Blinker',
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          bottom: TabBar(
            tabs: [
//

              Tab(
                icon: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
              ),
              Tab(icon: Icon(Icons.chat_bubble, color: Colors.white)),
              Tab(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Feeds(widget.currentuserid),
            TapChat(widget.currentuserid),
            SettingsPage(widget.currentuserid),
          ],
        ),
      ),
    );
  }
}
