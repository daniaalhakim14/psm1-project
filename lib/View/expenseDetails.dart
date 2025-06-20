import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fyp/ViewModel/expense/expense_viewmodel.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../Model/expense.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';

class expenseDetails extends StatefulWidget {
  const expenseDetails({
    super.key,
    required this.userid,
    required this.expensedetail,
  });
  final int userid;
  final ListExpense expensedetail;

  @override
  State<expenseDetails> createState() => _expenseDetailsState();
}

class _expenseDetailsState extends State<expenseDetails> {
  late ListExpense expenseDetail;

  Future<void> refreshExpenseDetails() async {
    final token =
        Provider
            .of<signUpnLogin_viewmodel>(context, listen: false)
            .authToken;
    if (token != null) {
      final viewModel_listexpense = Provider.of<expenseViewModel>(
        context,
        listen: false,
      );
      await viewModel_listexpense.fetchViewExpense(widget.userid, token);
      await viewModel_listexpense.fetchListExpense(widget.userid, token);

      // Find the updated expense in list
      final updateExpense = viewModel_listexpense.listExpense.firstWhere(
            (expense) => expense.expenseid == expenseDetail.expenseid,
        orElse: () => expenseDetail,
      );

      setState(() {
        expenseDetail = updateExpense;
      });
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date available'; // Fallback message for null date
    }

    // Convert to Malaysia time by adding 8 hours
    DateTime malaysiaTime = dateTime.toUtc().add(Duration(hours: 8));

    // Format the Malaysia time
    return DateFormat('dd MMM yyyy').format(malaysiaTime).toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    expenseDetail = widget.expensedetail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xFF5A7BE7),
        title: Text(
          expenseDetail.categoryname.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: expenseDetail.iconColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 3),
                  ),
                  child: Center(
                    child: Icon(
                      expenseDetail.iconData,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              '${expenseDetail.categoryname}',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              formatDateTime(expenseDetail.expenseDate),
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: Text(
                    'RM',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  expenseDetail.expenseAmount?.toStringAsFixed(2) ?? '0.00',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Text(
              'Description: ${expenseDetail.expenseDescription}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            Text(
              'Payment Type: ${expenseDetail.paymenttype}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),

            GestureDetector(
              onTap: () {
                if (expenseDetail.receiptPdf != null && expenseDetail.receiptPdf!.isNotEmpty) {
                  try {
                    Uint8List pdfBytes = base64Decode(expenseDetail.receiptPdf!);
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          height: 500,
                          padding: const EdgeInsets.all(16),
                          child: SfPdfViewer.memory(pdfBytes),
                        ),
                      ),
                    );
                  } catch (e) {
                    print("Base64 decode failed: $e");
                  }
                }
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
                        'receipt.pdf',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    /*
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                    */
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Edit Button
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        /*
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => edit_expense(
                                  userid: widget.userid,
                                  expenseDetail: expenseDetail,
                                ),
                          ),
                        );
                        // If transaction is edited, refresh
                        if (result == true) {
                          print("Refreshing transaction details...");
                          await refreshExpenseDetails();
                        }
                        */
                        print('edit transaction');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.white, // Background color of the button
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ), // Adjust button size
                      ),
                      child: const Icon(
                        Icons.edit_note_outlined,
                        size: 27, // Icon size
                        color: Colors.blue, // Icon color
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ), // Space between button and text
                    const Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Matches the button theme
                      ),
                    ),
                  ],
                ),
                // Delete Button
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Add delete functionality if needed
                        showDeleteConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.white, // Background color of the button
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ), // Adjust button size
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 27, // Icon size
                        color: Colors.red, // Icon color
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ), // Space between button and text
                    const Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // Matches the button theme
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'delete transaction',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      onPressed: () async {
                        final token = Provider
                            .of<signUpnLogin_viewmodel>(context, listen: false)
                            .authToken;
                        final viewModel = Provider.of<expenseViewModel>(
                            context, listen: false);
                        await viewModel.deleteExpense(
                          expenseDetail.expenseid!,
                          widget.userid,
                          token!,
                        );
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(
                            true); // Return to previous screen with success
                      },

                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

