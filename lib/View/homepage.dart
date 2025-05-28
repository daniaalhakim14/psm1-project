import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:fyp/View/accountpage.dart';
import 'package:fyp/View/comparepricepage.dart';
import 'package:fyp/ViewModel/expense/expense_viewmodel.dart';
import 'package:provider/provider.dart';
import '../Model/expense.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/receiptParser/receiptParser_viewmodel.dart';
import 'expenseInput.dart';

class homepage extends StatefulWidget {
  //final UserInfoModule userInfo; // Accept UserModel as a parameter
  //const homepage({super.key,required this.userInfo});
  const homepage({super.key});
  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  int _selectedButtonIndex = 0;
  int _currentPage = 0;
  File? _uploadedPdf;
  String _monthNamePieChart(int month) {
    const monthNames = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    return monthNames[month - 1];
  }

  String _formatMonth(DateTime date) {
    DateTime malaysiaTime = date.toUtc().add(Duration(hours: 8));
    return "${_monthNamePieChart(malaysiaTime.month)} ${malaysiaTime.year}";
  }

  String selectedMonth =
      ""; // Declare variable selectedMonth to store selectedMonth
  bool showDailySpending = true;
  List<Widget> carouselItem = [];

  @override
  void initState() {
    super.initState(); // ← Missing in your code!
    selectedMonth = _formatMonth(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<expenseViewModel>(context, listen: false);
      if (!viewModel.fetchingData && viewModel.viewExpense.isEmpty) {
        viewModel.fetchViewExpense(1);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF5A7BE7),
      ),
      // Dashboard Padding
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              // Dashboard Container
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.01,
                  left: screenHeight * 0.015,
                  right: screenHeight * 0.015,
                ),
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CarouselSlider(
                        items: [
                          Consumer<expenseViewModel>(
                            builder: (context, viewModel, child) {
                              if (viewModel.fetchingData) {
                                return SizedBox(
                                  width: screenHeight * 0.1,
                                  height: screenWidth * 0.1,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (viewModel.viewExpense.isEmpty) {
                                return Column(
                                  children: [
                                    Image.asset(
                                      'lib/Icons/statistics.png',
                                      width: screenWidth * 0.5,
                                      height: screenHeight * 0.180,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(height: 10),
                                    const Center(
                                      child: Text(
                                        'No Transaction Made',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              // to display expense pie graph
                              // Step 1: Aggregate data by categoryname
                              final Map<String, double> aggregatedData = {};
                              final Map<String, Color> categoryColors = {};
                              final Map<String, IconData> categoryIcons = {};
                              double totalAmount = 0.0;

                              // Date conversion
                              for (var expense in viewModel.viewExpense) {
                                String isoFormatDate =
                                    expense.expenseDate.toString();
                                DateTime dateTime = DateTime.parse(
                                  isoFormatDate,
                                );
                                String formattedExpenseDate = _formatMonth(
                                  dateTime,
                                ); // Format expense.date

                                if (expense.categoryName != null &&
                                    formattedExpenseDate == selectedMonth &&
                                    expense.userId == 1) {
                                  if (!aggregatedData.containsKey(
                                    expense.categoryName,
                                  )) {
                                    aggregatedData[expense.categoryName!] = 0.0;
                                    categoryColors[expense.categoryName!] =
                                        expense.iconColor!;
                                    categoryIcons[expense.categoryName!] =
                                        expense.iconData!;
                                  }
                                  aggregatedData[expense.categoryName!] =
                                      aggregatedData[expense.categoryName!]! +
                                      (expense.expenseAmount ?? 0.0);

                                  totalAmount +=
                                      (expense.expenseAmount ??
                                          0.0); // Sum up total expenses
                                }
                              }
                              // Check if there's any data to display
                              if (aggregatedData.isEmpty) {
                                return Column(
                                  children: [
                                    Image.asset(
                                      'lib/Icons/statistics.png',
                                      width: screenWidth * 0.05,
                                      height: screenHeight * 0.02,
                                    ),
                                    SizedBox(height: screenHeight * 0.2),
                                    Center(
                                      child: Text(
                                        "No expense data for $selectedMonth",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.1),
                                  ],
                                );
                              }
                              // Step 2: Calculate daily average spending
                              DateTime now = DateTime.now();
                              DateTime firstDayOfMonth = DateTime(
                                now.year,
                                now.month,
                                1,
                              );
                              int daysPassed =
                                  now.difference(firstDayOfMonth).inDays +
                                  1; // Add 1 to include the current day
                              double dailyAverageSpending =
                                  totalAmount / daysPassed;

                              // Step 3: Calculate total and percentages for pie chart
                              final List<PieChartSectionData> sections =
                                  aggregatedData.entries.map((entry) {
                                    final category = entry.key;
                                    final amount = entry.value;
                                    final percentage =
                                        (amount / totalAmount) * 100;
                                    // Set a minimum percentage threshold
                                    final adjustedPercentage =
                                        percentage < 0.01 ? 0.01 : percentage;
                                    // Adjust the radius and badge size dynamically
                                    final segmentRadius =
                                        adjustedPercentage < 1
                                            ? 20.0
                                            : 36.0; // Smaller radius for small percentages
                                    final badgeSize =
                                        adjustedPercentage < 1
                                            ? 16.0
                                            : 24.0; // Smaller badge size for small percentages
                                    // Enter data in pie chart
                                    return PieChartSectionData(
                                      value: adjustedPercentage,
                                      color:
                                          categoryColors[category], // Use color associated with the category
                                      title:
                                          adjustedPercentage < 1
                                              ? ''
                                              : '${adjustedPercentage.toStringAsFixed(1)}%', // Hide title for very small segments
                                      radius: segmentRadius,
                                      titleStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      badgeWidget:
                                          adjustedPercentage < 1
                                              ? null // No badge for very small segments
                                              : Icon(
                                                categoryIcons[category],
                                                color: categoryColors[category],
                                                size: badgeSize,
                                              ),
                                      badgePositionPercentageOffset:
                                          1.38, // Position badges outside
                                    );
                                  }).toList();
                              // To display Pie chart
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 300, // Set a fixed height
                                    //color: Colors.blue,
                                    child: PieChart(
                                      duration: const Duration(
                                        milliseconds: 1500,
                                      ),
                                      //curve: Curves.easeInOutQuint,
                                      PieChartData(
                                        sections: sections,
                                        borderData: FlBorderData(show: false),
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 75,
                                      ),
                                    ),
                                  ),
                                  // To show Daily Avg Spending and Spent So far
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showDailySpending = true;
                                          });
                                        },
                                      ),
                                      Text(
                                        showDailySpending
                                            ? "Daily Average Spending"
                                            : "Spent So Far",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        showDailySpending
                                            ? "RM ${dailyAverageSpending.toStringAsFixed(2)}"
                                            : "RM ${totalAmount.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showDailySpending = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          Text("data"),
                        ],
                        options: CarouselOptions(
                          initialPage: 0,
                          onPageChanged: (value, _) {
                            setState(() {
                              _currentPage = value;
                            });
                          },
                        ),
                      ),
                      carouselindicator(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Spending Summary", style: TextStyle(fontSize: 18)),
                      SizedBox(width: 60),
                      Text("View All", style: TextStyle(fontSize: 18)),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.01,
                      left: screenHeight * 0.015,
                      right: screenHeight * 0.015,
                      bottom: screenHeight * 0.02,
                    ),
                    child: Container(
                      height: screenHeight * 0.35,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Recent spending: RM',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            Divider(
                              height: 10, // Space above and below the divider
                              thickness: 3, // Thickness of the line
                              color: Colors.grey, // Optional: set color
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.white,
        onPressed: () async {
          final result = await FlutterDocScanner().getScannedDocumentAsPdf();

          //print("Scanner result: $result");

          if (result != null && result is Map) {
            final uriString = result['pdfUri'] as String?;
            final pdfPath = uriString?.replaceFirst(
              'file://',
              '',
            ); // ✅ strip prefix

            if (pdfPath != null && pdfPath.isNotEmpty) {
              setState(() {
                _uploadedPdf = File(
                  pdfPath,
                ); // ✅ This updates the UI to show the preview
              });
              File pdfFile = File(pdfPath);
              final receiptParserVM = ReceiptParserViewModel();
              final success = await receiptParserVM.uploadPdf(pdfFile);
              if (success && receiptParserVM.parsedResult != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => expenseInput(
                          parsedData: receiptParserVM.parsedResult,
                          pdfFile: pdfFile,
                        ),
                  ),
                );
              } else {
                print("Upload failed: ${receiptParserVM.errorMessage}");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      receiptParserVM.errorMessage ?? 'Upload failed.',
                    ),
                  ),
                );
              }
            } else {
              print("No valid PDF path found in pdfUri.");
            }
          } else {
            print("Document scan failed or returned unexpected format.");
          }
        },
        child: Icon(CupertinoIcons.qrcode_viewfinder, size: 40),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.home, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => comparepricepage()),
                );
              },
              icon: Icon(CupertinoIcons.search, size: 50, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.doc, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => accountpage()),
                );
              },
              icon: Icon(
                CupertinoIcons.profile_circled,
                size: 48,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int carouselCount = 2; // define as variable or count your items dynamically
  Row carouselindicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < carouselCount; i++)
          Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            height: i == _currentPage ? 7 : 5,
            width: i == _currentPage ? 7 : 5,
            decoration: BoxDecoration(
              color: i == _currentPage ? Colors.white : Colors.black,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
