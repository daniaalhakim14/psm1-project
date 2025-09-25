import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../Model/signupLoginpage.dart';
import '../../../Model/report.dart';
import '../../../ViewModel/report/report_viewmodel.dart';
import '../../PdfViewerPage.dart';

class PdfExportService {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ms_MY',
    symbol: 'RM',
    decimalDigits: 2,
  );

  Future<void> generateAndSavePdf({
    required BuildContext context,
    required ReportViewModel reportViewModel,
    required int userId,
    required String token,
    required UserInfoModule userInfo,
  }) async {
    try {
      // Show progress indicator
      _showProgressDialog(context, 'Generating PDF...');

      // Optimize: Load logo only once and cache it
      final logoBytes = await _loadLogoOnce();

      // Optimize: Generate PDF with reduced complexity for better performance
      final pdf = await _generateOptimizedPdfDocument(
        reportViewModel: reportViewModel,
        userInfo: userInfo,
        logoBytes: logoBytes,
      );

      // Update progress
      _updateProgress(context, 'Saving PDF...');

      // Get PDF bytes
      final pdfBytes = await pdf.save();

      // Create filename
      final dateFormatter = DateFormat('yyyy-MM-dd_HH-mm');
      final timestamp = dateFormatter.format(DateTime.now());
      final fileName =
          'MyManage_Report_${reportViewModel.formattedDateRange.replaceAll(' ', '_')}_$timestamp.pdf';

      // Save PDF to device storage (async in background)
      _savePdfToDevice(pdfBytes, fileName); // Don't await this

      // Close progress dialog
      if (context.mounted) Navigator.of(context).pop();

      // Navigate to PDF viewer immediately
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PdfViewerPage(
                  pdfBytes: pdfBytes,
                  fileName: fileName,
                  customTitle: 'Financial Report',
                ),
          ),
        );
      }
    } catch (e) {
      // Close progress dialog on error
      if (context.mounted) Navigator.of(context).pop();
      print('❌ Error generating PDF: $e');
      rethrow;
    }
  }

  void _showProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Expanded(child: Text(message)),
              ],
            ),
          ),
    );
  }

  void _updateProgress(BuildContext context, String message) {
    // Update the dialog text if still mounted
    if (context.mounted) {
      Navigator.of(context).pop();
      _showProgressDialog(context, message);
    }
  }

  // Cache logo to avoid loading it multiple times
  static Uint8List? _cachedLogo;

  Future<Uint8List?> _loadLogoOnce() async {
    if (_cachedLogo != null) return _cachedLogo;

    try {
      final logoData = await rootBundle.load(
        'assets/Stickers/assetmanagement.png',
      );
      _cachedLogo = logoData.buffer.asUint8List();
      return _cachedLogo;
    } catch (e) {
      print('Logo not found, continuing without logo');
      return null;
    }
  }

  Future<pw.Document> _generateOptimizedPdfDocument({
    required ReportViewModel reportViewModel,
    required UserInfoModule userInfo,
    Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

    // Optimize: Create single page with essential content only
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(24), // Reduced margin for more space
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Compact Header
              _buildCompactHeader(
                logoBytes,
                dateFormatter.format(now),
                reportViewModel.formattedDateRange,
              ),
              pw.SizedBox(height: 20),

              // Title
              pw.Center(
                child: pw.Text(
                  'Financial Report',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // Compact User Info
              _buildCompactUserInfo(userInfo),
              pw.SizedBox(height: 20),

              // Spending Analysis (if available)
              if (reportViewModel.expenseSummary != null) ...[
                _buildCompactSpendingAnalysis(reportViewModel.expenseSummary!),
                pw.SizedBox(height: 16),
              ],

              // Tax Relief (if available)
              if (reportViewModel.taxReliefReport != null) ...[
                _buildCompactTaxRelief(reportViewModel.taxReliefReport!),
              ],
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildCompactHeader(
    Uint8List? logoBytes,
    String generatedDate,
    String dateRange,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Logo or App Name
        if (logoBytes != null)
          pw.Image(pw.MemoryImage(logoBytes), width: 50, height: 50)
        else
          pw.Container(
            width: 50,
            height: 50,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Center(
              child: pw.Text(
                'MM',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        // Date info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Generated: $generatedDate',
              style: pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              'Period: $dateRange',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCompactUserInfo(UserInfoModule userInfo) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Report for: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.Text(
            '${userInfo.firstName} ${userInfo.lastName} (${userInfo.email})',
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCompactSpendingAnalysis(ExpenseSummary summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Spending Analysis',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),

        // Compact KPIs in a single row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildMiniKpi('Total', _currencyFormat.format(summary.totals.sum)),
            _buildMiniKpi(
              'Daily Avg',
              _currencyFormat.format(summary.dailyAverageSpending.activeDays),
            ),
            _buildMiniKpi(
              'Monthly Avg',
              _currencyFormat.format(summary.monthlyAverageSpending),
            ),
          ],
        ),
        pw.SizedBox(height: 12),

        // Top categories only (limit to 5)
        if (summary.breakdownByCategory.isNotEmpty) ...[
          pw.Text(
            'Top Categories:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _buildSimpleTable(
            summary.breakdownByCategory
                .take(5)
                .map((c) => [c.name, _currencyFormat.format(c.sum)])
                .toList(),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildCompactTaxRelief(TaxReliefEligibleReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Tax Relief (${report.year})',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),

        // Simplified tax relief info
        ...report.categories
            .take(3)
            .map(
              (category) => pw.Container(
                margin: pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(
                  '${category.reliefcategory}: ${category.items.length} items',
                  style: pw.TextStyle(fontSize: 11),
                ),
              ),
            ),
      ],
    );
  }

  pw.Widget _buildMiniKpi(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildSimpleTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children:
          data
              .map(
                (row) => pw.TableRow(
                  children:
                      row
                          .map(
                            (cell) => pw.Container(
                              padding: pw.EdgeInsets.all(4),
                              child: pw.Text(
                                cell,
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    );
  }

  /*
  // ORIGINAL DETAILED METHODS - COMMENTED OUT FOR PERFORMANCE
  // Uncomment these if you want detailed multi-page reports
  
  pw.Widget _buildSpendingAnalysisSection(ExpenseSummary summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title
        pw.Text(
          'Spending Analysis',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 20),

        // KPIs Grid
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildKpiCard(
                'Total Spent',
                _currencyFormat.format(summary.totals.sum),
                PdfColors.red,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildKpiCard(
                'Daily Average',
                _currencyFormat.format(summary.dailyAverageSpending.activeDays),
                PdfColors.blue,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildKpiCard(
                'Monthly Average',
                _currencyFormat.format(summary.monthlyAverageSpending),
                PdfColors.green,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildKpiCard(
                'Biggest Category',
                '${summary.biggestExpenseCategory.name}\n${_currencyFormat.format(summary.biggestExpenseCategory.sum)}',
                PdfColors.orange,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // Category Breakdown Table
        pw.Text(
          'Category Breakdown',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        _buildCategoryTable(summary.breakdownByCategory),
        pw.SizedBox(height: 20),

        // Platform Breakdown Table
        pw.Text(
          'Platform Breakdown',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        _buildPlatformTable(summary.breakdownByPlatform),
        pw.SizedBox(height: 20),

        // Top 5 Expenses
        pw.Text(
          'Top 5 Expenses',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        _buildTopExpensesTable(summary.top5Expenses),
      ],
    );
  }

  pw.Widget _buildTaxReliefSection(TaxReliefEligibleReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title
        pw.Text(
          'Tax Relief - Eligible Expenses (${report.year})',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 20),

        // Categories
        ...report.categories.map(
          (category) => _buildTaxReliefCategory(category),
        ),
      ],
    );
  }

  pw.Widget _buildKpiCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCategoryTable(List<CategoryBreakdown> categories) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
          ],
        ),
        // Data rows
        ...categories.map(
          (category) => pw.TableRow(
            children: [
              _buildTableCell(category.name),
              _buildTableCell(_currencyFormat.format(category.sum)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPlatformTable(List<PlatformBreakdown> platforms) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Platform', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
          ],
        ),
        // Data rows
        ...platforms.map(
          (platform) => pw.TableRow(
            children: [
              _buildTableCell(platform.name),
              _buildTableCell(_currencyFormat.format(platform.sum)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTopExpensesTable(List<TopExpense> expenses) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Expense', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
            _buildTableCell('Date', isHeader: true),
          ],
        ),
        // Data rows
        ...expenses.map(
          (expense) => pw.TableRow(
            children: [
              _buildTableCell(expense.name),
              _buildTableCell(_currencyFormat.format(expense.amount)),
              _buildTableCell(expense.date),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTaxReliefCategory(TaxReliefCategory category) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          category.reliefcategory,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        ...category.items.map((item) => _buildTaxReliefItem(item)),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildTaxReliefItem(TaxReliefItem item) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                item.itemName,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${_currencyFormat.format(item.itemTotalEligible)} / ${_currencyFormat.format(item.itemClaimLimit)}',
                style: pw.TextStyle(
                  color: PdfColors.blue700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          if (item.expenses.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Expenses:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            ...item.expenses.map(
              (expense) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, top: 4),
                child: pw.Text(
                  '• ${expense.name}: ${_currencyFormat.format(expense.eligibleamount)} (${expense.date})',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _savePdfToDevice(Uint8List pdfBytes, String fileName) async {
    // Run in background without blocking UI
    Future.microtask(() async {
      try {
        final output = await getExternalStorageDirectory();
        if (output != null) {
          final file = File('${output.path}/$fileName');
          await file.writeAsBytes(pdfBytes);
          print('📄 PDF saved to: ${file.path}');
        } else {
          // Fallback to application documents directory
          final documentsDirectory = await getApplicationDocumentsDirectory();
          final file = File('${documentsDirectory.path}/$fileName');
          await file.writeAsBytes(pdfBytes);
          print('📄 PDF saved to: ${file.path}');
        }
      } catch (e) {
        print('❌ Error saving PDF: $e');
        // Don't throw here since it's background operation
      }
    });
  }
  */ // End of commented detailed methods

  // Optimized save method that doesn't block UI
  Future<void> _savePdfToDevice(Uint8List pdfBytes, String fileName) async {
    // Run in background without blocking UI
    Future.microtask(() async {
      try {
        final output = await getExternalStorageDirectory();
        if (output != null) {
          final file = File('${output.path}/$fileName');
          await file.writeAsBytes(pdfBytes);
          print('📄 PDF saved to: ${file.path}');
        } else {
          // Fallback to application documents directory
          final documentsDirectory = await getApplicationDocumentsDirectory();
          final file = File('${documentsDirectory.path}/$fileName');
          await file.writeAsBytes(pdfBytes);
          print('📄 PDF saved to: ${file.path}');
        }
      } catch (e) {
        print('❌ Error saving PDF: $e');
        // Don't throw here since it's background operation
      }
    });
  }
}
