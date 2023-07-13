
import 'package:flutter/cupertino.dart';

class BookInfo {


  String type;

  String url;

  BookInfo( this.type, this.url);

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
    };
  }

  factory BookInfo.fromJson(Map<String, dynamic> json) {
    return BookInfo(json['type'], json['url']);
  }

}

const String pdf="pdf";
const String epub="epub";






