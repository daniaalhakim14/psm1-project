import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/signupLoginpage.dart';
import '../../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import '../../ViewModel/report/report_viewmodel.dart';
import 'widgets/spending_analysis_tab.dart';
import 'widgets/tax_relief_tab.dart';
import 'widgets/report_filters.dart';
import 'widgets/tax_relief_filters.dart';
import 'widgets/pdf_export_service.dart';

class ReportPage extends StatefulWidget {
  final UserInfoModule userInfo;

  const ReportPage({super.key, required this.userInfo});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final PdfExportService _pdfExportService = PdfExportService();
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportViewModel = Provider.of<ReportViewModel>(
        context,
        listen: false,
      );
      final authViewModel = Provider.of<signUpnLogin_viewmodel>(
        context,
        listen: false,
      );

      if (authViewModel.userInfo != null && authViewModel.authToken != null) {
        reportViewModel.fetchAllReports(
          authViewModel.userInfo!.id,
          authViewModel.authToken!,
        );
      }
    });
  }

  void _refreshData() {
    final reportViewModel = Provider.of<ReportViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<signUpnLogin_viewmodel>(
      context,
      listen: false,
    );

    if (authViewModel.userInfo != null && authViewModel.authToken != null) {
      reportViewModel.refresh(
        authViewModel.userInfo!.id,
        authViewModel.authToken!,
      );
    }
  }

  Future<void> _exportToPdf() async {
    final reportViewModel = Provider.of<ReportViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<signUpnLogin_viewmodel>(
      context,
      listen: false,
    );

    if (authViewModel.userInfo == null || authViewModel.authToken == null) {
      _showErrorSnackBar('Authentication required');
      return;
    }

    try {
      // The PDF service now handles its own progress dialogs and navigation
      await _pdfExportService.generateAndSavePdf(
        context: context,
        reportViewModel: reportViewModel,
        userId: authViewModel.userInfo!.id,
        token: authViewModel.authToken!,
        userInfo: widget.userInfo,
      );

      // Success - PDF service handles navigation to viewer
    } catch (e) {
      _showErrorSnackBar('Failed to generate PDF: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7BE7),
        title: const Text(
          'Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<ReportViewModel>(
            builder: (context, reportViewModel, child) {
              return IconButton(
                onPressed:
                    reportViewModel.isGeneratingPdf ? null : _exportToPdf,
                icon:
                    reportViewModel.isGeneratingPdf
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.picture_as_pdf, color: Colors.white),
                tooltip: 'Export to PDF',
              );
            },
          ),
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Spending Analysis'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Tax Relief'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters Section - Show different filters based on active tab
          Container(
            color: Colors.white,
            child:
                _currentTabIndex == 0
                    ? const ReportFilters() // Spending Analysis filters
                    : const TaxReliefFilters(), // Tax Relief filters (year only)
          ),
          // Error Message
          Consumer<ReportViewModel>(
            builder: (context, reportViewModel, child) {
              if (reportViewModel.errorMessage != null) {
                return Container(
                  width: double.infinity,
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reportViewModel.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        onPressed: reportViewModel.clearError,
                        icon: Icon(Icons.close, color: Colors.red.shade700),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SpendingAnalysisTab(userInfo: widget.userInfo),
                TaxReliefTab(userInfo: widget.userInfo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
