import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../configure_api.dart';

class ReceiptParserApiService {
  final http.Client _client = http.Client();

  Future<http.Response> sendReceiptText(String text,String token) async {
    String url = '${AppConfig.baseUrl}/parse-receipt';

    return await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
      body: jsonEncode({'text': text}),
    );
  }

  Future<http.Response> uploadPdf(File pdfFile, String token) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/upload-receipt');

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'receipt',
      pdfFile.path,
      contentType: MediaType('application', 'pdf'),
    ));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }


  void dispose() {
    _client.close();
  }
}
