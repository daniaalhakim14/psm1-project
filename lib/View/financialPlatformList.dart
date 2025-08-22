import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/expense.dart';
import 'expenseDetails.dart';
class financialPlatformList extends StatefulWidget {
  final userid;
  final String platformName;
  final List<ListExpense> platformType;
  const financialPlatformList({
    super.key,
    required this.userid,
    required this.platformName,
    required this.platformType,

  });

  @override
  State<financialPlatformList> createState() => _financialPlatformListState();
}

class _financialPlatformListState extends State<financialPlatformList> {
  late Map<String, List<ListExpense>> groupedByDate;


  @override
  void initState() {
    super.initState();
    groupedByDate = _groupExpenseByDate(widget.platformType);
  }

  Map<String, List<ListExpense>> _groupExpenseByDate(List<ListExpense> expenses) {
    final Map<String, List<ListExpense>> grouped = {};
    for (var expense in expenses) {
      final formattedDate = _formatDate(expense.expenseDate);
      grouped.putIfAbsent(formattedDate, () => []);
      grouped[formattedDate]!.add(expense);
    }
    return grouped;
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'No date';
    return DateFormat('d MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Text(widget.platformName,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF5A7BE7),
      ),
      body: ListView.builder(
          itemCount: groupedByDate.keys.length,
          itemBuilder: (context,index){
            final date = groupedByDate.keys.toList()[index];
            final dateExpenses = groupedByDate[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  height: 30.0,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      date,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                ...dateExpenses.map((expense){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // 👈 background color
                        border: Border.all(
                          color: Colors.grey, // Border color
                          width: 1.0, // Border width
                        ), borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: expense.iconColor,
                          child: Icon(
                            expense.iconData,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          expense.expenseName ?? 'No name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1, // 👈 only show first line
                          overflow: TextOverflow.ellipsis, // 👈 add "..." if text is too long
                        ),
                        subtitle: Text(
                          expense.expenseDescription ?? 'No Description',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1, // 👈 only show first line
                          overflow: TextOverflow.ellipsis, // 👈 add "..." if text is too long
                        ),
                        trailing: Text(
                          '-RM ${expense.expenseAmount?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
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
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }),
    );
  }
}
