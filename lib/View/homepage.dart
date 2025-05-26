import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:fyp/View/comparepricepage.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/receiptParser/receiptParser_viewmodel.dart';
import 'expenseInput.dart';

class homepage extends StatefulWidget {
  // final UserInfoModule userInfo; // Accept UserModel as a parameter
  // const homepage({super.key,required this.userInfo});
  const homepage({super.key});
  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  int _selectedButtonIndex = 0;
  final List<String> imgList = ['hello', 'world'];
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      // Dashboard Padding
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              // Dashboard Container
              Container(
                height: 280,
                decoration: BoxDecoration(color: Colors.grey),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CarouselSlider(
                      items:
                          imgList
                              .map(
                                (e) => Center(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      options: CarouselOptions(
                        initialPage: 0,
                        onPageChanged: (value, _) {
                          setState(() {
                            _currentPage = value;
                          });
                        },
                      ),
                    ),
                    carouselindicator(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Spending Summary", style: TextStyle(fontSize: 18)),
                      SizedBox(width: 60),
                      Text("View All", style: TextStyle(fontSize: 18)),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Recent spending: RM',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            Divider(
                              height: 10, // Space above and below the divider
                              thickness: 3, // Thickness of the line
                              color: Colors.grey, // Optional: set color
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.white,
        onPressed: () async {
          final result = await FlutterDocScanner().getScannedDocumentAsPdf();

          print("Scanner result: $result");

          if (result != null && result is Map) {
            final uriString = result['pdfUri'] as String?;
            final pdfPath = uriString?.replaceFirst(
              'file://',
              '',
            ); // ✅ strip prefix

            if (pdfPath != null && pdfPath.isNotEmpty) {
              File pdfFile = File(pdfPath);

              final receiptParserVM = ReceiptParserViewModel();
              final success = await receiptParserVM.uploadPdf(pdfFile);
              if (success && receiptParserVM.parsedResult != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => expenseInput(
                          parsedData: receiptParserVM.parsedResult,
                        ),
                  ),
                );
              } else {
                print("Upload failed: ${receiptParserVM.errorMessage}");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      receiptParserVM.errorMessage ?? 'Upload failed.',
                    ),
                  ),
                );
              }
            } else {
              print("No valid PDF path found in pdfUri.");
            }
          } else {
            print("Document scan failed or returned unexpected format.");
          }
        },
        child: Icon(CupertinoIcons.qrcode_viewfinder, size: 40),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.home, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => comparepricepage()),
                );
              },
              icon: Icon(CupertinoIcons.search, size: 50, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.doc, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.profile_circled,
                size: 48,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row carouselindicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < imgList.length; i++)
          Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            height: i == _currentPage ? 7 : 5,
            width: i == _currentPage ? 7 : 5,
            decoration: BoxDecoration(
              color: i == _currentPage ? Colors.white : Colors.black,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
