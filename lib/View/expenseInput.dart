import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/Model/expense.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../Model/Category.dart';
import '../ViewModel/expense/expense_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
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

DateTime selectedDate = DateTime.now().toUtc().add(Duration(hours: 8));
late String todayDate = 'Today';
late String yesterdayDate = 'Yesterday';
late String textdate = todayDate;
late DateFormat date;
final TextEditingController _textControllerName = TextEditingController();
final _textControllerAmount = TextEditingController();
final _textControllerDescription = TextEditingController(); // to store user input
Map<String, dynamic>? _selectedCategory;
File? _uploadedPdf;

class _expenseInputState extends State<expenseInput> {

  void _initializeParsedData(List<Category> allCategories) {
    final parsed = widget.parsedData;
    _uploadedPdf = widget.pdfFile;
    Map<String, dynamic>? extracted;

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
        _textControllerDescription.text = extracted['description'] ?? 'No description';
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
          ];

          bool parsed = false;
          for (final format in possibleFormats) {
            try {
              selectedDate = DateFormat(format, 'en_US').parse(rawDate).toLocal();
              textdate = DateFormat('dd-MM-yyyy').format(selectedDate);
              parsed = true;
              break;
            } catch (_) {}
          }

          if (!parsed) {
            print("❌ Failed to parse date from: $rawDate");
          }
        }

        // auto category
        final rawCategoryName = extracted['category']?['name']?.toString();
        final categoryName = rawCategoryName?.toLowerCase().replaceAll(RegExp(r'\s+'), '').trim();
        print("Extracted category: $categoryName");

        bool matched = false;
        for (var category in allCategories) {
          final name = category.categoryName
              ?.toLowerCase()
              .replaceAll(RegExp(r'\s+'), '')
              .trim();

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
      }
    }
  }


  @override
  void initState() {
    super.initState();

    // Wait until the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<expenseViewModel>(context, listen: false);

      // Optional: fetch category list if not already fetched
      if (viewModel.category.isEmpty) {
        await viewModel.fetchCategories(); // <-- add this method if you haven't already
      }

      // Wait until it's not empty
      while (viewModel.category.isEmpty) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      _initializeParsedData(viewModel.category);
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF5A7BE7),
        title: Center(
          child: const Text(
            'Expense Input',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.015),
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
                            } else if (dateTime.year == DateTime.now().year &&
                                dateTime.month == DateTime.now().month &&
                                dateTime.day == DateTime.now().day) {
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
                        padding: EdgeInsets.all(screenWidth * 0.018),
                        child: TextField(
                          controller:
                              _textControllerAmount, // Ensure this is initialized
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
                                '0.00', // Simplified to match the desired behavior
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
                              top: 0,
                              bottom: 0.0,
                              left: screenWidth * 0.025,
                              right: 0,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.74,
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
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween, // This will space the elements apart
                    children: [
                      GestureDetector(
                        onTap: () async {
                            final selectedcategory = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => categoryPage(),
                            ),
                          );
                          if (selectedcategory != null) {
                            setState(() {
                              _selectedCategory =
                                  selectedcategory; // to add to database and display the selected subcategory
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5.0,
                                bottom: 0.0,
                                left: 6,
                                right: 10,
                              ),
                              child: DottedBorder(
                                color: Colors.black,
                                strokeWidth: 2,
                                dashPattern: const [6, 3],
                                borderType: BorderType.Circle,
                                child: Container(
                                  width: 47,
                                  height: 47,
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedCategory != null
                                            ? _selectedCategory!['color']
                                            : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      _selectedCategory != null
                                          ? Center(
                                            child: Icon(
                                              _selectedCategory?['icon'],
                                              size: 30,
                                              color: Colors.white,
                                            ),
                                          )
                                          : null,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5.0,
                                bottom: 0.0,
                                left: 10,
                                right: 10,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedCategory != null
                                        ? _selectedCategory!['name']
                                        : 'Set Category',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 22.0,
                                      color:
                                          Colors
                                              .black, // Adjust color dynamically
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 30),
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
                        padding: EdgeInsets.only(
                          top: 0,
                          bottom: 0.0,
                          left: screenWidth * 0.025,
                          right: 0,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.74,
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
                // Payment type
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 0.0,
                        bottom: 0.0,
                        left: screenWidth * 0.025,
                        right: 0,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payment,
                            size: 50,
                            color: Colors.black87,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.0,
                              bottom: 0.0,
                              left: screenWidth * 0.025,
                              right: 0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Payment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 22.0,
                                    color:
                                        Colors
                                            .black, // Adjust color dynamically
                                  ),
                                ),
                                // Payment Type
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.23,
                                  ),
                                  child: Row(
                                    children: [
                                      DropdownButton<String>(
                                        value: dropdownValue,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                        ),
                                        elevation: 16,
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                        ),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String? value) {
                                          // this is called when the user selects an item.
                                          setState(() {
                                            dropdownValue = value!;
                                          });
                                        },
                                        items:
                                            paymentType.map<
                                              DropdownMenuItem<String>
                                            >((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Container(
                                                  width:
                                                      screenWidth *
                                                      0.20, // Customize the width
                                                  height:
                                                      screenHeight *
                                                      0.1, // Customize the height
                                                  alignment:
                                                      Alignment
                                                          .centerLeft, // Align text if needed
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ), // Add padding
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ), // Customize text style
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // border
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.020,
                  ),
                  child: Divider(thickness: 2, color: Colors.black),
                ),
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
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false,).authToken;
                final viewModel = Provider.of<expenseViewModel>(context, listen: false,);
                final pdfBytes = await _uploadedPdf!.readAsBytes();
                final base64Pdf = base64Encode(pdfBytes);

                AddExpense expense = AddExpense(
                  expenseAmount: double.parse(_textControllerAmount.text),
                  expenseDate: selectedDate,
                  expenseName: _textControllerName.text,
                  expenseDescription: _textControllerDescription.text,
                  financialPlatform: 1,
                  receiptPdf: base64Pdf,
                  userId: Provider.of<signUpnLogin_viewmodel>(context, listen: false,).userInfo?.id,
                  categoryId: _selectedCategory!['categoryId'],
                );
                try {
                  if (token != null) {
                    await viewModel.addExpense(expense, token);

                    bool dismissedByTimer = true;

                    await showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Prevent dismiss by tapping outside
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
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.065,
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
        await OpenFile.open(pdfFile.path); // open PDF on tap
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
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                pdfFile.path.split('/').last, // show filename
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
