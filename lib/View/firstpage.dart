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
                padding: EdgeInsets.only(top: screenHeight * 0.125),
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
                      enlargeCenterPage:
                          true, // enlarges image, make it stand out visually
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
          SizedBox(height: screenHeight * 0.22),
          Column(
            children: [
              _navigationButton('Login', screenWidth, screenHeight, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => loginpage()),
                );

              }),
              SizedBox(height: screenHeight * 0.025,),
              _navigationButton('Sign Up', screenWidth, screenHeight, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => signUpPage()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navigationButton(
    String text,
    double screenWidth,
    double screenHeight,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.85,
        height: screenHeight * 0.055,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF5A7BE7),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
