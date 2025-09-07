import 'dart:convert';
import '../../Model/report.dart';
import 'report_callapi.dart';

class ReportRepository {
  final ReportCallApi _service = ReportCallApi();

  // Cache for storing last fetch results
  final Map<String, CachedResult> _cache = {};
  static const int cacheExpiryMinutes = 5;

  // Fetch expense summary with caching
  Future<ExpenseSummary> fetchExpenseSummary({
    required int userId,
    required String period,
    required int year,
    int? month,
    required String token,
  }) async {
    // Create cache key
    final cacheKey =
        'expense_summary_${userId}_${period}_${year}_${month ?? 'null'}';

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().isBefore(cached.expiry)) {
        print('📦 Using cached expense summary');
        return cached.data as ExpenseSummary;
      } else {
        _cache.remove(cacheKey);
      }
    }

    final response = await _service.fetchExpenseSummary(
      userId: userId,
      period: period,
      year: year,
      month: month,
      token: token,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📊 Expense summary API response: ${response.body}');

      final expenseSummary = ExpenseSummary.fromJson(data);

      // Cache the result
      _cache[cacheKey] = CachedResult(
        data: expenseSummary,
        expiry: DateTime.now().add(Duration(minutes: cacheExpiryMinutes)),
      );

      return expenseSummary;
    } else {
      // Throw error instead of using demo data
      throw Exception(
        'Failed to fetch expense summary: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Fetch tax relief eligible expenses with caching
  Future<TaxReliefEligibleReport> fetchTaxReliefEligible({
    required int userId,
    required int year,
    required String token,
  }) async {
    print('🚀 Starting fetchTaxReliefEligible request');
    print('   👤 User ID: $userId');
    print('   📅 Year: $year');
    print('   🔑 Token length: ${token.length}');

    // Create cache key
    final cacheKey = 'tax_relief_eligible_${userId}_$year';

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().isBefore(cached.expiry)) {
        print('📦 Using cached tax relief eligible');
        return cached.data as TaxReliefEligibleReport;
      } else {
        _cache.remove(cacheKey);
        print('🗑️ Removed expired cache entry');
      }
    }

    print('📡 Making API call to fetchTaxReliefEligible...');
    try {
      final response = await _service.fetchTaxReliefEligible(
        userId: userId,
        year: year,
        token: token,
      );

      print('📲 API Response received:');
      print('   📊 Status Code: ${response.statusCode}');
      print('   📏 Response Length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🏛️ Tax relief eligible API response: ${response.body}');

        final taxReliefReport = TaxReliefEligibleReport.fromJson(data);

        // Cache the result
        _cache[cacheKey] = CachedResult(
          data: taxReliefReport,
          expiry: DateTime.now().add(Duration(minutes: cacheExpiryMinutes)),
        );

        print('✅ Tax relief data parsed and cached successfully');
        return taxReliefReport;
      } else {
        print('❌ API Error Response:');
        print('   📊 Status Code: ${response.statusCode}');
        print('   📝 Error Body: ${response.body}');
        // Throw error instead of using demo data
        throw Exception(
          'Failed to fetch tax relief data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💥 Exception during tax relief API call: $e');
      print('📍 Exception type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Generate PDF report
  Future<List<int>> generatePdfReport({
    required int userId,
    required String period,
    required int year,
    int? month,
    required String token,
  }) async {
    final response = await _service.generatePdfReport(
      userId: userId,
      period: period,
      year: year,
      month: month,
      token: token,
    );

    if (response.statusCode == 200) {
      print('📄 PDF report generated successfully');
      return response.bodyBytes;
    } else {
      // Throw error instead of using demo PDF
      throw Exception(
        'Failed to generate PDF report: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Clear cache
  void clearCache() {
    _cache.clear();
    print('🧹 Report cache cleared');
  }

  // Clear expired cache entries
  void clearExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) => now.isAfter(value.expiry));
  }

  // Clean up resources
  void dispose() {
    _service.dispose();
    clearCache();
    print("🧹 ReportRepository disposed.");
  }
}

// Helper class for caching
class CachedResult {
  final dynamic data;
  final DateTime expiry;

  CachedResult({required this.data, required this.expiry});
}
