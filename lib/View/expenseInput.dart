import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class expenseInput extends StatefulWidget {
  const expenseInput({super.key});

  @override
  State<expenseInput> createState() => _expenseInputState();
}

DateTime selectedDate = DateTime.now().toUtc().add(Duration(hours: 8));
late String todayDate = 'Today';
late String yesterdayDate = 'Yesterday';
late String textdate = todayDate;

class _expenseInputState extends State<expenseInput> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: const Text(
            'Expense Input',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
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
                            textdate = DateFormat(
                              'dd-MM-yyyy',
                            ).format(dateTime.toLocal()); // Default date format
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
