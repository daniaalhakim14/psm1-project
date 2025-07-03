import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../configure_api.dart';

class TaxReliefCallApi {
  final http.Client _httpClient = http.Client();

  Future<http.Response> fetchTaxReliefs(String token) async {
    final endpoint = '/taxRelief/getTaxRelief';
    final url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
  Future<http.Response> fetchTaxReliefType(String token) async {
    final endpoint = '/taxRelief/getTaxReliefTypes';
    final url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
  }


  void dispose() {
    _httpClient.close();
    print("🔌 HTTP client closed for TaxReliefCallApi.");
  }
}