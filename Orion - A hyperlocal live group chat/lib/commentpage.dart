import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orion/notificationcontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as tago;

class CommentPage extends StatefulWidget {
  final String currentuserid;
  final String posterid;
  final String docid;
  final String post;
  final int time;
  CommentPage(
      this.docid, this.post, this.time, this.posterid, this.currentuserid);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _formkey = GlobalKey<FormState>();

  bool notifstatus = true;

  String id = '';
  String photo = '';
  String handle = '';
  String peertoken = '';
  final TextEditingController tc = TextEditingController();

  @override
  void initState() {
    super.initState();
    readmydata();
    getnotifstatus();
  }

  getnotifstatus() {
    Future<DocumentSnapshot> ds =
        FirebaseFirestore.instance.collection('posts').doc(widget.docid).get();

    ds.then((value) {
      setState(() {
        notifstatus = value.data()['notif'];
        peertoken = value.data()['token'];
      });
    });
  }

  readmydata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      photo = prefs.getString('photo');
      id = prefs.getString('id');
      handle = prefs.getString('handle');
    });
  }

  togglenotif() {
    if (notifstatus == true) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.docid)
          .update({'notif': false}).then((value) {
        Fluttertoast.showToast(msg: 'Notifications are off');
      }).then((value) {
        setState(() {
          notifstatus = false;
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.docid)
          .update({'notif': true}).then((value) {
        Fluttertoast.showToast(msg: 'Notifications are on');
      }).then((value) {
        setState(() {
          notifstatus = true;
        });
      });
    }
  }

  addcomment(String comment) {
    getnotifstatus();
    String commentdocid = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.docid)
        .collection('comments')
        .doc()
        .id;

    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.docid)
        .collection('comments')
        .doc(commentdocid)
        .set({
      // 'notif': true,
      'comment': comment,
      'username': handle,
      'id': id,
      'docid': commentdocid,
      'photo': photo,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    }).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentuserid)
          .update({'comments': FieldValue.increment(1)});
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.docid)
          .update({'commentlength': FieldValue.increment(1)});

      if (widget.posterid != widget.currentuserid) {
        notifstatus == true
            ? NotificationController.instance
                .commentnotification('$handle', tc.text, peertoken)
            : NotificationController.instance
                .commentnotification('$handle', tc.text, '');

        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.posterid)
            .update({'karma': FieldValue.increment(5)});
      }

      tc.clear();
    });
  }

  Widget buildInput() {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    var corecolor = Color.fromRGBO(252, 90, 39, 1);

    return Form(
      key: _formkey,
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          child: Row(
            children: [
              // SizedBox(
              //   width: width * 2,
              // ),
              Container(
                padding: EdgeInsets.only(left: width * 4, right: width * 4),
                // color: Colors.blue,
                height: height * 13,
                width: width * 80,
                alignment: Alignment.center,
                child: TextFormField(
                  controller: tc,
                  validator: (v) {
                    if (v.trim().isEmpty || v.trim() == '') {
                      Fluttertoast.showToast(msg: 'Nothing to send');
                      return '';
                    }
                  },
                  // focusNode: focusnode,
                  // controller: msgC,
                  cursorColor: Colors.black,
                  style: TextStyle(
                    fontFamily: 'Blinker',
                    fontSize: width * 5,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '      Type a message',
                      hintStyle: TextStyle(
                        color: Colors.black26,
                        fontFamily: 'Blinker',
                        fontSize: width * 5,
                      )),
                ),
              ),
              SizedBox(
                width: width * 4,
              ),
              // InkWell(
              //   onTap: () async {
              //     if (msgC.text.trim() == '') {
              //       return null;
              //     } else {
              //       if (await ConnectivityWrapper.instance.isConnected) {
              //         // onSendMessage(msgC.text, 0);
              //         // msgC.clear();
              //       } else {
              //         showDialog(
              //             barrierDismissible: false,
              //             context: context,
              //             builder: (context) {
              //               return AlertDialog(
              //                 title: Text(
              //                   'No Internet',
              //                   style: TextStyle(
              //                     fontFamily: 'Blinker',
              //                   ),
              //                 ),
              //                 content: Text(
              //                   'Internet is required to be on orion :)',
              //                   style: TextStyle(
              //                     fontFamily: 'Blinker',
              //                   ),
              //                 ),
              //               );
              //             });
              //       }
              //     }
              //   },
              //   child: Icon(
              //     Icons.send,
              //     color: corecolor,
              //     size: width * 8,
              //   ),
              // ),
              IconButton(
                  icon: Icon(Icons.send,
                      size: 35, color: Theme.of(context).primaryColor),
                  onPressed: () async {
                    if (await ConnectivityWrapper.instance.isConnected) {
                      if (_formkey.currentState.validate()) {
                        addcomment(tc.text);
                      }
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
                    }
                  }),
              // SizedBox(
              //   width: width * 2,
              // ),
              // IconButton(
              //     icon: Icon(
              //       Icons.camera_alt_outlined,
              //       size: 35,
              //       color: Theme.of(context).primaryColor,
              //     ),
              //     onPressed: () {})

              // InkWell(
              //   onTap: () async {
              //     if (await ConnectivityWrapper.instance.isConnected) {
              //       // options();
              //     } else {
              //       showDialog(
              //           barrierDismissible: false,
              //           context: context,
              //           builder: (context) {
              //             return AlertDialog(
              //               title: Text(
              //                 'No Internet',
              //                 style: TextStyle(
              //                   fontFamily: 'Blinker',
              //                 ),
              //               ),
              //               content: Text(
              //                 'Internet is required to be on orion :)',
              //                 style: TextStyle(
              //                   fontFamily: 'Blinker',
              //                 ),
              //               ),
              //             );
              //           });
              //     }
              //   },
              //   child: Icon(
              //     Icons.camera_alt,
              //     color: corecolor,
              //     size: width * 8,
              //   ),
              // ),
            ],
          ),
          height: height * 8,
          width: width * 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.posterid);
    print(widget.currentuserid);
    var width = MediaQuery.of(context).size.width / 100;
    return Scaffold(
      appBar: AppBar(
        actions: [
          widget.posterid == widget.currentuserid
              ? IconButton(
                  icon: Icon(
                    notifstatus
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    togglenotif();
                  },
                )
              : Container()
        ],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Post',
          style: TextStyle(fontFamily: 'Blinker'),
        ),
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              widget.post,
              style: TextStyle(
                  fontFamily: 'Blinker',
                  fontSize: width * 5,
                  color: Theme.of(context).primaryColor),
            ),
          ),
          Container(
            padding: EdgeInsets.all(25),
            child: Text(
              tago.format(DateTime.fromMillisecondsSinceEpoch(widget.time)),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Blinker',
                  fontSize: width * 3,
                  color: Theme.of(context).primaryColor),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.docid)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SpinKitCircle(
                    color: Theme.of(context).primaryColor,
                    size: MediaQuery.of(context).size.width / 100 * 10,
                  );
                } else if (snapshot.data.docs.length == 0) {
                  return Center(
                    child: Text(
                      'No comments yet.',
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          fontSize: MediaQuery.of(context).size.width / 100 * 5,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (c, i) {
                    return ListTile(
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data.docs[i]['photo'])),
                      title: Text(
                        snapshot.data.docs[i]['comment'],
                        style: TextStyle(
                          fontFamily: 'Blinker',
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            snapshot.data.docs[i]['username'],
                            style: TextStyle(fontFamily: 'Blinker'),
                          ),
                          Text(
                            tago.format(DateTime.fromMillisecondsSinceEpoch(
                                snapshot.data.docs[i]['timestamp'])),
                            style: TextStyle(fontFamily: 'Blinker'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          buildInput(),
        ],
      )),
    );
  }
}
