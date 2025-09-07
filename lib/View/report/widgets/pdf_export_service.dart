import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../Model/signupLoginpage.dart';
import '../../../Model/report.dart';
import '../../../ViewModel/report/report_viewmodel.dart';

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
      // Generate PDF document
      final pdf = await _generatePdfDocument(
        reportViewModel: reportViewModel,
        userInfo: userInfo,
      );

      // Save PDF to device
      await _savePdfToDevice(pdf, reportViewModel.formattedDateRange);

      // Optionally print PDF
      await _showPrintOptions(context, pdf);
    } catch (e) {
      print('❌ Error generating PDF: $e');
      rethrow;
    }
  }

  Future<pw.Document> _generatePdfDocument({
    required ReportViewModel reportViewModel,
    required UserInfoModule userInfo,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

    // Load app logo (if available)
    Uint8List? logoBytes;
    try {
      final logoData = await rootBundle.load(
        'assets/Stickers/assetmanagement.png',
      );
      logoBytes = logoData.buffer.asUint8List();
    } catch (e) {
      print('Logo not found, continuing without logo');
    }

    // Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo and title
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logoBytes != null)
                    pw.Image(pw.MemoryImage(logoBytes), width: 60, height: 60)
                  else
                    pw.Container(
                      width: 60,
                      height: 60,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'MyManage',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Generated: ${dateFormatter.format(now)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Period: ${reportViewModel.formattedDateRange}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Title
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Smart Expense Organiser',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Financial Report',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.normal,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      reportViewModel.formattedDateRange,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),

              // User Information
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Report for:',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('${userInfo.firstName} ${userInfo.lastName}'),
                    pw.Text('${userInfo.email}'),
                    pw.Text('${userInfo.phoneNumber}'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Spending Analysis Page
    if (reportViewModel.expenseSummary != null) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build:
              (pw.Context context) => [
                _buildSpendingAnalysisSection(reportViewModel.expenseSummary!),
              ],
        ),
      );
    }

    // Tax Relief Page
    if (reportViewModel.taxReliefReport != null) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build:
              (pw.Context context) => [
                _buildTaxReliefSection(reportViewModel.taxReliefReport!),
              ],
        ),
      );
    }

    return pdf;
  }

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

  Future<void> _savePdfToDevice(pw.Document pdf, String dateRange) async {
    final output = await getExternalStorageDirectory();
    if (output != null) {
      final fileName =
          'MyManage_Report_${dateRange.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      print('📄 PDF saved to: ${file.path}');
    }
  }

  Future<void> _showPrintOptions(BuildContext context, pw.Document pdf) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('PDF Generated'),
            content: const Text(
              'Would you like to print the report or just save it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Just Save'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Printing.layoutPdf(
                    onLayout: (format) async => pdf.save(),
                  );
                },
                child: const Text('Print'),
              ),
            ],
          ),
    );
  }
}
