import 'package:flutter/material.dart';
import 'package:fyp/View/loginpage.dart';
import 'package:fyp/ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'package:provider/provider.dart';

class signUpPage extends StatefulWidget {
  const signUpPage({super.key});

  @override
  State<signUpPage> createState() => _signUpPageState();
}

class _signUpPageState extends State<signUpPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool isLoading = false;

  Future<void> _signUp() async {
    final viewModel = Provider.of<signUpnLogin_viewmodel>(
      context,
      listen: false,
    );
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String repeatPassword = _repeatPasswordController.text;
    final String phoneNumber = _phoneNumberController.text;

    final success = await viewModel.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      repeatPassword: repeatPassword,
      phoneNumber: phoneNumber,
    );

    if (success) {
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Sign-up Successful'),
              content: const Text(
                'Your account has been successfully created. Please log in to continue.',
              ),
              actions: [
                TextButton(
                  child: const Text("Login"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => loginpage()),
                    );
                  },
                ),
              ],
            ),
      );
    } else {
      // Display errors if validation fails
      setState(() {}); // Refresh UI to show validation errors
      AlertDialog(
        title: const Text('Sign-up failed'),
        content: const Text(
          'Sign-up failed. Please check the errors and try again.',
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

    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF5A7BE7),
        title: Text(
          'Sign Up',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.025,
                top: screenWidth * 0.05,
                right: screenWidth * 0.025,
              ),
              child: Column(
                children: [
                  _textLabel('First Name'),
                  _inputTextField(
                    'First Name',
                    'Enter your first name',
                    _firstNameController,
                    viewModel.firstNameError,
                  ),
                  _textLabel('Last Name'),
                  _inputTextField(
                    'Last Name',
                    'Enter your last name',
                    _lastNameController,
                    viewModel.lastNameError,
                  ),
                  _textLabel('Email'),
                  _inputTextField(
                    'Email',
                    'Enter your email',
                    _emailController,
                    viewModel.emailError,
                  ),
                  _textLabel('Password'),
                  _inputPasswordField(
                    'Password',
                    'Enter your password',
                    _passwordController,
                    viewModel.passwordError,
                  ),
                  _textLabel('Re-enter Password'),
                  _inputPasswordField(
                    'Re-enter Password',
                    'Re-enter Password',
                    _repeatPasswordController,
                    viewModel.repeatPasswordError,
                  ),
                  _textLabel('Phone Number'),
                  _inputTextField(
                    'Phone Number',
                    'Enter your phone number',
                    _phoneNumberController,
                    viewModel.phoneNumberError,
                  ),
                  /*
                  CSCPickerPlus(
                    layout: Layout.horizontal,
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey, width: 2.5),
                      color: Colors.white,
                    ),
                    selectedItemStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    onCountryChanged: (country) {
                      setState(() {
                        selectedCountry = country;
                        _countryController.text = country;
                      });
                    },
                    onStateChanged: (state) {
                      setState(() {
                        selectedState = state ?? '';
                        _stateController.text = state ?? '';
                      });
                    },
                    onCityChanged: (city) {
                      setState(() {
                        selectedCity = city ?? '';
                        _postcodeController.text = city ?? '';
                      });
                    },
                  ),

                   */

                  // floating button
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await _signUp(); // make sure _signUp is async
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.04,
                        bottom: screenHeight * 0.04,
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
                            'Sign up',
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
                ],
              ),
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
    final double screenWidth = screenSize.width;
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
        right: screenWidth * 0.05,
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
    final double screenWidth = screenSize.width;
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
        right: screenWidth * 0.05,
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

  Widget _textLabel(String text) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
        top: screenHeight * 0.007,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
