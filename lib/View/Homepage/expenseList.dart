import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Make sure this is imported
import '../../Model/expense.dart';
import '../../ViewModel/expense/expense_viewmodel.dart';
import '../expenseDetails.dart';
class expenseList extends StatefulWidget {
  expenseList({
    super.key,
    required this.selectedMonth,
    required this.userid,
  });

  String selectedMonth;
  final int userid;

  @override
  State<expenseList> createState() => _expenseListState();
}

class _expenseListState extends State<expenseList> {

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Text(widget.selectedMonth,style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Color(0xFF5A7BE7),
      ),
      body: Consumer<expenseViewModel>(
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
          // Filter list expense by the selected month
          final filteredExpense = listExpense.where((expense) {
            String isoFormatDate = expense.expenseDate.toString();
            DateTime utcTime = DateTime.parse(isoFormatDate,);
            DateTime localTime = utcTime.toLocal();
            String formattedExpenseDate = _formatMonth(localTime);
            return formattedExpenseDate == widget.selectedMonth;
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
                    'No transactions for ${widget.selectedMonth}',
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
          return ListView.builder(
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
                        userid: widget.userid, expensedetail: expense, // Pass the single transaction object
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    // List Header
                    if (index == 0 || filteredExpense[index - 1].expenseDate != expense.expenseDate)
                      Container(
                        decoration: BoxDecoration(color: Colors.grey[200],),
                        height: 30.0,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0,),
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
                        color: Colors.white, // Optional: Rounded corners
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: expense.iconColor,
                          child: Icon(expense.iconData, color: Colors.white,),
                        ),
                        title: Text(expense.expenseName.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Dynamic color based on dark mode
                          ),
                          maxLines: 1, // 👈 only show first line
                          overflow: TextOverflow.ellipsis, // 👈 add "..." if text is too long
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expense.expenseDescription.toString(),
                              maxLines: 1, // 👈 only show first line
                              overflow: TextOverflow.ellipsis, // 👈 add "..." if text is too long
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(left: 8.0,),
                          child: Text('RM ${expense.expenseAmount}',
                            // Format the amount
                            style: TextStyle(
                              color: Colors.black, // Dynamic color
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

    );
  }
}
