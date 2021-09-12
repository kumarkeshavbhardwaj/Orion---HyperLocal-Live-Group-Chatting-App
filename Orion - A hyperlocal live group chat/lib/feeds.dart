import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:orion/addpost.dart';
import 'package:orion/commentpage.dart';
import 'package:orion/directmessaging.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:polls/polls.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:timeago/timeago.dart' as tago;

// import 'addpoll.dart';

class Feeds extends StatefulWidget {
  final String currentuserid;
  Feeds(this.currentuserid);
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  GlobalKey previewContainer = GlobalKey();
  int originalSize = 1200;

  String code = '';
  // String posterusername = 'orion';
  // int posterkarma = 0;
  // String posterphoto =
  //     'https://image.flaticon.com/icons/png/512/149/149071.png';
  // String postertoken = '';

  bool reply = false;
  var corecolor = Color.fromRGBO(252, 90, 39, 1);

  List<DocumentSnapshot> listmessage = List.from([]);
  int limit = 20;
  final ScrollController listScrollcontroller = ScrollController();
  final FocusNode focusnode = FocusNode();
  final int limitIncrement = 2;

  adddialog() {
    // return showDialog(context: null)
  }

  @override
  void initState() {
    super.initState();
    getcode();
    // shadow();
  }

  updateir() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({'incomingRequest': false});
  }

  // submitfeedback() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String myhandle = prefs.getString('handle');
  //   FirebaseFirestore.instance
  //       .collection('feedbacks')
  //       .doc()
  //       .set({'feedback': tc.text, 'handle': myhandle});

  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.currentuserid)
  //       .update({'incomingRequest': false, 'feedbackgiven': true});
  // }

  handleupdate() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              content: Text('Update your app'),
              actions: [
                FlatButton(
                    onPressed: () {
                      StoreRedirect.redirect(
                          androidAppId: 'com.getorionapp.orion');
                    },
                    child: Text('Okay'))
              ],
            ),
        barrierDismissible: false);
  }

  getcode() {
    Future<DocumentSnapshot> d = FirebaseFirestore.instance
        .collection('codes')
        .doc(widget.currentuserid)
        .get();

    d.then((value) {
      setState(() {
        code = value.data()['code'];
      });
    });
  }

  reportpost(docid) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(docid)
        .update({'reported': true}).then((value) {
      Fluttertoast.showToast(
          msg: 'Post Reported',
          backgroundColor: Theme.of(context).primaryColor);
    });
  }

  _scrollListener() {
    if (listScrollcontroller.offset >=
            listScrollcontroller.position.maxScrollExtent &&
        !listScrollcontroller.position.outOfRange) {
      print('reached the bottom');
      setState(() {
        print('reached the bottom2');
        limit += limitIncrement;
      });
    }
    if (listScrollcontroller.offset <=
            listScrollcontroller.position.minScrollExtent &&
        !listScrollcontroller.position.outOfRange) {
      print('reached the top');
      setState(() {
        print('reached the top2');
      });
    }
  }

  upvotepost(docid, userid) async {
    var corecolor = Color.fromRGBO(252, 90, 39, 1);

    if (userid == widget.currentuserid) {
      Fluttertoast.showToast(
          msg: 'You cannot upvote your post',
          backgroundColor: Theme.of(context).primaryColor);
    } else {
      Future<DocumentSnapshot> q =
          FirebaseFirestore.instance.collection('posts').doc(docid).get();
      q.then((value) {
        List upvotedlist = value.data()['upvotedby'];
        if (value.data()['upvotedby'].contains(widget.currentuserid)) {
          Fluttertoast.showToast(
              msg: 'You already upvoted this post',
              backgroundColor: Colors.blue);
        } else {
          FirebaseFirestore.instance.collection('posts').doc(docid).update({
            'upvotedby': FieldValue.arrayUnion([widget.currentuserid]),
            'upvotes': FieldValue.increment(1),
          }).then((value) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(userid)
                .update({'karma': FieldValue.increment(3)});
            // prefs.setString('upvoted', 'true');
            Fluttertoast.showToast(
                msg: 'You upvoted!', backgroundColor: corecolor);
          });
        }
      });
    }
  }

  downvotepost(docid) async {
    var corecolor = Color.fromRGBO(252, 90, 39, 1);

    Future<DocumentSnapshot> q =
        FirebaseFirestore.instance.collection('posts').doc(docid).get();
    q.then((value) {
      List upvotedlist = value.data()['downvotedby'];
      if (value.data()['downvotedby'].contains(widget.currentuserid)) {
        Fluttertoast.showToast(
            msg: 'You already downvoted this post',
            backgroundColor: Colors.blue);
      } else {
        FirebaseFirestore.instance.collection('posts').doc(docid).update({
          'downvotedby': FieldValue.arrayUnion([widget.currentuserid]),
          'downvotes': FieldValue.increment(1),
        }).then((value) {
          // prefs.setString('upvoted', 'true');
          Fluttertoast.showToast(
              msg: 'You downvoted!', backgroundColor: corecolor);
        });
      }
    });
  }

  infodialog(posterid) {
    var width = MediaQuery.of(context).size.width / 100;

    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              // title:
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // bool datagot = false;
                String posterphoto;
                String posterusername;
                int posterkarma;
                String postertoken;

                return Container(
                    height: width * 50,
                    // child: datagot == true
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(posterid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SpinKitCircle(
                              color: Theme.of(context).primaryColor,
                            );
                          }
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(snapshot.data.data()['photo']),
                              ),
                              Text(snapshot.data.data()['name'],
                                  style: TextStyle(
                                      fontFamily: 'Blinker',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              Text('Karma : ${snapshot.data.data()['karma']}',
                                  style: TextStyle(
                                      fontFamily: 'Blinker',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: width * 5,
                              ),
                              widget.currentuserid == posterid
                                  ? Container()
                                  : InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) => DirectMessaging(
                                                    myId: widget.currentuserid,
                                                    peerAvatar: snapshot.data
                                                        .data()['photo'],
                                                    peerId: snapshot.data
                                                        .data()['id'],
                                                    peerToken: snapshot.data
                                                        .data()['devtoken'],
                                                    peerhandle: snapshot.data
                                                        .data()['handle'],
                                                    peernickname: snapshot.data
                                                        .data()['name'],
                                                  ))),
                                      child: Container(
                                        height: width * 10,
                                        width: width * 50,
                                        alignment: Alignment.center,
                                        child: Text('Message',
                                            style: TextStyle(
                                                fontFamily: 'Blinker',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    )
                            ],
                          );
                        })
                    // : SpinKitCircle(
                    //     color: Theme.of(context).primaryColor,
                    // )
                    );
              }),
            ));
  }

  // sharepost() {
  //   Share.file(title, name, bytes, mimeType)
  // }

  @override
  Widget build(BuildContext context) {
    print(widget.currentuserid);
    var width = MediaQuery.of(context).size.width / 100;

    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: Icon(
      //   Icons.add,
      //   color: Colors.white,
      //   size: width * 10,
      // ),
      body: RepaintBoundary(
        key: previewContainer,
        child: Stack(
          children: [
            Container(
              width: width * 100,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SpinKitCircle(
                        size: width * 10,
                        color: Theme.of(context).primaryColor,
                      );
                    }
                    return ListView.builder(
                      controller: listScrollcontroller,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        double total = snapshot.data.docs[index]['poll'] == true
                            ? snapshot.data.docs[index]['o1'].toDouble() +
                                snapshot.data.docs[index]['o2'].toDouble() +
                                snapshot.data.docs[index]['o3'].toDouble() +
                                snapshot.data.docs[index]['o4'].toDouble()
                            : 0;

                        double o1percent =
                            snapshot.data.docs[index]['poll'] == true
                                ? snapshot.data.docs[index]['o1'].toDouble() /
                                    total *
                                    100
                                : 0;

                        double o2percent =
                            snapshot.data.docs[index]['poll'] == true
                                ? snapshot.data.docs[index]['o2'].toDouble() /
                                    total *
                                    100
                                : 0;
                        double o3percent =
                            snapshot.data.docs[index]['poll'] == true
                                ? snapshot.data.docs[index]['o3'].toDouble() /
                                    total *
                                    100
                                : 0;
                        double o4percent =
                            snapshot.data.docs[index]['poll'] == true
                                ? snapshot.data.docs[index]['o4'].toDouble() /
                                    total *
                                    100
                                : 0;
                        //   double option3 = snapshot.data.docs[index]['o3'];
                        //  double option4 = snapshot.data.docs[index]['o4'];

                        // Map usersWhoVoted = {
                        //   'sam@mail.com': 3,
                        //   'mike@mail.com': 4,
                        //   'john@mail.com': 1,
                        //   'kenny@mail.com': 1
                        // };

                        return snapshot.data.docs[index]['poll'] == false
                            ? InkWell(
                                onTap: (snapshot.data.docs[index]['poster'] ==
                                            'Anonymous' &&
                                        snapshot.data.docs[index]
                                                ['downvotes'] ==
                                            5)
                                    ? () {}
                                    : () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (c) => CommentPage(
                                                    snapshot.data.docs[index]
                                                        ['docid'],
                                                    snapshot.data.docs[index]
                                                        ['post'],
                                                    snapshot.data.docs[index]
                                                        ['timestamp'],
                                                    snapshot.data.docs[index]
                                                        ['posterid'],
                                                    widget.currentuserid)));
                                      },

                                // } : () {},
                                child: Container(
                                    padding: EdgeInsets.all(width * 4),
                                    child: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // SizedBox(width: width*0),
                                            Padding(
                                              padding:
                                                  EdgeInsets.all(width * 2),
                                              child: Row(
                                                children: [
                                                  snapshot.data.docs[index]
                                                              ['poster'] ==
                                                          'Anonymous'
                                                      ? Container()
                                                      : IconButton(
                                                          icon: Icon(Icons
                                                              .info_outline),
                                                          onPressed: () =>
                                                              infodialog(snapshot
                                                                          .data
                                                                          .docs[
                                                                      index]
                                                                  ['posterid']),
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                  CircleAvatar(
                                                    backgroundImage: snapshot
                                                                    .data
                                                                    .docs[index]
                                                                ['poster'] ==
                                                            'Anonymous'
                                                        ? NetworkImage(
                                                            'https://image.flaticon.com/icons/png/512/149/149071.png')
                                                        : NetworkImage(snapshot
                                                                .data
                                                                .docs[index]
                                                            ['photo']),
                                                    radius: 10,
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                        width * 1.0),
                                                    child: Text(
                                                      // 'kumar keshav',
                                                      snapshot.data.docs[index]
                                                          ['poster'],
                                                      overflow:
                                                          TextOverflow.ellipsis,

                                                      style: TextStyle(
                                                          fontFamily: 'Blinker',
                                                          color: corecolor,
                                                          fontSize: width * 4,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding:
                                                  EdgeInsets.all(width * 1.0),
                                              child: Text(
                                                tago.format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        snapshot.data
                                                                .docs[index]
                                                            ['timestamp'])),
                                                style: TextStyle(
                                                    fontFamily: 'Blinker',
                                                    color: corecolor,
                                                    fontSize: width * 4,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_up,
                                                      size: width * 10,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    onPressed: () {
                                                      upvotepost(
                                                          snapshot.data
                                                                  .docs[index]
                                                              ['docid'],
                                                          snapshot.data
                                                                  .docs[index]
                                                              ['posterid']);
                                                    }),
                                                Text(
                                                    '  ' +
                                                        snapshot
                                                            .data
                                                            .docs[index]
                                                                ['upvotes']
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontFamily: 'Blinker',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: width * 5)),
                                                Text(
                                                    '  ' +
                                                        snapshot
                                                            .data
                                                            .docs[index]
                                                                ['downvotes']
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontFamily: 'Blinker',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: width * 5)),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      size: width * 10,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    onPressed: (snapshot.data
                                                                            .docs[
                                                                        index][
                                                                    'downvotes'] ==
                                                                5 &&
                                                            snapshot.data.docs[
                                                                        index][
                                                                    'poster'] ==
                                                                'Anonymous')
                                                        ? () {}
                                                        : () {
                                                            downvotepost(snapshot
                                                                    .data
                                                                    .docs[index]
                                                                ['docid']);
                                                          })
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: width * 80,
                                                  child: (snapshot.data.docs[index]['downvotes'] == 5 &&
                                                          snapshot.data.docs[index]
                                                                  ['poster'] ==
                                                              'Anonymous')
                                                      ? Text(
                                                          'This post is removed',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Blinker',
                                                              fontSize:
                                                                  width * 7,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              color: Colors
                                                                  .blueGrey))
                                                      : Text(snapshot.data.docs[index]['post'],
                                                          style: TextStyle(
                                                              fontFamily: 'Blinker',
                                                              fontSize: width * 7,
                                                              color: Theme.of(context).primaryColor)),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.comment,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: width * 7,
                                                      ),
                                                      onPressed: (snapshot.data.docs[
                                                                          index]
                                                                      [
                                                                      'poster'] ==
                                                                  'Anonymous' &&
                                                              snapshot.data.docs[
                                                                          index]
                                                                      [
                                                                      'downvotes'] ==
                                                                  5)
                                                          ? () {}
                                                          : () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (c) => CommentPage(
                                                                      snapshot.data
                                                                              .docs[index]
                                                                          [
                                                                          'docid'],
                                                                      snapshot.data
                                                                              .docs[index]
                                                                          [
                                                                          'post'],
                                                                      snapshot.data
                                                                              .docs[index]
                                                                          [
                                                                          'timestamp'],
                                                                      snapshot.data
                                                                              .docs[index]
                                                                          [
                                                                          'posterid'],
                                                                      widget
                                                                          .currentuserid),
                                                                ),
                                                              );
                                                            },
                                                    ),
                                                    Text(
                                                      snapshot
                                                          .data
                                                          .docs[index]
                                                              ['commentlength']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontFamily: 'Blinker',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: width * 4,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons.ios_share,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: width * 7,
                                                        ),
                                                        onPressed: () {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'Preparing for sharing...',
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor);
                                                          // sharepost();
                                                          ShareFilesAndScreenshotWidgets()
                                                              .shareScreenshot(
                                                                  previewContainer,
                                                                  originalSize,
                                                                  'orion post',
                                                                  'orion_share.png',
                                                                  'image/png',
                                                                  text:
                                                                      'Here is my post on orion. Use code $code while signing up and gain 25 karma. Install the app now. https://play.google.com/store/apps/details?id=com.getorionapp.orion');
                                                        }),
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons.report_problem,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: width * 7,
                                                        ),
                                                        onPressed: () {
                                                          reportpost(snapshot
                                                                  .data
                                                                  .docs[index]
                                                              ['docid']);
                                                        }),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    )))
                            //
                            //code poll from scratch
                            : Container(
                                padding: EdgeInsets.all(width * 4),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // SizedBox(width: width*0),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(left: width * 5),
                                          child: Row(
                                            children: [
                                              snapshot.data.docs[index]
                                                          ['poster'] ==
                                                      'Anonymous'
                                                  ? Container()
                                                  : IconButton(
                                                      icon: Icon(
                                                          Icons.info_outline),
                                                      onPressed: () =>
                                                          infodialog(snapshot
                                                                  .data
                                                                  .docs[index]
                                                              ['posterid']),
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                              CircleAvatar(
                                                backgroundImage: snapshot.data
                                                                .docs[index]
                                                            ['poster'] ==
                                                        'Anonymous'
                                                    ? NetworkImage(
                                                        'https://image.flaticon.com/icons/png/512/149/149071.png')
                                                    : NetworkImage(snapshot.data
                                                        .docs[index]['photo']),
                                                radius: 10,
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                    left: width * 2.0),
                                                child: Text(
                                                  // 'kumar keshav',
                                                  snapshot.data.docs[index]
                                                      ['poster'],
                                                  overflow:
                                                      TextOverflow.ellipsis,

                                                  style: TextStyle(
                                                      fontFamily: 'Blinker',
                                                      color: corecolor,
                                                      fontSize: width * 4,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: width * 2.0),
                                          child: Text(
                                            tago.format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    snapshot.data.docs[index]
                                                        ['timestamp'])),
                                            style: TextStyle(
                                                fontFamily: 'Blinker',
                                                color: corecolor,
                                                fontSize: width * 4,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(width * 4),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                          snapshot.data.docs[index]['question'],
                                          style: TextStyle(
                                              fontFamily: 'Blinker',
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 5,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    ),

                                    InkWell(
                                      onTap: () {
                                        updatevote(
                                            snapshot.data.docs[index]['docid']);
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: snapshot
                                              .data.docs[index]['userswhovoted']
                                              .contains(widget.currentuserid)
                                          ? Stack(
                                              children: [
                                                Container(
                                                  width: width * o1percent,
                                                  height: width * 14.5,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(.3),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                    // border: Border.all(
                                                    //     color: Theme.of(context)
                                                    //         .primaryColor)
                                                  ),
                                                  margin:
                                                      EdgeInsets.all(width * 4),
                                                  padding:
                                                      EdgeInsets.all(width * 5),
                                                  alignment: Alignment.topLeft,
                                                  // child: Row(
                                                  //   mainAxisAlignment:
                                                  //       MainAxisAlignment.spaceBetween,
                                                  //   children: [
                                                  //     Text(
                                                  //         snapshot.data.docs[index]
                                                  //             ['option1'],
                                                  //         style: TextStyle(
                                                  //             fontFamily: 'Blinker',
                                                  //             fontWeight: FontWeight.bold,
                                                  //             fontSize: width * 5,
                                                  //             color: Theme.of(context)
                                                  //                 .primaryColor)),
                                                  //     snapshot.data
                                                  //             .docs[index]['userswhovoted']
                                                  //             .contains(
                                                  //                 widget.currentuserid)
                                                  //         ? Text(
                                                  //             o1percent.toStringAsFixed(0) + '%'
                                                  //                 // snapshot
                                                  //                 //     .data.docs[index]['o1']
                                                  //                 ,
                                                  //             style: TextStyle(
                                                  //                 fontFamily: 'Blinker',
                                                  //                 fontWeight:
                                                  //                     FontWeight.bold,
                                                  //                 fontSize: width * 5,
                                                  //                 color: Theme.of(context)
                                                  //                     .primaryColor))
                                                  //         : Text(''),
                                                  //   ],
                                                  // ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor)),
                                                  margin:
                                                      EdgeInsets.all(width * 4),
                                                  padding:
                                                      EdgeInsets.all(width * 4),
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          snapshot.data
                                                                  .docs[index]
                                                              ['option1'],
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Blinker',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  width * 5,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor)),
                                                      snapshot
                                                              .data
                                                              .docs[index][
                                                                  'userswhovoted']
                                                              .contains(widget
                                                                  .currentuserid)
                                                          ? Text(
                                                              o1percent
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%'
                                                              // snapshot
                                                              //     .data.docs[index]['o1']
                                                              ,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Blinker',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      width * 5,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor))
                                                          : Text(''),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                              margin: EdgeInsets.all(width * 4),
                                              padding:
                                                  EdgeInsets.all(width * 4),
                                              alignment: Alignment.topLeft,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      snapshot.data.docs[index]
                                                          ['option1'],
                                                      style: TextStyle(
                                                          fontFamily: 'Blinker',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: width * 5,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor)),
                                                  snapshot
                                                          .data
                                                          .docs[index]
                                                              ['userswhovoted']
                                                          .contains(widget
                                                              .currentuserid)
                                                      ? Text(
                                                          o1percent
                                                                  .toStringAsFixed(
                                                                      0) +
                                                              '%'
                                                          // snapshot
                                                          //     .data.docs[index]['o1']
                                                          ,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Blinker',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  width * 5,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor))
                                                      : Text(''),
                                                ],
                                              ),
                                            ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        updatevote2(
                                            snapshot.data.docs[index]['docid']);
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: snapshot
                                              .data.docs[index]['userswhovoted']
                                              .contains(widget.currentuserid)
                                          ? Stack(
                                              children: [
                                                Container(
                                                  width: width * o2percent,
                                                  height: width * 14.5,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(.3),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                    // border: Border.all(
                                                    //     color: Theme.of(context)
                                                    //         .primaryColor)
                                                  ),
                                                  margin:
                                                      EdgeInsets.all(width * 4),
                                                  padding:
                                                      EdgeInsets.all(width * 5),
                                                  alignment: Alignment.topLeft,
                                                  // child: Row(
                                                  //   mainAxisAlignment:
                                                  //       MainAxisAlignment.spaceBetween,
                                                  //   children: [
                                                  //     Text(
                                                  //         snapshot.data.docs[index]
                                                  //             ['option1'],
                                                  //         style: TextStyle(
                                                  //             fontFamily: 'Blinker',
                                                  //             fontWeight: FontWeight.bold,
                                                  //             fontSize: width * 5,
                                                  //             color: Theme.of(context)
                                                  //                 .primaryColor)),
                                                  //     snapshot.data
                                                  //             .docs[index]['userswhovoted']
                                                  //             .contains(
                                                  //                 widget.currentuserid)
                                                  //         ? Text(
                                                  //             o1percent.toStringAsFixed(0) + '%'
                                                  //                 // snapshot
                                                  //                 //     .data.docs[index]['o1']
                                                  //                 ,
                                                  //             style: TextStyle(
                                                  //                 fontFamily: 'Blinker',
                                                  //                 fontWeight:
                                                  //                     FontWeight.bold,
                                                  //                 fontSize: width * 5,
                                                  //                 color: Theme.of(context)
                                                  //                     .primaryColor))
                                                  //         : Text(''),
                                                  //   ],
                                                  // ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor)),
                                                  margin:
                                                      EdgeInsets.all(width * 4),
                                                  padding:
                                                      EdgeInsets.all(width * 4),
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          snapshot.data
                                                                  .docs[index]
                                                              ['option2'],
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Blinker',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  width * 5,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor)),
                                                      snapshot
                                                              .data
                                                              .docs[index][
                                                                  'userswhovoted']
                                                              .contains(widget
                                                                  .currentuserid)
                                                          ? Text(
                                                              o2percent
                                                                      .toStringAsFixed(
                                                                          0) +
                                                                  '%'
                                                              // snapshot
                                                              //     .data.docs[index]['o1']
                                                              ,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Blinker',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      width * 5,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor))
                                                          : Text(''),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                              margin: EdgeInsets.all(width * 4),
                                              padding:
                                                  EdgeInsets.all(width * 4),
                                              alignment: Alignment.topLeft,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      snapshot.data.docs[index]
                                                          ['option2'],
                                                      style: TextStyle(
                                                          fontFamily: 'Blinker',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: width * 5,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor)),
                                                  snapshot
                                                          .data
                                                          .docs[index]
                                                              ['userswhovoted']
                                                          .contains(widget
                                                              .currentuserid)
                                                      ? Text(
                                                          o2percent
                                                                  .toStringAsFixed(
                                                                      0) +
                                                              '%'
                                                          // snapshot
                                                          //     .data.docs[index]['o1']
                                                          ,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Blinker',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  width * 5,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor))
                                                      : Text(''),
                                                ],
                                              ),
                                            ),
                                    ),
                                    snapshot.data.docs[index]['option3'] == ''
                                        ? Container()
                                        : InkWell(
                                            onTap: () {
                                              updatevote3(snapshot
                                                  .data.docs[index]['docid']);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: snapshot
                                                    .data
                                                    .docs[index]
                                                        ['userswhovoted']
                                                    .contains(
                                                        widget.currentuserid)
                                                ? Stack(
                                                    children: [
                                                      Container(
                                                        width:
                                                            width * o3percent,
                                                        height: width * 14.5,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor
                                                              .withOpacity(.3),
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                          // border: Border.all(
                                                          //     color: Theme.of(context)
                                                          //         .primaryColor)
                                                        ),
                                                        margin: EdgeInsets.all(
                                                            width * 4),
                                                        padding: EdgeInsets.all(
                                                            width * 5),
                                                        alignment:
                                                            Alignment.topLeft,
                                                        // child: Row(
                                                        //   mainAxisAlignment:
                                                        //       MainAxisAlignment.spaceBetween,
                                                        //   children: [
                                                        //     Text(
                                                        //         snapshot.data.docs[index]
                                                        //             ['option1'],
                                                        //         style: TextStyle(
                                                        //             fontFamily: 'Blinker',
                                                        //             fontWeight: FontWeight.bold,
                                                        //             fontSize: width * 5,
                                                        //             color: Theme.of(context)
                                                        //                 .primaryColor)),
                                                        //     snapshot.data
                                                        //             .docs[index]['userswhovoted']
                                                        //             .contains(
                                                        //                 widget.currentuserid)
                                                        //         ? Text(
                                                        //             o1percent.toStringAsFixed(0) + '%'
                                                        //                 // snapshot
                                                        //                 //     .data.docs[index]['o1']
                                                        //                 ,
                                                        //             style: TextStyle(
                                                        //                 fontFamily: 'Blinker',
                                                        //                 fontWeight:
                                                        //                     FontWeight.bold,
                                                        //                 fontSize: width * 5,
                                                        //                 color: Theme.of(context)
                                                        //                     .primaryColor))
                                                        //         : Text(''),
                                                        //   ],
                                                        // ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor)),
                                                        margin: EdgeInsets.all(
                                                            width * 4),
                                                        padding: EdgeInsets.all(
                                                            width * 4),
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                snapshot.data
                                                                            .docs[
                                                                        index]
                                                                    ['option3'],
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Blinker',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        width *
                                                                            5,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor)),
                                                            snapshot
                                                                    .data
                                                                    .docs[index]
                                                                        [
                                                                        'userswhovoted']
                                                                    .contains(widget
                                                                        .currentuserid)
                                                                ? Text(
                                                                    o3percent
                                                                            .toStringAsFixed(
                                                                                0) +
                                                                        '%'
                                                                    // snapshot
                                                                    //     .data.docs[index]['o1']
                                                                    ,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Blinker',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            width *
                                                                                5,
                                                                        color: Theme.of(context)
                                                                            .primaryColor))
                                                                : Text(''),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor)),
                                                    margin: EdgeInsets.all(
                                                        width * 4),
                                                    padding: EdgeInsets.all(
                                                        width * 4),
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            snapshot.data.docs[
                                                                    index]
                                                                ['option3'],
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Blinker',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    width * 5,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor)),
                                                        snapshot
                                                                .data
                                                                .docs[index][
                                                                    'userswhovoted']
                                                                .contains(widget
                                                                    .currentuserid)
                                                            ? Text(
                                                                o3percent
                                                                        .toStringAsFixed(
                                                                            0) +
                                                                    '%'
                                                                // snapshot
                                                                //     .data.docs[index]['o1']
                                                                ,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Blinker',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        width *
                                                                            5,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor))
                                                            : Text(''),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                    snapshot.data.docs[index]['option4'] == ''
                                        ? Container()
                                        : InkWell(
                                            onTap: () {
                                              updatevote4(snapshot
                                                  .data.docs[index]['docid']);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: snapshot
                                                    .data
                                                    .docs[index]
                                                        ['userswhovoted']
                                                    .contains(
                                                        widget.currentuserid)
                                                ? Stack(
                                                    children: [
                                                      Container(
                                                        width:
                                                            width * o4percent,
                                                        height: width * 14.5,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor
                                                              .withOpacity(.3),
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                          // border: Border.all(
                                                          //     color: Theme.of(context)
                                                          //         .primaryColor)
                                                        ),
                                                        margin: EdgeInsets.all(
                                                            width * 4),
                                                        padding: EdgeInsets.all(
                                                            width * 5),
                                                        alignment:
                                                            Alignment.topLeft,
                                                        // child: Row(
                                                        //   mainAxisAlignment:
                                                        //       MainAxisAlignment.spaceBetween,
                                                        //   children: [
                                                        //     Text(
                                                        //         snapshot.data.docs[index]
                                                        //             ['option1'],
                                                        //         style: TextStyle(
                                                        //             fontFamily: 'Blinker',
                                                        //             fontWeight: FontWeight.bold,
                                                        //             fontSize: width * 5,
                                                        //             color: Theme.of(context)
                                                        //                 .primaryColor)),
                                                        //     snapshot.data
                                                        //             .docs[index]['userswhovoted']
                                                        //             .contains(
                                                        //                 widget.currentuserid)
                                                        //         ? Text(
                                                        //             o1percent.toStringAsFixed(0) + '%'
                                                        //                 // snapshot
                                                        //                 //     .data.docs[index]['o1']
                                                        //                 ,
                                                        //             style: TextStyle(
                                                        //                 fontFamily: 'Blinker',
                                                        //                 fontWeight:
                                                        //                     FontWeight.bold,
                                                        //                 fontSize: width * 5,
                                                        //                 color: Theme.of(context)
                                                        //                     .primaryColor))
                                                        //         : Text(''),
                                                        //   ],
                                                        // ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor)),
                                                        margin: EdgeInsets.all(
                                                            width * 4),
                                                        padding: EdgeInsets.all(
                                                            width * 4),
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                                snapshot.data
                                                                            .docs[
                                                                        index]
                                                                    ['option4'],
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Blinker',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        width *
                                                                            5,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor)),
                                                            snapshot
                                                                    .data
                                                                    .docs[index]
                                                                        [
                                                                        'userswhovoted']
                                                                    .contains(widget
                                                                        .currentuserid)
                                                                ? Text(
                                                                    o4percent
                                                                            .toStringAsFixed(
                                                                                0) +
                                                                        '%'
                                                                    // snapshot
                                                                    //     .data.docs[index]['o1']
                                                                    ,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Blinker',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            width *
                                                                                5,
                                                                        color: Theme.of(context)
                                                                            .primaryColor))
                                                                : Text(''),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor)),
                                                    margin: EdgeInsets.all(
                                                        width * 4),
                                                    padding: EdgeInsets.all(
                                                        width * 4),
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            snapshot.data.docs[
                                                                    index]
                                                                ['option4'],
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Blinker',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    width * 5,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor)),
                                                        snapshot
                                                                .data
                                                                .docs[index][
                                                                    'userswhovoted']
                                                                .contains(widget
                                                                    .currentuserid)
                                                            ? Text(
                                                                o4percent
                                                                        .toStringAsFixed(
                                                                            0) +
                                                                    '%'
                                                                // snapshot
                                                                //     .data.docs[index]['o1']
                                                                ,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Blinker',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        width *
                                                                            5,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor))
                                                            : Text(''),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.reply_all_outlined,
                                          size: 30,
                                          color: corecolor,
                                        ),
                                        onPressed: () {
                                          Fluttertoast.showToast(
                                              msg: 'Preparing for sharing...',
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor);
                                          // sharepost();
                                          ShareFilesAndScreenshotWidgets()
                                              .shareScreenshot(
                                                  previewContainer,
                                                  originalSize,
                                                  'orion share',
                                                  'orion_share.png',
                                                  'image/png',
                                                  text:
                                                      'Here is my poll results on orion. Use code $code while signing up and gain 25 karma. Install the app now. https://play.google.com/store/apps/details?id=com.getorionapp.orion');
                                        }),
                                    Divider(),
                                    // Padding(
                                    //   padding: EdgeInsets.all(width * 4),
                                    //   child: LinearPercentIndicator(
                                    //     lineHeight: width * 10,
                                    //     percent: .8,
                                    //   ),
                                    // ),
                                  ],
                                ));
                      },
                    );
                  }),
            ),
            Container(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.currentuserid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SpinKitCircle(
                        color: corecolor,
                      );
                    } else if (snapshot.data['showupdate'] == true) {
                      return AlertDialog(
                          actions: [
                            FlatButton(
                                onPressed: () {
                                  StoreRedirect.redirect(
                                      androidAppId: 'com.getorionapp.orion');
                                },
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                      fontFamily: 'Righteous',
                                      fontSize: width * 4),
                                )),
                            FlatButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.currentuserid)
                                      .update({'showupdate': false});
                                },
                                child: Text(
                                  'Ignore',
                                  style: TextStyle(
                                      fontFamily: 'Righteous',
                                      fontSize: width * 4),
                                )),
                          ],
                          title: Text(
                            'Update available',
                            style: TextStyle(
                                fontFamily: 'Righteous',
                                fontSize: width * 5,
                                color: Colors.blueGrey),
                          ),
                          content:
                              Text('Update your app. Ignore if done already'));
                    } else {
                      return Container();
                    }
                  }),
            ),
            Positioned(
              bottom: width * 5,
              left: width * 80,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              // AddPoll(widget.currentuserid)
                              AddPost(widget.currentuserid)));
                },
                child: Card(
                  shape: CircleBorder(),
                  elevation: 5,
                  shadowColor: Theme.of(context).primaryColor,
                  child: Container(
                    height: width * 15,
                    width: width * 15,
                    child: Icon(
                      Icons.add,
                      size: width * 10,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  updatevote(docid) {
    Future<DocumentSnapshot> ds =
        FirebaseFirestore.instance.collection('posts').doc(docid).get();

    ds.then((value) {
      List votedusers = value.data()['userswhovoted'];

      if (!votedusers.contains(widget.currentuserid)) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(docid)
            .update({'o1': FieldValue.increment(1)});

        FirebaseFirestore.instance.collection('posts').doc(docid).update({
          'userswhovoted': FieldValue.arrayUnion([widget.currentuserid])
        });
      }
    });
  }

  updatevote2(docid) {
    Future<DocumentSnapshot> ds =
        FirebaseFirestore.instance.collection('posts').doc(docid).get();

    ds.then((value) {
      List votedusers = value.data()['userswhovoted'];

      if (!votedusers.contains(widget.currentuserid)) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(docid)
            .update({'o2': FieldValue.increment(1)});

        FirebaseFirestore.instance.collection('posts').doc(docid).update({
          'userswhovoted': FieldValue.arrayUnion([widget.currentuserid])
        });
      }
    });
  }

  updatevote3(docid) {
    Future<DocumentSnapshot> ds =
        FirebaseFirestore.instance.collection('posts').doc(docid).get();

    ds.then((value) {
      List votedusers = value.data()['userswhovoted'];

      if (!votedusers.contains(widget.currentuserid)) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(docid)
            .update({'o3': FieldValue.increment(1)});

        FirebaseFirestore.instance.collection('posts').doc(docid).update({
          'userswhovoted': FieldValue.arrayUnion([widget.currentuserid])
        });
      }
    });
  }

  updatevote4(docid) {
    Future<DocumentSnapshot> ds =
        FirebaseFirestore.instance.collection('posts').doc(docid).get();

    ds.then((value) {
      List votedusers = value.data()['userswhovoted'];

      if (!votedusers.contains(widget.currentuserid)) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(docid)
            .update({'o4': FieldValue.increment(1)});

        FirebaseFirestore.instance.collection('posts').doc(docid).update({
          'userswhovoted': FieldValue.arrayUnion([widget.currentuserid])
        });
      }
    });
  }
}
