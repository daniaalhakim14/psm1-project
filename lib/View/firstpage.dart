import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fyp/View/signUpPage.dart';

import 'loginpage.dart';

class firstpage extends StatefulWidget {
  const firstpage({super.key});

  @override
  State<firstpage> createState() => _firstpageState();
}

class _firstpageState extends State<firstpage> {
  final List<String> imgList = [
    'lib/Stickers/assetmanagement.png',
    'lib/Stickers/business.png',
    'lib/Stickers/dontletmoneyflyaway.png',
    'lib/Stickers/financialgoals.png',
  ];

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size; // Get screen size
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.25),
                child: Center(
                  child: CarouselSlider(
                    items:
                        imgList
                            .map(
                              (e) => Image.asset(
                                e,
                                fit: BoxFit.contain,
                                width: screenWidth * 0.8, // 80% of screen width
                                height:
                                    screenHeight * 0.4, // 40% of screen height
                              ),
                            )
                            .toList(),
                    options: CarouselOptions(
                      initialPage: 0,
                      enlargeCenterPage: true, // enlarges image, make it stand out visually
                      autoPlay: true, // automatic sliding of carousel image
                      reverse: false, // false, makes it move left to right
                      enableInfiniteScroll: true, // true, loop infinitely
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 1500),
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (value, _) {
                        setState(() {
                          _currentPage = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.20,
              bottom: screenHeight * 0.05,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: screenWidth * 0.6, // 60% of screen width
                  child: _ElevatedButton(
                    context,
                    text: 'Login',
                    destination: loginpage(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                SizedBox(
                  width: screenWidth * 0.6, // 60% of screen width
                  child: _ElevatedButton(
                    context,
                    text: 'Sign Up',
                    destination: signUpPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton _ElevatedButton(
    BuildContext context, {
    required String text,
    required Widget destination,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
