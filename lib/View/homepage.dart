import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:fyp/View/accountpage.dart';
import 'package:fyp/View/comparepricepage.dart';
import 'package:fyp/View/taxexempt.dart';
import 'package:provider/provider.dart';
import '../Model/expense.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/expense/expense_viewmodel.dart';
import '../ViewModel/receiptParser/receiptParser_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'expenseDetails.dart';
import 'expenseInput.dart';

class homepage extends StatefulWidget {
  final UserInfoModule userInfo; // Accept UserModel as a parameter
  const homepage({super.key, required this.userInfo});
  //const homepage({super.key});
  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  int _selectedButtonIndex = 0;
  int _currentPage = 0;
  File? _uploadedPdf;
  late ScrollController _scrollController;
  List<DateTime> months =
      []; // Declare list months and initialise to months to be empty
  late Timer _timer;

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

  String _monthNameTransactionList(int month) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return monthNames[month - 1];
  }

  /*
  String _formatMonth(DateTime date) {
    DateTime malaysiaTime = date.toUtc().add(Duration(hours: 8));
    return "${_monthNamePieChart(malaysiaTime.month)} ${malaysiaTime.year}";
  }
   */
  String _formatMonth(DateTime date) {
    DateTime malaysiaTime = date.toLocal();
    return "${_monthNamePieChart(malaysiaTime.month)} ${malaysiaTime.year}";
  }


  String _formatFullDate(DateTime date) {
    DateTime local = date.toLocal(); // use local time
    return "${local.day.toString().padLeft(2, '0')} ${_monthNameTransactionList(local.month)} ${local.year}";
  }

  String selectedMonth = ''; // Declare variable selectedMonth to store selectedMonth
  bool showDailySpending = true;
  List<Widget> carouselItem = [];

  void _initializeMonths() {
    // Populates list with the past 12 months, starting from current months
    DateTime now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      months.add(DateTime(now.year, now.month - i));
    }
    months =
        months.reversed.toList(); // Reverse the order to show the newest months
  }

  void _startMonthCheckTimer() {
    _timer = Timer.periodic(Duration(hours: 1), (_) {
      DateTime now = DateTime.now();
      if (!_isMonthInList(now)) {
        _updateMonths();
      }
    });
  }

  bool _isMonthInList(DateTime now) {
    String currentMonthFormatted = _formatMonth(now);
    return months.any((month) => _formatMonth(month) == currentMonthFormatted);
  }

  void _updateMonths() {
    //  checks hourly if a new month has arrived. Updates the months list by removing the oldest month and adding the next month
    setState(() {
      months.removeAt(0); // Remove the first (oldest) month
      DateTime lastMonth = months.last;
      months.add(
        DateTime(lastMonth.year, lastMonth.month + 1),
      ); // Add the next month
    });
  }

  void scrollToMonth(String month) {
    // this methods automatically scrolls to selected months
    int index = months.indexWhere((date) => _formatMonth(date) == month);
    if (index != -1) {
      double offset =
          index * 90.0; // Adjust offset based on item width and padding
      _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedMonth = _formatMonth(DateTime.now());
    _scrollController = ScrollController(); // instance created to manage horizontal behavior of the months Listview
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
      if (token != null) {
        final viewModel = Provider.of<expenseViewModel>(context, listen: false);
        viewModel.fetchViewExpense(widget.userInfo.id, token);
        final viewModel_listexpense = Provider.of<expenseViewModel>(context, listen: false);
        viewModel_listexpense.fetchListExpense(widget.userInfo.id,token);
      } else {
        print("Token is null — skipping fetchViewExpense");
      }
    });
    // Start a timer to check for month changes
    _startMonthCheckTimer();
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dashboard Container
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.01,
                  left: screenHeight * 0.015,
                  right: screenHeight * 0.015,
                ),
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: CarouselSlider(
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
                                // to display expense pie graph
                                // Step 1: Aggregate data by categoryname
                                final Map<String, double> aggregatedData = {};
                                final Map<String, Color> categoryColors = {};
                                final Map<String, IconData> categoryIcons = {};
                                double totalAmount = 0.0;

                                // Date conversion
                                for (var expense in viewModel.viewExpense) {
                                  String isoFormatDate = expense.expenseDate.toString();
                                  DateTime utcTime = DateTime.parse(isoFormatDate);
                                  DateTime localTime = utcTime.toLocal();
                                  String formattedExpenseDate = _formatMonth(localTime);
                                  print(formattedExpenseDate);
                                  //Format expense.date

                                  if (expense.categoryname != null && formattedExpenseDate == selectedMonth && expense.userId == widget.userInfo.id) {
                                    if (!aggregatedData.containsKey(
                                      expense.categoryname,
                                    )) {
                                      aggregatedData[expense.categoryname!] =
                                          0.0;
                                      categoryColors[expense.categoryname!] =
                                          expense.iconColor!;
                                      categoryIcons[expense.categoryname!] =
                                          expense.iconData!;
                                    }
                                    aggregatedData[expense.categoryname!] =
                                        aggregatedData[expense.categoryname!]! +
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
                                        'assets/Icons/statistics.png',
                                        width: screenWidth * 0.4,
                                        height: screenHeight * 0.2,
                                      ),
                                      SizedBox(height: screenHeight * 0.0025),
                                      Center(
                                        child: Text(
                                          "No Expense Data For $selectedMonth",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
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
                                                  color:
                                                      categoryColors[category],
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
                                    PieChart(
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
                                    // To show Daily Avg Spending and Spent So far
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      ),
                      /*
                      CarouselSlider(items: [
                        _monthNamePieChart(month),
                      ], options: options),

                       */
                      carouselindicator(),
                      SizedBox(height: 10),
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
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Divider(
                              height: 10, // Space above and below the divider
                              thickness: 3, // Thickness of the line
                              color: Colors.grey, // Optional: set color
                            ),
                            SizedBox(height: 8),
                            // latest transaction list
                            Consumer<expenseViewModel>(
                              builder: (context, viewModel_listexpense, child) {
                                List<ListExpense> listExpense = viewModel_listexpense.listExpense;
                                if (viewModel_listexpense.fetchingData) {
                                  return SizedBox(
                                    width: 220,
                                    height: 220,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                print("Fetched ListExpense Count: ${viewModel_listexpense.listExpense.length}");

                                // Filter list expense by the selected month
                                final filteredExpense =
                                    listExpense.where((expense) {
                                      String isoFormatDate = expense.expenseDate.toString();
                                      DateTime utcTime = DateTime.parse(isoFormatDate,);
                                      DateTime localTime = utcTime.toLocal();
                                      String formattedExpenseDate = _formatMonth(localTime);
                                      return formattedExpenseDate == selectedMonth;
                                    }).toList();
                                if (filteredExpense.isEmpty) {
                                  return Column(
                                    children: [
                                      Image.asset(
                                        'assets/Icons/statistics.png',
                                        width: 190,
                                        height: 180,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 10),
                                      Center(
                                        child: Text(
                                          'No transactions for $selectedMonth',
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return Expanded(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.43,
                                    child: ListView.builder(
                                      itemCount: filteredExpense.length,
                                      itemBuilder: (context, index) {
                                        final expense = filteredExpense[index];

                                        String isoFormatDate = expense.expenseDate.toString();
                                        DateTime utcTime = DateTime.parse(isoFormatDate,);
                                        DateTime localTime = utcTime.toLocal();
                                        String formattedExpenseDate = _formatMonth(localTime);
                                        
                                        // Format transaction.date
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => expenseDetails(
                                                      userid: widget.userInfo.id,
                                                      expensedetail: expense, // Pass the single transaction object
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              // List Header
                                              if (index == 0 || filteredExpense[index - 1].expenseDate != expense.expenseDate)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],

                                                  ),
                                                  height: 30.0,
                                                  width: double.infinity,
                                                  child: Padding(padding: const EdgeInsets.all(4.0,),
                                                    child: Text(
                                                      formattedExpenseDate,
                                                      // Display the transaction date
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              // Transaction Details
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    // Border color
                                                    width: 1.0, // Border width
                                                  ),
                                                  color: Colors.white,// Optional: Rounded corners
                                                ),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        expense.iconColor,
                                                    child: Icon(
                                                      expense.iconData,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    expense.categoryname
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors
                                                              .black, // Dynamic color based on dark mode
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        expense.expenseDescription
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8.0,
                                                        ),
                                                    child: Text(
                                                      'RM ${expense.expenseAmount}',
                                                      // Format the amount
                                                      style: TextStyle(
                                                        color:
                                                            Colors
                                                                .black, // Dynamic color
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 8),
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
              final token =
                  Provider.of<signUpnLogin_viewmodel>(
                    context,
                    listen: false,
                  ).authToken;
              final receiptParserVM =
                  ReceiptParserViewModel(); // or get from Provider if already registered
              final success = await receiptParserVM.uploadPdf(pdfFile, token!);

              if (success && receiptParserVM.parsedResult != null) {
                Navigator.push(
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
              icon: Icon(
                CupertinoIcons.home,
                size: 45,
                color: Color(0xFF5A7BE7),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            comparepricepage(userInfo: widget.userInfo),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.search, size: 50, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => taxExempt(userInfo: widget.userInfo),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.doc, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => accountpage(userInfo: widget.userInfo),
                  ),
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
