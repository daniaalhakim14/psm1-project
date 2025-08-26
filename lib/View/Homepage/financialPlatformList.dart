import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Model/expense.dart';
import '../../ViewModel/expense/expense_viewmodel.dart';
import '../financialPlatformExpenseList.dart';
class financialPlatformList extends StatefulWidget {
   financialPlatformList({
     super.key,
     required this.selectedMonth,
     required this.userid,
   });
   String selectedMonth;
   final int userid;

  @override
  State<financialPlatformList> createState() => _financialPlatformListState();
}

class _financialPlatformListState extends State<financialPlatformList> {
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
        title: Text('Financial Platform', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Color(0xFF5A7BE7),
      ),
      body: Consumer<expenseViewModel>(
        builder: (context, vm, child) {
          final List<ListExpense> fpList = vm.listExpense;
          if (vm.fetchingData) {
            return SizedBox(
              width: 250,
              height: 250,
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          // 1) Filter by selected month (and user if needed)
          final filtered = fpList.where((tx) {
            final iso = tx.expenseDate.toString();
            final localTime = DateTime.parse(iso).toLocal();
            final monthStr = _formatMonth(localTime);
            return monthStr == widget.selectedMonth;
          }).toList();

          // 2) Group by financial platform name
          final Map<String, List<ListExpense>> grouped = {};
          for (final tx in filtered) {
            final fpname = tx.name ?? 'Not Available';
            grouped.putIfAbsent(fpname, () => []).add(tx);
          }

          // 3) Build list (count + total per platform)
          return ListView.builder(
            itemCount: grouped.keys.length,
            itemBuilder: (context, index) {
              final platformName = grouped.keys.elementAt(index);
              final platformTxs = grouped[platformName]!;
              final totalAmount = platformTxs.fold<double>(
                0.0, (sum, t) => sum + (t.expenseAmount ?? 0.0),
              );
              // Take first transaction’s iconimage (assuming all tx under same platform share it)
              final firstTx = platformTxs.first;
              final iconBytes = firstTx.iconimage != null ? Uint8List.fromList(firstTx.iconimage!.cast<int>()) : null;

              if (filtered.isEmpty) {
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

              return GestureDetector(
                onTap: () {
                  // TODO: Push to a FinancialPlatformDetailScreen if you have one
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => financialPlatformExpenseList(
                      userid: widget.userid, platformType: platformTxs, platformName: platformName,
                    ),
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.white,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        // backgroundColor: bgColor,
                        backgroundColor: Colors.grey.shade300,
                        // backgroundColor: bgColor,
                        child:  iconBytes != null
                            ? Image.memory(iconBytes, filterQuality: FilterQuality.high)
                            : const Icon(Icons.account_balance, size: 16, color: Colors.white), // fallback color
                      ),
                      title: Text(
                        platformName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${platformTxs.length} Transaction${platformTxs.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'RM ${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
