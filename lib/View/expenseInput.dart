import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'categorypage.dart';

// Global Variable
const List<String> paymentType = <String>[
  'Cash',
  'Debit Card',
  'Credit Card',
  'Online Transfer',
  'E-Wallet'
];
// store the selected payment type
String dropdownValue = paymentType.first;

class expenseInput extends StatefulWidget {
  //const expenseInput({super.key, required this.userid});
  const expenseInput({super.key});
  // final int userid; // Accept UserModel as a parameter

  @override
  State<expenseInput> createState() => _expenseInputState();
}

DateTime selectedDate = DateTime.now().toUtc().add(Duration(hours: 8));
late String todayDate = 'Today';
late String yesterdayDate = 'Yesterday';
late String textdate = todayDate;
final _textControllerAmount = TextEditingController();
final _textControllerDescription = TextEditingController(); // to store user input
Map<String, dynamic>? _selectedCategory;

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
                  SizedBox(width: 10,),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller:
                        _textControllerAmount, // Ensure this is initialized
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                                r'^\d*\.?\d{0,2}'), // Restrict to two decimal places
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
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '-RM ',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
                child: Divider(
                  thickness: 2,
                  color: Colors.black,
                ),
              ),
              // select category
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // This will space the elements apart
                children: [
                  GestureDetector(
                    onTap: () async {

                        final selectedcategory = await Navigator.push(
                          context,
                          MaterialPageRoute(
                           /*
                            builder: (context) => CategoryPage(
                              userid: widget.userid,
                            ),
                            */
                            builder: (context) => CategoryPage(),
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
                              top: 5.0, bottom: 0.0, left: 6, right: 10),
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
                                  _selectedCategory?[
                                  'icon'],
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
                              top: 5.0, bottom: 0.0, left: 10, right: 10),
                          child: Row(
                            children: [
                              Text(
                                _selectedCategory != null
                                    ? _selectedCategory!['name']
                                    : 'Set Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 22.0,
                                  color: Colors
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
              // add description
              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 8.0, left: 4, right: 0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.note_add_outlined,
                            size: 60, color: Colors.black87),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, bottom: 0.0, left: 16, right: 0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 306,
                                height: 48,
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
                  ],
                ),
              ),
              // border
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
                child: Divider(
                  thickness: 2,
                  color: Colors.black,
                ),
              ),
              // Payment type
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 0.0, bottom: 0.0, left: 10.5, right: 0),
                    child: Row(
                      children: [
                        const Icon(Icons.payment,
                            size: 48, color: Colors.black87),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 17.5, right: 0),
                          child: Row(
                            children: [
                              Text('Payment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 22.0,
                                    color: Colors.black, // Adjust color dynamically
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(left: 114),
                                child: Row(children: [
                                  DropdownButton<String>(
                                    value: dropdownValue,
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down_outlined),
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
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
                                    items: paymentType
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Container(
                                              width: 80, // Customize the width
                                              height: 40, // Customize the height
                                              alignment: Alignment
                                                  .centerLeft, // Align text if needed
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8), // Add padding
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                    fontSize:
                                                    11), // Customize text style
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Column(
          children: [
            GestureDetector(
              onTap: (){

              },
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.deepPurpleAccent.shade100,
                  ),
                  width: 220.0,
                  height: 50.0,
                  child: const Text('Add Expense',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
