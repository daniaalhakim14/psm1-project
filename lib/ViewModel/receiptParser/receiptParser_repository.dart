import 'dart:convert';
import 'dart:io';
import 'receiptParser_callApi.dart';

class ReceiptParserRepository {
  final ReceiptParserApiService _service = ReceiptParserApiService();

  Future<Map<String, dynamic>?> parseReceipt(String text) async {
    final response = await _service.sendReceiptText(text);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['data'] ?? result['raw'];
    } else {
      print("Error parsing receipt: ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadReceiptPdf(File pdfFile) async {
    try {
      final response = await _service.uploadPdf(pdfFile);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("PDF uploaded successfully!");
        //print("📦 Full response body: $result");

        final extracted = result['data'] ?? result['raw'];
        //print("🧾 Extracted parsed result: $extracted");

        return extracted;
        /*
        final result = json.decode(response.body);
        print("PDF uploaded successfully!");
        return result['data'] ?? result['raw'];
        */
      } else {
        print("Upload failed: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception during upload: $e");
      return null;
    }
  }


  void dispose() => _service.dispose();
}
