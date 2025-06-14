import 'package:http/http.dart' as http;

import '../../configure_api.dart';

class itemPrice_callapi {
  final http.Client _httpClient = http.Client();

  Future<http.Response> fetchItemPrice() async {
    String endpoint = '/itemPrice';
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(Uri.parse(url));
  }

  Future<http.Response> fetchItemSearch(String searchTerm) async {
    //String endpoint = '/itemSearch?searchTerm=$searchTerm';
    String endpoint = '/itemPrice/itemSearch?searchTerm=$searchTerm';
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(Uri.parse(url));
  }
}
