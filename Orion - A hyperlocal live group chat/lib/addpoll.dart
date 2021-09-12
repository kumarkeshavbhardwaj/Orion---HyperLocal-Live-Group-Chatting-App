import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPoll extends StatefulWidget {
  final String currentuserid;
  AddPoll(this.currentuserid);
  @override
  _AddPollState createState() => _AddPollState();
}

class _AddPollState extends State<AddPoll> {
  final TextEditingController qC = TextEditingController();
  final TextEditingController o1 = TextEditingController();

  final TextEditingController o2 = TextEditingController();

  final TextEditingController o3 = TextEditingController();

  final TextEditingController o4 = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  final _formkey1 = GlobalKey<FormState>();

  final _formkey2 = GlobalKey<FormState>();

  final _formkey3 = GlobalKey<FormState>();

  final _formkey4 = GlobalKey<FormState>();

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

  submitpoll(poster) {
    String docid = FirebaseFirestore.instance.collection('posts').doc().id;
    FirebaseFirestore.instance.collection('posts').doc(docid).set({
      'post': '',
      'poll': true,
      'commentlength': 0,
      'posterid': widget.currentuserid,
      'upvotedby': [],
      'downvotedby': [],
      'token': '',
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
//experimental
      'o1': 0,
      'o2': 0,
      'o3': 0,
      'o4': 0,
      'question': qC.text,
      'option1': o1.text,
      'option2': o2.text,
      'option3': o3.text,
      'option4': o4.text,
      'userswhovoted': [],

      // 'userswhovoted': {},
    }).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentuserid)
          .update({'polls': FieldValue.increment(1)});
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentuserid)
          .update({'karma': FieldValue.increment(1)}).then((value) {
        setState(() {
          loader = false;
        });
        Fluttertoast.showToast(
            msg: 'Polled Successfully',
            backgroundColor: Theme.of(context).primaryColor);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      });
    });
  }

  showoption1() {
    final unit = MediaQuery.of(context).size.width / 100;
    return showDialog(
        context: context,
        builder: (c) => Form(
              key: _formkey1,
              child: AlertDialog(
                title: Text('Option1'),
                content: TextFormField(autofocus: true,
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.black,
                      fontSize: unit * 5),
                  validator: (v1) {
                    if (v1.trim().isEmpty) {
                      return 'Cannot be empty';
                    }
                  },
                  controller: o1,
                  decoration: InputDecoration(),
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        if (_formkey1.currentState.validate()) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Done'))
                ],
              ),
            ));
  }

  showoption2() {
    final unit = MediaQuery.of(context).size.width / 100;

    return showDialog(
        context: context,
        builder: (c) => Form(
              key: _formkey2,
              child: AlertDialog(
                title: Text('Option2'),
                content: TextFormField(autofocus: true,
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.black,
                      fontSize: unit * 5),
                  validator: (v) {
                    if (v.trim().isEmpty) {
                      return 'Cannot be empty';
                    }
                  },
                  controller: o2,
                  decoration: InputDecoration(),
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        if (_formkey2.currentState.validate()) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Done'))
                ],
              ),
            ));
  }

  showoption3() {
    final unit = MediaQuery.of(context).size.width / 100;

    return showDialog(
        context: context,
        builder: (c) => Form(
              key: _formkey3,
              child: AlertDialog(
                title: Text('Option3'),
                content: TextFormField(autofocus: true,
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.black,
                      fontSize: unit * 5),
                  validator: (v) {
                    if (v.trim().isEmpty) {
                      return 'Cannot be empty';
                    }
                  },
                  controller: o3,
                  decoration: InputDecoration(),
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        if (_formkey3.currentState.validate()) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Done'))
                ],
              ),
            ));
  }

  showoption4() {
    final unit = MediaQuery.of(context).size.width / 100;

    return showDialog(
        context: context,
        builder: (c) => Form(
              key: _formkey4,
              child: AlertDialog(
                title: Text('Option4'),
                content: TextFormField(autofocus: true,
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.black,
                      fontSize: unit * 5),
                  validator: (v) {
                    if (v.trim().isEmpty) {
                      return 'Cannot be empty';
                    }
                  },
                  controller: o4,
                  decoration: InputDecoration(),
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        if (_formkey4.currentState.validate()) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Done'))
                ],
              ),
            ));
  }

  bool option3 = false;
  bool option4 = false;
  @override
  Widget build(BuildContext context) {
    var unit = MediaQuery.of(context).size.width / 100;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                if (_formkey.currentState.validate()) {
                    if (o1.text.trim().isNotEmpty) {
                      if (o2.text.trim().isNotEmpty) {
                        postdialog();
                      } else {
                        odialog();
                      }
                    } else {
                      odialog();
                    }
                  }
              })
        ],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Create a Poll',
          style: TextStyle(fontFamily: 'Blinker'),
        ),
      ),
      body: Form(
        key: _formkey,
        child: Container(
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.only(
                      right: unit * 5, left: unit * 5, top: unit * 2),
                  padding: EdgeInsets.all(unit * 3),
                  // height: unit * 50,
                  child: TextFormField(
                    validator: (v) {
                      if (v.trim().isEmpty) {
                        return 'Question cannot be empty';
                      }
                    },
                    controller: qC,
                    // maxLines: null,
                    maxLength: 200,
                    style: TextStyle(
                      fontFamily: 'Blinker',
                      fontWeight: FontWeight.bold,
                      fontSize: unit * 5,
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type your question',
                        hintStyle: TextStyle(fontFamily: 'Blinker')),
                  )),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (option3 == false) {
                    setState(() {
                      option3 = true;
                    });
                  } else if (option4 == false) {
                    setState(() {
                      option4 = true;
                    });
                  } else {
                    Fluttertoast.showToast(msg: 'No More Options');
                  }
                },
                child: Container(
                    height: unit * 10,
                    alignment: Alignment.center,
                    width: unit * 80,
                    margin: EdgeInsets.only(
                        top: unit * 2, right: unit * 5, left: unit * 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor),
                    child: Text(
                      'Click to Add More Options',
                      style: TextStyle(
                        fontFamily: 'Blinker',
                        color: Colors.white,
                      ),
                    )),
              ),
              SizedBox(height: unit * 3),
              InkWell(
                onTap: () {
                  showoption1();
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Option 1',
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: unit * 5)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: unit * 10,
                  width: unit * 60,
                ),
              ),
              SizedBox(height: unit * 3),
              InkWell(
                onTap: () {
                  showoption2();
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Option 2',
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: unit * 5)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: unit * 10,
                  width: unit * 60,
                ),
              ),
              SizedBox(height: unit * 3),
              option3
                  ? InkWell(
                      onTap: () {
                        showoption3();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text('Option 3',
                            style: TextStyle(
                                fontFamily: 'Blinker',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: unit * 5)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: unit * 10,
                        width: unit * 60,
                      ),
                    )
                  : Container(),
              SizedBox(height: unit * 3),
              option4
                  ? InkWell(
                      onTap: () {
                        showoption4();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text('Option 4',
                            style: TextStyle(
                                fontFamily: 'Blinker',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: unit * 5)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: unit * 10,
                        width: unit * 60,
                      ),
                    )
                  : Container(),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (_formkey.currentState.validate()) {
                    if (o1.text.trim().isNotEmpty) {
                      if (o2.text.trim().isNotEmpty) {
                        postdialog();
                      } else {
                        odialog();
                      }
                    } else {
                      odialog();
                    }
                  }
                },
                child: Container(
                    height: unit * 10,
                    alignment: Alignment.center,
                    width: unit * 80,
                    margin: EdgeInsets.only(
                        top: unit * 2, right: unit * 5, left: unit * 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
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
                          submitpoll('Anonymous');
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
                      child: Text('Poll as Anonymous',
                          style: TextStyle(
                              fontFamily: 'Blinker',
                              fontWeight: FontWeight.bold,
                              fontSize: width * 5)),
                    ),
                    SimpleDialogOption(
                      onPressed: () async {
                        if (await ConnectivityWrapper.instance.isConnected) {
                          submitpoll('$handle');
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
                      child: Text('Poll as $handle',
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

  odialog() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              content: Text('2 options are mandatory'),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Okay'))
              ],
            ));
  }
}
