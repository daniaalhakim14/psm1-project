import 'package:flutter/material.dart';
import 'package:fyp/View/loginpage.dart';
import 'package:fyp/ViewModel/signUpnLogIn/signUpnLogin_viewmodel.dart';
import 'package:provider/provider.dart';

class signUpPage extends StatefulWidget {
  const signUpPage({super.key});

  @override
  State<signUpPage> createState() => _signUpPageState();
}

final TextEditingController _firstname = TextEditingController();

class _signUpPageState extends State<signUpPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController  _postcodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();


  Future<void> _signUp() async{
    final viewModel = Provider.of<signUpnLogin_viewmodel>(context, listen: false);
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String repeatPassword = _repeatPasswordController.text;
    final String dob = _dobController.text;
    final String gender = _genderController.text;
    final String address = _addressController.text;
    final String city = _cityController.text;
    final String postcode = _postcodeController.text;
    final String state = _stateController.text;
    final String country = _countryController.text;
    final String phoneNumber = _phoneNumberController.text;

    final success = await viewModel.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        repeatPassword: repeatPassword,
        dob: dob,
        gender: gender,
        address: address,
        city: city,
        postcode: postcode,
        state: state,
        country: country,
        phoneNumber: phoneNumber,
    );

    if (success) {
      // Navigate to login page on successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginpage()),
      );
    } else {
      // Display errors if validation fails
      setState(() {}); // Refresh UI to show validation errors
      AlertDialog(
        title: const Text('Sign-up failed'),
        content: const Text('Sign-up failed. Please check the errors and try again.'),
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
        title: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
        //automaticallyImplyLeading: true,
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
                  _inputTextField('First Name','Enter your first name', _firstNameController, viewModel.firstNameError),
                  _textLabel('Last Name'),
                  _inputTextField('Last Name','Enter your last name', _lastNameController, viewModel.lastNameError),
                  _textLabel('Email'),
                  _inputTextField('Email', 'Enter your email', _emailController, viewModel.emailError),
                  _textLabel('Password'),
                  _inputPasswordField('Password','Enter your password', _passwordController, viewModel.passwordError),
                  _textLabel('Re-enter Password'),
                  _inputPasswordField('Re-enter Password','Re-enter Password', _repeatPasswordController, viewModel.repeatPasswordError),
                  _textLabel('Phone Number'),
                  _inputTextField('Phone Number','Enter your phone number', _phoneNumberController, viewModel.phoneNumberError),
                  /*
                  Row(
                    children: [
                      Column(
                        children: [
                          _textLabel('Nationality'),
                          _inputTextField('Nationality','Enter your Nationality', _countryController, viewModel.countryError),
                        ],
                      ),
                      Column(
                        children: [
                          _textLabel('Date of Birth'),
                          _inputTextField('Date of Birth','Enter your date birth', _dobController, viewModel.dobError),
                        ],
                      ),
                      Column(
                        children: [
                          _textLabel('Gender'),
                          _inputTextField('Gender','Enter your gender', _genderController, viewModel.genderError),
                        ],
                      ),

                    ],
                  ),
                  _textLabel('Address'),
                  _inputTextField('Address','Enter your Address', _addressController, viewModel.addressError),
                  Row(
                    children: [
                      Column(
                        children: [
                          _textLabel('Postcode'),
                          _inputTextField('Postcode','Enter your postcode', _postcodeController, viewModel.postcodeError),
                        ],
                      ),
                      Column(
                        children: [
                          _textLabel('City'),
                          _inputTextField('City','Enter your city', _cityController, viewModel.cityError),
                        ],
                      ),
                      Column(
                        children: [
                          _textLabel('State'),
                          _inputTextField('State','Enter your State', _stateController, viewModel.stateError),
                        ],
                      ),
                    ],
                  ),
                  */

                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ElevatedButton(
            //onPressed: viewModel.isLoading ? null : _signUp,
            onPressed: viewModel.isLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => loginpage()),
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
                "Sign Up",
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

  Widget _inputTextField(String label, String hint, TextEditingController controller,String? errorText) {
    final screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width;
    final double verticalPadding = screenSize.height * 0.015;
    return Padding(
      padding:EdgeInsets.symmetric(horizontal: horizontalPadding  * 0.05, vertical: verticalPadding * 0.015),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          labelStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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

  Widget _inputPasswordField(String label, String hint, TextEditingController controller, String? errorText) {
    final screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width;
    final double verticalPadding = screenSize.height * 0.015;
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: horizontalPadding  * 0.05, vertical: verticalPadding * 0.015),
      child: TextField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5), // Thicker border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5, color: Colors.grey), // Thicker border for enabled state
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5, color: Colors.blue), // Thicker border for focused state
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5, color: Colors.red), // Thicker border for error state
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.5, color: Colors.red), // Thicker border for focused error state
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

  Widget _textLabel(String text){
    final screenSize = MediaQuery.of(context).size;
    final double leftPadding = screenSize.width;   //
    final double verticalPadding = screenSize.height; //
    return Padding(
      padding:  EdgeInsets.only(left: leftPadding * 0.05, top: verticalPadding * 0.004),
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
