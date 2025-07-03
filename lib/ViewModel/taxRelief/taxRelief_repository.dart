import 'dart:convert';
import '../../Model/taxrelief.dart';
import 'taxRelief_callApi.dart';

class TaxReliefRepository {
  final TaxReliefCallApi _api = TaxReliefCallApi();

  Future<List<TaxRelief>> getTaxReliefs(String token) async {
    final response = await _api.fetchTaxReliefs(token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<TaxRelief>.from(
        data.map((json) => TaxRelief.fromJson(json)),
      );
    } else {
      print('API Error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch tax reliefs');
    }
  }
  Future<List<TaxRelief>> fetchTaxReliefType(String token) async {
    final response = await _api.fetchTaxReliefs(token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<TaxRelief>.from(
        data.map((json) => TaxRelief.fromJson(json)),
      );
    } else {
      print('API Error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch tax reliefs');
    }
  }



  void dispose() {
    _api.dispose();
    print("🗑️ Repository cleaned up.");
  }
}