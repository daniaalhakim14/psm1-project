import 'dart:convert';
import '../../Model/taxRelief.dart';

import 'taxRelief_callApi.dart';

class TaxReliefRepository {
  final TaxReliefCallApi _service = TaxReliefCallApi();

  Future<List<TotalCanClaim>> getTotalCanClaim(String token) async {
    final response = await _service.fetchTotalCanClaim(token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<TotalCanClaim>.from(data.map((x) => TotalCanClaim.fromJson(x)));
    } else {
      throw Exception('Failed to fetch total relief: ${response.body}');
    }
  }

  Future<List<TotalEligibleClaim>> getTotalEligibleClaim(int userid, String token) async {
    final response = await _service.fetchTotalEligibleClaim(userid, token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // decode into List

      return List<TotalEligibleClaim>.from(
        data.map((x) => TotalEligibleClaim.fromJson(x)),
      );
    } else {
      throw Exception('Failed to fetch total eligible relief: ${response.body}');
    }
  }

  Future<List<TaxReliefCategory>> getTaxReliefCategory(int userid, String token) async {
    final response = await _service.fetchTaxReliefCategory(userid, token);
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🔍 TaxReliefCategory API Response: ${response.body}");
      return List<TaxReliefCategory>.from(
        data.map((x) => TaxReliefCategory.fromJson(x)),
      );
    } else {
      throw Exception('Failed to fetch total eligible relief: ${response.body}');
    }
  }

  Future<List<ReliefTypeInfo>> getReliefTypeInfo(int categoryid, String token)async{
    final response = await _service.fetchReliefTypeInfo(categoryid, token);
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🔍 ReliefTypeInfo API Response: ${response.body}");
      return List<ReliefTypeInfo>.from(
        data.map((x) => ReliefTypeInfo.fromJson(x)),
      );
    } else {
      throw Exception('Failed to fetchReliefTypeInfo: ${response.body}');
    }
  }

  Future<List<ReliefCategoryInfo>> getReliefCategoryInfo(int categoryid, String token)async{
    final response = await _service.fetchReliefCategoryInfo(categoryid, token);
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🔍 CategoryInfo API Response: ${response.body}");
      return List<ReliefCategoryInfo>.from(
        data.map((x) => ReliefCategoryInfo.fromJson(x)),
      );
    } else {
      throw Exception('Failed to fetchReliefCategoryInfo: ${response.body}');
    }
  }


  void dispose() {
    _service.dispose();
    print("🗑️ Repository cleaned up.");
  }
}