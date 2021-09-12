import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'package:orion/firebasecontroller.dart';
import 'package:orion/firstpage.dart';
import 'package:orion/homepage.dart';
import 'package:orion/notificationcontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  String phoneno;
  String sms;

  bool tm = false;

  @override
  void initState() {
    super.initState();
    NotificationController.instance.takeFCMTokenWhenAppLaunch();
    NotificationController.instance.initLocalNotification();
    FirebaseController.instance.getUnreadMSGCount();
  }

  //backend logic part-----

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool isLoading = false;
  // bool isLoggedIn = false;
  // User currentUser;

  Future<void> test() async {
    preferences = await SharedPreferences.getInstance();
    loader();
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(milliseconds: 90000),
      phoneNumber: phoneno,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await firebaseAuth.signInWithCredential(credential).then((value) async {
          var userid = value.user.uid;
          //all code will go here as 1 of 2
          final QuerySnapshot result = await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: userid)
              .get();

          final List<DocumentSnapshot> documents = result.docs;
          if (documents.length == 0) {
            //user is new like completely new
            FirebaseFirestore.instance.collection('users').doc(userid).set({
              'name': null,
              'feedbackgiven': false,
              'lastused': 1584253800000,
              'showupdate': false,
              'photo': null,
              'phone': phoneno,
               'dailycounts' : [],
              //  'invited': 0,
          'polls' : 0,
          'posts' : 0,
          'comments' : 0,
          'messaged' : 0,
          'invited' : 0,
              'isverified': false,
              'logincount': 0,
              'id': userid,
              'createdat': DateFormat.yMEd().add_jms().format(DateTime.now()),
              'chattingWith': null,
              // 'l_chattingwith': null,
              // 'clickcount': 0,
              'devtoken': null,
              // 'code': null,
              'incomingRequest': false,
              'index': null,
              'isonline': false,
              'handle': null,
              'querysearch': '',
              'karma': 0,
              'bio': null,
              'dob': null,
              'country': null,
              'countrycode': 'Earth',
              'postalcode': null,
              'adminarea': 'orion',
              'addressline': null,
            }).then((value) {
              _firebaseMessaging.getToken().then((val) async {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userid)
                    .update({
                  'devtoken': val,
                });
                await preferences.setString('FCMtoken', val);
                print('Token for this user: ' + val);

                updateindex(userid);
              });
            });
            await preferences.setString('id', userid);
            await preferences.setString('key', userid);
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
            // currentUser = value.user;

          } else {
            // await preferences.setString('code', documents[0].data()['code']);
            //user is old and trying to relogin
            // await preferences.setString('code', documents[0].data()['id']);
            await preferences.setString('id', documents[0].data()['id']);
            await preferences.setString('key', documents[0].data()['id']);
            await preferences.setString('name', documents[0].data()['name']);
            await preferences.setString(
                'dob', documents[0].data()['dob'].toString());
            await preferences.setString('fp', 'okay');


            // await preferences.setString('bio', documents[0].data()['bio']);
            await preferences.setString('photo', documents[0].data()['photo']);
            await preferences.setString(
                'handle', documents[0].data()['handle']);
            await preferences.setString(
                'countrycode', documents[0].data()['countrycode']);
            await preferences.setString(
                'adminarea', documents[0].data()['adminarea']);
            await preferences.setString('interests', 'true').then((value) {
              _firebaseMessaging.getToken().then((val) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userid)
                    .update({
                  'devtoken': val,
                });
                preferences.setString('FCMtoken', val);
                print('Token for this user: ' + val);
              }).then((value) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage(
                              preferences.getString('id'),
                            )),
                    (Route<dynamic> route) => false);
              });
            });
            Fluttertoast.showToast(msg: 'Welcome Back');
          }
        });

        print('success');
      },
      verificationFailed: (FirebaseAuthException e) async {
        print('failed');
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Verification failed'),
                content: Text(
                    'Restart the app. If problem persists please write to the admin panel'),
              );
            });
      },
      codeSent: (String verificationId, int resendToken) async {
        print('code sent');

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              var width = MediaQuery.of(context).size.width / 100;

              return AlertDialog(
                title: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Auto-validating',
                          style: TextStyle(
                              fontFamily: 'Righteous', fontSize: width * 2),
                        ),
                        SpinKitCircle(
                          size: width * 4,
                          color: Color.fromRGBO(252, 90, 39, 1),
                        ),
                      ],
                    ),
                    Text(
                      'Enter OTP',
                      style: TextStyle(fontFamily: 'Righteous'),
                    ),
                  ],
                ),
                actions: [
                  FlatButton(
                      onPressed: () async {
                        loader();
                        try {
                          PhoneAuthCredential phoneAuthCredential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId, smsCode: sms);
                          await firebaseAuth
                              .signInWithCredential(phoneAuthCredential)
                              .then((value) async {
                            //all code will go here as 2 of 2

                            var userid = value.user.uid;
                            final QuerySnapshot result = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .where('id', isEqualTo: userid)
                                .get();

                            final List<DocumentSnapshot> documents =
                                result.docs;
                            if (documents.length == 0) {
                              print('new user');

                              await preferences.setString('id', userid);
                              await preferences.setString('key', userid);
                              //user is new like completely new
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userid)
                                  .set({
                                'name': null,
                                'lastused': 1584253800000,
                                // 'code': null,
                                'isverified': false,
                                'phone': phoneno,
                                'photo': null,
                                 'dailycounts' : [],
          'polls' : 0,
          'posts' : 0,
          'comments' : 0,
          'messaged' : 0,
          'invited' : 0,
                                'id': userid,
                                'createdat': DateFormat.yMEd()
                                    .add_jms()
                                    .format(DateTime.now()),
                                'chattingwith': null,
                                'l_chattingwith': null,
                                // 'clickcount': 0,
                                'devtoken': null,
                                'showupdate': false,
                                'incomingRequest': false,
                                'index': null,
                                'isonline': false,
                                'handle': null,
                                'querysearch': '',
                                'karma': 0,
                                'bio': null,
                                'dob': null,
                                'country': null,
                                'countrycode': 'Earth',
                                'postalcode': null,
                                'adminarea': 'orion',
                                'addressline': null,
                              }).then((value) {
                                _firebaseMessaging.getToken().then((val) async {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userid)
                                      .update({
                                    'devtoken': val,
                                  });
                                  await preferences.setString('FCMtoken', val);
                                  print('Token for this user: ' + val);
                                  await preferences.setString(
                                      'countrycode', 'Earth');
                                  await preferences.setString(
                                      'adminarea', 'orion');

                                  updateindex(userid);
                                });
                              });

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          FirstPage(
                                            preferences.getString('id'),
                                          )),
                                  (Route<dynamic> route) => false);

                              Fluttertoast.showToast(msg: 'Success!');

                              //write data to local
                              // currentUser = value.user;

                            } else {
                              print('old user');
                              //  await preferences.setString(
                              //     'code', documents[0].data()['code']);
                              //user is old and trying to relogin
                                          await preferences.setString('fp', 'okay');

                              await preferences.setString(
                                  'id', documents[0].data()['id']);
                              await preferences.setString(
                                  'key', documents[0].data()['id']);
                              await preferences.setString(
                                  'name', documents[0].data()['name']);
                              await preferences.setString(
                                  'dob', documents[0].data()['dob'].toString());

                              await preferences.setString(
                                  'photo', documents[0].data()['photo']);
                              await preferences.setString(
                                  'handle', documents[0].data()['handle']);
                              await preferences.setString('countrycode',
                                  documents[0].data()['countrycode']);
                              await preferences.setString('adminarea',
                                  documents[0].data()['adminarea']);
                              await preferences
                                  .setString('interests', 'true')
                                  .then((value) {
                                _firebaseMessaging.getToken().then((val) {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userid)
                                      .update({
                                    'devtoken': val,
                                  });
                                  preferences.setString('FCMtoken', val);
                                  print('Token for this user: ' + val);
                                }).then((value) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              HomePage(
                                                preferences.getString('id'),
                                              )),
                                      (Route<dynamic> route) => false);
                                });
                              });
                              Fluttertoast.showToast(msg: 'Welcome Back');
                            }

                            print(value.credential);
                            print(value.additionalUserInfo);
                            print(value.user);
                            print('uid is ${value.user.uid}');
                            print('sucess with code');
                          });
                        } catch (e) {
                          print('hey you this is ${e.message}');
                          if (e.message.contains(
                              'The sms verification code used to create the phone auth credential is invalid')) {
                            return showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      actions: [
                                        FlatButton(
                                          child: Text(
                                            'Okay',
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                      title: Text('Error'),
                                      content: Text('Invalid OTP'),
                                    ));
                          } else if (e.message
                              .contains('The sms code has expired')) {
                            return showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      actions: [
                                        FlatButton(
                                          child: Text(
                                            'Okay',
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                      title: Text('Error'),
                                      content: Text('Expired OTP'),
                                    ));
                          }
                        }
                      },
                      child: Text('Submit')),
                ],
                content: TextFormField(
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: 'xxxxxx',
                      hintStyle: TextStyle(
                          fontFamily: 'Righteous', fontSize: width * 5)),
                  style: TextStyle(
                      // fontFamily: 'Kaushan',
                      fontWeight: FontWeight.bold,
                      fontSize: width * 7),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    setState(() {
                      sms = v;
                    });
                  },
                ),
              );
            });
      },
      codeAutoRetrievalTimeout: (String verificationId) async {
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('TimedOut'),
                  content: Text('Click on Resend to send OTP again'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);

                          test();
                        },
                        child: Text('Resend'))
                  ],
                ));
      },
    );
  }

  setSearchParam(String name) {
    List<String> subjectSearchList = List();
    String temp = "";
    for (int i = 0; i < name.length; i++) {
      temp = temp + name[i];
      subjectSearchList.add(temp);
    }
    return subjectSearchList;
  }

  // Future<void> _submitPhoneNumber() async {
  //   /// NOTE: Either append your phone number country code or add in the code itself
  //   /// Since I'm in India we use "+91 " as prefix `phoneNumber`
  //   String phoneNumber = phoneno;
  //   print(phoneNumber);

  //   /// The below functions are the callbacks, separated so as to make code more readable
  //   void verificationCompleted(AuthCredential phoneAuthCredential) {
  //     print('verificationCompleted');
  //     // ...
  //     // this.phoneAuthCredential = phoneAuthCredential;
  //     print(phoneAuthCredential);
  //   }

  //   void verificationFailed(FirebaseAuthException error) {
  //     // ...
  //     print(error);
  //   }

  //   void codeSent(String verificationId, [int code]) {
  //     // ...
  //     print('codeSent');
  //   }

  //   void codeAutoRetrievalTimeout(String verificationId) {
  //     // ...
  //     print('codeAutoRetrievalTimeout');
  //   }

  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     /// Make sure to prefix with your country code
  //     phoneNumber: phoneNumber,

  //     /// `seconds` didn't work. The underlying implementation code only reads in `milliseconds`
  //     timeout: Duration(milliseconds: 10000),

  //     /// If the SIM (with phoneNumber) is in the current device this function is called.
  //     /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
  //     verificationCompleted: verificationCompleted,

  //     /// Called when the verification is failed
  //     verificationFailed: verificationFailed,

  //     /// This is called after the OTP is sent. Gives a `verificationId` and `code`
  //     codeSent: codeSent,

  //     /// After automatic code retrival `tmeout` this function is called
  //     codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
  //   ); // All the callbacks are above
  // }
  // @override
  // void initState() {
  //   super.initState();
  //   // NotificationController.instance.takeFCMTokenWhenAppLaunch();
  //   // NotificationController.instance.inithomepNotification();
  //   // FirebaseController.instance.getUnreadMSGCount();

  //   // initfcm();
  //   // isSignedIn();
  // }

  // void isSignedIn() async {
  //   this.setState(() {
  //     isLoading = false;
  //   });
  //   preferences = await SharedPreferences.getInstance();

  //   isLoggedIn = await googleSignIn.isSignedIn();
  //   if (isLoggedIn) {
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => HomeScreen(
  //                   currentUserId: preferences.getString('id'),
  //                 )));
  //   }
  //   this.setState(() {
  //     isLoading = false;
  //   });
  // }

  updateindex(userid) async {
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

  loading() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => SimpleDialog(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 100 * 15,
                  width: MediaQuery.of(context).size.width / 100 * 20,
                  child: SpinKitCircle(
                    color: Color.fromRGBO(252, 90, 39, 1),
                    size: MediaQuery.of(context).size.height / 100 * 10,
                  ),
                )
              ],
            ));
  }

  loader() {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (c) => AlertDialog(
              content: Container(
                height: height * 20,
                width: width * 60,
                child: SpinKitCircle(
                  color: Color.fromRGBO(252, 90, 39, 50),
                ),
              ),
            ));
  }

  tc() {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              actions: [
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              title: Text('Terms and Conditions'),
              content: Container(
                height: height * 80,
                width: width * 80,
                child: ListView(
                  children: [
                    Text(
                        'By downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy, or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, and you also shouldn’t try to translate the app into other languages, or make derivative versions. The app itself, and all the trade marks, copyright, database rights and other intellectual property rights related to it, still belong to Kumar Keshav. Kumar Keshav is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for. The orion app stores and processes personal data that you have provided to us, in order to provide my Service. It’s your responsibility to keep your phone and access to the app secure. We therefore recommend that you do not jailbreak or root your phone, which is the process of removing software restrictions and limitations imposed by the official operating system of your device. It could make your phone vulnerable to malware/viruses/malicious programs, compromise your phone’s security features and it could mean that the orion app won’t work properly or at all.The app does use third party services that declare their own Terms and Conditions.'),
                    Text(
                        'If we find you breaking our intellectual properties right in any way, You will be contacted by concerned office as in breaking the cyber rules for safety and can be liable for illegal activities and thus concerned officer might put charges against you.'),
                  ],
                ),
              ),
            ));
  }

  pp() {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Okay'))
              ],
              title: Text('Privacy Policy'),
              content: Container(
                height: height * 80,
                width: width * 80,
                child: ListView(
                  children: [
                    Text(
                        'orion is produced as a Free app. This app doesn\'t include any ads but holds right to implement them in future. This Service is provided by Kumar Keshav at no cost and is intended for use as is. This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at orion unless otherwise defined in this Privacy Policy.'),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                      'Information Collection and Use',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                        'For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to Mobile Number, Physical Address, Name, Photo. The information that I request will be retained on your device and is not collected by me in any way.The app does use third party services that may collect information used to identify you.'),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                      'Log Data',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                        'I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.'),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                      'Service Providers',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                        'I may employ third-party companies and individuals due to the following reasons: To facilitate our Service | To provide the Service on our behalf | To perform Service-related services | To assist us in analyzing how our Service is used.I want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.'),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                      'Security',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                        'I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.'),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                      'Children\s Privacy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                        'These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do necessary actions. However We also would like to confirm that if any children under the age of 13 signup we somehow would not be able to detect their data, we might not be able to remove their data due to unconfirmed confidential but if you help us in validating then their data will be removed immediately'),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                      'Changes to This Privacy Policy',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                        'I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page. This policy is effective as of 2021-02-03 and will not change its state until further notice.'),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                      'Contact Us',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                        'If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me at kumarkeshavbhardwaj@gmail.com.'),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                      'Side Note',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 2,
                    ),
                    Text(
                        'This app uses third party services inside and all of the credits of those services goes to them directly. You may experience a few bugs and we are working day and night to fix them. Please rate us on Google Play Store and leave a review/feedback.'),
                    Text('Thanks for using'),
                    Text('Kumar.'),
                  ],
                ),
              ),
            ));
  }

  //ui part-----
  @override
  Widget build(BuildContext context) {
    var corecolor = Color.fromRGBO(252, 90, 39, 1);

    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      // backgroundColor: Colors.redAccent,
      body: Form(
        key: _formkey,
        child: Column(
          children: [
            Container(
              height: height * 25,
              width: width * 100,
              alignment: Alignment.bottomCenter,
              // height: heigh,
              // color: Colors.blue,
              child: Image.asset(
                'images/playstore.png',
                height: width * 30,
              ),
            ),
            SizedBox(
              height: height * 1,
            ),
            Container(
              child: Text(
                'orion',
                style: TextStyle(
                    fontFamily: 'Righteous',
                    color: corecolor,
                    fontWeight: FontWeight.bold,
                    fontSize: width * 10),
              ),
            ),
            SizedBox(
                // height: height * 8,
                ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'Fully Secured Authentication. We will take your Phone No. for Authentication purposes only.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Theme.of(context).primaryColor)),
            ),

            Container(
              child: Text('Enter your phone no.',
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      fontWeight: FontWeight.bold,
                      fontSize: width * 5,
                      color: Colors.blueGrey)),
            ),
            SizedBox(
              height: height * 1,
            ),
            Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: width * 3),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(60)),
                width: width * 90,
                height: height * 9,
                child: IntlPhoneField(
                  // validator: (v) {
                  //   if (v.isEmpty) {
                  //     return 'ENTER A VALID PHONE NO.';
                  //   }
                  // },
                  onChanged: (v) {
                    setState(() {
                      phoneno = v.completeNumber;
                    });
                  },

                  keyboardType: TextInputType.number,
                  autoValidate: true,
                  style: TextStyle(
                      // fontFamily: 'Kaushan',
                      fontWeight: FontWeight.bold,
                      fontSize: width * 7),
                  decoration: InputDecoration(border: InputBorder.none),
                  // initialCountryCode: 'US',
                ),
              ),
            ),

            SizedBox(
              height: height * 5,
            ),
            // Container(
            //   child: Image.asset(
            //     'images/imageworld.png',
            //     width: width * 60,
            //     color: Colors.white,
            //     colorBlendMode: BlendMode.dstIn,
            //   ),
            // ),
            // SizedBox(
            //   height: height * 3,
            // ),
            //TODO2:uncomment below
            // InkWell(
            //   borderRadius: BorderRadius.circular(30),
            //   onTap: () {
            //     loader();

            //     signin();
            //   },
            //   splashColor: Colors.orange,
            //   child: Container(
            //     height: height * 7,
            //     alignment: Alignment.center,
            //     width: width * 80,
            //     decoration: BoxDecoration(
            //         color: corecolor, borderRadius: BorderRadius.circular(30)),
            //     child: Text(
            //       'SignUp with Gmail',
            //       style: TextStyle(
            //           fontSize: width * 5,
            //           color: Colors.white,
            //           fontFamily: 'Righteous',
            //           fontWeight: FontWeight.w400),
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   height: height * 5,
            // ),
            InkWell(
              onTap: () async {
                if (_formkey.currentState.validate()) {
                  if (await ConnectivityWrapper.instance.isConnected) {
                    print(phoneno);
                    test();
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
                }
              },
              borderRadius: BorderRadius.circular(30),
              child: Card(
                shadowColor: Colors.white,
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Container(
                  height: height * 7,
                  alignment: Alignment.center,
                  width: width * 80,
                  decoration: BoxDecoration(
                      color: corecolor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(
                    'REGISTER',
                    style: TextStyle(
                        fontSize: width * 5,
                        color: Colors.white,
                        fontFamily: 'Righteous',
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 5,
            ),
            Container(
              // color: Colors.blue,
              width: width * 90,
              alignment: Alignment.center,
              height: height * 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'By Signing up, you agree to our',
                    style: TextStyle(
                      fontFamily: 'Righteous',
                    ),
                  ),
                  InkWell(
                    onTap: tc,
                    child: Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Righteous',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: pp,
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Righteous',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * 4,
            ),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'made with',
                  style: TextStyle(color: corecolor, fontFamily: 'Righteous'),
                ),
                Icon(Icons.favorite, color: corecolor),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
