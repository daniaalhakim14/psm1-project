import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../configure_api.dart';

class ReceiptParserApiService {
  final http.Client _client = http.Client();

  Future<http.Response> sendReceiptText(String text) async {
    String url = '${AppConfig.baseUrl}/parse-receipt';

    return await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
  }

  Future<http.Response> uploadPdf(File pdfFile) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/upload-receipt');

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(
      'receipt',
      pdfFile.path,
      contentType: MediaType('application', 'pdf'),
    ));

    // Send request
    final streamedResponse = await request.send();

    // Convert to full response to access body
    return await http.Response.fromStream(streamedResponse);
  }

  void dispose() {
    _client.close();
  }
}
