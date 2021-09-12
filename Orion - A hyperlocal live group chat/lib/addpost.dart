import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orion/addpoll.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPost extends StatefulWidget {
  final String currentuserid;
  AddPost(this.currentuserid);
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _formkey = GlobalKey<FormState>();

  final TextEditingController pC = TextEditingController();
  String handle = '';
  String photo = '';
  String token = '';
  bool loader = false;
  @override
  void initState() {
    super.initState();
    read();
  }

  read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      handle = prefs.getString('handle' ?? 'Anonymous');
      photo = prefs.getString('photo');
      token = prefs.getString('FCMtoken' ?? '');
    });
  }

  postupload(String poster) {
    setState(() {
      loader = true;
    });
    String docid = FirebaseFirestore.instance.collection('posts').doc().id;
    FirebaseFirestore.instance.collection('posts').doc(docid).set({
      'post': pC.text,
      'commentlength': 0,
      'poll': false,
      'posterid': widget.currentuserid,
      'upvotedby': [],
      'downvotedby': [],
      'token': token,
      'notif': true,
      'docid': docid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'poster': poster,
      'photo': poster == 'Anonymous'
          ? 'https://image.flaticon.com/icons/png/512/149/149071.png'
          : photo,
      'upvotes': 0,
      'downvotes': 0,
      'reported': false,
    }).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentuserid)
          .update({'posts': FieldValue.increment(1)});
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentuserid)
          .update({'karma': FieldValue.increment(1)}).then((value) {
        setState(() {
          loader = false;
        });
        Fluttertoast.showToast(
            msg: 'Posted Successfully',
            backgroundColor: Theme.of(context).primaryColor);
        Navigator.pop(context);
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width / 100;
    var height = MediaQuery.of(context).size.height / 100;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Poll / Post',
          style: TextStyle(fontFamily: 'Blinker'),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      // title: Text('Post', style: TextStyle(fontFamily: 'Blinker'),),),
      body: Form(
        key: _formkey,
        child: Stack(
          children: [
            loader
                ? SpinKitCircle(
                    color: Theme.of(context).primaryColor,
                    size: width * 10,
                  )
                : Container(),
            Container(
              padding: EdgeInsets.all(width * 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => AddPoll(widget.currentuserid)));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('Create a Poll',
                          style: TextStyle(
                            fontFamily: 'Blinker',
                            fontSize: width * 5,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  Center(
                    child: Text('or',
                        style: TextStyle(
                          fontFamily: 'Blinker',
                          fontSize: width * 5,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                  // SizedBox(height: height * 3),
                  Container(
                    padding: EdgeInsets.all(width * 2),
                    height: height * 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: width * .5)),
                    child: TextFormField(
                      validator: (v) {
                        if (v.trim().isEmpty) {
                          return 'Please write something';
                        }
                      },
                      controller: pC,
                      maxLines: null,
                      maxLength: 250,
                      autofocus: true,
                      cursorColor: Theme.of(context).primaryColor,
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          fontSize: width * 5),
                      decoration: InputDecoration(
                          hintText: 'Write your post',
                          border: InputBorder.none),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      if (_formkey.currentState.validate()) {
                        postdialog();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          color: Theme.of(context).primaryColor),
                      width: width * 100,
                      height: height * 5,
                      child: Text(
                        'Post',
                        style: TextStyle(
                            fontFamily: 'Blinker',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: width * 4),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: width * 2, top: height * 3),
                    child: Text(
                      'Anonymous post with 5 Downvotes will be deleted automatically. Do not post anything offensive otherwise your account will be banned.',
                      style: TextStyle(
                          fontFamily: 'Blinker', fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  postdialog() {
    var width = MediaQuery.of(context).size.width / 100;
    var height = MediaQuery.of(context).size.height / 100;
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              content: Container(
                height: height * 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleDialogOption(
                      onPressed: () async {
                        if (await ConnectivityWrapper.instance.isConnected) {
                          postupload('Anonymous');
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
                      },
                      child: Text('Post as Anonymous',
                          style: TextStyle(
                              fontFamily: 'Blinker',
                              fontWeight: FontWeight.bold,
                              fontSize: width * 5)),
                    ),
                    SimpleDialogOption(
                      onPressed: () async {
                        if (await ConnectivityWrapper.instance.isConnected) {
                          postupload('$handle');
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
                      },
                      child: Text('Post as $handle',
                          style: TextStyle(
                              fontFamily: 'Blinker',
                              fontWeight: FontWeight.bold,
                              fontSize: width * 5)),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel',
                          style: TextStyle(
                              fontFamily: 'Blinker',
                              fontWeight: FontWeight.bold,
                              fontSize: width * 5)),
                    )
                  ],
                ),
              ),
            ));
  }
}
