import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/Model/activitylog.dart';
import 'package:fyp/Model/expense.dart';
import 'package:fyp/View/Homepage/financialPlatformCategory.dart';
import 'package:fyp/ViewModel/activitylog/activitylog_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../Model/Category.dart';
import '../Model/financialplatformcategory.dart';
import '../ViewModel/expense/expense_viewmodel.dart';
import '../ViewModel/financialplatform/paltform_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'PdfViewerPage.dart';
import 'categorypage.dart';

// Global Variable
const List<String> paymentType = <String>[
  'Cash',
  'Debit Card',
  'Credit Card',
  'Online Transfer',
  'E-Wallet',
];
// store the selected payment type
String dropdownValue = paymentType.first;

class expenseInput extends StatefulWidget {
  final Map<String, dynamic>? parsedData;
  final File? pdfFile;
  const expenseInput({super.key, this.parsedData, this.pdfFile});

  @override
  State<expenseInput> createState() => _expenseInputState();
}

DateTime selectedDate = DateTime.now().toLocal();
late String todayDate = 'Today';
late String yesterdayDate = 'Yesterday';
late String textdate = todayDate;
late DateFormat date;
final TextEditingController _textControllerName = TextEditingController();
final _textControllerAmount = TextEditingController();
final _textControllerDescription = TextEditingController(); // to store user input
Map<String, dynamic>? _selectedCategory;
Map<String, dynamic>? _selectedFPCategory;
File? _uploadedPdf;

class _expenseInputState extends State<expenseInput> {
  bool _isLoading = true;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _labelForDate(DateTime d) {
    final now = DateTime.now().toLocal();
    if (_isSameDay(d, now)) return 'Today';
    if (_isSameDay(d, now.subtract(const Duration(days: 1))))
      return 'Yesterday';
    return DateFormat('dd-MM-yyyy').format(d);
  }

  void _initializeParsedData(List<ExpenseCategories> allCategories,
      List<FinancialPlatform> allFinancialPlatforms,) {
    final parsed = widget.parsedData;
    _uploadedPdf = widget.pdfFile;
    Map<String, dynamic>? extracted;

    // parse payment details
    if (parsed != null) {
      if (parsed.containsKey('rawText')) {
        try {
          final raw = parsed['rawText']
              .replaceAll(RegExp(r'```json\n?'), '')
              .replaceAll('```', '')
              .trim();
          extracted = json.decode(raw);
        } catch (e) {
          print("Failed to parse rawText: $e");
        }
      } else {
        extracted = parsed;
      }

      if (extracted != null) {
        // name, amount, desc
        _textControllerName.text = extracted['name'] ?? 'No name';
        _textControllerDescription.text =
            extracted['description'] ?? 'No description';
        _textControllerAmount.text = extracted['total'] ?? '';

        // date parsing
        if (extracted['date'] != null && extracted['date'] is String) {
          final rawDate = extracted['date'];
          final possibleFormats = [
            'dd/MM/yyyy',
            'dd-MM-yyyy',
            'dd MMM yyyy',
            'dd-MMM-yy',
            'yyyy-MM-dd',
            'yyyy.MM.dd',
            'dd.MM.yyyy',
          ];

          bool parsed = false;
          for (final format in possibleFormats) {
            try {
              final parsedLocal = DateFormat(format, 'en_US')
                  .parse(rawDate)
                  .toLocal();
              setState(() {
                selectedDate = parsedLocal;
                textdate = _labelForDate(
                    parsedLocal); // 👈 will say Today / Yesterday / formatted
              });

              parsed = true;
              break;
            } catch (_) {}
          }

          if (!parsed) {
            print("❌ Failed to parse date from: $rawDate");
          }
        }

        // auto categorise
        final rawCategoryName = extracted['category']?['name']?.toString();
        final categoryName = rawCategoryName?.toLowerCase().replaceAll(
            RegExp(r'\s+'), '').trim();
        print("Extracted category: $categoryName");

        bool matched = false;
        for (var category in allCategories) {
          final name = category.categoryName?.toLowerCase().replaceAll(
              RegExp(r'\s+'), '').trim();
          //print("🔍 Comparing '$name' with '$categoryName'");
          if (name == categoryName) {
            setState(() {
              _selectedCategory = {
                'categoryId': category.categoryId,
                'name': category.categoryName,
                'icon': category.iconData,
                'color': category.iconColor,
              };
            });
            matched = true;
            break;
          }
        }

        if (!matched) {
          print("❌ No matching category found for '$categoryName'");
        }

        // auto categorise
        final rawFinancialPlatformName = extracted['financialPlatform']?['name']
            ?.toString();
        final FPName = rawFinancialPlatformName?.toLowerCase().replaceAll(
            RegExp(r'\s+'), '').trim();
        print("Extracted Financial Platform: $FPName");

        bool matchedFP = false;
        for (var fp in allFinancialPlatforms) {
          final name = fp.name
              ?.toLowerCase()
              .replaceAll(RegExp(r'\s+'), '')
              .trim();
          //print("🔍 Comparing '$name' with '$categoryName'");
          if (name == FPName) {
            setState(() {
              _selectedFPCategory = {
                'platformid': fp.platfromid,
                'fpname': fp.name,
                'iconimage': fp.iconimage,
                'color': fp.iconColorExpense,
              };
            });
            matchedFP = true;
            break;
          }

          setState(() {
            _isLoading = false; // 👈 finished parsing
          });
        }

        if (!matched) {
          print("❌ No matching financial platform found for '$FPName'");
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading;
    // Wait until the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<expenseViewModel>(context, listen: false);
      final viewModel_fp = Provider.of<platformViewModel>(context, listen: false);
      // Optional: fetch category list if not already fetched
      if (viewModel.categoryList.isEmpty) {
        await viewModel
            .fetchCategories(); // <-- add this method if you haven't already
      }
      if (viewModel_fp.FPcategory.isEmpty) {
        await viewModel_fp
            .fetchFPCategories(); // <-- add this method if you haven't already
      }
      // Wait until it's not empty
      while (viewModel.categoryList.isEmpty ||
          viewModel_fp.FPcategory.isEmpty) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      _initializeParsedData(viewModel.categoryList, viewModel_fp.FPcategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF5A7BE7),
        title: const Text(
          'Expense Input',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.only(top: screenHeight * 0.015),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.025),
            child: Column(
              children: [
                // date and expense input
                Row(
                  children: [
                    // Enter date button
                    ElevatedButton(
                      onPressed: () async {
                        print('date: $selectedDate');

                        final DateTime? dateTime = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.utc(2000, 01, 01),
                          lastDate: DateTime.utc(2100, 12, 31),
                        );
                        if (dateTime != null &&
                            !dateTime.isAfter(DateTime.now().toLocal())) {
                          setState(() {
                            // Update `selectedDate` to the picked date
                            selectedDate = dateTime;

                            // Check if the date is yesterday
                            DateTime yesterday = DateTime.now()
                                .toLocal()
                                .subtract(Duration(days: 1));
                            if (dateTime.year == yesterday.year &&
                                dateTime.month == yesterday.month &&
                                dateTime.day == yesterday.day) {
                              textdate = yesterdayDate; // Set to 'Yesterday'
                              selectedDate = yesterday;
                            } else if (dateTime.year == DateTime
                                .now()
                                .year &&
                                dateTime.month == DateTime
                                    .now()
                                    .month &&
                                dateTime.day == DateTime
                                    .now()
                                    .day) {
                              textdate = todayDate; // Set to 'Today'
                            } else {
                              textdate = DateFormat('dd-MM-yyyy').format(
                                dateTime.toLocal(),
                              ); // Default date format
                            }
                          });
                        } else {
                          // show a message if the date is invalid
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select today\'s date or a past date.',
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(textdate),
                    ),
                    SizedBox(width: screenWidth * 0.025),
                    // Amount
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 0.2, right: 2),
                        child: TextField(
                          controller:
                          _textControllerAmount,
                          // Ensure this is initialized
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                r'^\d*\.?\d{0,2}',
                              ), // Restrict to two decimal places
                            ),
                          ],
                          onChanged: (value) {
                            // Dynamically handle input formatting if needed
                            setState(() {}); // Trigger UI update
                          },
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.025,
                              ),
                              child: Text(
                                '-RM ',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            hintText:
                            '0.00',
                            // Simplified to match the desired behavior
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 18,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _textControllerAmount.clear();
                                setState(() {}); // Clear and refresh UI
                              },
                              icon: const Icon(Icons.clear, size: 25.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //border
                Divider(thickness: 2, color: Colors.black),
                // Receipt Name
                Padding(
                  padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/Icons/id-card.png', scale: 9),
                          Padding(
                            padding: EdgeInsets.only(
                              left: screenWidth * 0.025,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.76,
                                  height: screenHeight * 0.065,
                                  child: TextField(
                                    controller: _textControllerName,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: 'Add Receipt Name',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          _textControllerName.clear();
                                        },
                                        icon: const Icon(Icons.clear),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // select category
                Padding(
                  padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // This will space the elements apart
                    children: [
                      Material(
                        color: Colors.transparent,
                        // keep background transparent
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          // same radius as your container
                          onTap: () async {
                            final selectedcategory = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => categoryPage()),
                            );
                            if (selectedcategory != null) {
                              setState(() {
                                _selectedCategory = selectedcategory;
                              });
                            }
                          },
                          child: Container(
                            width: screenWidth * 0.95,
                            height: screenHeight * 0.080,
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 10),
                                  child: DottedBorder(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                    dashPattern: const [6, 3],
                                    borderType: BorderType.Circle,
                                    child: Container(
                                      width: 47,
                                      height: 47,
                                      decoration: BoxDecoration(
                                        color: _selectedCategory != null
                                            ? _selectedCategory!['color']
                                            : Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: _selectedCategory != null
                                          ? Center(
                                        child: Icon(
                                          _selectedCategory?['icon'],
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      )
                                          : const Icon(
                                          Icons.image, color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(
                                    _selectedCategory != null
                                        ? _selectedCategory!['name']
                                        : 'Select Category',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios, size: 30),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(thickness: 2, color: Colors.black),
                // add description
                Padding(
                  padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.doc, size: 60, color: Colors.black87),
                      Padding(
                        padding: EdgeInsets.only(left: 6.4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.76,
                              height: screenHeight * 0.065,
                              child: TextField(
                                controller: _textControllerDescription,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: 'Add Description',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      _textControllerDescription.clear();
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // select financial platform
                Padding(
                  padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // This will space the elements apart
                    children: [
                      Material(
                        color: Colors.transparent,
                        // keep background transparent
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          // same radius as your container
                          onTap: () async {
                            final selectedFPcategory = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  financialPlatformCategory()),
                            );
                            if (selectedFPcategory != null) {
                              setState(() {
                                _selectedFPCategory = selectedFPcategory;
                              });
                            }
                          },
                          child: Container(
                              width: screenWidth * 0.95,
                              height: screenHeight * 0.080,
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 6, right: 10),
                                    child: DottedBorder(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                      dashPattern: const [6, 3],
                                      borderType: BorderType.Circle,
                                      child: Container(
                                        width: 47,
                                        height: 47,
                                        decoration: BoxDecoration(
                                          color: (_selectedFPCategory != null &&
                                              _selectedFPCategory!['color'] is Color)
                                              ? _selectedFPCategory!['color'] as Color
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: (_selectedFPCategory != null &&
                                            _selectedFPCategory!['iconimage'] !=
                                                null)
                                            ? Center(
                                          child: Image.memory(
                                            _selectedFPCategory!['iconimage'] as Uint8List,
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                            : const Icon(
                                            Icons.image, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Name (flexible to avoid overflow)
                                  Expanded(
                                    child: Text(
                                      _selectedFPCategory != null
                                          ? (_selectedFPCategory!['fpname']
                                          ?.toString() ?? '')
                                          : 'Select Financial Platform',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 20),
                                ],
                              )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // border
                Divider(thickness: 2, color: Colors.black),
                // Attached PDF
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.02,
                    top: screenHeight * 0.005,
                  ),
                  child: Column(
                    children: [
                      if (_uploadedPdf != null)
                        pdfUploadPreview(_uploadedPdf!, () {
                          setState(() {
                            _uploadedPdf = null;
                          });
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFE3ECF5),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false,).authToken;
                final viewModel = Provider.of<expenseViewModel>(context, listen: false,);
                final viewModelActivity = Provider.of<activitylog_viewModel>(context, listen: false,);
                final pdfBytes = await _uploadedPdf!.readAsBytes();
                final base64Pdf = base64Encode(pdfBytes);

                AddExpense expense = AddExpense(
                  expenseAmount: double.parse(_textControllerAmount.text),
                  expenseDate: selectedDate,
                  expenseName: _textControllerName.text,
                  expenseDescription: _textControllerDescription.text,
                  financialPlatformId: _selectedFPCategory!['platformid'],
                  receiptPdf: base64Pdf,
                  userId: Provider.of<signUpnLogin_viewmodel>(context, listen: false,).userInfo?.id,
                  categoryId: _selectedCategory!['categoryId'],
                );

                print({
                  'expenseAmount': double.parse(_textControllerAmount.text),
                  'expenseDate': selectedDate,
                  'expenseName': _textControllerName.text,
                  'expenseDescription': _textControllerDescription.text,
                  'financialPlatform': _selectedFPCategory?['platformid'],
                  'receiptPdf': base64Pdf != null
                      ? 'PDF attached, length: ${base64Pdf.length} chars'
                      : 'No PDF',
                  'userId': Provider.of<signUpnLogin_viewmodel>(context, listen: false)
                      .userInfo
                      ?.id,
                  'categoryId': _selectedCategory?['categoryId'],
                });


                // Activity log
                ActivityLog activitylog = ActivityLog(userid: Provider.of<signUpnLogin_viewmodel>(context, listen: false,).userInfo!.id,
                    activitytypeid: 2, // id code for - add expense
                    timestamp: DateTime.now()
                );

                try {
                  if (token != null) {
                    await viewModel.addExpense(expense, token);
                    await viewModelActivity.logActivity(activitylog, token);
                    bool dismissedByTimer = true;

                    await showDialog(context: context,
                      barrierDismissible: false,
                      // Prevent dismiss by tapping outside
                      builder: (BuildContext context) {
                        // Start a delayed close
                        Future.delayed(Duration(seconds: 3), () {
                          if (dismissedByTimer && Navigator.canPop(context)) {
                            Navigator.of(context).pop(); // Auto close after 3s
                          }
                        });

                        return AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Expense added successfully!'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                dismissedByTimer =
                                false; // User pressed manually
                                Navigator.of(context).pop(); // Close dialog
                              },
                            ),
                          ],
                        );
                      },
                    );

                    // fetch updated data
                    final homeExpenseViewModel = Provider.of<expenseViewModel>(context, listen: false,);
                    await homeExpenseViewModel.fetchViewExpense(expense.userId!, token,);
                    await homeExpenseViewModel.fetchViewExpenseFinancialPlatform(expense.userId!, token); // feeds platform pie
                    await homeExpenseViewModel.fetchListExpense(expense.userId!, token);                  // feeds list
                    Navigator.pop(context); // Return to previous screen
                  }
                  // Navigate back on success
                } catch (e) {
                  print("Failed to add Expense: $e");
                  print(selectedDate);
                  print(_textControllerAmount.text);
                  print(_selectedCategory!['categoryId']);
                  print(_textControllerDescription.text);
                  print(dropdownValue);
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF5A7BE7),
                ),
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.85,
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.065,
                child: const Text(
                  'Add Expense',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget pdfUploadPreview(File pdfFile, VoidCallback onRemove) {
    return GestureDetector(
      onTap: () async {
        // Open in in-app PDF viewer
        final bytes = await pdfFile.readAsBytes();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(pdfBytes: bytes),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                pdfFile.path.split('/').last,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                final confirmed = await showDarkConfirmDialog(
                  context: context,
                  line1: ' Remove PDF Receipt?\n',
                  line2: 'You will need to scan or reupload a new receipt.',
                  yesText: 'Yes',
                  noText: 'No',
                  yesColor: Colors.red,
                  noColor: Colors.green,
                );

                if (confirmed == true) {
                  onRemove();         // remove preview/file
                  Navigator.pop(context); // optional: also leave the page (pop once)
                  // If you need to pop twice, do another Navigator.pop(context);
                }
              },
              child: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> showDarkConfirmDialog({
    required BuildContext context,
    required String line1,
    required String line2,
    String yesText = 'Yes',
    String noText  = 'No',
    Color? yesColor,
    Color? noColor,
  }) {
    return showDialog<bool>(context: context, builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(line1, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center),
                Text(line2, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yesColor ?? Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(yesText,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: noColor ?? Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(noText,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}