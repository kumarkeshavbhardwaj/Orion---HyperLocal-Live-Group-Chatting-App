import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:orion/firstpage.dart';
import 'package:orion/homepage.dart';
import 'package:orion/phonesignin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';

class Signupscreen extends StatefulWidget {
  @override
  _SignupscreenState createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool loader = false;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  //  sign in function
  Future<Null> signin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    User firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      //check if already signed up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      print(documents.length);
      if (documents.length == 0) {
        //update data to server if new user

        FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
          'name': null,
          // 'code': null,
          'lastused': 1584253800000,

          'email': firebaseUser.email,
          'photo': firebaseUser.photoURL ?? '',
          'id': firebaseUser.uid,
          'createdat': DateFormat.yMEd().add_jms().format(DateTime.now()),
          'chattingwith': null,
          // 'l_chattingwith': null,
          'clickcount': 0,
          'devtoken': null,
          'incomingRequest': false,
          'invited': 0,
          'index': null,
          'dailycounts' : [],
          'polls' : 0,
          'posts' : 0,
          'comments' : 0,
          'messaged' : 0,
          // 'invited' : 0,
          'isonline': false,
          'handle': null,
          'querysearch': '',
          'karma': 0,
          'showupdate': false,
          // 'bio': null,
          'dob': null,
          'country': null,
          'countrycode': null,
          'postalcode': null,
          'adminarea': null,
          'addressline': null,
        }).then((value) {
          _firebaseMessaging.getToken().then((val) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .update({
              'devtoken': val,
            });
            preferences.setString('FCMtoken', val);
            print('Token for this user: ' + val);

            updateindex(firebaseUser.uid);
          });
        });
        await preferences.setString('id', firebaseUser.uid);
        await preferences.setString('key', firebaseUser.uid);
        await preferences.setString('name', 'okay');
        await preferences.setString('dob', 'okay');
        await preferences.setString('fp', 'okay');

        await preferences.setString('countrycode', 'Earth');
        await preferences.setString('adminarea', 'orion');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => FirstPage(
                      preferences.getString('id'),
                    )),
            (Route<dynamic> route) => false);

        Fluttertoast.showToast(msg: 'Success!');

        //write data to local
        // currentUser = firebaseUser;
        // await preferences.setString('id', currentUser.uid);
        // await preferences.setString('key', currentUser.uid);

        // await preferences.setString('nickname', currentUser.displayName);

        // await preferences.setString('photourl', currentUser.photoURL);
      } else {
        //user exists
        //write data to local
        await preferences.setString('id', documents[0].data()['id']);
        await preferences.setString('key', documents[0].data()['id']);
        await preferences.setString('name', documents[0].data()['name']);
        await preferences.setString('handle', documents[0].data()['handle']);

        await preferences.setString('fp', 'okay');
        await preferences.setString('dob', 'dob');
        await preferences.setString('photo', documents[0].data()['photo']);

        // await preferences.setString(
        //     'nickname', documents[0].data()['nickname']);

        // await preferences.setString(
        //     'photourl', documents[0].data()['photourl']);
        Fluttertoast.showToast(msg: 'Welcome Back!');
        // this.setState(() {
        //   isLoading = false;
        // });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => HomePage(
                      preferences.getString('id'),
                    )),
            (Route<dynamic> route) => false);
        // await preferences.setString('aboutme', documents[0].data()['aboutme']);
      }

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => GetInfo(
      //               preferences.getString('id'),
      //             )));
    } else {
      Fluttertoast.showToast(
          msg:
              'Sign in failed. Try again. If problem persists contact us kumarkeshavbhardwaj@gmail.com');
      // this.setState(() {
      //   isLoading = false;
      // });
    }
  }

  updateindex(String userid) async {
    print('init index');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) {
      int length = value.size - 1;
      var docref = FirebaseFirestore.instance.collection('users').doc(userid);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(docref, {'index': length});
      });
      print('index will be $length');
    });
  }

  @override
  Widget build(BuildContext context) {
    final unit = MediaQuery.of(context).size.width / 100;
    return Scaffold(
      body: Stack(
        children: [
          loader
              ? SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: MediaQuery.of(context).size.width / 100 * 20,
                )
              : Container(),
          SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: unit*5),
              Center(
                child: Text('orion',
                    style: TextStyle(
                      fontFamily: 'Righteous',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: unit * 10,
                    )),
              ),
              Text(
                'Meet people with similar interests locally',
                style: TextStyle(
                  fontFamily: 'Blinker',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                height: unit*5,
              ),
              Container(
                child: Image.asset('images/playstore.png'),
                height: unit*50,
              ),
              Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      'Post what\'s on your mind and students will comment in your location. You can post anonymously without the risk of being judged. Meet with students in your location. Chat with them. Share Views. Connect locally online. Talk on trends',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          fontSize: unit*4,
                          color: Theme.of(context).primaryColor))),
              SizedBox(
                height: unit*5,
              ),
              SignInButton(
                  buttonSize: ButtonSize.large,
                  buttonType: ButtonType.googleDark,
                  onPressed: () async {
                    Fluttertoast.showToast(
                        msg: 'Please Wait...',
                        backgroundColor: Theme.of(context).primaryColor);

                    if (await ConnectivityWrapper.instance.isConnected) {
                      setState(() {
                        loader = true;
                      });
                      signin();
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
                  }),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Container(
                    alignment: Alignment.center,
                    height: unit*13,
                    width: unit*80,
                    child: Text(
                      'Sign In with Phone',
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: unit*4),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
