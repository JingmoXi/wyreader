import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../common/CounterProvider.dart';

class Pdfscreen extends StatefulWidget {
  String url;
  int page;
  String dir;

  @override
  _Pdfscreen createState() => _Pdfscreen();

  Pdfscreen(this.url, this.page, this.dir);
}

class _Pdfscreen extends State<Pdfscreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late PdfTextSearchResult _searchResult;
  late PdfViewerController _pdfViewerController;
  var _counter;

  int tmp = 0;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    _searchResult = PdfTextSearchResult();
    super.initState();
  }

  // late OverlayEntry _overlayEntry=OverlayEntry(builder: builder);
  OverlayEntry? _overlayEntry;

  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState _overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion!.center.dy - 55,
        left: details.globalSelectedRegion!.bottomLeft.dx,
        child: ElevatedButton(
            child: Text('Copy', style: TextStyle(fontSize: 17)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: details.selectedText!));
              _pdfViewerController.clearSelection();
            }),
      ),
    );
    _overlayState.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    _counter = Provider.of<CounterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Syncfusion Flutter PDF Viewer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              _searchResult = _pdfViewerController.searchText(
                'the',
              );

              _searchResult.addListener(() {
                if (_searchResult.hasResult) {
                  setState(() {});
                }
              });
            },
          ),
          Visibility(
            visible: _searchResult.hasResult,
            child: IconButton(
              icon: const Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _searchResult.clear();
                });
              },
            ),
          ),
          Visibility(
            visible: _searchResult.hasResult,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
              onPressed: () {
                _searchResult.previousInstance();
              },
            ),
          ),
          Visibility(
            visible: _searchResult.hasResult,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              onPressed: () {
                _searchResult.nextInstance();
              },
            ),
          ),
        ],
      ),
      body: Listener(
          onPointerSignal: (PointerSignalEvent event) {
            if (tmp % 10 == 0) {
              Provider.of<CounterProvider>(context, listen: false).increment();
            }
            tmp++;
          },
          child: SfPdfViewer.file(
            File(widget.url),
            enableTextSelection: true,
            // 允许文本选择
            controller: _pdfViewerController,
            onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
              if (details.selectedText == null && _overlayEntry != null) {
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  // _overlayEntry.dispose()
                }

                _overlayEntry = null;
              } else if (details.selectedText != null &&
                  _overlayEntry == null) {
                _showContextMenu(context, details);
              }
            },
            onPageChanged: (PdfPageChangedDetails details) {
              //更新文件
              updateBookPage(widget.url, details.newPageNumber, widget.dir);
            },
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              _pdfViewerController.jumpToPage(widget.page);
            },
          )),
    );
  }

  void updateBookPage(String url, int page, String dir) {
    if (tmp % 3 != 0) {
      return;
    }
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(url);
    final file = File(dir + Platform.pathSeparator + encoded);
    file.writeAsStringSync('');
    file.writeAsStringSync(page.toString());
  }
}
