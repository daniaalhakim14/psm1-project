import 'package:flutter/material.dart';
import '../../Model/report.dart';
import 'report_repository.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  // State variables
  bool _isLoadingExpenseSummary = false;
  bool _isLoadingTaxRelief = false;
  bool _isGeneratingPdf = false;

  bool get isLoadingExpenseSummary => _isLoadingExpenseSummary;
  bool get isLoadingTaxRelief => _isLoadingTaxRelief;
  bool get isGeneratingPdf => _isGeneratingPdf;
  bool get isLoading => _isLoadingExpenseSummary || _isLoadingTaxRelief;

  // Data
  ExpenseSummary? _expenseSummary;
  TaxReliefEligibleReport? _taxReliefReport;
  String? _errorMessage;

  ExpenseSummary? get expenseSummary => _expenseSummary;
  TaxReliefEligibleReport? get taxReliefReport => _taxReliefReport;
  String? get errorMessage => _errorMessage;

  // Filters
  ReportFilters _filters = ReportFilters(
    period: 'month',
    year: DateTime.now().year,
    month: DateTime.now().month,
  );

  ReportFilters get filters => _filters;

  // Update filters
  void updateFilters(ReportFilters newFilters) {
    _filters = newFilters;
    _errorMessage = null;
    notifyListeners();
  }

  // Set period filter (month or year)
  void setPeriod(String period, {int? month}) {
    _filters = ReportFilters(
      period: period,
      year: _filters.year,
      month: period == 'month' ? (month ?? _filters.month) : null,
    );
    _errorMessage = null;
    notifyListeners();
  }

  // Set year filter
  void setYear(int year) {
    _filters = ReportFilters(
      period: _filters.period,
      year: year,
      month: _filters.month,
    );
    _errorMessage = null;
    notifyListeners();
  }

  // Set month filter
  void setMonth(int month) {
    _filters = ReportFilters(
      period: 'month',
      year: _filters.year,
      month: month,
    );
    _errorMessage = null;
    notifyListeners();
  }

  // Quick filter presets
  void setThisMonth() {
    final now = DateTime.now();
    _filters = ReportFilters(period: 'month', year: now.year, month: now.month);
    _errorMessage = null;
    notifyListeners();
  }

  void setLastMonth() {
    final lastMonth = DateTime.now().subtract(Duration(days: 30));
    _filters = ReportFilters(
      period: 'month',
      year: lastMonth.year,
      month: lastMonth.month,
    );
    _errorMessage = null;
    notifyListeners();
  }

  void setYearToDate() {
    _filters = ReportFilters(period: 'year', year: DateTime.now().year);
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch expense summary
  Future<void> fetchExpenseSummary(int userId, String token) async {
    _isLoadingExpenseSummary = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenseSummary = await _repository.fetchExpenseSummary(
        userId: userId,
        period: _filters.period,
        year: _filters.year,
        month: _filters.month,
        token: token,
      );
      print('✅ Expense summary loaded successfully');
    } catch (e) {
      _errorMessage = 'Failed to load expense summary: $e';
      print('❌ Error loading expense summary: $e');
      _expenseSummary = null;
    } finally {
      _isLoadingExpenseSummary = false;
      notifyListeners();
    }
  }

  // Fetch tax relief eligible expenses
  Future<void> fetchTaxReliefEligible(int userId, String token) async {
    print('🎯 ReportViewModel.fetchTaxReliefEligible called');
    print('   👤 User ID: $userId');
    print('   📅 Filter Year: ${_filters.year}');
    print('   🔑 Token available: ${token.isNotEmpty}');

    _isLoadingTaxRelief = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📞 Calling repository.fetchTaxReliefEligible...');
      _taxReliefReport = await _repository.fetchTaxReliefEligible(
        userId: userId,
        year: _filters.year,
        token: token,
      );
      print('✅ Tax relief eligible loaded successfully');
      print(
        '   📊 Categories found: ${_taxReliefReport?.categories.length ?? 0}',
      );
    } catch (e) {
      _errorMessage = 'Failed to load tax relief data: $e';
      print('❌ Error loading tax relief data: $e');
      print('📍 Error type: ${e.runtimeType}');
      _taxReliefReport = null;
    } finally {
      _isLoadingTaxRelief = false;
      notifyListeners();
      print(
        '🏁 fetchTaxReliefEligible completed, loading: $_isLoadingTaxRelief',
      );
    }
  }

  // Fetch both reports
  Future<void> fetchAllReports(int userId, String token) async {
    print('🚀 ReportViewModel.fetchAllReports called');
    print('   👤 User ID: $userId');
    print('   🔑 Token length: ${token.length}');
    print(
      '   📅 Current filters: period=${_filters.period}, year=${_filters.year}, month=${_filters.month}',
    );

    await Future.wait([
      fetchExpenseSummary(userId, token),
      fetchTaxReliefEligible(userId, token),
    ]);

    print('🏁 fetchAllReports completed');
  }

  // Generate PDF report
  Future<List<int>?> generatePdfReport(int userId, String token) async {
    _isGeneratingPdf = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pdfBytes = await _repository.generatePdfReport(
        userId: userId,
        period: _filters.period,
        year: _filters.year,
        month: _filters.month,
        token: token,
      );
      print('✅ PDF report generated successfully');
      return pdfBytes;
    } catch (e) {
      _errorMessage = 'Failed to generate PDF report: $e';
      print('❌ Error generating PDF report: $e');
      return null;
    } finally {
      _isGeneratingPdf = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh(int userId, String token) async {
    _repository.clearCache();
    await fetchAllReports(userId, token);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Utility getters for quick access to key metrics
  double get totalSpent => _expenseSummary?.totals.sum ?? 0.0;
  double get dailyAverageCalendar =>
      _expenseSummary?.dailyAverageSpending.calendarDays ?? 0.0;
  double get dailyAverageActive =>
      _expenseSummary?.dailyAverageSpending.activeDays ?? 0.0;
  double get monthlyAverage => _expenseSummary?.monthlyAverageSpending ?? 0.0;
  String get biggestCategory =>
      _expenseSummary?.biggestExpenseCategory.name ?? '';
  String get mostUsedPlatformByCount =>
      _expenseSummary?.mostUsedFinancialPlatform.byCount.name ?? '';
  String get mostUsedPlatformByAmount =>
      _expenseSummary?.mostUsedFinancialPlatform.byAmount.name ?? '';

  // Tax relief totals
  double get totalTaxReliefEligible {
    if (_taxReliefReport == null) return 0.0;
    return _taxReliefReport!.categories
        .expand((category) => category.items)
        .fold(0.0, (sum, item) => sum + item.itemTotalEligible);
  }

  double get totalTaxReliefLimit {
    if (_taxReliefReport == null) return 0.0;
    return _taxReliefReport!.categories
        .expand((category) => category.items)
        .fold(0.0, (sum, item) => sum + item.itemClaimLimit);
  }

  double get totalTaxReliefRemaining {
    if (_taxReliefReport == null) return 0.0;
    return _taxReliefReport!.categories
        .expand((category) => category.items)
        .fold(0.0, (sum, item) => sum + item.itemRemaining);
  }

  // Get formatted date range for display
  String get formattedDateRange {
    if (_expenseSummary?.range != null) {
      return '${_expenseSummary!.range.start} to ${_expenseSummary!.range.end}';
    }
    if (_filters.period == 'month' && _filters.month != null) {
      return '${_getMonthName(_filters.month!)} ${_filters.year}';
    }
    return '${_filters.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
    print("🧹 ReportViewModel disposed.");
  }
}
