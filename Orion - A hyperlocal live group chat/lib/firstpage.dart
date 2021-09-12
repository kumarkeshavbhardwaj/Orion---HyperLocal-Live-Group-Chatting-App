import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orion/dob.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstPage extends StatefulWidget {
  final String currentuserid;
  FirstPage(this.currentuserid);
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final TextEditingController inv = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  String ic = '';
  String invcode = '';

  String codedocid = '';

  bool loader = false;

  managecode() {
    // Timer(Duration(seconds: 1), verify);
    print('method init');
    // showcircular = true;
    Future<QuerySnapshot> handler = FirebaseFirestore.instance
        .collection('codes')
        .where('code', isEqualTo: inv.text.trim().toUpperCase())
        .limit(1)
        .get();

    print('you said' + inv.text.trim().toUpperCase());

    handler.then((value) {
      print('val is $value');
      print('method reached1 code');
      value.docs.forEach((element) {
        print('each val is $element');
        ic = element['code'];
        codedocid = element['id'];

        print('ic is $ic');
      });
    }).then((value) {
      verify();
    });
  }

  verify() {
    setState(() {
      loader = false;
    });
    print('verify init');
    if (ic == inv.text.trim().toUpperCase()) {
      print('invited');

      print(inv.text.trim());
      proceed();
    } else {
      print(inv.text.trim());

      unav();
      print('uninvited out');
    }
  }

  unav() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Okay',
                      style: TextStyle(fontFamily: 'Righteous'),
                    ))
              ],
              title: Text(
                'Wrong Invitation Code. You are not invited. Ask your friends to invite.',
                style: TextStyle(fontFamily: 'Blinker'),
              ),
            ));
  }

  proceed() {
    print('final set reached');
    FirebaseFirestore.instance.collection('codes').doc(codedocid).update({
      'joined': FieldValue.increment(1),
      // 'querysearch': setSearchParam(handleC.text.trim()),
    }).then((value) async {
    
      FirebaseFirestore.instance
          .collection('users')
          .doc(codedocid)
          .update({'karma': FieldValue.increment(25), 'invited' : FieldValue.increment(1)}).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentuserid)
            .update({'karma': FieldValue.increment(25)});
      });

      Fluttertoast.showToast(
          msg: 'Both of you gained 25 Karma for being invited',
          backgroundColor: Theme.of(context).primaryColor);
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('fp', inv.text.trim());
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DOB(widget.currentuserid)),
          (Route<dynamic> route) => false);

      // Navigator.push(context,
      //     MaterialPageRoute(builder: (c) => Intro()));
      // print('final done');
    });
    // FirebaseFirestore.instance
    //     .collection('handles')
    //     .doc()
    //     .set({'handle': handleC.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 100;
    final width = MediaQuery.of(context).size.width / 100;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Invitation Code',
          style: TextStyle(
            fontFamily: 'Blinker',
          ),
        ),
      ),
      body: Form(
        key: _formkey,
        child: Stack(
          children: [
            loader
                ? SpinKitCircle(
                    color: Theme.of(context).primaryColor,
                    size: width * 20,
                  )
                : Container(),
            Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Type your Invitation Code',
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        color: Theme.of(context).primaryColor,
                        fontSize: width*5),
                  ),
                ),
                Container(
                    width: width * 60,
                    child: TextFormField(
                      controller: inv,
                      validator: (v) {
                        if (v.trim().isEmpty || v.trim() == '') {
                          return 'You need to be invited by your friends. Contact your friends.';
                        }
                      },
                      autofocus: true,
                      textAlign: TextAlign.center,
                      cursorColor: Theme.of(context).primaryColor,
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: width*5),
                      decoration: InputDecoration(),
                    )),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(width * 8),
                  child: Text(
                    'Don\'t have invitation code, Ask your friends to invite you or We will send you the invitation code when we will see enough demand from your College/School. Write to us kumarkeshavbhardwaj@gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: width*5),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90)),
                  elevation: 20,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(90),
                    onTap: () async {
                      if (await ConnectivityWrapper.instance.isConnected) {
                        if (_formkey.currentState.validate()) {
                          setState(() {
                            loader = true;
                          });
                          managecode();
                          // Navigator.pushAndRemoveUntil(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (BuildContext context) =>
                          //             DOB(widget.currentuserid)),
                          //     (Route<dynamic> route) => false);
                        }
                        // signin();
                      } else {
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
                                  'Internet is required to be on orion :)',
                                  style: TextStyle(
                                    fontFamily: 'Righteous',
                                  ),
                                ),
                              );
                            });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: height * 6,
                      width: width * 90,
                      child: Text(
                        'Next',
                        style: TextStyle(
                            fontFamily: 'Blinker',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: width * 5),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(90),
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
