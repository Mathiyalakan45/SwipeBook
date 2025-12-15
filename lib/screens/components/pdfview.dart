import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';



class PdfView extends StatefulWidget {
 
   final String? pdfName;
  final String? pdfUrl;
  const PdfView({ super.key, this.pdfName,this.pdfUrl });


  @override

  
  State<PdfView> createState() => _PdfViewState();
}
PdfViewerController _pdfViewerController =PdfViewerController();
class _PdfViewState extends State<PdfView> {
   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
     @override
  void initState() {
  _pdfViewerController = PdfViewerController();
  super.initState();
  
  // On web, open PDF in new tab and go back
  if (kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      launchUrl(Uri.parse(widget.pdfUrl!), mode: LaunchMode.externalApplication);
      Navigator.pop(context);
    });
  }
}
  @override
  Widget build(BuildContext context) {
    // On web, show loading while redirecting
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black54,
          backgroundColor: Colors.white,
          title: Text(widget.pdfName!, style: TextStyle(color: Colors.black87)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Opening PDF in new tab...'),
            ],
          ),
        ),
      );
    }
    
   return Scaffold(
      appBar: AppBar(
        foregroundColor:Colors.black54 ,
        iconTheme: IconThemeData(color: Colors.black54),
        
       
        backgroundColor: Colors.white,
        title:  Text(widget.pdfName!,style: TextStyle(color: Colors.black87)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.black,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
          IconButton(
          icon: Icon(
            Icons.keyboard_arrow_up,
            color: Colors.black,
          ),
          onPressed: () {
            _pdfViewerController.previousPage();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          ),
          onPressed: () {
            _pdfViewerController.nextPage();
          },
        )
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl!,
        key: _pdfViewerKey,
        controller: _pdfViewerController,
      ),
    );
  }
}
/// Represents Homepage for Navigation
