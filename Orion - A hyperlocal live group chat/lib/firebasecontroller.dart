import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseController {
  static FirebaseController get instance => FirebaseController();

  Future<int> getUnreadMSGCount([String peerUserID, String chatId]) async {
    try {
      String targetID = '';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      peerUserID == null
          ? targetID = (prefs.getString('id') ?? 'NoId')
          : targetID = peerUserID;
      print('peeruserid$peerUserID');
      print('peeruserid$chatId');
      int unReadMSGCount = 0;
      final QuerySnapshot chatListResult = await FirebaseFirestore.instance
          .collection('lchats')
          .doc(chatId)
          .collection(chatId)
          .get();
      final List<DocumentSnapshot> chatListDocuments = chatListResult.docs;
      //algorith for getting unread messages for one to one chat....
      for (var data in chatListDocuments) {
        final QuerySnapshot unReadMSGDocument = await FirebaseFirestore.instance
            .collection('lchats')
            .doc(chatId)
            .collection(chatId)
            .where('idTo', isEqualTo: targetID)
            .where('isseen', isEqualTo: false)
            .get();

        final List<DocumentSnapshot> unReadMSGDocuments =
            unReadMSGDocument.docs;
        unReadMSGCount = unReadMSGDocuments.length;
      }
      // print('unread MSGleng count is ${}');
      print('unread MSG count is $unReadMSGCount');
//      }
      if (targetID == null) {
        print('a');
        FlutterAppBadger.updateBadgeCount(unReadMSGCount);
        // AppBadge.setAppBadge(unReadMSGCount);
        // ScheduleBadgeUpdates.setBadge(4);
        return null;
      } else {
        print('b');
        // FlutterAppBadger.updateBadgeCount(unReadMSGCount);
        // ScheduleBadgeUpdates.setBadge(4);

        return unReadMSGCount;
      }
    } catch (e) {
      print(e.message);
    }
  }

//   Future<int> getUnreadMSGCountschat([String peerUserID, String chatId]) async {
//     try {
//       int unReadMSGCount = 0;
//       // String targetID = '';
//       // SharedPreferences prefs = await SharedPreferences.getInstance();

//       // peerUserID == null
//       //     ? targetID = (prefs.get('userId') ?? 'NoId')
//       //     : targetID = peerUserID;
// //      if (targetID != 'NoId') {
//       final QuerySnapshot chatListResult = await FirebaseFirestore.instance
//           .collection('chatroom')
//           .doc(chatId)
//           .collection(chatId)
//           .get();
//       final List<DocumentSnapshot> chatListDocuments = chatListResult.docs;
//       //algorith for getting unread messages for one to one chat....
//       for (var data in chatListDocuments) {
//         final QuerySnapshot unReadMSGDocument = await FirebaseFirestore.instance
//             .collection('chatroom')
//             .doc(chatId)
//             .collection(chatId)
//             .where('idTo', isEqualTo: peerUserID)
//             .where('isseen', isEqualTo: false)
//             .get();

//         final List<DocumentSnapshot> unReadMSGDocuments =
//             unReadMSGDocument.docs;
//         unReadMSGCount = unReadMSGCount + unReadMSGDocuments.length;
//       }
//       print('unread MSG count is $unReadMSGCount');
// //      }
//       if (peerUserID == null) {
//         FlutterAppBadger.updateBadgeCount(unReadMSGCount);
//         return null;
//       } else {
//         return unReadMSGCount;
//       }
//     } catch (e) {
//       print(e.message);
//     }
//   }
}
