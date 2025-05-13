// Service class
import 'dart:convert';
import 'package:http/http.dart'as http;
import '../../configure_api.dart';


class CallingApi{
// Indicates that the function is asynchronous and does not return a value.
// Instead, it returns a Future, which represents a potential value or error that will be available at some point in the future.

  final http.Client _httpClient = http.Client();

  Future<http.Response> fetchCategories() async{
    String endpoint = '/category';
    String url = '${AppConfig.baseUrl}$endpoint';
    //print(url);
    return await http.get(Uri.parse(url));
  }


// Add a dispose method to clean up
  void dispose() {
    _httpClient.close(); // Close the HTTP client to release resources
    print("HTTP client closed.");
  }

}
