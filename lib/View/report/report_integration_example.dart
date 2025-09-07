// Example of how to integrate the Report feature into your app

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fyp/View/report/report_page.dart';
import 'package:fyp/ViewModel/report/report_viewmodel.dart';
import 'package:fyp/Model/signupLoginpage.dart';

class ReportIntegrationExample extends StatelessWidget {
  final UserInfoModule userInfo;

  const ReportIntegrationExample({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Method 1: Direct navigation with Provider
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChangeNotifierProvider(
                          create: (context) => ReportViewModel(),
                          child: ReportPage(userInfo: userInfo),
                        ),
                  ),
                );
              },
              child: const Text('Open Reports (Method 1)'),
            ),

            const SizedBox(height: 20),

            // Method 2: Using MultiProvider if you have other providers
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (context) => ReportViewModel(),
                            ),
                            // Add other providers as needed
                          ],
                          child: ReportPage(userInfo: userInfo),
                        ),
                  ),
                );
              },
              child: const Text('Open Reports (Method 2)'),
            ),

            const SizedBox(height: 40),

            // Example of using ReportViewModel in your widget
            const Text('Or integrate ReportViewModel in your existing widget:'),
            const SizedBox(height: 10),
            _buildInlineReportExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineReportExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'Quick Spending Summary',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Consumer<ReportViewModel>(
            builder: (context, reportViewModel, child) {
              if (reportViewModel.isLoading) {
                return const CircularProgressIndicator();
              }

              if (reportViewModel.expenseSummary == null) {
                return const Text('No data available');
              }

              return Column(
                children: [
                  Text(
                    'Total Spent: RM ${reportViewModel.totalSpent.toStringAsFixed(2)}',
                  ),
                  Text(
                    'Daily Average: RM ${reportViewModel.dailyAverageActive.toStringAsFixed(2)}',
                  ),
                  Text('Biggest Category: ${reportViewModel.biggestCategory}'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Example of a custom report widget
class CustomReportWidget extends StatefulWidget {
  final UserInfoModule userInfo;

  const CustomReportWidget({super.key, required this.userInfo});

  @override
  State<CustomReportWidget> createState() => _CustomReportWidgetState();
}

class _CustomReportWidgetState extends State<CustomReportWidget> {
  late ReportViewModel _reportViewModel;

  @override
  void initState() {
    super.initState();
    _reportViewModel = ReportViewModel();

    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // You would get the token and user ID from your auth service
      _loadReportData();
    });
  }

  void _loadReportData() {
    // Example of loading report data
    const userId = 123; // Get from your auth service
    const token = 'your-auth-token'; // Get from your auth service

    _reportViewModel.fetchAllReports(userId, token);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _reportViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Report'),
          actions: [
            IconButton(
              onPressed: () async {
                const userId = 123;
                const token = 'your-auth-token';

                final pdfBytes = await _reportViewModel.generatePdfReport(
                  userId,
                  token,
                );
                if (pdfBytes != null) {
                  // Handle PDF bytes (save, share, etc.)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PDF generated successfully!'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
            ),
          ],
        ),
        body: Consumer<ReportViewModel>(
          builder: (context, reportViewModel, child) {
            return Column(
              children: [
                // Custom filter UI
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          reportViewModel.setThisMonth();
                          _loadReportData();
                        },
                        child: const Text('This Month'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          reportViewModel.setYearToDate();
                          _loadReportData();
                        },
                        child: const Text('Year to Date'),
                      ),
                    ],
                  ),
                ),

                // Custom content
                Expanded(
                  child:
                      reportViewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Custom KPI cards
                                _buildCustomKpiCard(
                                  'Total Spent',
                                  'RM ${reportViewModel.totalSpent.toStringAsFixed(2)}',
                                ),
                                _buildCustomKpiCard(
                                  'Tax Relief Eligible',
                                  'RM ${reportViewModel.totalTaxReliefEligible.toStringAsFixed(2)}',
                                ),

                                // You can add custom charts, lists, etc. here
                              ],
                            ),
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomKpiCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reportViewModel.dispose();
    super.dispose();
  }
}

// Example of using the report data in other parts of your app
class DashboardWithReportData extends StatelessWidget {
  final UserInfoModule userInfo;

  const DashboardWithReportData({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReportViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Consumer<ReportViewModel>(
          builder: (context, reportViewModel, child) {
            return Column(
              children: [
                // Quick stats widget
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickStat(
                          'This Month Spent',
                          'RM ${reportViewModel.totalSpent.toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickStat(
                          'Tax Relief',
                          'RM ${reportViewModel.totalTaxReliefEligible.toStringAsFixed(2)}',
                          Icons.receipt_long,
                        ),
                      ),
                    ],
                  ),
                ),

                // Button to open full reports
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChangeNotifierProvider(
                              create: (context) => ReportViewModel(),
                              child: ReportPage(userInfo: userInfo),
                            ),
                      ),
                    );
                  },
                  child: const Text('View Full Reports'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
