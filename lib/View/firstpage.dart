import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fyp/View/loadingPage.dart';
import 'package:fyp/View/signUpPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'homepage.dart';
import 'loginpage.dart';

class firstpage extends StatefulWidget {
  const firstpage({super.key});

  @override
  State<firstpage> createState() => _firstpageState();
}

class _firstpageState extends State<firstpage> {
  final List<String> imgList = [
    'assets/Stickers/assetmanagement.png',
    'assets/Stickers/business.png',
    'assets/Stickers/dontletmoneyflyaway.png',
    'assets/Stickers/financialgoals.png',
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadingPage();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedin') ?? false;
    final email = prefs.getString('userEmail');
    final token = prefs.getString('authToken');

    if (isLoggedIn && email != null && token != null) {
      final viewModel = Provider.of<signUpnLogin_viewmodel>(
        context,
        listen: false,
      );
      final success = await viewModel.autoLoginWithPrefs(email, token);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => homepage(userInfo: viewModel.userInfo!),
          ),
        );
      } else {
        debugPrint("Stored credentials invalid or expired.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size; // Get screen size
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.225),
                  child: Center(
                    child: CarouselSlider(
                      items:
                          imgList
                              .map(
                                (e) => Image.asset(
                                  e,
                                  fit: BoxFit.contain,
                                  width:
                                      screenWidth * 0.8, // 80% of screen width
                                  height:
                                      screenHeight *
                                      0.4, // 40% of screen height
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
            SizedBox(height: screenHeight * 0.02),
            Text(
              'MyManageMate',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 80,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black26, width: 1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '💸 Take control of your spending, 🛍️ discover smart deals, and 🧾 simplify your tax relief tracking. All in one place!',
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.10),
            Column(
              children: [
                _navigationButton('Login', screenWidth, screenHeight, () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(
                        milliseconds: 800,
                      ), // 🔧 Adjust timer here
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              loginpage(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(
                          1.0,
                          0.0,
                        ); // Start off-screen to the right
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                }),
                SizedBox(height: screenHeight * 0.025),
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
