
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
  DateTime? selectedDate;
  bool _isPasswordVisible = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? selectedGender,selectedCountry,selectedState,selectedCity;
  final genderOptions = ['Male', 'Female'];


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
                  _inputTextField('First Name', 'Enter your first name', _firstNameController, viewModel.firstNameError,),
                  _textLabel('Last Name'),
                  _inputTextField('Last Name', 'Enter your last name', _lastNameController, viewModel.lastNameError,),
                  _textLabel('Email'),
                  _inputTextField('Email', 'Enter your email', _emailController, viewModel.emailError,),
                  _textLabel('Password'),
                  _inputPasswordField('Password', 'Enter your password', _passwordController, viewModel.passwordError,),
                  _textLabel('Re-enter Password'),
                  _inputPasswordField('Re-enter Password', 'Re-enter Password', _repeatPasswordController, viewModel.repeatPasswordError,),
                  _textLabel('Phone Number'),
                  _inputTextField('Phone Number', 'Enter your phone number', _phoneNumberController, viewModel.phoneNumberError,),
                  Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min, // ⬅️ prevents it from taking full height
                        crossAxisAlignment: CrossAxisAlignment.start, // aligns to the left
                        children: [
                          _textLabel('Date of Birth'),
                          _dobPickerTextField(controller: _dobController, context: context, width: screenWidth * 0.34, height: screenHeight * 0.06,
                            errorText: viewModel.dobError,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min, // ⬅️ prevents it from taking full height
                        crossAxisAlignment: CrossAxisAlignment.start, // aligns to the left
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.02),
                            child: _textLabel('Gender'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.04),
                            child: _customDropdown(
                              label: 'Gender',
                              items: genderOptions,
                              selectedValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                });
                              },
                              errorText: viewModel.genderError,
                              width: screenWidth * 0.29,
                              height: screenHeight * 0.06,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  _textLabel('Address'),
                  _inputTextField('Address', 'Enter your Address', _phoneNumberController, viewModel.phoneNumberError,),
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
                    onTap: () {
                      viewModel.isLoading
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => loginpage(),
                              ),
                            );
                          };
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.04,bottom: screenHeight * 0.04),
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

  Widget _inputTextField(String label, String hint, TextEditingController controller, String? errorText,) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
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

  Widget _inputPasswordField(String label, String hint, TextEditingController controller, String? errorText,) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
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

  Widget _dobPickerTextField({required TextEditingController controller, required BuildContext context,
    double width = double.infinity,
    double height = 55,
    String label = 'dd/mm/yyyy',
    String hint = 'Select your date of birth',
    String? errorText,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
      ),
      child: GestureDetector(
        onTap: () async {
          final DateTime now = DateTime.now();
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(1900, 1, 1),
            firstDate: DateTime(1900),
            lastDate: DateTime(now.year, now.month, now.day),
            helpText: 'Date of Birth',
          );
          if (picked != null) {
            controller.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
          }
        },
        child: AbsorbPointer(
          child: SizedBox(
            width: width,
            height: height,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                hintStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold),
                labelStyle: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 2.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 2.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2.5),
                ),
                filled: true,
                fillColor: Colors.white,
                errorText: errorText,
                errorStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customDropdown({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
    String? errorText,
    double? width,
    double height = 55,

  }) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.03,
      ),
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 2.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 2.5, color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 2.5, color: Colors.blue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 2.5, color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 2.5, color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            errorStyle: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }


  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2002, 11, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Select Date of Birth',
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String get formattedDate {
    if (selectedDate == null) return 'Select your date of birth';
    return '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
  }
}
