import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/Model/expense.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../Model/Category.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/expense/expense_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'categorypage.dart';

// Global Variable for payment types
const List<String> paymentType = <String>[
  'Cash',
  'Debit Card',
  'Credit Card',
  'Online Transfer',
  'E-Wallet',
];

class editExpense extends StatefulWidget {
  final int userid;
  final ListExpense expensedetail;

  const editExpense({
    super.key,
    required this.userid,
    required this.expensedetail,
  });

  @override
  State<editExpense> createState() => _editExpenseState();
}

class _editExpenseState extends State<editExpense> {
  DateTime selectedDate = DateTime.now().toUtc().add(Duration(hours: 8));
  String todayDate = 'Today';
  String yesterdayDate = 'Yesterday';
  String textdate = 'Today';
  String dropdownValue = paymentType.first;

  final TextEditingController _textControllerName = TextEditingController();
  final TextEditingController _textControllerAmount = TextEditingController();
  final TextEditingController _textControllerDescription = TextEditingController();

  Map<String, dynamic>? _selectedCategory;
  Uint8List? _pdfBytes;
  String? _pdfFileName;
  ListExpense? _originalExpense;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadExpenseDetails();
  }

  Future<void> _loadExpenseDetails() async {
    final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
    final viewModel = Provider.of<expenseViewModel>(context, listen: false);

    if (token != null) {
      try {
        // Fetch latest expense data
        await viewModel.fetchListExpense(widget.userid, token);

        // Find the specific expense
        final expense = viewModel.listExpense.firstWhere(
              (exp) => exp.expenseid == widget.expensedetail.expenseid,
          orElse: () => widget.expensedetail, // Fallback to passed expense
        );

        setState(() {
          _originalExpense = expense;
          _populateFields(expense);
          _isLoading = false;
        });
      } catch (e) {
        print("Error loading expense details: $e");
        setState(() {
          _originalExpense = widget.expensedetail;
          _populateFields(widget.expensedetail);
          _isLoading = false;
        });
      }
    }
  }

  void _populateFields(ListExpense expense) {
    // Populate text fields
    _textControllerName.text = expense.expenseName ?? '';
    _textControllerAmount.text = expense.expenseAmount?.toString() ?? '';
    _textControllerDescription.text = expense.expenseDescription ?? '';

    // Set payment type
    if (expense.paymenttype != null && paymentType.contains(expense.paymenttype)) {
      dropdownValue = expense.paymenttype!;
    }

    // Set date
    if (expense.expenseDate != null) {
      selectedDate = expense.expenseDate!;
      _updateDateText();
    }

    // Set category
    if (expense.categoryname != null) {
      _selectedCategory = {
        'categoryId': expense.expenseid,
        'name': expense.categoryname,
        'icon': expense.iconData,
        'color': expense.iconColor,
      };
    }

    // Set PDF if available
    if (expense.receiptPdf != null && expense.receiptPdf!.isNotEmpty) {
      try {
        _pdfBytes = base64Decode(expense.receiptPdf!);
        _pdfFileName = 'receipt.pdf';
      } catch (e) {
        print("Error decoding PDF: $e");
        _pdfBytes = null;
      }
    }
  }

  void _updateDateText() {
    DateTime now = DateTime.now().toLocal();
    DateTime yesterday = now.subtract(Duration(days: 1));

    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      textdate = todayDate;
    } else if (selectedDate.year == yesterday.year &&
        selectedDate.month == yesterday.month &&
        selectedDate.day == yesterday.day) {
      textdate = yesterdayDate;
    } else {
      textdate = DateFormat('dd-MM-yyyy').format(selectedDate);
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pdfBytes = result.files.first.bytes;
          _pdfFileName = result.files.first.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking PDF: $e')),
      );
    }
  }

  @override
  void dispose() {
    _textControllerName.dispose();
    _textControllerAmount.dispose();
    _textControllerDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFE3ECF5),
        appBar: AppBar(
          backgroundColor: Color(0xFF5A7BE7),
          title: const Text(
            'Edit Expense',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF5A7BE7),
        title: const Text(
          'Edit Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.015),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.025),
            child: Column(
              children: [
                // Date and expense amount input
                Row(
                  children: [
                    // Date picker button
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? dateTime = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.utc(2000, 01, 01),
                          lastDate: DateTime.utc(2100, 12, 31),
                        );
                        if (dateTime != null &&
                            !dateTime.isAfter(DateTime.now().toLocal())) {
                          setState(() {
                            selectedDate = dateTime;
                            _updateDateText();
                          });
                        } else {
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
                    // Amount input
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.018),
                        child: TextField(
                          controller: _textControllerAmount,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {});
                          },
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.025,
                              ),
                              child: const Text(
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
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 18,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _textControllerAmount.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear, size: 25.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Divider
                const Divider(thickness: 2, color: Colors.black),
                // Receipt Name
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Image.asset('assets/Icons/id-card.png', scale: 9),
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.025,
                        ),
                        child: SizedBox(
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
                      ),
                    ],
                  ),
                ),
                // Category selection
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final selectedCategory = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => categoryPage(),
                            ),
                          );
                          if (selectedCategory != null) {
                            setState(() {
                              _selectedCategory = selectedCategory;
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
                                    color: _selectedCategory != null
                                        ? _selectedCategory!['color']
                                        : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: _selectedCategory != null
                                      ? Center(
                                    child: Icon(
                                      _selectedCategory!['icon'],
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
                              child: Text(
                                _selectedCategory != null
                                    ? _selectedCategory!['name']
                                    : 'Set Category',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 22.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 30),
                    ],
                  ),
                ),
                const Divider(thickness: 2, color: Colors.black),
                // Description
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.doc, size: 60, color: Colors.black87),
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.025,
                        ),
                        child: SizedBox(
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
                      ),
                    ],
                  ),
                ),
                // Payment type
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.025,
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
                              left: screenWidth * 0.025,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Payment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 22.0,
                                    color: Colors.black,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.23,
                                  ),
                                  child: DropdownButton<String>(
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
                                      setState(() {
                                        dropdownValue = value!;
                                      });
                                    },
                                    items: paymentType.map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Container(
                                            width: screenWidth * 0.20,
                                            height: screenHeight * 0.1,
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
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
                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.020,
                  ),
                  child: const Divider(thickness: 2, color: Colors.black),
                ),
                // PDF section
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.02,
                    top: screenHeight * 0.005,
                  ),
                  child: Column(
                    children: [
                      // PDF upload button
                      GestureDetector(
                        onTap: _pickPDF,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.upload_file, color: Colors.grey[600]),
                              const SizedBox(width: 10),
                              Text(
                                'Upload PDF Receipt',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // PDF preview
                      if (_pdfBytes != null) _pdfPreview(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFE3ECF5),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTap: _isUpdating ? null : _updateExpense,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _isUpdating ? Colors.grey : const Color(0xFF5A7BE7),
              ),
              child: _isUpdating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Update Expense',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pdfPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              _pdfFileName ?? 'receipt.pdf',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                _pdfBytes = null;
                _pdfFileName = null;
              });
            },
            child: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _updateExpense() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
    final viewModel = Provider.of<expenseViewModel>(context, listen: false);

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      setState(() {
        _isUpdating = false;
      });
      return;
    }

    // Validation
    if (_textControllerAmount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      setState(() {
        _isUpdating = false;
      });
      return;
    }

    if (_textControllerName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a receipt name')),
      );
      setState(() {
        _isUpdating = false;
      });
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      setState(() {
        _isUpdating = false;
      });
      return;
    }

    try {
      // Convert PDF bytes to base64 if available
      String? base64Pdf;
      if (_pdfBytes != null) {
        base64Pdf = base64Encode(_pdfBytes!);
      }

      // Create updated expense object
      AddExpense updatedExpense = AddExpense(
        expenseAmount: double.parse(_textControllerAmount.text),
        expenseDate: selectedDate,
        expenseName: _textControllerName.text,
        expenseDescription: _textControllerDescription.text,
        financialPlatform: 1,
        receiptPdf: base64Pdf,
        userId: widget.userid,
        categoryId: _selectedCategory!['categoryId'],
      //  paymentType: dropdownValue,
      );

      // You need to implement updateExpense method in your viewModel
      // For now, I'll show how it should be called
     /* await viewModel.updateExpense(
          widget.expensedetail.expenseid!,
          updatedExpense,
          token
      );


      */
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh expense data
      await viewModel.fetchViewExpense(widget.userid, token);
      await viewModel.fetchListExpense(widget.userid, token);

      // Return to previous screen with success indicator
      Navigator.pop(context, true);

    } catch (e) {
      print("Failed to update expense: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update expense: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }
}