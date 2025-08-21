import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // Make sure this is imported
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

class _homepageState extends State<homepage> with AutomaticKeepAliveClientMixin {
  int _selectedButtonIndex = 0;
  int _currentPage = 0;
  File? _uploadedPdf;
  late ScrollController _scrollController;
  List<DateTime> Months = []; // Declare list months and initialise to months to be empty
  late Timer _timer;
  String selectedMonth = ''; // Declare variable selectedMonth to store selectedMonth
  bool showDailySpending = true;
  List<String> months = [];
  int _selectedMonthIndex = 0;

  String _monthNamePieChart(int month) {
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

  String _formatMonth(DateTime date) {
    DateTime malaysiaTime = date.toLocal();
    return '${_monthNamePieChart(malaysiaTime.month)} ${malaysiaTime.year}';
  }

  String _formatFullDate(DateTime date) {
    // ensure local time
    final local = date.toLocal();
    // e.g. "06 Jun 2025"
    return DateFormat('dd MMM yyyy').format(local);
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
    return Months.any((month) => _formatMonth(month) == currentMonthFormatted);
  }

  void _updateMonths() {
    setState(() {
      months.removeAt(0);
      final last = months.last;
      DateTime lastMonthDate = DateFormat('MMM yyyy').parse(last);
      DateTime nextMonthDate = DateTime(
        lastMonthDate.year,
        lastMonthDate.month + 1,
      );
      String formatted = DateFormat('MMM yyyy').format(nextMonthDate);
      months.add(formatted);
    });
  }

  // month scroll slider
  List<String> getLast12Months() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM yyyy'); // e.g. "Jun 2025"
    final months = List.generate(12, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      return formatter.format(date);
    });
    return months.reversed.toList(); // So latest month is at the end
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    months = getLast12Months(); // Store in state
    _selectedMonthIndex = months.length - 1; // Select current month
    selectedMonth = months[_selectedMonthIndex];
    // Start a timer to check for month changes
    _startMonthCheckTimer();
    _scrollController = ScrollController(); // instance created to manage horizontal behavior of the months Listview
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
      if (token != null) {
        final viewModel = Provider.of<expenseViewModel>(context, listen: false);
        viewModel.fetchViewExpense(widget.userInfo.id, token);
        final viewModel_listexpense = Provider.of<expenseViewModel>(context, listen: false,);
        viewModel_listexpense.fetchListExpense(widget.userInfo.id, token);
        final viewModel_financialPlatform = Provider.of<expenseViewModel>(context, listen: false,);
        viewModel_financialPlatform.fetchViewExpenseFinancialPlatform(widget.userInfo.id, token);
      } else {
        print("Token is null — skipping fetchViewExpense");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // <--- this is required
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Text('MyManageMate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
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
                            // pie chart
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
                                  DateTime utcTime = DateTime.parse(
                                    isoFormatDate,
                                  );
                                  DateTime localTime = utcTime.toLocal();
                                  String formattedExpenseDate = _formatMonth(
                                    localTime,
                                  );
                                  //print(formattedExpenseDate);
                                  //Format expense.date
                                  if (expense.categoryname != null && formattedExpenseDate == selectedMonth && expense.userId == widget.userInfo.id) {
                                    if (!aggregatedData.containsKey(expense.categoryname,))
                                    {
                                      aggregatedData[expense.categoryname!] = 0.0;
                                      categoryColors[expense.categoryname!] = expense.iconColor!;
                                      categoryIcons[expense.categoryname!] = expense.iconData!;
                                    }
                                    aggregatedData[expense.categoryname!] = aggregatedData[expense.categoryname!]! + (expense.expenseAmount ?? 0.0);

                                    totalAmount += (expense.expenseAmount ?? 0.0); // Sum up total expenses
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
                                final List<PieChartSectionData> sections = aggregatedData.entries.map((entry) {
                                      final category = entry.key;
                                      final amount = entry.value;
                                      final percentage = (amount / totalAmount) * 100;
                                      // Set a minimum percentage threshold
                                      final adjustedPercentage = percentage < 0.01 ? 0.01 : percentage;
                                      // Adjust the radius and badge size dynamically
                                      final segmentRadius = adjustedPercentage < 1 ? 20.0 : 36.0; // Smaller radius for small percentages
                                      final badgeSize = adjustedPercentage < 1 ? 16.0 : 24.0; // Smaller badge size for small percentages
                                      // Enter data in pie chart
                                      return PieChartSectionData(
                                        value: adjustedPercentage,
                                        color: categoryColors[category], // Use color associated with the category
                                        title: adjustedPercentage < 1 ? '' : '${adjustedPercentage.toStringAsFixed(1)}%', // Hide title for very small segments
                                        radius: segmentRadius,
                                        titleStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        badgeWidget: adjustedPercentage < 1 ? null // No badge for very small segments
                                                : Icon(categoryIcons[category],
                                                  color: categoryColors[category],
                                                  size: badgeSize,
                                                ),
                                        badgePositionPercentageOffset: 1.38, // Position badges outside
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
                                        Text(showDailySpending ? "Daily Average Spending" : "Spent So Far",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          showDailySpending ? "RM ${dailyAverageSpending.toStringAsFixed(2)}"
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
                            Consumer<expenseViewModel>(
                              builder: (context, viewModel_financialPlatform, child) {
                                if (viewModel_financialPlatform.fetchingData) {
                                  return SizedBox(
                                    width: screenHeight * 0.1,
                                    height: screenWidth * 0.1,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                // Step 1: Aggregate data by financial platform type
                                final Map<String, double> aggregatedData = {};
                                final Map<String, Color> financialPlatformColors = {};
                                final Map<String, Uint8List> financialPlatformIcons = {};
                                double totalAmount = 0.0;

                                // Date conversion and data aggregation
                                for (var expense in viewModel_financialPlatform.viewExpenseFinancialPlatform) {
                                  String isoFormatDate = expense.expenseDate.toString();
                                  DateTime utcTime = DateTime.parse(isoFormatDate);
                                  DateTime localTime = utcTime.toLocal();
                                  String formattedExpenseDate = _formatMonth(localTime);

                                  // Filter by month and user
                                  if (expense.name != null &&
                                      formattedExpenseDate == selectedMonth &&
                                      expense.userId == widget.userInfo.id) {

                                    // Initialize aggregated amount if not exists
                                    if (!aggregatedData.containsKey(expense.name!)) {
                                      aggregatedData[expense.name!] = 0.0;
                                      financialPlatformColors[expense.name!] = expense.iconColor!.withAlpha(255);
                                    }

                                    // Add to total amount
                                    aggregatedData[expense.name!] = aggregatedData[expense.name!]! + (expense.expenseAmount ?? 0.0);
                                    totalAmount += (expense.expenseAmount ?? 0.0);

                                    // 🔧 FIX: Store the icon data for this financial platform
                                    if (expense.iconimage != null && expense.iconimage!.isNotEmpty) {
                                      // Convert List<int> to Uint8List if needed
                                      if (expense.iconimage is List<int>) {
                                        financialPlatformIcons[expense.name!] = Uint8List.fromList(expense.iconimage!.cast<int>());
                                      } else if (expense.iconimage is Uint8List) {
                                        financialPlatformIcons[expense.name!] = expense.iconimage!;
                                      }
                                    }
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
                                          "No Financial Platform Data For $selectedMonth",
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
                                DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
                                int daysPassed = now.difference(firstDayOfMonth).inDays + 1;
                                double dailyAverageSpending = totalAmount / daysPassed;

                                // Step 3: Calculate total and percentages for pie chart
                                final List<PieChartSectionData> sections = aggregatedData.entries.map((entry) {
                                  final name = entry.key;
                                  final amount = entry.value;
                                  final percentage = (amount / totalAmount) * 100;
                                  final adjustedPercentage = percentage < 0.01 ? 0.01 : percentage;
                                  final segmentRadius = adjustedPercentage < 1 ? 20.0 : 36.0;
                                  final badgeSize = adjustedPercentage < 1 ? 16.0 : 24.0;

                                  return PieChartSectionData(
                                    value: adjustedPercentage,
                                    title: adjustedPercentage < 1 ? '' : '${adjustedPercentage.toStringAsFixed(1)}%',
                                    radius: segmentRadius,
                                    color: financialPlatformColors[name], // ✅ ADD THIS LINE
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    badgeWidget: adjustedPercentage < 1 ? null : SizedBox(
                                      width: badgeSize,
                                      height: badgeSize,
                                      child: DecoratedBox(
                                        decoration: const BoxDecoration(
                                          color: Colors.white, // helps visibility on teal
                                          shape: BoxShape.circle, // or BoxShape.rectangle
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3), // breathing room
                                          child: FittedBox(
                                            fit: BoxFit.contain, // keep aspect ratio
                                            child: Image.memory(
                                              financialPlatformIcons[name]!,
                                              filterQuality: FilterQuality.high,
                                              errorBuilder: (_, __, ___) => Icon(Icons.account_balance, size: badgeSize * 0.8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    badgePositionPercentageOffset: 1.38,
                                  );
                                }).toList();

                                // Display Pie chart
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      duration: const Duration(milliseconds: 1500),
                                      PieChartData(
                                        sections: sections,
                                        borderData: FlBorderData(show: false),
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 75,
                                      ),
                                    ),
                                    // Daily Average Spending and Spent So Far display
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
                                          showDailySpending ? "Daily Average Spending" : "Spent So Far",
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
                            )
                          ],
                          options: CarouselOptions(
                            initialPage: 0,
                            viewportFraction:
                                1.0, // 👈 Makes the item take full width (no edge bleed)
                            onPageChanged: (value, _) {
                              setState(() {
                                _currentPage = value;
                              });
                            },
                          ),
                        ),
                      ),
                      // months slider
                      CarouselSlider(
                        items:
                            months.map((month) {
                              bool isSelected = month == selectedMonth;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMonth = month;
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      month,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            isSelected
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        height: 2,
                                        width: 30,
                                        margin: const EdgeInsets.only(top: 4),
                                        color: Colors.black,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                        options: CarouselOptions(
                          height: 50,
                          viewportFraction: 0.3,
                          enlargeCenterPage:
                              true, // enlarges image, make it stand out visually
                          enableInfiniteScroll: false,
                          initialPage: months.length - 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              selectedMonth = months[index];
                            });
                          },
                        ),
                      ),
                      carouselindicator(),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              // Spending table
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
                                List<ListExpense> listExpense =
                                    viewModel_listexpense.listExpense;
                                if (viewModel_listexpense.fetchingData) {
                                  return SizedBox(
                                    width: 220,
                                    height: 220,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                // Filter list expense by the selected month
                                final filteredExpense = listExpense.where((expense) {
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
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.43,
                                    child: ListView.builder(
                                      itemCount: filteredExpense.length,
                                      itemBuilder: (context, index) {
                                        final expense = filteredExpense[index];
                                        final localTime = expense.expenseDate!.toLocal();
                                        final formattedExpenseDate = _formatFullDate(localTime);
                                        // Format transaction.date
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => expenseDetails(
                                                      userid:
                                                          widget.userInfo.id,
                                                      expensedetail:
                                                          expense, // Pass the single transaction object
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              // List Header
                                              if (index == 0 ||
                                                  filteredExpense[index - 1]
                                                          .expenseDate !=
                                                      expense.expenseDate)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                  ),
                                                  height: 30.0,
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          4.0,
                                                        ),
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
                                                  color:
                                                      Colors
                                                          .white, // Optional: Rounded corners
                                                ),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: expense.iconColor,
                                                    child: Icon(expense.iconData, color: Colors.white,),
                                                  ),
                                                  title: Text(expense.expenseName.toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors
                                                              .black, // Dynamic color based on dark mode
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        expense
                                                            .expenseDescription
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
      floatingActionButton: GestureDetector(
          onLongPress: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
            );

            if (result != null && result.files.single.path != null) {
              File file = File(result.files.single.path!);

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              // Check extension
              final extension = result.files.single.extension?.toLowerCase();
              if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
                // Convert image to PDF
                final pdf = pw.Document();
                final image = pw.MemoryImage(await file.readAsBytes());

                pdf.addPage(
                  pw.Page(
                    build: (pw.Context context) => pw.Center(child: pw.Image(image)),
                  ),
                );

                final tempDir = await getTemporaryDirectory();
                final converted = File('${tempDir.path}/converted_receipt.pdf');
                await converted.writeAsBytes(await pdf.save());

                file = converted; // Use converted PDF file
              }

              final token = Provider.of<signUpnLogin_viewmodel>(
                context,
                listen: false,
              ).authToken;

              final receiptParserVM = ReceiptParserViewModel();
              final success = await receiptParserVM.uploadPdf(file, token!);
              Navigator.of(context).pop(); // ✅ Dismiss loading dialog

              if (success && receiptParserVM.parsedResult != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => expenseInput(
                      parsedData: receiptParserVM.parsedResult,
                      pdfFile: file,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(receiptParserVM.errorMessage ?? 'Upload failed.'),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No file selected.')),
              );
            }
          },
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          onPressed: () async {
            final result = await FlutterDocScanner().getScannedDocumentAsPdf();
            if (result != null && result is Map) {
              final uriString = result['pdfUri'] as String?;
              final pdfPath = uriString?.replaceFirst('file://', '');

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              if (pdfPath != null && pdfPath.isNotEmpty) {
                setState(() {
                  _uploadedPdf = File(pdfPath);
                });
                File pdfFile = File(pdfPath);
                final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false,).authToken;
                final receiptParserVM = ReceiptParserViewModel();
                final success = await receiptParserVM.uploadPdf(
                  pdfFile,
                  token!,
                );
                Navigator.of(context).pop(); // ✅ Dismiss loading dialog
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
          child: const Icon(CupertinoIcons.qrcode_viewfinder, size: 40),
        ),
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
                Navigator.push(
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
