import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fyp/View/homepage.dart';
import 'package:fyp/View/signUpPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Password visibility toggle
  bool _stayLogin = false;
  bool showError = false;
  String errorText = 'Wrong username or password';
  bool isLoading = false;
  final List<String> imgList = [
    'lib/Stickers/assetmanagement.png',
    'lib/Stickers/business.png',
    'lib/Stickers/dontletmoneyflyaway.png',
    'lib/Stickers/financialgoals.png',
  ];

  Future<void> _login() async {
    final viewModel = Provider.of<signUpnLogin_viewmodel>(
      context,
      listen: false,
    );

    final String email = _emailController.text;
    final String password = _passwordController.text;

    final success = await viewModel.login(email, password, context);
    if (success) {
      if (_stayLogin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedin', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userPassword', password);
      }

      // Fecth user details
      if (viewModel.userInfo != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => homepage(userInfo: viewModel.userInfo!),
          ),
        );
      }
    } else {
      // Display errors if validation fails
      setState(() {}); // Refresh UI to show validation errors
      AlertDialog(
        title: const Text('Login failed'),
        content: const Text(
          'Login failed. Please check the errors and try again.',
        ),
        actions: [
          TextButton(
            child: const Text("Try Again"),
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<signUpnLogin_viewmodel>(context);
    final Size screenSize = MediaQuery.of(context).size; // Get screen size
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    int _currentPage = 0;

    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF5A7BE7),
        title: Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.10),
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.08),
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
            ),
            Column(
              children: [
                _inputTextField(
                  'Email',
                  'Enter your email',
                  _emailController,
                  viewModel.emailError,
                ),
                SizedBox(height: 10),
                _inputPasswordField(
                  'Password',
                  'Enter your password',
                  _passwordController,
                  viewModel.passwordError,
                ),
              ],
            ),
            // floating action button
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.035),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await _login();
                  setState(() {
                    isLoading = false;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.04,
                    bottom: screenHeight * 0.0,
                  ),
                  child: Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.055,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFF5A7BE7),
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Not a member?",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => signUpPage()),
                    );
                  },
                  child: const Text(
                    "Register now",
                    style: TextStyle(
                      color: Color(0xFF5A7BE7),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF5A7BE7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputTextField(
    String label,
    String hint,
    TextEditingController controller,
    String? errorText,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width;
    final double verticalPadding = screenSize.height * 0.015;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding * 0.05,
        vertical: verticalPadding * 0.015,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          labelStyle: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _inputPasswordField(
    String label,
    String hint,
    TextEditingController controller,
    String? errorText,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width;
    final double verticalPadding = screenSize.height * 0.015;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding * 0.05,
        vertical: verticalPadding * 0.015,
      ),
      child: TextField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
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
