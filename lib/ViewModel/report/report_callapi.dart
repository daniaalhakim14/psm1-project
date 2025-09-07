import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../configure_api.dart';

class ReportCallApi {
  final http.Client _httpClient = http.Client();

  // Fetch expense summary for spending analysis
  Future<http.Response> fetchExpenseSummary({
    required int userId,
    required String period,
    required int year,
    int? month,
    required String token,
    String tz = 'Asia/Kuala_Lumpur',
  }) async {
    String endpoint = '/reports/expenses/summary';
    String url = '${AppConfig.baseUrl}$endpoint';

    // Build query parameters
    Map<String, String> queryParams = {
      'userId': userId.toString(),
      'period': period,
      'year': year.toString(),
      'tz': tz,
    };

    if (month != null) {
      queryParams['month'] = month.toString();
    }

    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    print('📊 Fetching expense summary from: $uri');

    return await _httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Fetch tax relief eligible expenses
  Future<http.Response> fetchTaxReliefEligible({
    required int userId,
    required int year,
    required String token,
    String tz = 'Asia/Kuala_Lumpur',
  }) async {
    String endpoint = '/reports/taxrelief/eligible';
    String url = '${AppConfig.baseUrl}$endpoint';

    // Build query parameters
    Map<String, String> queryParams = {
      'userId': userId.toString(),
      'year': year.toString(),
      'tz': tz,
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    print('🏛️ Fetching tax relief eligible from: $uri');
    print('📋 Request details:');
    print('   🌐 Base URL: ${AppConfig.baseUrl}');
    print('   🔗 Endpoint: $endpoint');
    print('   🎯 Full URL: $uri');
    print('   📊 Query Params: $queryParams');
    print('   🔑 Authorization: Bearer ${token.substring(0, 10)}...');

    try {
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📱 Tax Relief API Call Complete:');
      print('   📊 Status: ${response.statusCode}');
      print('   📏 Response Size: ${response.body.length} chars');
      print(
        '   🔍 Response Preview: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}',
      );

      return response;
    } catch (e) {
      print('💥 Error in fetchTaxReliefEligible API call: $e');
      print('📍 Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Generate and download PDF report
  Future<http.Response> generatePdfReport({
    required int userId,
    required String period,
    required int year,
    int? month,
    required String token,
    String tz = 'Asia/Kuala_Lumpur',
  }) async {
    String endpoint = '/reports/pdf';
    String url = '${AppConfig.baseUrl}$endpoint';

    // Build request body
    Map<String, dynamic> requestBody = {
      'userId': userId,
      'period': period,
      'year': year,
      'tz': tz,
    };

    if (month != null) {
      requestBody['month'] = month;
    }

    print('📄 Generating PDF report for user $userId');

    return await _httpClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
  }

  // Clean up resources
  void dispose() {
    _httpClient.close();
    print("🧹 ReportCallApi HTTP client closed.");
  }
}
