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
import '../Model/activitylog.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/activitylog/activitylog_viewmodel.dart';
import '../ViewModel/expense/expense_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'Homepage/financialPlatformCategory.dart';
import 'PdfViewerPage.dart';
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
  Map<String, dynamic>? _selectedFPCategory;
  Uint8List? _pdfBytes;
  String? _pdfFileName;
  String? pdfreceipt;

  int? _expenseid;
  ListExpense? _originalExpense;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Defer to after the first frame so notifyListeners() won't happen during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadExpenseDetails();
    });
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
    _expenseid = expense.expenseid;
    pdfreceipt = expense.receiptPdf;
    // Populate text fields
    _textControllerName.text = expense.expenseName ?? '';
    _textControllerAmount.text = expense.expenseAmount?.toString() ?? '';
    _textControllerDescription.text = expense.expenseDescription ?? '';

    // Set date
    if (expense.expenseDate != null) {
      selectedDate = expense.expenseDate!;
      _updateDateText();
    }

    // Set category
    if (expense.categoryname != null) {
      _selectedCategory = {
        'categoryId': expense.categoryid,
        'name': expense.categoryname,
        'icon': expense.iconData,
        'color': expense.iconColor,
      };
    }

    // Set financial platform
    if (expense.name !=null){
      _selectedFPCategory ={
        'platformid': expense.platformid,
        'fpname':expense.name,
        'iconimage':expense.iconimage,
        'iconcolorexpense':expense.iconColorExpense
      };
    }

    // Set PDF if available
    if (expense.receiptPdf != null && expense.receiptPdf!.isNotEmpty) {
      try {
        _pdfBytes = base64Decode(expense.receiptPdf!);
        _pdfFileName = 'Receipt.pdf';
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
                                padding: const EdgeInsets.only(left: 6, right: 10),
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
                              Padding(padding: const EdgeInsets.only(left: 10, right: 10),
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
                      GestureDetector(
                        onTap: () {
                          Uint8List pdfBytes = base64Decode(pdfreceipt!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewerPage(pdfBytes: pdfBytes),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.picture_as_pdf, color: Colors.red),
                              SizedBox(width: 12),
                              Expanded(child: Text('Receipt.pdf', style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis)),
                              Icon(Icons.open_in_new, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
              _pdfFileName ?? 'Receipt.pdf',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
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
      UpdateExpense updatedExpense = UpdateExpense(
        expenseId: _expenseid,
        expenseAmount: double.parse(_textControllerAmount.text),
        expenseDate: selectedDate,
        expenseName: _textControllerName.text,
        expenseDescription: _textControllerDescription.text,
        financialPlatform: _selectedFPCategory!['platformid'],
        userId: widget.userid,
        categoryId: _selectedCategory!['categoryId'],
      //  paymentType: dropdownValue,
      );
      final viewModelActivity = Provider.of<activitylog_viewModel>(context, listen: false,);
      // Activity log
      ActivityLog activitylog = ActivityLog(
        userid: Provider.of<signUpnLogin_viewmodel>(context, listen: false,).userInfo!.id,
        activitytypeid: 3, // id code for - edit expense
        timestamp: DateTime.now(),
      );


      /*
      print("🔧 Updating Expense:");
      print("  expenseId: ${updatedExpense.expenseId}");
      print("  amount: ${updatedExpense.expenseAmount}");
      print("  date: ${updatedExpense.expenseDate?.toIso8601String()}");
      print("  name: ${updatedExpense.expenseName}");
      print("  description: ${updatedExpense.expenseDescription}");
      print("  platformId: ${updatedExpense.financialPlatform}");
      print("  userId: ${updatedExpense.userId}");
      print("  categoryId: ${updatedExpense.categoryId}");

       */

      await viewModel.updateExpense(updatedExpense, token!);
      await viewModelActivity.logActivity(activitylog, token);
      bool dismissedByTimer = true;
      // Show success message
       AlertDialog(
        title: const Text('Success'),
        content: const Text('Expense updated successfully!'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              dismissedByTimer = false; // User pressed manually
              Navigator.of(context).pop(); // Close dialog
            },
          ),
        ],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh expense data
      await viewModel.fetchViewExpense(widget.userid, token);
      await viewModel.fetchListExpense(widget.userid, token);
      await viewModel.fetchViewExpenseFinancialPlatform(widget.userid, token);

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