import 'package:http/http.dart' as http;
import 'dart:convert';

class TaxMappingAPI {
  Future<http.Response> mapTaxFromExpense(Map<String, dynamic> expensePayload, String token) async {
    final url = 'http://localhost:3000/taxRelief/mapTaxFromExpense'; // Your API endpoint

    return await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expensePayload),
    );
  }
}
