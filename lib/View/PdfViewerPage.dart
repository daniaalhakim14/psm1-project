import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

class PdfViewerPage extends StatefulWidget {
  final Uint8List pdfBytes;
  final String fileName; // e.g 'badminton_receipt.pdf'

  const PdfViewerPage(
      {super.key, required this.pdfBytes, this.fileName = 'receipt.pdf'});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage>{
  bool _saving = false;

  // Save to your app’s documents folder (safe on Android & iOS, no special storage permission).
  /*
  Future<String> _getAppSavePath(String fileName) async {
    // App-safe location (works on Android & iOS)
    if (Platform.isAndroid) {
      // External app dir is user-visible under Android/Android/data/<pkg>/files
      final dir = await getExternalStorageDirectory();
      final d = dir ?? await getApplicationDocumentsDirectory();
      return '${d.path}/$fileName';
    } else {
      final d = await getApplicationDocumentsDirectory();
      return '${d.path}/$fileName';
    }
  }

  Future<void> _saveBytesToFile() async {
    try {
      setState(() => _saving = true);
      final path = await _getAppSavePath(widget.fileName);
      final file = File(path);
      await file.writeAsBytes(widget.pdfBytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to: $path')),
      );
      // Optional: open immediately
      await OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
   */

  // Share/Save-As via the OS share sheet (lets the user put it in Downloads, Drive, etc.) using your existing printing package
  Future<void> _sharedPdf() async{
    // Opens the platform share sheet; user can save to Downloads/Drive/Files, etc
    await Printing.sharePdf(bytes: widget.pdfBytes,filename: widget.fileName);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'View Receipt',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5A7BE7),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Share / Download ',
            icon: const Icon(Icons.ios_share),
            onPressed: _sharedPdf,
          ),
          /*
          IconButton(
            tooltip: _saving ? 'Saving…' : 'Download',
            onPressed: _saving ? null : _saveBytesToFile,
            icon: _saving
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download),
          ),
          const SizedBox(width: 8),
           */
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SfPdfViewer.memory(widget.pdfBytes),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A7BE7),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}



