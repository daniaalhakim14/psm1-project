import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fyp/View/homepage.dart';
import 'package:provider/provider.dart';

import '../ViewModel/signUpnLogIn/signUpnLogin_viewmodel.dart';
class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  bool _isPasswordVisible = false; // Password visibility toggle
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorText = 'Wrong username or password';
  final List<String> imgList = [
    'lib/Stickers/assetmanagement.png',
    'lib/Stickers/business.png',
    'lib/Stickers/dontletmoneyflyaway.png',
    'lib/Stickers/financialgoals.png',
  ];


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size; // Get screen size
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    int _currentPage = 0;

    final viewModel = Provider.of<signUpnLogin_viewmodel>(context);
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF5A7BE7),
        title: Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body:    Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.10),
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.06),
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
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.12),
            child: Column(
              children: [
                _inputTextField('Email','Enter your email', _emailController, errorText),
                _inputPasswordField('Password', 'Enter your password', _passwordController, errorText)
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ElevatedButton(
            //onPressed: viewModel.isLoading ? null : _signUp,
            onPressed: viewModel.isLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => homepage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A7BE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Center(
              child: viewModel.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Login",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _inputTextField(String label, String hint,
      TextEditingController controller, String? errorText) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final double horizontalPadding = screenSize.width;
    final double verticalPadding = screenSize.height * 0.015;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.05,
          vertical: verticalPadding * 0.015),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          labelStyle: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5), // Thicker border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 2.5,
              color: Colors.grey,
            ), // Thicker border for enabled state
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 2.5,
              color: Colors.blue,
            ), // Thicker border for focused state
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 2.5,
              color: Colors.red,
            ), // Thicker border for error state
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 2.5,
              color: Colors.red,
            ), // Thicker border for focused error state
          ),
          filled: true,
          fillColor: Colors.white,
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold, // Make the error message bold
          ),
        ),
      ),
    );
  }

  Widget _inputPasswordField(String label, String hint,
      TextEditingController controller, String? errorText) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final double horizontalPadding = screenSize.width;
    final double verticalPadding = screenSize.height * 0.015;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.05,
          vertical: verticalPadding * 0.015),
      child: TextField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold),
          labelStyle: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5), // Thicker border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5,
                color: Colors.grey), // Thicker border for enabled state
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5,
                color: Colors.blue), // Thicker border for focused state
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5,
                color: Colors.red), // Thicker border for error state
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5,
                color: Colors.red), // Thicker border for focused error state
          ),
          filled: true,
          fillColor: Colors.white,
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold, // Make the error message bold
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}


