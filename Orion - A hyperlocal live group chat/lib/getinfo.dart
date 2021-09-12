import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orion/homepage.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoGet extends StatefulWidget {
  final String currentuserid;
  InfoGet(this.currentuserid);
  @override
  _InfoGetState createState() => _InfoGetState();
}

class _InfoGetState extends State<InfoGet> {
  final TextEditingController handleC = TextEditingController();
  String han = '';
  String handlemsg = '';
  final TextEditingController nameC = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();

  bool loader = false;

  String code = '';

  @override
  void initState() {
    super.initState();
    randomalpha();
    // addkarma();
    // createinvitationcode();
  }

  randomalpha() {
    setState(() {
      code = randomAlpha(4);
    });
    Timer(Duration(seconds: 2), createinvitationcode);
  }

  // addkarma() {
  //   FirebaseFirestore.instance.collection('codes').doc(hostid).
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.currentuserid)
  //       .update({'karma': FieldValue.increment(25)});
  // }

  createinvitationcode() {
    // print(randomAlpha(4));

    FirebaseFirestore.instance
        .collection('codes')
        .doc(widget.currentuserid)
        .set({
      'code': code.toUpperCase(),
      'id': widget.currentuserid,
      'joined': 0
    }).then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('code', code.toUpperCase());
    });
  }

  proceed() {
    print('final set reached');
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({
      'handle': handleC.text.trim(),
      // 'querysearch': setSearchParam(handleC.text.trim()),
    }).then((value) async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('handle', handleC.text.trim());
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(
                    widget.currentuserid,
                  )),
          (Route<dynamic> route) => false);

      // Navigator.push(context,
      //     MaterialPageRoute(builder: (c) => Intro()));
      // print('final done');
    });
    FirebaseFirestore.instance
        .collection('handles')
        .doc()
        .set({'handle': handleC.text.trim()});
  }

  managehandle() {
    setState(() {
      loader = true;
    });
    // Timer(Duration(seconds: 1), verify);
    print('method init');
    // showcircular = true;
    Future<QuerySnapshot> handler = FirebaseFirestore.instance
        .collection('handles')
        .where('handle', isEqualTo: handleC.text.trim())
        .get();

    handler.then((value) {
      print('val is $value');
      print('method reached1');
      value.docs.forEach((element) {
        print('each val is $element');
        han = element['handle'];
        print('han is $han');
      });
    }).then((value) {
      verify();
    });
  }
//TODO4------------------------------Just in this version
  // setSearchParam(String handle) {
  //   List<String> subjectSearchList = List();
  //   String temp = "";
  //   for (int i = 0; i < handle.length; i++) {
  //     temp = temp + handle[i];
  //     subjectSearchList.add(temp);
  //   }
  //   return subjectSearchList;
  // }

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
                      style: TextStyle(fontFamily: 'Blinker'),
                    ))
              ],
              title: Text(
                'This handle is taken. Try another one',
                style: TextStyle(fontFamily: 'Blinker'),
              ),
            ));
  }

  verify() {
    setState(() {
      loader = false;
    });
    print('verify init');
    if (han == handleC.text.trim()) {
      print('bro this exist');

      print(handleC.text.trim());
      unav();
    } else {
      print(handleC.text.trim());

      proceed();
      print('bro dont exist');
    }
  }

  inithandle() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Form(
              key: _formkey2,
              child: AlertDialog(
                actions: [
                  FlatButton(
                      onPressed: () async {
                        if (await ConnectivityWrapper.instance.isConnected) {
                          managehandle();
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
                      child: Text(
                        'Go',
                        style: TextStyle(
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(252, 90, 39, 1),
                        ),
                      ))
                ],
                content: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a username',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width / 100 * 5,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'Blinker',
                            color: Colors.black),
                      ),
                      TextFormField(
                        validator: (v) {
                          if (v.trim() == '') {
                            return 'username is necessary';
                          }
                        },
                        controller: handleC,
                        cursorColor: Colors.black,
                        autofocus: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w100,
                            color: Colors.black87,
                            fontSize:
                                MediaQuery.of(context).size.width / 100 * 5,
                            fontFamily: 'Blinker'),
                        decoration: InputDecoration(
                          hintText: 'your username ( without spaces )',
                          hintStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width / 100 * 3,
                              fontWeight: FontWeight.normal,
                              color: Colors.black26,
                              fontFamily: 'Righteous'),
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 100 * 4,
                      ),
                      Text(
                        handlemsg,
                        style: TextStyle(fontFamily: 'Righteous'),
                      )
                    ],
                  ),
                  height: MediaQuery.of(context).size.height / 100 * 20,
                  width: MediaQuery.of(context).size.width / 100 * 70,
                ),
              ),
            ));
  }

  File imagepath;

  uploadImage() async {
    //store intialize
    StorageReference profilepics =
        FirebaseStorage.instance.ref().child('profilepics');
    //store image
    StorageUploadTask storageUploadTask =
        profilepics.child(widget.currentuserid).putFile(imagepath);
    //store complete
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    //download pic thru url
    String downloadpic = await storageTaskSnapshot.ref.getDownloadURL();
    print('hey this is something $downloadpic');

    return downloadpic;
  }

  uploaddata() async {
    String downloadpic = imagepath == null
        ? 'https://image.flaticon.com/icons/png/512/149/149071.png'
        : await uploadImage();
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({
      // 'querysearch': setSearchParam(displaynameC.text.trim()),
      'name': nameC.text,
      // 'dob': selectedDate,
      // 'bio': bioC.text,
      'photo': downloadpic,
    }).then((value) {
      setState(() {
        loader = false;
      });
      inithandle();
      // isloading = false;
      // isloading ? loading() : Container();
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', nameC.text);
    // sharedPreferences.setString('dob', selectedDate.toString());

    // sharedPreferences.setString('bio', bioC.text);
    sharedPreferences.setString('photo', downloadpic);
  }

  showimagedialog() {
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              content: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleDialogOption(
                      child: Text('Pick Image from Gallery',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width / 100 * 5,
                              fontFamily: 'Blinker',
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 100 * 5,
                    ),
                    SimpleDialogOption(
                      child: Text('Pick Image from Camera',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width / 100 * 5,
                              fontFamily: 'Blinker',
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 100 * 5,
                    ),
                    SimpleDialogOption(
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width / 100 * 5,
                              fontFamily: 'Blinker',
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // _pickImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height / 100 * 35,
                // width: MediaQuery.of(context).size.width / 100 * 30,
              ),
            ));
  }

  _pickImage(ImageSource s) async {
    var image =
        await ImagePicker.pickImage(source: s, maxHeight: 400, maxWidth: 400);
    print('original length is ${image.lengthSync()}');
    File croppedfile = await ImageCropper.cropImage(
      maxHeight: 400,
      maxWidth: 400,
      compressFormat: ImageCompressFormat.png,
      sourcePath: image.path,
      cropStyle: CropStyle.circle,
    );

    setState(() {
      imagepath = croppedfile;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 100;
    final width = MediaQuery.of(context).size.width / 100;
    return Scaffold(resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Basics',
          style: TextStyle(
            fontFamily: 'Blinker',
            color: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(width * 3),
                  child: Text(
                    'Name',
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        fontSize: width * 5,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(width * 3),
                  width: width * 60,
                  child: TextFormField(
                      controller: nameC,
                      validator: (v) {
                        if (v.trim().isEmpty || v.trim() == '') {
                          return 'Name cannot be empty';
                        }
                      },
                      cursorColor: Theme.of(context).primaryColor,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Blinker',
                          fontWeight: FontWeight.bold,
                          fontSize: width * 5)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: width * 10, top: height * 5),
                      child: InkWell(
                          onTap: () {
                            showimagedialog();
                          },
                          child: imagepath == null
                              ? Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      radius: width * 10,
                                    ),
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: width * 20,
                                      color: Colors.white,
                                    ),
                                  ],
                                )
                              : CircleAvatar(
                                  backgroundImage: FileImage(imagepath),
                                  radius: width * 10,
                                )),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: height * 5),
                      child: Text(
                        'Add a photo',
                        style: TextStyle(
                            fontFamily: 'Blinker',
                            fontSize: width * 5,
                            color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: height * 5,
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
                          uploaddata();
                          // inithandle();
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
                      width: width * 100,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
