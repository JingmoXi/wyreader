import 'dart:ffi';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:wyreader/screen/epub.dart';
import './modle/BookInfo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:pdfx/pdfx.dart';
import 'dart:convert';
import './screen/pdfscreen.dart';
import './cover.dart';
import 'package:provider/provider.dart';
import './common/CounterProvider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => CounterProvider(), child: const MyApp()));
}

//阅读器，阅读pdf、epub、aws3等网络资源。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var books = [];

  var bookinfospath;
  var dir;

  @override
  void initState() {
    super.initState();
    _getLocalBooks();

    print("init over");
    //构建图片信息
  }

  void _getLocalBooks() async {
    final docDir = await getApplicationDocumentsDirectory();
    final result = await docDir.path;
    dir = result;
    bookinfospath = result + "/" + "books.json";

    final file = File(bookinfospath);
    var exit = await file.exists();
    if (!exit) {
      file.create();
      return;
    }
    final jsonString = await file.readAsString();
    if (jsonString.isEmpty) {
      return;
    }
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    setState(() {
      books = jsonList.map((json) => BookInfo.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
        builder: (context, counter, child) => Scaffold(
              body: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 每行显示的子小部件数量
                ),
                itemBuilder: (BuildContext context, int index) {
                  BookInfo item = books[index];
                  Future<Widget> _buildItem() async {
                    // 执行异步操作，例如获取数据或进行其他耗时任务

                    if(item.type=="pdf"){
                      final document = await PdfDocument.openFile(item.url);
                      final page = await document.getPage(1);
                      final pageImage = await page.render(
                          width: page.width, height: page.height);
                      await page.close();
                      var pagenum = await getBookCurrentPage(item.url);
                      return Consumer<CounterProvider>(
                          builder: (context, counter, child) => GestureDetector(
                              child:
                              Cover(item.url, pagenum, pageImage!.bytes, dir),
                              onTap: () {
                                //
                                setState(() {
                                  books.removeAt(index);
                                  books.insert(0, item);
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      var pdf = Pdfscreen(item.url, pagenum, dir);
                                      return pdf;
                                    },
                                  ),
                                );
                              }));
                    }else{
                      //处理epub文件格式数据,
                      EpubBook epubBook= await EpubDocument.openFile(File(item.url));

                      var coverImage = epubBook.CoverImage;
                      //var pagenum = await getBookCurrentPage(item.url);
                      return Consumer<CounterProvider>(
                          builder: (context, counter, child) => GestureDetector(
                              child: coverImage as Widget,

                              onTap: () {
                                //
                                setState(() {
                                  books.removeAt(index);
                                  books.insert(0, item);
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      //var pdf = Pdfscreen(item.url, pagenum, dir);
                                      //return pdf;
                                      return WyEpubPage( url: item.url);

                                    },
                                  ),
                                );
                              }));
                    }

                  }

                  return FutureBuilder<Widget>(
                    future: _buildItem(),
                    builder:
                        (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // 异步操作尚未完成，可以显示加载指示器或占位符
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // 处理异步操作中的错误
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // 异步操作已完成，返回构建好的列表项小部件
                        return snapshot.data!;
                      }
                    },
                  );
                },
                itemCount: books.length,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  var book = await _addbook();
                  var page = await getBookCurrentPage(book.url);
                  if (!book.url.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          var pdf = Pdfscreen(book.url, page, dir);
                          return pdf;
                        },
                      ),
                    );
                  }
                },
                tooltip: 'AddBook',
                child: const Icon(Icons.add),
              ), // This trailing comma makes auto-formatting nicer for build methods.
            ));
    // return Scaffold(
    //   body: GridView.builder(
    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 3, // 每行显示的子小部件数量
    //     ),
    //     itemBuilder: (BuildContext context, int index) {
    //       BookInfo item = books[index];
    //
    //       Future<Widget> _buildItem() async {
    //         // 执行异步操作，例如获取数据或进行其他耗时任务
    //         final document = await PdfDocument.openFile(item.url);
    //         final page = await document.getPage(1);
    //         final pageImage = await page.render(width: page.width, height: page.height);
    //         await page.close();
    //         var pagenum = await getBookCurrentPage(item.url);
    //
    //         return Consumer<CounterProvider>(
    //             builder: (context, counter, child) => GestureDetector(
    //                 child: Cover(item.url, pagenum, pageImage!.bytes, dir), onTap: () {
    //               //
    //               setState(() {
    //                 books.removeAt(index);
    //                 books.insert(0, item);
    //               });
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (context) {
    //                     var pdf = Pdfscreen(item.url, pagenum, dir);
    //                     return pdf;
    //                   },
    //                 ),
    //               );
    //             })
    //         );
    //       }
    //
    //       return FutureBuilder<Widget>(
    //         future: _buildItem(),
    //         builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             // 异步操作尚未完成，可以显示加载指示器或占位符
    //             return CircularProgressIndicator();
    //           } else if (snapshot.hasError) {
    //             // 处理异步操作中的错误
    //             return Text('Error: ${snapshot.error}');
    //           } else {
    //             // 异步操作已完成，返回构建好的列表项小部件
    //             return snapshot.data!;
    //           }
    //         },
    //       );
    //     },
    //     itemCount: books.length,
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () async {
    //       var book = await _addbook();
    //       var page = await getBookCurrentPage(book.url);
    //       if (!book.url.isEmpty) {
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) {
    //               var pdf = Pdfscreen(
    //                   book.url, page, dir
    //               );
    //               return pdf;
    //             },
    //           ),
    //         );
    //       }
    //     },
    //     tooltip: 'AddBook',
    //     child: const Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );
  }

  Future<PdfPageImage?> renderPdfCover(String url) async {
    final document = await PdfDocument.openFile(url);
    final page = await document.getPage(1);
    final pageImage = await page.render(width: page.width, height: page.height);
    await page.close();
    return pageImage;
  }

  Future<BookInfo> _addbook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      print('Selected file: $filePath');
      var book = BookInfo(pdf, filePath);
      if (filePath.endsWith("pdf")) {
        //
        book = BookInfo(pdf, filePath);
      } else if (filePath.endsWith("epub")) {
        //
        book = BookInfo(epub, filePath);
      } else {
        return BookInfo("", "");
      }
      setState(() {
        books.add(book);
      });

      final jsonList = books.map((book) => book.toMap()).toList();
      final jsonString = jsonEncode(jsonList);
      final file = File(bookinfospath);
      file.writeAsStringSync('');
      file.writeAsStringSync(jsonString);
      //
      //持久化
      return book;
    } else {
      //
      print('No file selected.');
    }
    return BookInfo("", "");
  }

  Future<int> getBookCurrentPage(String url) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(url);
    final file = File(dir + Platform.pathSeparator + encoded);
    if (!await file.exists()) {
      return 1;
    }
    String contents = await file.readAsString();
    if (contents.isEmpty) {
      return 1;
    }
    int? number = int.tryParse(contents);
    if (number != null) {
      // 成功解析为整数
      return number!;
    } else {
      // 字符串无法解析为整数
      return 1;
    }
  }
}
