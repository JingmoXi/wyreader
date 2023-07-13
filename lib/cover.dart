import 'dart:ffi';
import 'dart:typed_data';
import './screen/pdfscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Cover extends StatefulWidget {
  String url;
  int page;
  Uint8List image;
  String dir;
  Cover(this.url, this.page, this.image,this.dir);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CoverState();
  }
}

class _CoverState extends State<Cover> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      // color: Colors.blue,
      height: 100,
      width: 100,
      child: Center(
        child: Image.memory(widget.image, fit: BoxFit.fill),
      ),
      // child: GestureDetector(
      //   onTap: (){
      //
      //
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) {
      //           var pdf = Pdfscreen(widget.url,widget.page,widget.dir);
      //           return pdf;
      //         },
      //       ),
      //     );
      //
      //   },
      //   child: Center(
      //     child: Image.memory(widget.image, fit: BoxFit.fill),
      //   ),
      // ),
    );
  }
}
