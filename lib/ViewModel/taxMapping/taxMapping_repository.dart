import 'dart:convert';
import 'package:fyp/ViewModel/taxMapping/taxMapping_callApi.dart';
import 'package:http/http.dart' as http;

import '../../Model/taxMapping.dart';

class TaxMappingRepository {
  final TaxMappingAPI _service = TaxMappingAPI();

  Future<MappedTaxRelief?> processTaxMapping(Map<String, dynamic> expensePayload, String token) async {
    final response = await _service.mapTaxFromExpense(expensePayload, token);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return MappedTaxRelief.fromJson(jsonData);
    } else {
      print('Tax mapping failed: ${response.body}');
      return null;
    }
  }
}
