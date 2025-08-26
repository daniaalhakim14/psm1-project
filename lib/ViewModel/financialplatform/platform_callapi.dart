import 'package:http/http.dart' as http;

import '../../configure_api.dart';

class platform_callapi{
  final http.Client _httpClient = http.Client();

  // Financial Platform Categories
  Future<http.Response>fetchFPCategories() async {
    String endpoint = '/categories';
    String url = '${AppConfig.baseUrl}$endpoint';
    //print(url);
    return await http.get(Uri.parse(url));
  }

  Future<http.Response> fetchViewExpenseFinancialPlatform(int userid, String token)async{
    String endpoint = '/expense/financialPlatform/$userid'; // to change
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(Uri.parse(url),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'}
    );
  }

  // Add a dispose method to clean up
  void dispose() {
    _httpClient.close(); // Close the HTTP client to release resources
    print("HTTP client closed.");
  }
}