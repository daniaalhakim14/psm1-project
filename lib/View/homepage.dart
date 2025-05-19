import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/View/camerascreen.dart';
import 'package:fyp/View/comparepricepage.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../Model/signupLoginpage.dart';
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
          DocumentScannerOptions
          documentScannerOptions = DocumentScannerOptions(
            documentFormat: DocumentFormat.pdf, // set output document format
            mode: ScannerMode.filter, // to control what features are enabled
            pageLimit: 10, // setting a limit to the number of pages scanned
            isGalleryImport: true, // importing from the photo gallery
          );
          final documentScanner = DocumentScanner(
            options: documentScannerOptions,
          );
          DocumentScanningResult result = await documentScanner.scanDocument();
          final pdf = result.pdf; // A PDF object.
          final images = result.images; // A list with the paths to the images.
          documentScanner.close();

          final textRecognizer = TextRecognizer(
            script: TextRecognitionScript.latin,
          );

          if (images.isNotEmpty) {
            final inputImage = InputImage.fromFilePath(images.first);
            final recognizedText = await textRecognizer.processImage(
              inputImage,
            );

            String rawText = recognizedText.text;

            // 🔍 You can now parse `rawText` to extract date, amount, items
          }

          if (result.pdf != null) {
            MaterialPageRoute(
              //builder: (context) => expenseInput(userid: widget.userInfo.id),
              builder: (context) => expenseInput(),
            );
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
