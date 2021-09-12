import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'package:orion/getinfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DOB extends StatefulWidget {
  final String currentuserid;
  DOB(this.currentuserid);
  @override
  _DOBState createState() => _DOBState();
}

class _DOBState extends State<DOB> {
  bool loader = false;
  final TextEditingController dobC = TextEditingController();
  final _formkey = GlobalKey<FormState>();


  @override
  void initState() { 
    super.initState();
     _determinePosition();
  }

   double latitude;
  double lonngitude;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('countrycode', 'Earth');
      prefs.setString('adminarea', 'orion');

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('countrycode', 'Earth');
      prefs.setString('adminarea', 'orion');

      // uploadaddresstodb(null, null, 'NA', 'NA', 'NA');

      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        showDialog(
            context: context,
            builder: (c) => AlertDialog(
                  actions: [
                    FlatButton(
                        onPressed: () {
                          _determinePosition();
                          Navigator.pop(context);
                        },
                        child: Text('Okay'))
                  ],
                  content: Text(
                    'orion needs to access your location',
                    style: TextStyle(fontFamily: 'Righteous'),
                  ),
                ));
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    final location = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best)
        .then((value) {
      setState(() {
        print('loc is ${value.latitude} and ${value.longitude}');
        // loc = true;
        latitude = value.latitude;
        lonngitude = value.longitude;
      });
      Timer(Duration(seconds: 1), getaddress);
      // getaddress();
    });

    print('heylat' + location.latitude);
    print('heylong' + location.longitude);
  }

  getaddress() async {
    print('get address init');
    final coordinates = Coordinates(latitude, lonngitude);
    print('glat$latitude glong$lonngitude');
    var addresses = await Geocoder.local
        .findAddressesFromCoordinates(coordinates)
        .then((value) {
      print(value.first.addressLine);
      print(value.first.adminArea);
      // print(first.coordinates);
      print(value.first.countryCode);
      print(value.first.countryName);
      if (value.first.countryCode != null) {
        print('valid-----------------' + value.first.countryCode);

        uploadaddresstodb(
            value.first.countryName,
            value.first.countryCode,
            value.first.addressLine,
            value.first.adminArea,
            value.first.postalCode);
      } else {
        print('things r empty');
      }
    });
    var first = addresses.first;

    // print(first.featureName);
    // print(first.locality);
    print(first.postalCode);

    // Timer(
    //     Duration(seconds: 2),
    //    );

    return first;
  }

  uploadaddresstodb(String country, String countrycode, String addressline,
      String adminarea, String postalcode) async {
    print('upload add init');
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({
      'country': country,
      'countrycode': countrycode,
      'addressline': addressline,
      'adminarea': adminarea,
      'postalcode': postalcode
    }).then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('countrycode', countrycode);
      prefs.setString('adminarea', adminarea);
    });
  }


  updatedob() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentuserid)
        .update({'dob': dobC.text.trim()}).then((value) async {
      setState(() {
        loader = true;
      });
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('dob', dobC.text.trim());
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => InfoGet(widget.currentuserid)),
          (Route<dynamic> route) => false);
    });
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
          'DOB',
          style: TextStyle(fontFamily: 'Blinker'),
        ),
      ),
      body: Form(
        key: _formkey,
        child: Stack(
          children: [
                        loader ? SpinKitCircle(color: Theme.of(context).primaryColor,size: width*20,) : Container(),

            Column(
              children: [
                Container(
                  // padding: EdgeInsets.only(left: width*4),
                  child: Text(
                    'Enter your Date of Birth',
                    style: TextStyle(fontFamily: 'Blinker', fontSize: width * 5),
                  ),
                ),
                Container(
                  width: width * 60,
                  padding: EdgeInsets.all(width * 5),
                  child: TextFormField(
                    controller: dobC,
                    validator: (v) {
                      if (v.trim().isEmpty || v.trim() == '') {
                        return 'You need to confirm your age';
                      }
                    },
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: width * 6),
                    autofocus: true,
                    decoration: InputDecoration(hintText: 'DD/MM/YYYY'),
                    inputFormatters: [
                      MultiMaskedTextInputFormatter(
                          masks: ['xx/xx/xxxx'], separator: '/'),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: width * 4),
                  child: Text(
                    '*You must be at least 14 to use the app.',
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        fontWeight: FontWeight.bold,
                        fontSize: width * 4),
                  ),
                ),
                SizedBox(height: height * 5),
                Container(
                  padding: EdgeInsets.only(left: width * 4),
                  child: Text(
                    'Only for people in Begusarai, Bihar, India. If you are not from here then write to us kumarkeshavbhardwaj@gmail.com to get access to your location.',textAlign: 
                    TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Blinker',
                        fontWeight: FontWeight.bold,
                        fontSize: width * 4),
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
                          updatedob();
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
