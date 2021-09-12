import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePage extends StatefulWidget {
  final String id;
  UpdatePage(this.id);
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool loader = false;
  final _formkey = GlobalKey<FormState>();

  // String name;
  final TextEditingController nc = TextEditingController();


  

  // updatename() {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.id)
  //       .update({'name': nc.text}).then((value) {
  //     Fluttertoast.showToast(msg: 'Updated Successfully');
  //     Navigator.pop(context);
  //   });
  // }

  File imagepath;

  uploadImage() async {
    //store intialize
    StorageReference profilepics =
        FirebaseStorage.instance.ref().child('profilepics');
    //store image
    StorageUploadTask storageUploadTask =
        profilepics.child(widget.id).putFile(imagepath);
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
    FirebaseFirestore.instance.collection('users').doc(widget.id).update({
      // 'querysearch': setSearchParam(displaynameC.text.trim()),
      'name': nc.text,
      // 'dob': selectedDate,
      // 'bio': bioC.text,
      'photo': downloadpic,
    }).then((value) {
      setState(() {
        loader = false;
      });
      // inithandle();
      // isloading = false;
      // isloading ? loading() : Container();
    });
    Fluttertoast.showToast(
        msg: 'Updated Successfully',
        backgroundColor: Theme.of(context).primaryColor);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', nc.text);
    // sharedPreferences.setString('dob', selectedDate.toString());

    // sharedPreferences.setString('bio', bioC.text);
    sharedPreferences.setString('photo', downloadpic);
    Navigator.pop(context);
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

  // updatephoto() {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.id)
  //       .update({'photo': nc.text}).then((value) {
  //     Fluttertoast.showToast(msg: 'Updated Successfully');
  //     Navigator.pop(context);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          FlatButton(
              onPressed: () async{
                if (await ConnectivityWrapper.instance.isConnected) {
                          // managehandle();
                           
                if(_formkey.currentState.validate()) {
                  setState(() {
                  loader = true;
                });
 uploaddata();
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
               
              },
              child: Text(
                'Save',
                style: TextStyle(
                    fontFamily: 'Blinker', color: Colors.white, fontSize: width*5),
              ))
        ],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Update',
          style: TextStyle(
              fontFamily: 'Blinker', fontWeight: FontWeight.bold, fontSize:width*5),
        ),
      ),
      body: Form(
        key: _formkey,
        child: Stack(
          children: [
            loader
                ? SpinKitCircle(
                    color: Theme.of(context).primaryColor,
                    size: MediaQuery.of(context).size.width / 100 * 20,
                  )
                : Container(),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Name',
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        fontSize: width*7,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: width*3),
                  Center(
                    child: Container(
                      margin: EdgeInsets.all(20),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 10),
                        // height: height * 10,
                        width: width * 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        child: TextFormField(
                          validator: (v) {
                            if (v.trim().isEmpty) {
                              return 'Cannot be empty';
                            }
                          },
                          controller: nc,
                          autofocus: true,
                          cursorColor: Theme.of(context).primaryColor,
                          style: TextStyle(fontFamily: 'Blinker', fontSize: width*4),
                          decoration: InputDecoration(
                              hintText: 'Type your new name here',
                              border: InputBorder.none),
                        )),
                  ),
                  SizedBox(
                    height: width*3,
                  ),
                  InkWell(
                    onTap: showimagedialog,
                    child: imagepath == null
                        ? Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: MediaQuery.of(context).size.width /
                                    100 *
                                    10,
                              ),
                              Icon(
                                Icons.camera_alt_outlined,
                                size: MediaQuery.of(context).size.width /
                                    100 *
                                    20,
                                color: Colors.white,
                              ),
                            ],
                          )
                        : CircleAvatar(
                            backgroundImage: FileImage(imagepath),
                            radius:
                                MediaQuery.of(context).size.width / 100 * 10,
                          ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  InkWell(
                    onTap: () async{
                      if (await ConnectivityWrapper.instance.isConnected) {
                         if (_formkey.currentState.validate()) {
 setState(() {
                  loader = true;
                });
                        uploaddata();
                      }
                          // managehandle();
                          
               
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
                    child: Container(
                      width: 400,
                      alignment: Alignment.center,
                      height: 50,
                      child: Text(
                        'Update',
                        style: TextStyle(
                            fontFamily: 'Blinker',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: width*5),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(90),
                          color: Theme.of(context).primaryColor),
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
}
