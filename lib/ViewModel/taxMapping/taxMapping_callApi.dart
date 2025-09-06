// Service class
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../configure_api.dart';

class TaxMappingAPI {
  final http.Client _httpClient = http.Client();

  Future<http.Response> mapTaxFromExpense(
    Map<String, dynamic> expensePayload,
    String token,
  ) async {
    String endpoint =
        '/taxMapping/mapTax'; // Updated to match your backend route
    String url = '${AppConfig.baseUrl}$endpoint';

    print(
      "Sending tax mapping data: $expensePayload",
    ); // Log the data being sent

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expensePayload),
    );

    print("Tax mapping response status: ${response.statusCode}");
    print(
      "Tax mapping response body: ${response.body}",
    ); // Log the response body

    return response;
  }

  // Add a dispose method to clean up
  void dispose() {
    _httpClient.close(); // Close the HTTP client to release resources
    print("TaxMapping HTTP client closed.");
  }
}
