import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../configure_api.dart';

class TaxReliefCallApi {
  final http.Client _httpClient = http.Client();

  Future<http.Response> fetchTotalCanClaim(String token) async {
    final endpoint = '/taxRelief/getTotalCanClaim';
    final url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> fetchTotalEligibleClaim(
    int userid,
    String token,
  ) async {
    final endpoint = '/taxRelief/getTotalEligibleClaim/$userid';
    final url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> fetchTaxReliefCategory(int userid, String token) async {
    final endpoint = '/taxRelief/getTaxReliefCategory/$userid';
    final url = '${AppConfig.baseUrl}$endpoint';
    print(url);
    return await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> fetchReliefTypeInfo(int categoryid, String token) async{
    final endpoint = '/taxRelief/getReliefTypeInfo/$categoryid';
    final url = '${AppConfig.baseUrl}$endpoint';
    print(url);
    return await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> fetchReliefCategoryInfo(int categoryid, String token) async{
    final endpoint = '/taxRelief/getReliefCategoryInfo/$categoryid';
    final url = '${AppConfig.baseUrl}$endpoint';
    print(url);
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
