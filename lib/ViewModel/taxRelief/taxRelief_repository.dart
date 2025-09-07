import 'dart:convert';
import '../../Model/taxRelief.dart';

import 'taxRelief_callApi.dart';

class TaxReliefRepository {
  final TaxReliefCallApi _service = TaxReliefCallApi();

  Future<List<TotalCanClaim>> getTotalCanClaim(String token) async {
    final response = await _service.fetchTotalCanClaim(token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<TotalCanClaim>.from(
        data.map((x) => TotalCanClaim.fromJson(x)),
      );
    } else {
      throw Exception('Failed to fetch total relief: ${response.body}');
    }
  }

  Future<List<TotalEligibleClaim>> getTotalEligibleClaim(
    int userid,
    String token,
  ) async {
    final response = await _service.fetchTotalEligibleClaim(userid, token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // decode into List

      return List<TotalEligibleClaim>.from(
        data.map((x) => TotalEligibleClaim.fromJson(x)),
      );
    } else {
      throw Exception(
        'Failed to fetch total eligible relief: ${response.body}',
      );
    }
  }

  Future<List<TaxReliefCategory>> getTaxReliefCategory(
    int userid,
    String token,
  ) async {
    final response = await _service.fetchTaxReliefCategory(userid, token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //print("🔍 TaxReliefCategory API Response: ${response.body}");
      return List<TaxReliefCategory>.from(
        data.map((x) => TaxReliefCategory.fromJson(x)),
      );
    } else {
      throw Exception('Failed to fetch Tax Relief category: ${response.body}');
    }
  }

  Future<List<TaxReliefItem>> getTaxReliefItem(
    int userid,
    int categoryid,
    String token,
  ) async {
    final response = await _service.fetchReliefItem(categoryid, userid, token);
    print("🚀 TaxReliefItem API Call Details:");
    print("   📍 URL: /taxRelief/getReliefItem/$categoryid/$userid");
    print("   👤 User ID: $userid");
    print("   🏷️ Category ID: $categoryid");
    print("   📱 Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🔍 TaxReliefItem API Response: ${response.body}");
      print("📊 Response Type: ${data.runtimeType}");
      print("📝 Data Length: ${data is List ? data.length : 'Not a List'}");

      if (data is List && data.isEmpty) {
        print("⚠️ Empty response - possible causes:");
        print("   • No eligible expenses found for this tax relief item");
        print("   • CategoryID $categoryid might not exist or have no items");
        print("   • UserID $userid might not have expenses for this category");
        print("   • Database query might need different parameters");
      }

      return List<TaxReliefItem>.from(
        data.map((x) => TaxReliefItem.fromJson(x)),
      );
    } else {
      print("❌ API Error: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to fetch Tax Relief Item: ${response.body}');
    }
  }

  void dispose() {
    _service.dispose();
    print("🗑️ Repository cleaned up.");
  }
}
