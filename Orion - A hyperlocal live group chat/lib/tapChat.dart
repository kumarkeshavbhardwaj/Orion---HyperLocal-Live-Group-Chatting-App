import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orion/personalChatroom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as tago;
import 'package:uuid/uuid.dart';

import 'notificationcontroller.dart';

class TapChat extends StatefulWidget {
  final String currentuserid;
  TapChat(this.currentuserid);
  @override
  _TapChatState createState() => _TapChatState();
}

class _TapChatState extends State<TapChat> {
  // String ngroupchatid = '';
  int lastused;
  int currenttime;
  int dayhourtime = 86400000;

  //new values
  int length = 0;
  String tickleid = '';

  String peernickname = '';
  // String peercc = '';
  // String peeraa = '';
  String peerhandle = '';
  String peerid = '';
  String peerimageurl = '';
  String peertoken = '';
  // String peerbio = '';

  String chatroomid = '';
  int peerindex = 0;

  int click;
  bool ena = true;

  int dk;
  int myindex;
  String ngroupchatid = '';
  String myid;
  String myname;
  String myhandle;
  String myphoto;
  String mytoken;
  String docid;
  // String mybio;
  // String myaa;
  // String mycc;

  int staticvalue = 1584253800000;

  @override
  void initState() {
    super.initState();

    getmyindex();
    getdoclength();
    readlocal();
  }

  getdoclength() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) {
      dk = value.size;
    });

    print('dkdkdkd$dk');
  }

  getmyindex() {
    Future<QuerySnapshot> querySnapshot = FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.currentuserid)
        .get();
    querySnapshot.then((value) {
      value.docs.forEach((element) {
        myindex = element['index'];
      });
      print('object$myindex');
    });
  }

  readlocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myid = prefs.getString('id');
      // mytoken = prefs.getString('FCMtoken');
      myphoto = prefs.getString('photo');
      myname = prefs.getString('name');
      // mybio = prefs.getString('bio');
      myhandle = prefs.getString('handle');
      // myaa = prefs.getString('countrycode');
      // mycc = prefs.getString('adminarea');
    });
    print('my token is $mytoken');
  }

  checklastused() {
    Future<DocumentSnapshot> ds = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .get();

    ds.then((value) {
      setState(() {
        lastused = value.data()['lastused'];
      });
    }).then((value) {
      decide();
    });
  }

  decide() {
    if (DateTime.now().millisecondsSinceEpoch - lastused >= dayhourtime) {
      //valid now
      donut2();

      print('you can use now');
      print('last used is $lastused');
    } else {
      waitingdialog();
      // print('last used is $lastused');

      // print('You have used within a minute...wait');
      // print('cya' + tago.format(DateTime.fromMillisecondsSinceEpoch(lastused)));
    }
  }

  waitingdialog() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Okay', style: TextStyle(fontFamily: 'Blinker', fontWeight: FontWeight.bold),)),
              ],
              content: Container(
                child: Text(
                  'You have used once within last 24 hours. After sometime you can use it again.',
                  style: TextStyle(fontFamily: 'Blinker'),
                ),
              ),
            ));
  }

  shower() {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    var corecolor = Color.fromRGBO(252, 90, 39, 1);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              height: height * 20,
              width: width * 50,
              child: Column(
                children: [
                  Text(
                    'finding...wait',
                    style: TextStyle(
                        color: corecolor,
                        fontFamily: 'Blinker',
                        fontWeight: FontWeight.bold,
                        fontSize: width * 5),
                  ),
                  SizedBox(
                    height: height * 1,
                  ),
                  SpinKitCircle(
                    color: corecolor,
                  ),
                  SizedBox(
                    height: height * 1,
                  ),
                  Text(
                    'the city is so big',
                    style: TextStyle(
                        color: corecolor,
                        fontFamily: 'Blinker',
                        fontWeight: FontWeight.bold,
                        fontSize: width * 5),
                  )
                ],
              ),
            ),
          );
        });
  }

  int key;

  mm() {
    var n = myindex;
    do {
      key = Random().nextInt(dk);
      print('youruniquekeyis$key');
    } while (key == n);
    print('excludingyourindex=$n');
    Timer(Duration(seconds: 2), () {
      matchindex(key);
    });
  }

  matchindex(int key) {
    Future<DocumentSnapshot> d = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .collection('lchat-users')
        .doc('indexlist')
        .get();

    d.then((value) {
      if (value.exists) {
        print('the val exist');
        Future<DocumentSnapshot> ds = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentuserid)
            .collection('lchat-users')
            .doc('indexlist')
            .get();

        ds.then((value) {
          List indexlist = value.data()['indexlist'];
          if (indexlist.contains(key)) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(widget.currentuserid)
                .update({'lastused': staticvalue});
            print('same val showing busy');
            return showDialog(
                context: context,
                builder: (c) => AlertDialog(
                      content: Text('Server Busy'),
                      actions: [
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text('Okay'))
                      ],
                    ));
          } else {
            print('new val');
            getstream();
          }
        });
      } else {
        print('creating the val');
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentuserid)
            .collection('lchat-users')
            .doc('indexlist')
            .set({'indexlist': []}).then((value) {
          Future<DocumentSnapshot> ds = FirebaseFirestore.instance
              .collection('users')
              .doc(widget.currentuserid)
              .collection('lchat-users')
              .doc('indexlist')
              .get();

          ds.then((value) {
            List indexlist = value.data()['indexlist'];
            if (indexlist.contains(key)) {
              print('same val showing busy');
              return showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                        content: Text('Server Busy'),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text('Okay'))
                        ],
                      ));
            } else {
              print('new val');
              getstream();
            }
          });
        });
      }
    });
  }

  getstream() {
    Future<QuerySnapshot> querySnapshot = FirebaseFirestore.instance
        .collection('users')
        .where('index', isEqualTo: key)
        .get();
    print('key is here$key');
    querySnapshot.then((value) {
      value.docs.forEach((element) {
        peernickname = element['name'];
        peertoken = element['devtoken'];
        peerimageurl = element['photo'];
        peerid = element['id'];
        // peerbio = element['bio'];
        peerhandle = element['handle'];
        // peercc = element['countrycode'];
        // peeraa = element['adminarea'];

        peerindex = element['index'];
      });
    }).then((value) {
      if (myid.hashCode <= peerid.hashCode) {
        setState(() {
          chatroomid = '$myid-$peerid';
        });
      } else {
        setState(() {
          chatroomid = '$peerid-$myid';
        });
      }

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentuserid)
          .collection('lchat-users')
          .doc(ngroupchatid)
          .set({
        'userindex': peerindex,
        'dm': false,
        'lchatuserid': peerid,
        'notif': true,
        // 'lchatuserbio': peerbio,
        'lchatphotourl': peerimageurl,
        'lchatnickname': peernickname,
        'lchatdevtoken': peertoken,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        // 'lchataa': peeraa,
        // 'lchatcc': peercc,
        'lchatpeerhandle': peerhandle,
        'docid': ngroupchatid,
        'chatroomid': chatroomid,

        // 'lchatpeerbio'
      }).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentuserid)
            .collection('lchat-users')
            .doc('indexlist')
            .update({
          'indexlist': FieldValue.arrayUnion([peerindex])
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(peerid)
            .collection('lchat-users')
            .doc(ngroupchatid)
            .set({
          'lchatuserid': myid,
          // 'lchatuserbio': mybio,
          'dm': false,
          'lchatphotourl': myphoto,
          'lchatnickname': myname,
          'notif': true,
          'lchatdevtoken': mytoken,
          'lchatpeerhandle': myhandle,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          // 'lchataa': myaa,
          // 'lchatcc': mycc,
          'docid': ngroupchatid,
          'chatroomid': chatroomid,
        });
      });
    }).then((value) {
       FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({'lastused': DateTime.now().millisecondsSinceEpoch});
      funcs();
    });

    Timer(Duration(seconds: 3), () {
      setState(() {
        chatroomid = '';
      });
    });
  }

  funcs() {
   
    // print(click);

    // shower();
    Timer(Duration(seconds: 1), () {
      Navigator.pop(context);
    });

    Timer(Duration(seconds: 1), () {
      print('inside the chatroom');
      NotificationController.instance.notifylchatuser(peernickname, peertoken);
      print(
        peernickname,
      );
      print(peertoken);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PersonalChatroom(
                    // anony: true,
                    // aa: peeraa,
                    // cc: peercc,
                    myId: myid,
                    // peerbio: peerbio,
                    peerhandle: peerhandle,
                    peerAvatar: peerimageurl,
                    peernickname: peernickname,
                    peerId: peerid,
                    peerToken: peertoken,
                  )));
    });
  }

  nrgroupchatidgen() {
    var uuid = Uuid().v4();
    ngroupchatid = uuid;
    print('so...ngroup chat id is $ngroupchatid');
    Timer(Duration(seconds: 1), mm);
  }

  donut2() async {
    if (await ConnectivityWrapper.instance.isConnected) {
      shower();
      print('you r connected');
      nrgroupchatidgen();

      // mm();
      // getstream();
      // funcs();
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'No Internet',
                style: TextStyle(
                  fontFamily: 'Blinker',
                ),
              ),
              content: Text(
                'Internet is required to be on orion :)',
                style: TextStyle(
                  fontFamily: 'Blinker',
                ),
              ),
            );
          });
      print('u r not connected');
    }
    // Timer(Duration(seconds: 1), () {
    //
    // });
  }

  Future<bool> onBackPress() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(myid)
        .update({'isonline': false});
    SystemNavigator.pop();

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    return WillPopScope(
      onWillPop: onBackPress,
      child: Container(color: Colors.white,
        child: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.currentuserid)
                    .collection('lchat-users')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SpinKitCircle(
                      color: Theme.of(context).primaryColor,
                    );
                  } else if (snapshot.data.docs.length == 0) {
                    return Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              top: height * 2,
                              left: width * 5,
                              right: width * 5),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Chat with other students in your location. Start Chatting by messaging them.',
                                 textAlign: TextAlign.center, style: TextStyle(
                                    color: Colors.black45,
                                    fontFamily: 'Blinker',
                                    fontSize: width * 7,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(height: width*4),
                              Text(
                                  'Do give us the feedback by clicking on Settings Icon in the Tab Bar',
                                  textAlign: TextAlign.center,style: TextStyle(
                                    color: Colors.black45,
                                    fontFamily: 'Blinker',
                                    fontSize: width * 6,
                                    fontWeight: FontWeight.normal,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 10,
                                      // blurRadius: 2,
                                      color: Colors.white70,
                                      offset: Offset.zero)
                                ],
                              ),
                              margin: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: height * 2,
                              ),
                              // padding: EdgeInsets.all(2.5),
                              child: ListTile(
                                  onLongPress: () {
                                    showd(
                                      snapshot.data.docs[index]['docid'],
                                      snapshot.data.docs[index]['lchatuserid'],
                                      snapshot.data.docs[index]['lchatuserid'],
                                    );
                                  },
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) => PersonalChatroom(
                                                  // anony:
                                                  //     snapshot.data.docs[index]
                                                  //                 ['dm'] ==
                                                          //     true
                                                          // ? false
                                                          // : true,
                                                  docid: snapshot.data
                                                      .docs[index]['docid'],
                                                  // aa: snapshot.data
                                                  //         .docs[index]
                                                  //     ['lchataa'],
                                                  // cc: snapshot.data
                                                  //         .docs[index]
                                                  //     ['lchatcc'],
                                                  // peerbio: snapshot.data
                                                  //         .docs[index]
                                                  //     ['lchatuserbio'],
                                                  peerhandle:
                                                      snapshot.data.docs[index]
                                                          ['lchatpeerhandle'],
                                                  peerAvatar:
                                                      snapshot.data.docs[index]
                                                          ['lchatphotourl'],
                                                  peerId:
                                                      snapshot.data.docs[index]
                                                          ['lchatuserid'],
                                                  peerToken:
                                                      snapshot.data.docs[index]
                                                          ['lchatdevtoken'],
                                                  peernickname:
                                                      snapshot.data.docs[index]
                                                          ['lchatnickname'],
                                                )));
                                  },
                                  leading: CachedNetworkImage(
                                    imageUrl: snapshot.data.docs[index]
                                        ['lchatphotourl'],
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      backgroundImage: imageProvider,
                                      radius: width * 5,
                                    ),
                                    //   //     Container(
                                    //   //   width: width * 10,
                                    //   //   height: height * 10,
                                    //   //   decoration: BoxDecoration(
                                    //   //     shape: BoxShape.circle,
                                    //   //     image: DecorationImage(
                                    //   //         image: imageProvider,
                                    //   //         fit: BoxFit.cover),
                                    //   //   ),
                                    //   // ),
                                    placeholder: (context, url) =>
                                        SpinKitFoldingCube(
                                            color:
                                                Theme.of(context).primaryColor),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                  // leading: CircleAvatar(
                                  //   radius: 25,
                                  //   backgroundImage: NetworkImage(snapshot
                                  //       .data.docs[index]['lchatphotourl']),
                                  // ),
                                  trailing: Container(
                                    width: width * 20,
                                    child: Row(
                                      children: [
                                        StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('lchats')
                                                .doc(snapshot.data.docs[index]
                                                    ['chatroomid'])
                                                .collection(snapshot.data
                                                    .docs[index]['chatroomid'])
                                                .where('isseen',
                                                    isEqualTo: false)
                                                .where('idTo',
                                                    isEqualTo:
                                                        widget.currentuserid)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData ||
                                                  snapshot.data == null) {
                                                return Container(
                                                  width: width * 1,
                                                );
                                              }
                                              // print(snapshot.data.size);
                                              return snapshot.data.size == 0
                                                  ? Container(
                                                      width: width * 5,
                                                    )
                                                  : CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      child: Text(
                                                        snapshot.data.size == 0
                                                            ? ''
                                                            : snapshot.data.size
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Righteous'),
                                                      ),
                                                    );
                                            }),
                                        IconButton(
                                          icon: Icon(Icons.more_vert,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          onPressed: () {
                                            showd(
                                              snapshot.data.docs[index]
                                                  ['docid'],
                                              snapshot.data.docs[index]
                                                  ['lchatuserid'],
                                              snapshot.data.docs[index]
                                                  ['lchatuserid'],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    snapshot.data.docs[index]['lchatnickname'] + ' | Nearby',
                                    style: TextStyle(
                                        fontFamily: 'Blinker',
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(
                                                snapshot.data.docs[index]
                                                    ['lchatuserid'],
                                              )
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData ||
                                                snapshot.data == null) {
                                              return Container();
                                            }
                                            return snapshot.data
                                                    .data()['isonline']
                                                ? Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        color: Colors.teal),
                                                    child: Text(
                                                      'Online',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Righteous',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: width * 3),
                                                    ),
                                                  )
                                                : Container();
                                          })
                                    ],
                                  )),
                            ),
                            // Container(
                            //   margin: EdgeInsets.symmetric(horizontal: width*5),
                            // child: Divider(thickness: .5, color: corecolor,))
                          ],
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }

  showd(
    String id,
    String peerId,
    String peeerId,
  ) {
    var width = MediaQuery.of(context).size.width / 100;

    return showDialog(
        context: context,
        builder: (c) => SimpleDialog(
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    leavechat(id, peerId);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Leave chat',
                    style:
                        TextStyle(fontFamily: 'Blinker', fontSize: width * 5),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    blockuser(peeerId, id, peerId);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Block user',
                    style:
                        TextStyle(fontFamily: 'Blinker', fontSize: width * 5),
                  ),
                ),
              ],
            ));
  }

  blockuser(String peeerId, String id, String peerId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .collection('blockedusers')
        .doc()
        .set({
      'id': peeerId,
      'time': DateTime.now(),
    });

    leavechat(id, peerId);
  }

  leavechat(String id, String peerId) {
    var docref = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .collection('lchat-users')
        .doc(id);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      await transaction.delete(docref);
    });

    var peerdocref = FirebaseFirestore.instance
        .collection('users')
        .doc(peerId)
        .collection('lchat-users')
        .doc(id);

    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      await transaction.delete(peerdocref);
    });
    print('done');
  }
}
