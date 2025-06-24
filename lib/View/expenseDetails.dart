import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fyp/ViewModel/expense/expense_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../Model/expense.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'PdfViewerPage.dart';

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
    final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
    if (token != null) {
      final viewModel_listexpense = Provider.of<expenseViewModel>(context, listen: false);
      await viewModel_listexpense.fetchViewExpense(widget.userid, token);
      await viewModel_listexpense.fetchListExpense(widget.userid, token);

      final updateExpense = viewModel_listexpense.listExpense.firstWhere(
            (expense) => expense.expenseid == expenseDetail.expenseid,
        orElse: () => expenseDetail,
      );

      setState(() {
        expenseDetail = updateExpense;
      });
    }
  }

  String formatDateTime(DateTime? date) {
    final local = date?.toLocal();
    return DateFormat('dd MMM yyyy').format(local!);
  }

  @override
  void initState() {
    super.initState();
    expenseDetail = widget.expensedetail;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7BE7),
        title: Text(expenseDetail.expenseName ?? 'Receipt Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: expenseDetail.iconColor,
              child: Icon(expenseDetail.iconData, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text('RM${expenseDetail.expenseAmount?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Category: '),
                        TextSpan(
                          text: '${expenseDetail.categoryname}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Date: '),
                        TextSpan(
                          text: formatDateTime(expenseDetail.expenseDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Description: '),
                        TextSpan(
                          text: '${expenseDetail.expenseDescription}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Payment Type: '),
                        TextSpan(
                          text: '${expenseDetail.paymenttype ?? 'Not specified'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),
            if (expenseDetail.receiptPdf != null && expenseDetail.receiptPdf!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Uint8List pdfBytes = base64Decode(expenseDetail.receiptPdf!);
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
                      Expanded(child: Text('receipt.pdf', style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis)),
                      Icon(Icons.open_in_new, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => print('edit transaction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      child: const Icon(Icons.edit_note_outlined, size: 27, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    const Text("Edit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => showDeleteConfirmationDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      child: const Icon(Icons.delete_outline, size: 27, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    const Text("Delete", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFE3ECF5),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 70,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFF5A7BE7),
            ),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
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
                const Text('Are you sure you want to', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), textAlign: TextAlign.center),
                const Text('delete this transaction?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      onPressed: () async {
                        final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
                        final viewModel = Provider.of<expenseViewModel>(context, listen: false);
                        await viewModel.deleteExpense(
                          expenseDetail.expenseid!,
                          widget.userid,
                          token!,
                        );
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Yes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('No', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
