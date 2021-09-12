import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';

class FullView extends StatefulWidget {
  final String photourl;

  const FullView({Key key, this.photourl}) : super(key: key);
  @override
  _FullViewState createState() => _FullViewState();
}

class _FullViewState extends State<FullView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: PhotoView(
        loadingBuilder: (c, d) {
          return SpinKitCircle(
            color: Theme.of(context).primaryColor,
          );
        },
        imageProvider: NetworkImage(widget.photourl),
      )),
    );
  }
}
