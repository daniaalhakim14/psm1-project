import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../configure_api.dart';

class activitylog_callApi{
  final http.Client _httpClient = http.Client();

  Future<http.Response> logActivity(Map<String,dynamic> activityLogData,String token) async{
    String endpoint = '/activitylog';
    String url = '${AppConfig.baseUrl}$endpoint';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type':'application/json',
        'Authorization': 'Bearer $token'},
      body: jsonEncode(activityLogData),
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}"); // Log the response body
    return response;
  }
}