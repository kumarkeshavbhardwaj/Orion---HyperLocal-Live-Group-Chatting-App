import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:orion/phonesignin.dart';
import 'package:orion/signupscreen.dart';
import 'package:orion/update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final String currentuserid;
  SettingsPage(this.currentuserid);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String name = '';
  String photo = 'https://image.flaticon.com/icons/png/512/149/149071.png';
  String username = '';
  String code = 'GGS';
  int karma = 0;

  TextEditingController fc = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getdatafromnet();
    getcode();
    getdatalocal();
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
                        'orion is produced as a Free app. This app doesn\'t include any ads but holds right to implement them in future. This Service is provided by Kumar Keshav at no cost and is intended for use as is. This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy. The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at orion unless otherwise defined in this Privacy Policy.'),
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
                    Text('kumarkeshavbhardwaj@gmail.com.'),
                  ],
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

  submitfeedback() {
    FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(widget.currentuserid)
        .set({'feedback': fc.text, 'id': widget.currentuserid}).then((value) {
      fc.clear();
      Fluttertoast.showToast(
          msg: 'Feedback Submit Successfully',
          backgroundColor: Theme.of(context).primaryColor);
      Navigator.pop(context);
    });
  }

  submitfeedback2() {
    FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(widget.currentuserid)
        .set({'feedback': fc.text, 'id': widget.currentuserid}).then((value) {
      deleteaccount();
      
    });
  }

  // final
  feedbackdialog() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Feedback'),
              content: Form(
                key: _formkey,
                child: Container(
                    height: MediaQuery.of(context).size.width / 100 * 30,
                    child: TextFormField(
                      controller: fc,
                      validator: (v) {
                        if (v.trim().isEmpty) {
                          return 'Please Write something';
                        }
                      },
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          fontSize:
                              MediaQuery.of(context).size.width / 100 * 5),
                      maxLines: null,
                    )),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
                FlatButton(
                    onPressed: () {
                      if (_formkey.currentState.validate()) {
                        submitfeedback();
                      }
                    },
                    child: Text('Submit'))
              ],
            ));
  }

  feedbackdialog2() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Feedback'),
              content: Form(
                key: _formkey,
                child: Container(
                    height: MediaQuery.of(context).size.width / 100 * 30,
                    child: TextFormField(
                      controller: fc,
                      validator: (v) {
                        if (v.trim().isEmpty) {
                          return 'Please Write something';
                        }
                      },
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          fontSize:
                              MediaQuery.of(context).size.width / 100 * 5),
                      maxLines: null,
                    )),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      deleteaccount();
                    },
                    child: Text('No Thanks')),
                FlatButton(
                    onPressed: () {
                      if (_formkey.currentState.validate()) {
                        submitfeedback2();
                      }
                    },
                    child: Text('Submit'))
              ],
            ));
  }

  deleteaccount() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({'devtoken': 'deleted'}).then((value) {
      handleSignOut();
    });
  }

  deleteac() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Delete Account'),
              content: Container(
                height: MediaQuery.of(context).size.width / 100 * 30,
                child: Text('Are you sure you want to delete your account ?',
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width / 100 * 5)),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
                FlatButton(
                    onPressed: () {
                      feedbackdialog2();
                      deleteaccount();
                    },
                    child: Text('Yes'))
              ],
            ));
  }

  logout() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Log Out'),
              content: Container(
                height: MediaQuery.of(context).size.width / 100 * 30,
                child: Text('Are you sure you want to log out ?',
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width / 100 * 5)),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
                FlatButton(
                    onPressed: () {
                      handleSignOut();
                    },
                    child: Text('Yes'))
              ],
            ));
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<Null> handleSignOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await FirebaseAuth.instance.signOut();
    // await googleSignIn.disconnect();
    await googleSignIn.signOut();
    prefs.remove('key');
    prefs.remove('name');
    prefs.remove('dob');
    prefs.remove('fp');

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Signupscreen()));
  }

  getdatalocal() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState(() {
      name = p.getString('name');
      photo = p.getString('photo');
      username = p.getString('handle');
      // code = p.getString('code');
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

  getcode() {
    Future<DocumentSnapshot> ds = FirebaseFirestore.instance
        .collection('codes')
        .doc(widget.currentuserid)
        .get();

    ds.then((value) {
      setState(() {
        code = value.data()['code'];
      });
    });
  }

  invite() async {
    final ByteData bytes = await rootBundle.load('images/signup.png');

    await Share.file(
        'orion invite',
        'signup.png',
        bytes.buffer.asUint8List(),
        'image/png',
        text:
            'Hey, Join me on orion and meet with other students locally. Use code : $code to sign up. https://play.google.com/store/apps/details?id=com.getorionapp.orion');
  }

  @override
  Widget build(BuildContext context) {
    final unit = MediaQuery.of(context).size.width / 100;
    print('id is' + widget.currentuserid);
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 10, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(photo),
                  // backgroundColor: Colors.red,
                  radius: 50,
                ),
                Column(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          fontSize: unit * 7),
                    ),
                    Text(username,
                        style: TextStyle(
                            fontFamily: 'Blinker',
                            fontWeight: FontWeight.bold,
                            fontSize: unit * 5)),
                    Text('My Karma  :   $karma',
                        style: TextStyle(
                            fontFamily: 'Blinker',
                            fontWeight: FontWeight.bold,
                            fontSize: unit * 5)),
                    Text('Invitation code: $code',
                        style: TextStyle(
                            fontFamily: 'Blinker',
                            fontWeight: FontWeight.bold,
                            fontSize: unit * 5)),
                    // Row(
                    //   children: [
                    //     Icon(Icons.location_on_outlined),
                    //     Text('Begusarai',style: TextStyle(fontFamily: 'Blinker',fontWeight: FontWeight.bold)),
                    //   ],
                    // ),
                    
                  ],
                ),
              ],
            ),
          ),
          Spacer(),

          // Spacer(),
          InkWell(
            onTap: () {
              Fluttertoast.showToast(
                  msg: 'Preparing for Invitation',
                  backgroundColor: Theme.of(context).primaryColor);
              invite();
            },
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'Invite your friends and gain karma',
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.white,
                      fontSize: unit * 5),
                ),
              ),
            ),
          ),

          InkWell(
            onTap: feedbackdialog,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'Feedback',
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.white,
                      fontSize: unit * 5),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => UpdatePage(widget.currentuserid)));
            },
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'Update your profile',
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.white,
                      fontSize: unit * 5),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: tc,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.white,
                      fontSize: unit * 5),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: pp,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.white,
                      fontSize: unit * 5),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: logout,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'Logout',
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Colors.white,
                      fontSize: unit * 5),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: deleteac,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                      fontFamily: 'Blinker',
                      color: Theme.of(context).primaryColor,
                      fontSize: unit * 5),
                ),
              ),
            ),
          ),
          Spacer(),
          Container(),
          Spacer(),
        ],
      ),
    );
  }
}
