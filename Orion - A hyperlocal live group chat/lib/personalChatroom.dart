import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_pickers/chat_pickers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:orion/fullphotoview.dart';
import 'package:timeago/timeago.dart' as tago;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:orion/firebasecontroller.dart';
import 'package:orion/notificationcontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalChatroom extends StatefulWidget {
  final String myId;
  // final bool anony;
  final String peerAvatar;
  // final String cc;
  // final String aa;
  final String peernickname;
  final String peerToken;
  final String peerId;
  final String docid;
  // final String peerbio;
  final String peerhandle;

  const PersonalChatroom(

      {Key key,
      // this.anony,
      this.myId,
      // this.aa,
      // this.cc,
      // this.peerbio,
      this.docid,
      this.peerhandle,
      this.peerAvatar,
      this.peernickname,
      this.peerToken,
      this.peerId})
      : super(key: key);
  @override
  _PersonalChatroomState createState() => _PersonalChatroomState();
}

class _PersonalChatroomState extends State<PersonalChatroom>
    with SingleTickerProviderStateMixin {
  TextEditingController msgC = TextEditingController();
  // GifController controller = GifController(vsync: ,
  //   duration: Duration(seconds: 10),
  // );
  String myname;
  String mytoken;
  String myphoto;
  bool showload = false;

  String myid;
  int click;
  List<DocumentSnapshot> listmessage = List.from([]);
  int limit = 20;
  final int limitIncrement = 20;
  String groupchatid;
  SharedPreferences prefs;
  bool isloading;
  File imageFile;
  bool isShowSticker;
  String imageUrl;

  // final EmojiPickerConfig emojiPickerConfig = EmojiPickerConfig();
  // final GiphyPickerConfig giphyPickerConfig =
  //     GiphyPickerConfig(apiKey: 'w7wdzb32s8Ya4FUDkVEk8K9L56nO98EJ');

  int docl;
  bool showinput = false;
  // String imageurl;
  final ScrollController listScrollcontroller = ScrollController();
  final FocusNode focusnode = FocusNode();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  var corecolor = Color.fromRGBO(252, 90, 39, 1);
  var picker = ChatPickers(
      // chatController: msgC,
      emojiPickerConfig: EmojiPickerConfig(
          //optional configure  (as below)
          ),
      giphyPickerConfig: GiphyPickerConfig(
        apiKey: "w7wdzb32s8Ya4FUDkVEk8K9L56nO98EJ",
        // other optional configure (as below)
      ));

  bool notifstatus = true;

  bool t1 = true;

  // var picker = ChatPickers(
  //     // chatController: _chatController,
  //     emojiPickerConfig: EmojiPickerConfig(
  //         //optional configure  (as below)
  //         ),
  //     giphyPickerConfig: GiphyPickerConfig(
  //       apiKey: "some API Key",
  //       // other optional configure (as below)
  //     ));

  //when limit of getting 20 docs(message) is reached call _scrollcontroller;
  //to save some read counts
  // GifController _animationCtrl;
  @override
  void initState() {
    super.initState();
    FirebaseController.instance.getUnreadMSGCount();
    // getnotifstatus();
    focusnode.addListener(onFocusChange);
    listScrollcontroller.addListener(_scrollListener);
    print(widget.docid);
    print(widget.myId);

    // pushtopeer();

    groupchatid = '';
    isloading = false;
    imageUrl = '';
    isShowSticker = false;
    // updater();

    readLocal();
    // Timer(Duration(seconds: 1), getnotifstatus);
    // Timer(Duration(seconds: 3), () {
    // FirebaseController.instance.getUnreadMSGCount(widget.peerId, groupchatid);
    // });
  }

  // updater() {
  //   FlutterAppBadger.updateBadgeCount(2);
  // }

  _scrollListener() {
    if (listScrollcontroller.offset >=
            listScrollcontroller.position.maxScrollExtent &&
        !listScrollcontroller.position.outOfRange) {
      print('reached the bottom');
      setState(() {
        print('reached the bottom2');
        limit += limitIncrement;
      });
    }
    if (listScrollcontroller.offset <=
            listScrollcontroller.position.minScrollExtent &&
        !listScrollcontroller.position.outOfRange) {
      print('reached the top');
      setState(() {
        print('reached the top2');
      });
    }
  }

  getnotifstatus() {
    Future<DocumentSnapshot> ds = FirebaseFirestore.instance
        .collection('users')
        .doc(myid)
        .collection('lchat-users')
        .doc(widget.docid)
        .get();
    ds.then((value) {
      setState(() {
        notifstatus = value.data()['notif'];
        print('present notif status is $notifstatus');
      });
    });
  }

  void onFocusChange() {
    if (focusnode.hasFocus) {
      //hide sticker when keyboard appears
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    // id = prefs.getString('id') ?? '';
    myname = prefs.getString('name') ?? '';
    mytoken = prefs.getString('FCMtoken') ?? '';
    myphoto = prefs.getString('photo') ?? '';
    myid = prefs.getString('id') ?? '';
    if (myid.hashCode <= widget.peerId.hashCode) {
      groupchatid = '$myid-${widget.peerId}';
    } else {
      groupchatid = '${widget.peerId}-$myid';
    }
    FirebaseFirestore.instance.collection('users').doc(widget.myId).update({
      'lchattingWith': widget.peerId,
    });

    getnotifstatus();

    setState(() {});
  }

//   updategroupchatidtolchatuser()
//  {
//    FirebaseFirestore.instance.collection('users').doc(myid).collection('lchat-users').doc()
//  }
  Future getImage(ImageSource s) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: s);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      setState(() {
        showload = true;
        // isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusnode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      print('this is imageurl $imageUrl');
      setState(() {
        showload = false;
        // isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        // isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String msg, int type) {
    checknotif1();
    //type: 0 = text, type : 1 = image, type : 2 = sticker
    if (msg.trim() != '') {
      // textEditingController.clear();
      var docref = FirebaseFirestore.instance
          .collection('lchats')
          .doc(groupchatid)
          .collection(groupchatid)
          .doc(
            DateTime.now().millisecondsSinceEpoch.toString(),
          );

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(docref, {
          'idFrom': myid,
          'idTo': widget.peerId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'msg': msg,
          'isseen': false,
          'type': type,
          // 'toToken': widget.peerToken,
        });
      });
      msgC.clear();

      type == 0
          ? _getUnreadMSGCountThenSendMessage(msg)
          : type == 1
              ? _getUnreadMSGCountThenSendMessage('Image')
              : _getUnreadMSGCountThenSendMessage('Gif');

      listScrollcontroller.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      Fluttertoast.showToast(
        msg: 'Nothing to send',
      );
    }
  }

  checknotif1() {
    print('check init');
    Future<DocumentSnapshot> q = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.peerId)
        .collection('lchat-users')
        .doc(widget.docid)
        .get();
    q.then((value) {
      setState(() {
        t1 = value.data()['notif'];
        print(t1.toString());
      });
    });
  }

  Future<void> _getUnreadMSGCountThenSendMessage(String msg) async {
    try {
      print('try called');
      int unReadMSGCount = await FirebaseController.instance.getUnreadMSGCount(
        widget.peerId,
        groupchatid,
      );
     await NotificationController.instance.sendNotificationMessageToPeerUser(myname, unReadMSGCount , msg, groupchatid, t1 == true ? widget.peerToken : '')
          ;
      print('object');
    } catch (e) {
      print(e.message);
      print('object');
    }
  }

  //build message item/container...
  // Widget buildItem(
  //   int index,
  //   DocumentSnapshot document,
  // ) {
  //   if (document.data()['idFrom'] == myid) {
  //     var height = MediaQuery.of(context).size.height / 100;
  //     var width = MediaQuery.of(context).size.width / 100;
  //     var corecolor = Color.fromRGBO(252, 90, 39, 1);
  //     //Right (my message)
  //     return Row(
  //       children: <Widget>[
  //         Container(
  //           child: Text(
  //             document.data()['msg'],
  //             style: TextStyle(
  //                 fontFamily: 'Righteous',
  //                 color: Colors.white,
  //                 fontSize: width * 4),
  //           ),
  //           padding: EdgeInsets.symmetric(
  //               horizontal: width * 4, vertical: height * 2),
  //           width: width * 40,
  //           decoration: BoxDecoration(
  //             // border: Border.all(
  //             //     color: document.data()['isseen']
  //             //         ? Colors.teal
  //             //         : Colors.amber,
  //             //     width: 1.5),
  //             color: Colors.teal,
  //             // borderRadius: BorderRadius.only(
  //             //     topLeft: Radius.circular(30),
  //             //     bottomLeft: Radius.circular(30),
  //             //     // bottomRight: Radius.circular(30),
  //             //     topRight: Radius.circular(30)
  //           ),
  //           margin: EdgeInsets.only(
  //             bottom: isLastMessageRight(index) ? 20 : 10,
  //             // right: 10,
  //           ),
  //         ),

  //         // Container(child: Text(document.data()['isseen'] ? '' : 'Unseen'))
  //       ],
  //       mainAxisAlignment: MainAxisAlignment.end,
  //     );
  //   } else {
  //     var height = MediaQuery.of(context).size.height / 100;
  //     var width = MediaQuery.of(context).size.width / 100;
  //     var corecolor = Color.fromRGBO(252, 90, 39, 1);
  //     //left peer message
  //     return Container(
  //       child: Column(
  //         children: <Widget>[
  //           Row(
  //             children: <Widget>[
  //               isLastMessageLeft(index)
  //                   ? Material(
  //                       child: CachedNetworkImage(
  //                         imageUrl: widget.peerAvatar,
  //                         placeholder: (context, url) => Container(
  //                           child: CircularProgressIndicator(),
  //                           width: 35,
  //                           height: 35,
  //                           padding: EdgeInsets.all(10),
  //                         ),
  //                         width: 35,
  //                         height: 35,
  //                         fit: BoxFit.cover,
  //                       ),
  //                       borderRadius: BorderRadius.circular(18),
  //                       clipBehavior: Clip.hardEdge,
  //                     )
  //                   : Container(
  //                       width: 35,
  //                     ),
  //               Card(
  //                 shadowColor: Colors.teal,
  //                 elevation: 10,
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.only(
  //                   // topLeft: Radius.circular(30),
  //                   topRight: Radius.circular(30),
  //                   bottomLeft: Radius.circular(30),
  //                   bottomRight: Radius.circular(30),
  //                 )),
  //                 child: Container(
  //                   child: Text(
  //                     document.data()['msg'],
  //                     style: TextStyle(
  //                         fontFamily: 'Righteous',
  //                         color: Colors.white,
  //                         fontSize: width * 4),
  //                   ),
  //                   padding: EdgeInsets.symmetric(
  //                       horizontal: width * 4, vertical: height * 2),
  //                   width: width * 60,
  //                   decoration: BoxDecoration(
  //                       // border: Border.all(color: Colors.teal, width: 1.5),
  //                       color: corecolor,
  //                       borderRadius: BorderRadius.only(
  //                           // topLeft: Radius.circular(30),
  //                           bottomLeft: Radius.circular(30),
  //                           bottomRight: Radius.circular(30),
  //                           topRight: Radius.circular(30))),
  //                   margin: EdgeInsets.only(
  //                       // bottom: isLastMessageRight(index) ? 20 : 10,
  //                       // right: 10,
  //                       ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           //time
  //           isLastMessageLeft(index)
  //               ? Container(
  //                   child: Text(
  //                     DateFormat('dd MMMM kk:mm').format(
  //                       DateTime.fromMillisecondsSinceEpoch(
  //                         int.parse(
  //                           document.data()['timestamp'],
  //                         ),
  //                       ),
  //                     ),
  //                     style: TextStyle(
  //                         color: Colors.grey,
  //                         fontSize: 12,
  //                         fontStyle: FontStyle.italic),
  //                   ),
  //                 )
  //               :Container()
  //                            
  //         ],
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //       ),
  //       margin: EdgeInsets.only(bottom: 10),
  //     );
  //   }
  // } 
  

  Widget buildItem(
    int index,
    DocumentSnapshot document,
  ) {
    if (document.data()['idFrom'] == myid) {
      var height = MediaQuery.of(context).size.height / 100;
      var width = MediaQuery.of(context).size.width / 100;
      var corecolor = Color.fromRGBO(252, 90, 39, 1);
      //Right (my message)
      return Row(
        children: <Widget>[
          document.data()['type'] == 0
              ?
              //text
              Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width * 70),
                        child: Card(
                          // borderOnForeground: true,
                          // shadowColor: document.data()['isseen'] ? Colors.teal : Colors.amber,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            // bottomRight: Radius.circular(30),
                          )),
                          child: Container(
                            child: Text(
                              document.data()['msg'],
                              style: TextStyle(
                                  fontFamily: 'JosefinSans',
                                  color: document.data()['isseen']
                                      ? Colors.white
                                      : corecolor,
                                  fontSize: width * 4),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 4, vertical: height * 1),
                            // width: width * 60,
                            decoration: BoxDecoration(
                                // border: Border.all(
                                //     color: document.data()['isseen']
                                //         ? Colors.teal
                                //         : Colors.amber,
                                //     width: 1.5),
                                color: document.data()['isseen']
                                    ? Colors.teal
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    // bottomRight: Radius.circular(30),
                                    topRight: Radius.circular(10))),
                            margin: EdgeInsets.only(
                                // bottom: isLastMessageRight(index) ? 20 : 10,
                                // right: 10,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: width * 33),
                        child: Text(
                          tago.format(
                            DateTime.fromMillisecondsSinceEpoch(
                              int.parse(
                                document.data()['timestamp'],
                              ),
                            ),
                          ),
                          // textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: width * 2,
                              fontFamily: 'JosefinSans',
                              color: Colors.black38),
                        ),
                      )
                    ],
                  ),
                )
              : document.data()['type'] == 1
                  //image
                  ?
                  // Text('imagefound')

                  Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width * 70),
                            child: Card(
                              color: document.data()['isseen']
                                  ? Colors.teal
                                  : Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                // bottomRight: Radius.circular(30),
                                // topRight: Radius.circular(30),
                                bottomLeft: Radius.circular(10),
                              )),
                              child: InkWell(
                                // TODO7
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => FullView(
                                              photourl:
                                                  document.data()['msg'])));
                                },
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10)),
                                child: Container(
                                    decoration: BoxDecoration(
                                      // color: corecolor,
                                      borderRadius: BorderRadius.only(
                                        // bottomRight: Radius.circular(30),
                                        // topRight: Radius.circular(30),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: SpinKitCircle(
                                          color: corecolor,
                                        ),
                                        // width: width * 40,
                                        height: height * 20,
                                        // height: 200.0,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                      //TODO1
                                      errorWidget: (context, url, error) =>
                                          Material(
                                        child: Text(
                                            'image not available image here'),
                                        borderRadius: BorderRadius.only(
                                          // bottomRight: Radius.circular(30),
                                          // topRight: Radius.circular(30),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      imageUrl: document.data()['msg'],
                                      // width: width * 50,
                                      height: height * 30,
                                      fit: BoxFit.cover,
                                    ),
                                    margin: EdgeInsets.only(
                                      top: height * 1, bottom: height * 2,
                                      right: width * 1, left: width * 1,
                                      // bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                    )),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: width * 33),
                              child: Text(
                                tago.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(
                                      document.data()['timestamp'],
                                    ),
                                  ),
                                ),
                                // textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: width * 2,
                                    fontFamily: 'Righteous',
                                    color: Colors.black38),
                              ))
                        ],
                      ),
                    )
                  :
                  // gif Sticker
                  Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width * 70),
                            child: Card(
                              color: document.data()['isseen']
                                  ? Colors.teal
                                  : Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                // bottomRight: Radius.circular(30),
                                // topRight: Radius.circular(30),
                                bottomLeft: Radius.circular(10),
                              )),
                              child: Container(
                                  decoration: BoxDecoration(
                                      // color: corecolor,
                                      borderRadius: BorderRadius.only(
                                    // bottomRight: Radius.circular(30),
                                    // topRight: Radius.circular(30),
                                    bottomLeft: Radius.circular(10),
                                  )),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: SpinKitCircle(
                                            color: corecolor,
                                          ),
                                          // width: width * 60,
                                          height: height * 30,
                                          // height: 200.0,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                        //TODO1
                                        errorWidget: (context, url, error) =>
                                            Material(
                                          child: Text('Image not available'),
                                          borderRadius: BorderRadius.only(
                                            // bottomRight: Radius.circular(30),
                                            // topRight: Radius.circular(30),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        imageUrl: document.data()['msg'],
                                        // width: width * 20,
                                        height: height * 20,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                          top: height * 17,
                                          child: Image.asset(
                                            'images/logo1.png',
                                            height: height * 3,
                                            // color: corecolor,
                                          ))
                                    ],
                                  ),
                                  margin: EdgeInsets.only(
                                    top: height * 1, bottom: height * 2,
                                    right: width * 1, left: width * 1,
                                    // bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                  )),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: width * 33),
                              child: Text(
                                tago.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(
                                      document.data()['timestamp'],
                                    ),
                                  ),
                                ),
                                // textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: width * 2,
                                    fontFamily: 'Righteous',
                                    color: Colors.black38),
                              )),
                        ],
                      ),
                    ),

          // Container(child: Text(document.data()['isseen'] ? '' : 'Unseen'))
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      var height = MediaQuery.of(context).size.height / 100;
      var width = MediaQuery.of(context).size.width / 100;
      var corecolor = Color.fromRGBO(252, 90, 39, 1);
      //left peer message
      return Row(
        children: <Widget>[
          document.data()['type'] == 0
              ? Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width * 70),
                        child: Card(
                          shadowColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            // topLeft: Radius.circular(30),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          )),
                          child: Container(
                            child: Text(
                              document.data()['msg'],
                              style: TextStyle(
                                  fontFamily: 'JosefinSans',
                                  color: Colors.white,
                                  fontSize: width * 4),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 4, vertical: height * 1),
                            // width: width * 60,
                            decoration: BoxDecoration(
                                // border: Border.all(color: Colors.teal, width: 1.5),
                                color: corecolor,
                                borderRadius: BorderRadius.only(
                                    // topLeft: Radius.circular(30),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                    ),
                            margin: EdgeInsets.only(
                                // bottom: isLastMessageRight(index) ? 20 : 10,
                                // right: 10,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: width * 10),
                        child: Text(
                          tago.format(
                            DateTime.fromMillisecondsSinceEpoch(
                              int.parse(
                                document.data()['timestamp'],
                              ),
                            ),
                          ),
                          style: TextStyle(
                              fontSize: width * 2,
                              fontFamily: 'Righteous',
                              color: Colors.black38),
                        ),
                      )
                    ],
                  ),
                )
              : document.data()['type'] == 1
                  ? Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width * 70),
                            child: Card(
                              color: document.data()['isseen']
                                  ? corecolor
                                  : Colors.white,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                // topRight: Radius.circular(30),
                                // bottomLeft: Radius.circular(30),
                              )),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => FullView(
                                              photourl:
                                                  document.data()['msg'])));
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        // color: corecolor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: SpinKitCircle(
                                          color: corecolor,
                                        ),
                                        // width: width * 40,
                                        height: height * 20,
                                        // height: 200.0,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Material(
                                        child: Text('image not available'),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      imageUrl: document.data()['msg'],
                                      // width: width * 60,
                                      height: height * 30,
                                      fit: BoxFit.cover,
                                    ),
                                    margin: EdgeInsets.only(
                                      top: height * 1, bottom: height * 2,
                                      right: width * 1, left: width * 1,
                                      // bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                    )),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: width * 1),
                            child: Text(
                              tago.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(
                                    document.data()['timestamp'],
                                  ),
                                ),
                              ),
                              // textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: width * 2,
                                  fontFamily: 'Righteous',
                                  color: Colors.black38),
                            ),
                          )
                        ],
                      ),
                    )
                  : Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width * 70),
                            child: Card(
                              color: document.data()['isseen']
                                  ? corecolor
                                  : Colors.white,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                // topRight: Radius.circular(30),
                                // bottomLeft: Radius.circular(30),
                              )),
                              child: Container(
                                  decoration: BoxDecoration(
                                      // color: corecolor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: SpinKitCircle(
                                            color: corecolor,
                                          ),
                                          // width: width * 60,
                                          height: height * 30,
                                          // height: 200.0,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Material(
                                          child: Text('image not available'),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        imageUrl: document.data()['msg'],
                                        // width: width * 60,
                                        height: height * 20,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                          top: height * 17,
                                          child: Image.asset(
                                            'images/logo1.png',
                                            height: height * 3,
                                            // color: corecolor,
                                          ))
                                    ],
                                  ),
                                  margin: EdgeInsets.only(
                                    top: height * 1, bottom: height * 2,
                                    right: width * 1, left: width * 1,
                                    // bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: width * 1),
                            child: Text(
                              tago.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(
                                    document.data()['timestamp'],
                                  ),
                                ),
                              ),
                              // textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: width * 2,
                                  fontFamily: 'Righteous',
                                  color: Colors.black38),
                            ),
                          )
                        ],
                      ),
                    )
        ],
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if (index > 0 &&
            listmessage != null &&
            listmessage[index - 1].data()['idFrom'] == widget.myId ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listmessage != null &&
            listmessage[index - 1].data()['idFrom'] != widget.myId ||
        index == 0)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(myid)
          .update({'lchattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  // Future<bool> onBackPress() {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.myId)
  //       .update({'chattingwith': null});
  //   Navigator.pop(context);
  // }

  options() {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    var corecolor = Color.fromRGBO(252, 90, 39, 1);
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
              content: Container(
                height: height * 20,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SimpleDialogOption(
                        onPressed: () {
                          getImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Camera',
                          style: TextStyle(
                            fontFamily: 'Righteous',
                            fontWeight: FontWeight.normal,
                            fontSize: width * 5,
                          ),
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          getImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Gallery',
                          style: TextStyle(
                            fontFamily: 'Righteous',
                            fontWeight: FontWeight.normal,
                            fontSize: width * 5,
                          ),
                        ),
                      ),
                      SimpleDialogOption(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Righteous',
                            fontWeight: FontWeight.normal,
                            fontSize: width * 5,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ]),
              ),
            ));
  }

  // pushtopeer() {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.peerId)
  //       .collection('lchat-users')
  //       .doc(DateTime.now().toString())
  //       .set({
  //     'lchatuserid': widget.myId,
  //     'lchatphotourl': myphoto,
  //     'lchatnickname': myname,
  //     'lchatdevtoken': mytoken,
  //   });
  // }

  // buildemoticon() {

  //   return Expanded(
  //   child: ChatPickers(

  //     giphyPickerConfig: GiphyPickerConfig(
  //         apiKey: 'w7wdzb32s8Ya4FUDkVEk8K9L56nO98EJ',
  //         lang: 'English',
  //         onSelected: (gif) {
  //           // print('1sturl${d.contentUrl}');
  //           // print('2' + d.bitlyGifUrl);
  //           // // print('3' + d.);
  //           // print('4' + d.sourcePostUrl);
  //           // print('5' + d.url);
  //           // print('6' + d.bitlyUrl);
  //           // print(d.sourceTld);
  //           onSendMessage(gif.images.original.url, 2);
  //         }),
  //     // chatController: msgC,
  //     emojiPickerConfig: EmojiPickerConfig(columns: 7),
  //   ),
  // );

  // }

  buildSticker() {
    return Expanded(
      child: ChatPickers(
        giphyPickerConfig: GiphyPickerConfig(
            apiKey: 'w7wdzb32s8Ya4FUDkVEk8K9L56nO98EJ',
            lang: 'English',
            onSelected: (gif) {
              // print('1sturl${d.contentUrl}');
              // print('2' + d.bitlyGifUrl);
              // // print('3' + d.);
              // print('4' + d.sourcePostUrl);
              // print('5' + d.url);
              // print('6' + d.bitlyUrl);
              // print(d.sourceTld);
              onSendMessage(gif.images.original.url, 2);
            }),
        // chatController: msgC,
        emojiPickerConfig: EmojiPickerConfig(columns: 7),
      ),
    );
    // final gif = await GiphyPicker.pickGif(
    //     context: context,
    //     apiKey: 'w7wdzb32s8Ya4FUDkVEk8K9L56nO98EJ',
    //     decorator: GiphyDecorator(
    //       giphyTheme: ThemeData.light(),
    //     ),
    //     fullScreenDialog: false,
    //     previewType: GiphyPreviewType.previewGif,
    //     showPreviewPage: true,
    //     sticker: true);

    // Image.network(gif.images.original.url, headers: {'accept': 'image/*'});

    // return Container(
    //   height: 200,
    //   child: EmojiPicker(
    //     rows: 3,
    //     columns: 7,
    //     buttonMode: ButtonMode.MATERIAL,
    //     // recommendKeywords: ["racing", "horse"],
    //     numRecommended: 10,
    //     onEmojiSelected: (emoji, category) {
    //       print(emoji);
    //     },
    //   ),
    // );
  }

  // Widget buildSticker() {
  //   print('inini');
  //   return Container(
  //     height: 70,
  //     child: EmojiPicker(
  //       //context: context,
  //       rows: 150,
  //       columns: emojiPickerConfig.columns,
  //       buttonMode: ButtonMode.MATERIAL,
  //       numRecommended: emojiPickerConfig.numRecommended,
  //       bgBarColor: emojiPickerConfig.bgBarColor,
  //       bgColor: emojiPickerConfig.bgColor,
  //       indicatorColor: emojiPickerConfig.indicatorColor,
  //       onEmojiSelected: (emoji, category) {
  //         // setState(() {
  //         msgC.text += emoji.emoji;
  //         //});

  //         // print(_messageText);
  //       },
  //     ),
  //   );
  // }

  // Widget buildSticker() {
  //   var height = MediaQuery.of(context).size.height / 100;
  //   var width = MediaQuery.of(context).size.width / 100;
  //   var corecolor = Color.fromRGBO(252, 90, 39, 1);

  //   //implement everything here
  //   return EmojiPicker(
  //       // onEmojiSelected: (Emoji emoji, d) {
  //       //   print('emoji');
  //       // },
  //       columns: 7, // default is 7
  //       bgBarColor: Colors.red, // top/bottom bar color
  //       bgColor: Colors.blue,
  //       indicatorColor: Colors.green);
  // }

  Widget buildInput() {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    var corecolor = Color.fromRGBO(252, 90, 39, 1);
    // if(FirebaseFirestore.instance
    //               .collection('lchats')
    //               .doc(groupchatid)
    //               .collection(groupchatid).snapshots().)

    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        child: Row(
          children: [
           

            Padding(
              padding: EdgeInsets.all( width * 1),
              child: 
                 IconButton(
                   onPressed: () async {
                     if (await ConnectivityWrapper.instance.isConnected) {
                    setState(() {
                      isShowSticker = !isShowSticker;
                    });
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
                  icon: Icon(Icons.gif,
                  color: corecolor,
                  size: width * 10,)
                ),
              ),
            

            // SizedBox(
            //   width: width * 2,
            // ),
            Container(
              // color: Colors.blue,
              // height: height * 13,
              width: width * 55,
              alignment: Alignment.center,
              child: TextFormField(maxLines: null,
                focusNode: focusnode,
                controller: msgC,
                cursorColor: Colors.black,
                style: TextStyle(
                  fontFamily: 'JosefinSans',
                  fontSize: width * 5,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '      Type a message',
                    hintStyle: TextStyle(
                      color: Colors.black26,
                      fontFamily: 'Righteous',
                      fontSize: width * 5,
                    )),
              ),
            ),
            // SizedBox(
            //   width: width * 8,
            // ),
            
             IconButton(
               onPressed: () async {
                 if (msgC.text.trim() == '') {
                  return null;
                } else {
                  if (await ConnectivityWrapper.instance.isConnected) {
                    print('internet is on');
                    onSendMessage(msgC.text, 0);
                    msgC.clear();
                  } else {
                    print('no internet');
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

               icon: Icon( Icons.send,
                color: corecolor,
                size: width * 8,),
              
            ),
            // SizedBox(
            //   width: width * 2,
            // ),

            IconButton(
              onPressed: () async {
                if (await ConnectivityWrapper.instance.isConnected) {
                  options();
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
               icon: Icon( Icons.camera_alt,
                color: corecolor,
                size: width * 8,
              ),
            ),
          ],
        ),
        // height: height * 6,
        width: width * 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }



  //needs to
  //be
  //updated

  Widget buildListMessage() {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    return Flexible(
      child: groupchatid == ''
          ? Center(
              child: SpinKitCircle(
              color: corecolor,
            ))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('lchats')
                  .doc(groupchatid)
                  .collection(groupchatid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: SpinKitCircle(
                    color: corecolor,
                  ));
                } else if (snapshot.data.docs.length == 0) {
                  return Container();
                  // showinput = false;

                  // return Stack(
                  //   children: [
                  //     Positioned(
                  //       top: height * 72,
                  //       // left: width * 2,
                  //       child: InkWell(
                  //         onTap: () {
                  //           pushtopeer();

                  //           // NotificationController.instance
                  //           //     .notifylchatuser(myname, peerToken);
                  //           onSendMessage('Hey from $myname');

                  //           print('send first notification to peer user');
                  //         },
                  //         child: Card(
                  //           elevation: 20,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(30)),
                  //           child: Container(
                  //             alignment: Alignment.center,
                  //             child: Text(
                  //               'Start Convo',
                  //               style: TextStyle(
                  //                   fontFamily: 'Righteous',
                  //                   fontWeight: FontWeight.bold,
                  //                   color: corecolor,
                  //                   fontSize: width * 8),
                  //             ),
                  //             decoration: BoxDecoration(
                  //                 // color: Colors.blue,
                  //                 borderRadius: BorderRadius.circular(30)),
                  //             height: height * 8,
                  //             width: width * 100,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // );
                } else {
                  // showinput = true;

                  for (var data in snapshot.data.documents) {
                    if (data['idTo'] == myid && data['isseen'] == false) {
                      if (data.reference != null) {
                        FirebaseFirestore.instance
                            .runTransaction((Transaction myTransaction) async {
                          await myTransaction
                              .update(data.reference, {'isseen': true});
                        });
                      }
                    }
                  }
                  Timer(Duration(minutes: 1), () {
                    print('deletion init');
                    for (var data in snapshot.data.documents) {
                      if (data['idFrom'] == myid && data['isseen'] == true) {
                        if (data.reference != null) {
                          FirebaseFirestore.instance.runTransaction(
                              (Transaction myTransaction) async {
                            await myTransaction.delete(data.reference);
                          });
                        }
                      }
                    }
                  });

                  listmessage.addAll(snapshot.data.documents);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollcontroller,
                  );
                }
              },
            ),
    );
  }

  File imagepath;

  _pickImage(ImageSource s) async {
    var image = await ImagePicker.pickImage(source: s);
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

  mutenotifs() {
    if (notifstatus == true) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(myid)
          .collection('lchat-users')
          .doc(widget.docid)
          .update({'notif': false}).then((value) {
        setState(() {
          notifstatus = false;
        });
        Fluttertoast.showToast(msg: 'You will not recieve notifications');
        // Navigator.pop(context);
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(myid)
          .collection('lchat-users')
          .doc(widget.docid)
          .update({'notif': true}).then((value) {
        setState(() {
          notifstatus = true;
        });
        Fluttertoast.showToast(msg: 'You will recieve notifications');
        // Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 100;
    var width = MediaQuery.of(context).size.width / 100;
    var corecolor = Color.fromRGBO(252, 90, 39, 1);
    return VisibilityDetector(
      key: Key('1'),
      onVisibilityChanged: ((visibility) {
        print('ChatRoom Visibility code is ' + '${visibility.visibleFraction}');
        if (visibility.visibleFraction == 1.0) {
          FirebaseController.instance.getUnreadMSGCount();
        }
      }),
      child: WillPopScope(
        onWillPop: onBackPress,
        child: Scaffold(
          appBar: AppBar(title: 
          Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CachedNetworkImage(
                        imageUrl: widget.peerAvatar,
                        imageBuilder: (context, imageProvider) =>
                            CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: width * 5,
                        ),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error),
                          ),
              SizedBox(width: width*2,),
              Column(
                children: [
                  Text(widget.peernickname, style: TextStyle(fontFamily: 'Blinker', fontWeight: FontWeight.bold, ),
                  ),
                   StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.peerId)
                          .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                          return Container();
                      }
                      return snapshot.data.data()['isonline']
                      // ? Padding(
                      //   padding:  EdgeInsets.only(left: width*5.0),
                      //   child: CircleAvatar(backgroundColor: Colors.teal,radius: width*2,),
                      // )
                            ? Text(
                                  'online',
                                  style: TextStyle(
                                      fontSize: width * 3,
                                      color: Colors.white,
                                      fontFamily: 'Blinker'),
                                )
                            : Container();
                    }),

                ],
              ),
             

            ],
          ),actions: [
           Padding(
             padding: EdgeInsets.all(width*2),
             child: IconButton(
                            icon: Icon(
                              notifstatus == true
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: Colors.white,
                              size: width * 7,
                            ),
                            onPressed: () {
                              mutenotifs();
                            },
                          ),
           ),
          ],
          elevation: 0,),

          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                        
                    buildListMessage(),
                    (showload
                        ? Container(
                            child: Column(
                              children: [
                                Text(
                                  'Uploading Image',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Righteous'),
                                ),
                                SpinKitCircle(
                                  color: corecolor,
                                ),
                              ],
                            ),
                          )
                        : Container()),
                    //sticker
                    (isShowSticker ? buildSticker() : Container()),
                    buildInput(),

                    // buildInput(),
                    // Expanded(child: Container(
                    //   child: StreamBuilder(
                    //     stream: ,
                    //   ),
                    // )),

                    // Spacer(),

                    // Card(
                    //   elevation: 20,
                    //   shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(30)),
                    //   child: Container(
                    //     child: Row(
                    //       children: [
                    //         Container(
                    //           padding: EdgeInsets.only(left: width * 2),
                    //           child: Icon(
                    //             Icons.emoji_emotions_sharp,
                    //             color: corecolor,
                    //             size: width * 10,
                    //           ),
                    //         ),

                    //         Icon(
                    //           Icons.gif,
                    //           color: corecolor,
                    //           size: width * 10,
                    //         ),

                    //         // SizedBox(
                    //         //   width: width * 2,
                    //         // ),
                    //         Container(
                    //           // color: Colors.blue,
                    //           height: height * 13,
                    //           width: width * 55,
                    //           alignment: Alignment.center,
                    //           child: TextFormField(
                    //             focusNode: focusnode,
                    //             controller: msgC,
                    //             cursorColor: Colors.black,
                    //             style: TextStyle(
                    //               fontFamily: 'Righteous',
                    //               fontSize: width * 5,
                    //               color: Colors.black,
                    //             ),
                    //             decoration: InputDecoration(
                    //                 border: InputBorder.none,
                    //                 hintText: '      Type a message',
                    //                 hintStyle: TextStyle(
                    //                   color: Colors.black26,
                    //                   fontFamily: 'Righteous',
                    //                   fontSize: width * 5,
                    //                 )),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           width: width * 1,
                    //         ),
                    //         InkWell(
                    //           onTap: () {
                    //             if (msgC.text.trim() == '') {
                    //               return null;
                    //             } else {
                    //               onSendMessage(msgC.text);
                    //               msgC.clear();
                    //             }
                    //             msgC.clear();
                    //           },
                    //           child: Icon(
                    //             Icons.send,
                    //             color: corecolor,
                    //             size: width * 8,
                    //           ),
                    //         ),

                    //         InkWell(
                    //           onTap: options,
                    //           child: Icon(
                    //             Icons.camera_alt,
                    //             color: corecolor,
                    //             size: width * 8,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     height: height * 8,
                    //     width: width * 100,
                    //     decoration:
                    //         BoxDecoration(borderRadius: BorderRadius.circular(30)),
                    //   ),
                    // ),
                  ],
                ),
                //display only when chats are empty
                // Positioned(
                //   top: height * 80,
                //   left: width * 20,
                //   child: InkWell(
                //     splashColor: corecolor,
                //     onTap: () {},
                //     borderRadius: BorderRadius.circular(30),
                //     child: Card(
                //       elevation: 20,
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(30)),
                //       child: Container(
                //         alignment: Alignment.center,
                //         child: Text(
                //           'Start Convo',
                //           style: TextStyle(
                //               fontFamily: 'Righteous',
                //               fontWeight: FontWeight.bold,
                //               color: corecolor,
                //               fontSize: width * 6),
                //         ),
                //         decoration: BoxDecoration(
                //             // color: Colors.blue,
                //             borderRadius: BorderRadius.circular(30)),
                //         height: height * 8,
                //         width: width * 60,
                //       ),
                //     ),
                //   ),
                // ),
                

                Positioned(
                  top: height *0,
                  left: width * 5,
                  right: width*5,
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(90),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'seen messages will disappear after 1 minute',
                        style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'JosefinSans',
                            fontSize: width * 3.5),
                      ),
                      // margin: EdgeInsets.only(left: width * 10, top: height * 12),
                      height: height * 4,
                      width: width * 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        // color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
